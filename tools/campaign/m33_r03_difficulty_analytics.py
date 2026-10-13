#!/usr/bin/env python3
"""Deterministic, read-only BCM-M33 all-island difficulty diagnostics.

The report certifies only structural campaign-data conditions. It never claims
that a recipe is physically solvable or fair for a human player.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import time
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

ISLAND_LEVEL_FILES = {
    "sunny_cove": "sunny_cove.json",
    "tiki_island": "tiki_island_full.json",
    "azure_bay": "azure_bay.json",
    "coconut_beach": "coconut_beach.json",
    "sunset_island": "sunset_island.json",
    "party_beach": "party_beach.json",
    "frozen_paradise": "frozen_paradise.json",
    "volcano_bay": "volcano_bay.json",
    "billionaire_island": "billionaire_island.json",
    "final_island": "final_island.json",
}
MAX_COCKTAIL_LEVEL = 12
FIRST_CANDIDATE_GLOBAL_ID = 102  # R02/R03 slice; includes frozen M32 Tiki L2-L12.
LAST_GLOBAL_ID = 1000
SPAWN_L1_EQUIVALENT_VALUES = (1, 2, 4)
EXPECTED_SPAWN_VALUE = sum(SPAWN_L1_EQUIVALENT_VALUES) / len(SPAWN_L1_EQUIVALENT_VALUES)
PLANNING_SECONDS_PER_EXPECTED_LAUNCH = (1.5, 3.0)  # M17DifficultyModel: 1.5s raw x 1..2.
SUSPICIOUS_EXPECTED_LAUNCH_THRESHOLD = 100
SUSPICIOUS_T_THRESHOLD = 64
SUSPICIOUS_STEP_RELATIVE_THRESHOLD = 0.50


def cocktail_cost(level: int) -> int:
    return 1 << (level - 1) if level >= 1 else 0


def integer_field(value: Any) -> int | None:
    if isinstance(value, bool) or not isinstance(value, int):
        return None
    return value


def order_cost(orders: Any) -> int:
    if not isinstance(orders, list):
        return 0
    return sum(
        cocktail_cost(int(order.get("cocktail_level", 0))) * int(order.get("quantity", 0))
        for order in orders
        if isinstance(order, dict)
    )


def vip_cost(vip: Any) -> int:
    if not isinstance(vip, dict) or not bool(vip.get("enabled", True)):
        return 0
    level = integer_field(vip.get("cocktail_level"))
    quantity = integer_field(vip.get("quantity"))
    if level is None or quantity is None or quantity <= 0:
        return 0
    return cocktail_cost(level) * quantity


def l3_equivalent(cost: int) -> int:
    return cost // 4 if cost > 0 and cost % 4 == 0 else 0


def expected_launches(cost: int) -> float:
    return cost / EXPECTED_SPAWN_VALUE if cost > 0 else 0.0


def enabled_vip(vip: Any) -> bool:
    return isinstance(vip, dict) and bool(vip.get("enabled", True))


def vip_intermediate_pieces(level: dict[str, Any]) -> int:
    vip = level.get("vip")
    if not enabled_vip(vip):
        return 0
    vip_level_value = integer_field(vip.get("cocktail_level"))
    vip_level = vip_level_value if vip_level_value is not None else 0
    if not 3 <= vip_level <= MAX_COCKTAIL_LEVEL:
        return 0
    return sum(
        int(integer_field(order.get("quantity")) or 0) * (1 << (int(integer_field(order.get("cocktail_level")) or 0) - vip_level))
        for order in level.get("orders", [])
        if isinstance(order, dict)
        and integer_field(order.get("cocktail_level")) is not None
        and int(integer_field(order.get("cocktail_level")) or 0) > vip_level
        and integer_field(order.get("quantity")) is not None
        and int(integer_field(order.get("quantity")) or 0) > 0
    )


def recipe_signature(level: dict[str, Any], include_vip: bool) -> str:
    orders = [
        {
            "cocktail_level": integer_field(item.get("cocktail_level")) if integer_field(item.get("cocktail_level")) is not None else f"invalid:{item.get('cocktail_level')!r}",
            "quantity": integer_field(item.get("quantity")) if integer_field(item.get("quantity")) is not None else f"invalid:{item.get('quantity')!r}",
        }
        for item in level.get("orders", [])
        if isinstance(item, dict)
    ]
    result: dict[str, Any] = {"orders": orders}
    vip = level.get("vip")
    if include_vip:
        result["time_limit_sec"] = float(level.get("time_limit_sec", 0.0))
        normalized_vip = {"enabled": False, "cocktail_level": 0, "quantity": 0}
        if enabled_vip(vip):
            normalized_vip = {
                "enabled": True,
                "cocktail_level": integer_field(vip.get("cocktail_level")) if integer_field(vip.get("cocktail_level")) is not None else f"invalid:{vip.get('cocktail_level')!r}",
                "quantity": integer_field(vip.get("quantity")) if integer_field(vip.get("quantity")) is not None else f"invalid:{vip.get('quantity')!r}",
            }
        result["vip"] = normalized_vip
    return json.dumps(result, sort_keys=True, separators=(",", ":"))


def nearest_rank(values: list[float], p: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    return ordered[max(0, min(len(ordered) - 1, math.ceil(p * len(ordered)) - 1))]


def data_diagnostics(
    level: dict[str, Any], island: dict[str, Any], expected_global_id: int
) -> tuple[list[str], list[str], dict[str, int]]:
    errors: list[str] = []
    warnings: list[str] = []
    orders = level.get("orders")
    if not isinstance(orders, list) or not orders:
        errors.append("NORMAL_OBJECTIVES_MISSING")
        orders = []
    policy = island.get("target_policy", {})
    policy_min = int(policy.get("min_level", 3))
    policy_max = int(policy.get("max_level", MAX_COCKTAIL_LEVEL))
    normal_t = 0
    normal_cost = 0
    targets: list[int] = []
    for index, order in enumerate(orders):
        if not isinstance(order, dict):
            errors.append(f"ORDER_{index}_NOT_OBJECT")
            continue
        raw_target, raw_quantity = order.get("cocktail_level"), order.get("quantity")
        if isinstance(raw_target, bool) or not isinstance(raw_target, int):
            errors.append(f"ORDER_{index}_TARGET_NOT_INTEGER")
            continue
        if isinstance(raw_quantity, bool) or not isinstance(raw_quantity, int) or raw_quantity <= 0:
            errors.append(f"ORDER_{index}_QUANTITY_NOT_POSITIVE_INTEGER")
            continue
        target, quantity = raw_target, raw_quantity
        targets.append(target)
        if targets.count(target) > 1:
            warnings.append("DUPLICATE_NORMAL_TARGETS_REVIEW_AS_COMBINED_QUANTITY")
        if quantity > 2:
            warnings.append(f"ORDER_{index}_QUANTITY_ABOVE_GENERATOR_MAX_2")
        if target < 3 or target > MAX_COCKTAIL_LEVEL or not policy_min <= target <= policy_max:
            errors.append(f"ORDER_{index}_TARGET_OUTSIDE_PRODUCTION_OR_ISLAND_POLICY")
            continue
        cost = cocktail_cost(target) * quantity
        normal_cost += cost
        normal_t += l3_equivalent(cost)
    vip = level.get("vip")
    vip_t = 0
    vip_level = 0
    vip_quantity = 0
    if vip is not None:
        if not isinstance(vip, dict):
            errors.append("VIP_NOT_NULL_OR_OBJECT")
        elif enabled_vip(vip):
            target, quantity = vip.get("cocktail_level"), vip.get("quantity")
            if (
                isinstance(target, bool)
                or not isinstance(target, int)
                or isinstance(quantity, bool)
                or not isinstance(quantity, int)
                or quantity <= 0
            ):
                errors.append("VIP_TARGET_OR_QUANTITY_INVALID")
            else:
                vip_level, vip_quantity = target, quantity
                if target < 3 or target > MAX_COCKTAIL_LEVEL or not policy_min <= target <= policy_max:
                    errors.append("VIP_TARGET_OUTSIDE_PRODUCTION_OR_ISLAND_POLICY")
                else:
                    vip_t = l3_equivalent(cocktail_cost(target) * quantity)

    normal_t_from_cost = l3_equivalent(normal_cost)
    if normal_cost <= 0 or normal_t != normal_t_from_cost:
        errors.append("NORMAL_MERGE_ALGEBRA_COST_INVALID")
    total_t = normal_t_from_cost + vip_t
    expected_moves = 4 * total_t
    if "theoretical_shots_total" in level:
        stored_total = level["theoretical_shots_total"]
        if isinstance(stored_total, bool) or not isinstance(stored_total, int):
            errors.append("STORED_THEORETICAL_T_NOT_INTEGER")
        elif stored_total != total_t:
            errors.append("STORED_THEORETICAL_T_MISMATCH")
    if "move_limit" in level:
        stored_moves = level["move_limit"]
        if isinstance(stored_moves, bool) or not isinstance(stored_moves, int):
            errors.append("STORED_MOVE_LIMIT_NOT_INTEGER")
        elif stored_moves != expected_moves:
            errors.append("MOVE_LIMIT_NOT_4T_TOTAL")
    try:
        time_limit = float(level.get("time_limit_sec", -1))
    except (TypeError, ValueError):
        time_limit = -1.0
    if time_limit != 0.0:
        errors.append("UNEXPECTED_TIMER")
    feature_flags = level.get("feature_flags", {})
    if not isinstance(feature_flags, dict):
        errors.append("FEATURE_FLAGS_NOT_OBJECT")
    elif bool(feature_flags.get("timed", False)):
        errors.append("TIMED_FEATURE_FLAG_ENABLED")
    if isinstance(level.get("global_level_id", expected_global_id), bool) or not isinstance(level.get("global_level_id", expected_global_id), int) or int(level.get("global_level_id", expected_global_id)) != expected_global_id:
        errors.append("GLOBAL_LEVEL_ID_MISMATCH")
    if str(level.get("island_id", island.get("id", ""))) != str(island.get("id", "")):
        errors.append("ISLAND_ID_MISMATCH")
    if isinstance(level.get("level_id", 0), bool) or not isinstance(level.get("level_id", 0), int) or int(level.get("level_id", 0)) != ((expected_global_id - 1) % 100) + 1:
        errors.append("LOCAL_LEVEL_ID_MISMATCH")

    if enabled_vip(vip):
        if any(target == vip_level for target in targets):
            warnings.append("VIP_NORMAL_TARGET_COLLISION_REVIEW")
        if vip_quantity > 2:
            warnings.append("VIP_QUANTITY_ABOVE_GENERATOR_MAX_2")
        if vip_intermediate_pieces(level) > 0:
            warnings.append("VIP_INTERMEDIATE_RESERVE_REQUIRED")
    tier = str(level.get("difficulty_tier", level.get("difficulty_band", "")))
    if expected_global_id >= FIRST_CANDIDATE_GLOBAL_ID and tier != "PRESERVED_M32_SEED" and len(orders) < 2:
        warnings.append("GENERATED_RECIPE_BELOW_TWO_NORMAL_OBJECTIVES")
    return errors, warnings, {
        "normal_T": normal_t_from_cost,
        "vip_T": vip_t,
        "total_T": total_t,
        "move_limit_4T": expected_moves,
        "normal_cost_L1": normal_cost,
        "vip_cost_L1": vip_cost(vip),
        "normal_expected_launches": normal_cost / EXPECTED_SPAWN_VALUE if normal_cost > 0 else 0,
        "vip_expected_launches": vip_cost(vip) / EXPECTED_SPAWN_VALUE if vip_cost(vip) > 0 else 0,
        "vip_level": vip_level,
        "vip_quantity": vip_quantity,
    }


def analyze_level(
    level: dict[str, Any], island: dict[str, Any], expected_global_id: int
) -> dict[str, Any]:
    errors, warnings, metrics = data_diagnostics(level, island, expected_global_id)
    t = metrics["total_T"]
    normal_cost = metrics["normal_cost_L1"]
    vip_cost_value = metrics["vip_cost_L1"]
    normal_launches = metrics["normal_expected_launches"]
    vip_launches = metrics["vip_expected_launches"]
    full_recipe = recipe_signature(level, True)
    normal_recipe = recipe_signature(level, False)
    suspicious: list[str] = list(warnings)
    if normal_launches >= SUSPICIOUS_EXPECTED_LAUNCH_THRESHOLD:
        suspicious.append("NORMAL_EXPECTED_LAUNCHES_GE_100")
    if metrics["normal_T"] >= SUSPICIOUS_T_THRESHOLD:
        suspicious.append("NORMAL_T_GE_64")
    labels = ["PHYSICS_UNVERIFIED", "HUMAN_FAIRNESS_UNVERIFIED"]
    if errors:
        labels.insert(0, "ANALYTICALLY_SUSPICIOUS")
    else:
        labels.insert(0, "CERTIFIED_DATA_LEGAL")
    if suspicious and "ANALYTICALLY_SUSPICIOUS" not in labels:
        labels.insert(1, "ANALYTICALLY_SUSPICIOUS")
    time_low = normal_launches * PLANNING_SECONDS_PER_EXPECTED_LAUNCH[0]
    time_high = normal_launches * PLANNING_SECONDS_PER_EXPECTED_LAUNCH[1]
    vip_time_low = vip_launches * PLANNING_SECONDS_PER_EXPECTED_LAUNCH[0]
    vip_time_high = vip_launches * PLANNING_SECONDS_PER_EXPECTED_LAUNCH[1]
    vip_piece_demand = vip_intermediate_pieces(level)
    vip_reserve_status = (
        "NOT_APPLICABLE_NO_ENABLED_VIP"
        if not enabled_vip(level.get("vip"))
        else "RESERVE_SENSITIVE_RUNTIME_CHECK_REQUIRED"
        if vip_piece_demand > 0
        else "NO_HIGHER_NORMAL_ORDER_INTERMEDIATE_FLAG"
    )
    orders = level.get("orders", [])
    return {
        "global_level_id": expected_global_id,
        "island_id": str(level.get("island_id", island.get("id", ""))),
        "local_level_id": integer_field(level.get("level_id")) if integer_field(level.get("level_id")) is not None else -1,
        "tier": str(level.get("difficulty_tier", level.get("difficulty_band", "UNSPECIFIED"))),
        "normal_orders": ";".join(
            f"L{int(o.get('cocktail_level', 0))}x{int(o.get('quantity', 0))}"
            for o in orders if isinstance(o, dict)
        ),
        "vip": (
            f"L{metrics['vip_level']}x{metrics['vip_quantity']}"
            if enabled_vip(level.get("vip")) else "NONE"
        ),
        "normal_T": metrics["normal_T"],
        "vip_T": metrics["vip_T"],
        "total_T": t,
        "normal_expected_launches": round(normal_launches, 3),
        "normal_expected_launch_budget_ceil": math.ceil(normal_launches),
        "vip_expected_launches_optional": round(vip_launches, 3),
        "vip_expected_launch_budget_ceil_optional": math.ceil(vip_launches),
        "move_limit_4T": metrics["move_limit_4T"],
        "one_star_max_launches_if_complete": 4 * t,
        "two_star_max_launches_if_complete": max(0, 3 * t - 1),
        "three_star_max_launches_if_complete": max(0, 2 * t - 1),
        "human_duration_planning_sec_low_normal_only": round(time_low, 3),
        "human_duration_planning_sec_high_normal_only": round(time_high, 3),
        "vip_duration_increment_sec_low_optional": round(vip_time_low, 3),
        "vip_duration_increment_sec_high_optional": round(vip_time_high, 3),
        "normal_recipe_signature": normal_recipe,
        "full_recipe_signature": full_recipe,
        "vip_intermediate_piece_demand_heuristic": vip_piece_demand,
        "vip_reserve_status": vip_reserve_status,
        "data_errors": errors,
        "suspicion_flags": suspicious,
        "status_labels": labels,
        "difficulty_tier": str(level.get("difficulty_tier", "UNSPECIFIED")),
    }


def progression_steps(rows: list[dict[str, Any]]) -> dict[str, Any]:
    by_island: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        by_island[row["island_id"]].append(row)
    all_steps: list[dict[str, Any]] = []
    island_metrics: dict[str, Any] = {}
    ordered_ids = list(ISLAND_LEVEL_FILES)
    for island_id in ordered_ids:
        levels = sorted(by_island[island_id], key=lambda x: x["local_level_id"])
        transitions = []
        for before, after in zip(levels, levels[1:]):
            delta = after["normal_T"] - before["normal_T"]
            rel = delta / max(1, before["normal_T"])
            item = {
                "from_global": before["global_level_id"],
                "to_global": after["global_level_id"],
                "from_T": before["normal_T"],
                "to_T": after["normal_T"],
                "delta_T": delta,
                "relative_delta": round(rel, 4),
                "expected_launch_delta": round(after["normal_expected_launches"] - before["normal_expected_launches"], 3),
                "tier_changed": before["tier"] != after["tier"],
            }
            transitions.append(item)
            if abs(rel) >= SUSPICIOUS_STEP_RELATIVE_THRESHOLD:
                all_steps.append({"island_id": island_id, **item})
        island_metrics[island_id] = {
            "within_island_transition_count": len(transitions),
            "nonzero_T_transition_count": sum(x["delta_T"] != 0 for x in transitions),
            "relative_change_ge_50_percent_count": sum(abs(x["relative_delta"]) >= SUSPICIOUS_STEP_RELATIVE_THRESHOLD for x in transitions),
            "maximum_absolute_T_step": max((abs(x["delta_T"]) for x in transitions), default=0),
            "tier_boundary_changes": [x for x in transitions if x["tier_changed"]],
            "largest_steps": sorted(transitions, key=lambda x: abs(x["delta_T"]), reverse=True)[:8],
        }
    island_boundaries = []
    for prev_id, next_id in zip(ordered_ids, ordered_ids[1:]):
        before = max(by_island[prev_id], key=lambda x: x["local_level_id"])
        after = min(by_island[next_id], key=lambda x: x["local_level_id"])
        island_boundaries.append({
            "from_island": prev_id,
            "from_global": before["global_level_id"],
            "from_T": before["normal_T"],
            "to_island": next_id,
            "to_global": after["global_level_id"],
            "to_T": after["normal_T"],
            "delta_T": after["normal_T"] - before["normal_T"],
            "relative_delta": round((after["normal_T"] - before["normal_T"]) / max(1, before["normal_T"]), 4),
        })
    return {
        "within_island_threshold_relative_delta": SUSPICIOUS_STEP_RELATIVE_THRESHOLD,
        "by_island": island_metrics,
        "island_boundaries": island_boundaries,
        "largest_relative_steps": sorted(all_steps, key=lambda x: abs(x["relative_delta"]), reverse=True)[:40],
    }


def load_campaign(root: Path) -> tuple[list[dict[str, Any]], list[dict[str, Any]], dict[str, Any]]:
    island_doc = json.loads((root / "data/campaign/islands.json").read_text(encoding="utf-8"))
    islands = island_doc["islands"]
    island_by_id = {item["id"]: item for item in islands}
    rows: list[dict[str, Any]] = []
    raw_levels_by_island: list[dict[str, Any]] = []
    for index, (island_id, filename) in enumerate(ISLAND_LEVEL_FILES.items()):
        source = json.loads((root / "data/campaign/levels" / filename).read_text(encoding="utf-8"))
        levels = source["levels"]
        raw_levels_by_island.append({"island_id": island_id, "levels": levels, "source": source})
        for local_index, level in enumerate(levels, 1):
            global_id = index * 100 + local_index
            rows.append(analyze_level(level, island_by_id[island_id], global_id))
    return rows, raw_levels_by_island, island_doc


def build_report(rows: list[dict[str, Any]], raw_islands: list[dict[str, Any]], island_doc: dict[str, Any]) -> dict[str, Any]:
    candidate_rows = [x for x in rows if FIRST_CANDIDATE_GLOBAL_ID <= x["global_level_id"] <= LAST_GLOBAL_ID]
    generated_candidate_rows = [
        x for x in candidate_rows if x["difficulty_tier"] != "PRESERVED_M32_SEED"
    ]
    preserved_tiki = [x for x in rows if x["island_id"] == "tiki_island" and x["local_level_id"] <= 12]
    all_t = [x["normal_T"] for x in rows]
    candidate_t = [x["normal_T"] for x in candidate_rows]
    per_island: dict[str, Any] = {}
    for island_id in ISLAND_LEVEL_FILES:
        subset = [x for x in rows if x["island_id"] == island_id]
        normal_counts = Counter(x["normal_recipe_signature"] for x in subset)
        full_counts = Counter(x["full_recipe_signature"] for x in subset)
        normal_launches = [x["normal_expected_launches"] for x in subset]
        expected_launch_ceil = [x["normal_expected_launch_budget_ceil"] for x in subset]
        normal_duration_low = [x["human_duration_planning_sec_low_normal_only"] for x in subset]
        normal_duration_high = [x["human_duration_planning_sec_high_normal_only"] for x in subset]
        per_island[island_id] = {
            "level_count": len(subset),
            "vip_enabled_count": sum(x["vip"] != "NONE" for x in subset),
            "candidate_count_global_102_to_1000": sum(x["global_level_id"] >= FIRST_CANDIDATE_GLOBAL_ID for x in subset),
            "preserved_m32_tiki_seed_count": sum(x["difficulty_tier"] == "PRESERVED_M32_SEED" for x in subset),
            "normal_T": {
                "min": min((x["normal_T"] for x in subset), default=0),
                "median_nearest_rank": nearest_rank([float(x["normal_T"]) for x in subset], 0.5),
                "p90_nearest_rank": nearest_rank([float(x["normal_T"]) for x in subset], 0.9),
                "max": max((x["normal_T"] for x in subset), default=0),
            },
            "normal_expected_launches": {
                "median": round(nearest_rank(normal_launches, 0.5), 3),
                "p90": round(nearest_rank(normal_launches, 0.9), 3),
                "max": round(max(normal_launches, default=0), 3),
                "count_ceil_100_or_more": sum(x >= 100 for x in expected_launch_ceil),
                "count_ceil_500_or_more": sum(x >= 500 for x in expected_launch_ceil),
                "count_ceil_1000_or_more": sum(x >= 1000 for x in expected_launch_ceil),
            },
            "hypothetical_normal_duration_minutes": {
                "median_low": round(nearest_rank(normal_duration_low, 0.5) / 60.0, 2),
                "median_high": round(nearest_rank(normal_duration_high, 0.5) / 60.0, 2),
                "p90_low": round(nearest_rank(normal_duration_low, 0.9) / 60.0, 2),
                "p90_high": round(nearest_rank(normal_duration_high, 0.9) / 60.0, 2),
                "note": "planning assumption only; excludes aiming, settling, retries, and observed human data",
            },
            "normal_recipe_diversity": {
                "unique_templates": len(normal_counts),
                "duplicate_records_beyond_first": sum(count - 1 for count in normal_counts.values()),
                "repeat_record_rate": round((len(subset) - len(normal_counts)) / len(subset), 4) if subset else 0.0,
                "max_same_template_count": max(normal_counts.values(), default=0),
            },
            "full_recipe_diversity": {
                "unique_including_vip": len(full_counts),
                "duplicate_records_beyond_first": sum(count - 1 for count in full_counts.values()),
                "repeat_record_rate": round((len(subset) - len(full_counts)) / len(subset), 4) if subset else 0.0,
                "max_same_recipe_count": max(full_counts.values(), default=0),
            },
            "band_counts": dict(sorted(Counter(x["tier"] for x in subset).items())),
            "analytically_suspicious_count": sum("ANALYTICALLY_SUSPICIOUS" in x["status_labels"] for x in subset),
            "data_legal_count": sum("CERTIFIED_DATA_LEGAL" in x["status_labels"] for x in subset),
        }

    unique_full = len({x["full_recipe_signature"] for x in rows})
    unique_normal = len({x["normal_recipe_signature"] for x in rows})
    data_invalid = [x for x in rows if x["data_errors"]]
    suspicious = [x for x in candidate_rows if "ANALYTICALLY_SUSPICIOUS" in x["status_labels"]]
    vip_intermediate = [x for x in candidate_rows if x["vip_intermediate_piece_demand_heuristic"] > 0]
    high_launch_candidates = [x for x in candidate_rows if x["normal_expected_launch_budget_ceil"] >= SUSPICIOUS_EXPECTED_LAUNCH_THRESHOLD]
    return {
        "schema_version": 1,
        "milestone": "BCM-M33-R03",
        "source_contract": island_doc.get("campaign_contract", {}),
        "scope": {
            "all_player_facing_levels": len(rows),
            "candidate_slice_global_102_to_1000": len(candidate_rows),
            "candidate_slice_note": "The 899 R02/R03 audit slice includes global 102-112 (11 preserved M32 Tiki records). They are analyzed read-only; 888 generated records occupy global 113-1000 plus 201-1000 excluding Sunny Cove and Tiki seed records.",
            "preserved_sunny_cove_levels": sum(x["island_id"] == "sunny_cove" for x in rows),
            "preserved_m32_tiki_l1_l12": len(preserved_tiki),
            "newly_generated_candidate_records": sum(x["difficulty_tier"] != "PRESERVED_M32_SEED" and x["global_level_id"] >= FIRST_CANDIDATE_GLOBAL_ID for x in rows),
            "generated_recipes_are_read_only_analysis": True,
        },
        "assumptions": {
            "cocktail_l1_equivalent_cost": "2^(cocktail_level-1)",
            "theoretical_T": "sum(2^(target_level-3) * quantity) for normal objectives; VIP is separate; total_T includes enabled VIP for the 4T budget and stars denominator",
            "random_launch_mix": "uniform independent launch levels 1,2,3 with L1-equivalent values 1,2,4; expected value 7/3 per launch",
            "expected_launches": "ceil is not applied to the expectation; an additional integer ceiling is provided as a planning budget only. Random variance, merge geometry, strategy, retries, and player skill are excluded",
            "planning_time": "1.5-3.0 seconds per expected launch from M17DifficultyModel's 1.5-second provisional launch cadence multiplied by its 1x-2x planning multiplier; not observed human data, excludes aiming/settling/menu time, and is not a human fairness certification",
            "stars": "production calculate_stars: normal objective completion required; 1-star permits <=4T launches, 2-star <=3T-1, 3-star <=2T-1; score and VIP completion do not change star calculation",
            "vip_intermediate_flag": "same conservative M17 heuristic as R02: higher normal targets can create VIP-level intermediate pieces; flag means reserve-sensitive recipe, not forced VIP capture. Runtime M17VipOptionalityModel is the production authority",
            "suspicion_thresholds": {
                "expected_launch_budget_ceil": SUSPICIOUS_EXPECTED_LAUNCH_THRESHOLD,
                "normal_T": SUSPICIOUS_T_THRESHOLD,
                "within_island_relative_step": SUSPICIOUS_STEP_RELATIVE_THRESHOLD,
                "interpretation": "review thresholds for workload/step diagnostics; never physical-impossibility thresholds",
            },
        },
        "summary": {
            "data_invalid_record_count_all_1000": len(data_invalid),
            "candidate_data_legal_count": sum("CERTIFIED_DATA_LEGAL" in x["status_labels"] for x in candidate_rows),
            "candidate_analytically_suspicious_count": len(suspicious),
            "candidate_physics_unverified_count": sum("PHYSICS_UNVERIFIED" in x["status_labels"] for x in candidate_rows),
            "candidate_human_fairness_unverified_count": sum("HUMAN_FAIRNESS_UNVERIFIED" in x["status_labels"] for x in candidate_rows),
            "candidate_expected_launch_budget_ceil_ge_100_count": len(high_launch_candidates),
            "candidate_expected_launch_budget_ceil_ge_500_count": sum(x["normal_expected_launch_budget_ceil"] >= 500 for x in candidate_rows),
            "candidate_expected_launch_budget_ceil_ge_1000_count": sum(x["normal_expected_launch_budget_ceil"] >= 1000 for x in candidate_rows),
            "candidate_vip_enabled_count": sum(x["vip"] != "NONE" for x in candidate_rows),
            "candidate_conservative_vip_intermediate_flags": len(vip_intermediate),
            "candidate_recipe_diversity_global_102_to_1000": {
                "unique_normal_templates": len({x["normal_recipe_signature"] for x in candidate_rows}),
                "normal_template_repeat_records": len(candidate_rows) - len({x["normal_recipe_signature"] for x in candidate_rows}),
                "unique_full_recipes_including_vip": len({x["full_recipe_signature"] for x in candidate_rows}),
                "full_recipe_repeat_records": len(candidate_rows) - len({x["full_recipe_signature"] for x in candidate_rows}),
            },
            "new_generated_recipe_diversity_global_113_to_1000": {
                "record_count": len(generated_candidate_rows),
                "unique_normal_templates": len({x["normal_recipe_signature"] for x in generated_candidate_rows}),
                "normal_template_repeat_records": len(generated_candidate_rows) - len({x["normal_recipe_signature"] for x in generated_candidate_rows}),
                "unique_full_recipes_including_vip": len({x["full_recipe_signature"] for x in generated_candidate_rows}),
                "full_recipe_repeat_records": len(generated_candidate_rows) - len({x["full_recipe_signature"] for x in generated_candidate_rows}),
            },
            "all_campaign_unique_normal_templates": unique_normal,
            "all_campaign_unique_full_recipes_including_vip": unique_full,
            "normal_T_all_1000": {"min": min(all_t), "median_nearest_rank": nearest_rank([float(x) for x in all_t], 0.5), "p90_nearest_rank": nearest_rank([float(x) for x in all_t], 0.9), "max": max(all_t), "sum": sum(all_t)},
            "normal_T_candidates_102_to_1000": {"min": min(candidate_t), "median_nearest_rank": nearest_rank([float(x) for x in candidate_t], 0.5), "p90_nearest_rank": nearest_rank([float(x) for x in candidate_t], 0.9), "max": max(candidate_t), "sum": sum(candidate_t)},
        },
        "by_island": per_island,
        "progression_steps": progression_steps(rows),
        "global_top_workload_levels": sorted(candidate_rows, key=lambda x: x["normal_expected_launches"], reverse=True)[:50],
        "vip_intermediate_flagged_global_ids": [x["global_level_id"] for x in vip_intermediate],
        "data_invalid_records": [{"global_level_id": x["global_level_id"], "errors": x["data_errors"]} for x in data_invalid],
        "conclusion": "CERTIFIED_DATA_LEGAL records have passed necessary structural checks only. Every generated candidate remains PHYSICS_UNVERIFIED and HUMAN_FAIRNESS_UNVERIFIED. ANALYTICALLY_SUSPICIOUS marks workload/recipe review conditions, not an impossibility finding.",
    }


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    fields = [
        "global_level_id", "island_id", "local_level_id", "tier", "normal_orders", "vip",
        "normal_T", "vip_T", "total_T", "normal_expected_launches", "normal_expected_launch_budget_ceil",
        "vip_expected_launches_optional", "vip_expected_launch_budget_ceil_optional", "move_limit_4T",
        "one_star_max_launches_if_complete", "two_star_max_launches_if_complete", "three_star_max_launches_if_complete",
        "human_duration_planning_sec_low_normal_only", "human_duration_planning_sec_high_normal_only",
        "vip_duration_increment_sec_low_optional", "vip_duration_increment_sec_high_optional",
        "vip_intermediate_piece_demand_heuristic", "vip_reserve_status", "status_labels", "suspicion_flags", "data_errors",
    ]
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        for row in rows:
            writer.writerow({key: json.dumps(row[key], separators=(",", ":")) if isinstance(row[key], (list, dict)) else row[key] for key in fields})


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--output-dir", type=Path, default=None)
    args = parser.parse_args()
    root = args.project_root.resolve()
    output_dir = args.output_dir or root / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R03"
    output_dir.mkdir(parents=True, exist_ok=True)
    started = time.perf_counter()
    cpu_started = time.process_time()
    rows, raw_islands, island_doc = load_campaign(root)
    report = build_report(rows, raw_islands, island_doc)
    candidates = [x for x in rows if FIRST_CANDIDATE_GLOBAL_ID <= x["global_level_id"] <= LAST_GLOBAL_ID]
    validator = {
        "schema_version": 1,
        "validator": "BCM-M33-R03-NECESSARY-CONDITION-1.0.0",
        "candidate_range": [FIRST_CANDIDATE_GLOBAL_ID, LAST_GLOBAL_ID],
        "candidate_count": len(candidates),
        "status_contract": {
            "CERTIFIED_DATA_LEGAL": "passes structural target, quantity, merge-cost, ID, timer, stored-T and 4T arithmetic checks; not a solvability certification",
            "ANALYTICALLY_SUSPICIOUS": "data error or a declared review heuristic such as high launch burden, VIP intermediate reserve, objective overlap, or high T",
            "PHYSICS_UNVERIFIED": "no physical reachability conclusion from this analytic validator",
            "HUMAN_FAIRNESS_UNVERIFIED": "no measured human effort/fairness conclusion from this analytic validator",
        },
        "records": [{
            "global_level_id": x["global_level_id"],
            "data_legal": "CERTIFIED_DATA_LEGAL" in x["status_labels"],
            "labels": x["status_labels"],
            "errors": x["data_errors"],
            "suspicion_flags": x["suspicion_flags"],
            "vip_reserve_status": x["vip_reserve_status"],
            "physics": "PHYSICS_UNVERIFIED",
            "human_fairness": "HUMAN_FAIRNESS_UNVERIFIED",
        } for x in candidates],
        "aggregate": report["summary"],
    }
    (output_dir / "all_level_difficulty_analysis.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    (output_dir / "candidate_validator_report.json").write_text(json.dumps(validator, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    write_csv(output_dir / "all_1000_levels.csv", rows)
    input_paths = [
        root / "data/campaign/islands.json",
        root / "data/campaign/content_manifest_m33.json",
        *(root / "data/campaign/levels" / name for name in ISLAND_LEVEL_FILES.values()),
    ]
    source_paths = [
        root / "tools/campaign/m33_r03_difficulty_analytics.py",
        root / "scripts/campaign/level_database.gd",
        root / "scripts/campaign/m17_difficulty_model.gd",
        root / "scripts/campaign/m17_vip_optionality_model.gd",
        root / "scripts/campaign/m17_canonical_screening_model.gd",
        root / "scripts/campaign/gameplay_session_bridge.gd",
        root / "tools/validate_m33_campaign_content.py",
        root / "tests/test_m33_r03_difficulty_analytics.py",
    ]
    output_paths = [
        output_dir / "all_level_difficulty_analysis.json",
        output_dir / "candidate_validator_report.json",
        output_dir / "all_1000_levels.csv",
    ]
    evidence_payload = [path for path in output_dir.iterdir() if path.is_file() and path.name != "execution_metadata.json"]
    metadata = {
        "schema_version": 1,
        "runner": "BCM-M33-R03-NECESSARY-CONDITION-1.0.0",
        "scope": "read-only static campaign analysis; no physics or Godot runtime simulation",
        "python_version": __import__("sys").version.split()[0],
        "input_bytes": sum(path.stat().st_size for path in input_paths),
        "input_sha256": {str(path.relative_to(root)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest().upper() for path in input_paths},
        "source_sha256": {str(path.relative_to(root)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest().upper() for path in source_paths},
        "outputs_before_this_metadata_file": {path.name: path.stat().st_size for path in output_paths},
        "output_bytes_before_metadata": sum(path.stat().st_size for path in output_paths),
        "evidence_payload_files_before_metadata": {path.name: path.stat().st_size for path in sorted(evidence_payload)},
        "evidence_payload_bytes_before_metadata": sum(path.stat().st_size for path in evidence_payload),
        "wall_elapsed_seconds": round(time.perf_counter() - started, 6),
        "process_cpu_seconds": round(time.process_time() - cpu_started, 6),
    }
    (output_dir / "execution_metadata.json").write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    elapsed = time.perf_counter() - started
    print(json.dumps({
        "result": "PASS_ANALYTIC_DIAGNOSTICS_ONLY" if not report["summary"]["data_invalid_record_count_all_1000"] else "DATA_FINDINGS_PRESENT",
        "levels": len(rows),
        "candidate_slice": len(candidates),
        "data_invalid": report["summary"]["data_invalid_record_count_all_1000"],
        "candidate_vip_intermediate_flags": report["summary"]["candidate_conservative_vip_intermediate_flags"],
        "wall_elapsed_seconds": round(elapsed, 6),
        "process_cpu_seconds": metadata["process_cpu_seconds"],
        "output_bytes_before_metadata": metadata["output_bytes_before_metadata"],
        "output_dir": str(output_dir),
    }, sort_keys=True))


if __name__ == "__main__":
    main()
