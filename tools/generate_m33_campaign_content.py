#!/usr/bin/env python3
"""Deterministically generate the nine M33 island level-data files.

Generated challenges use existing cocktail/To-Go/VIP fields and the production
L3-equivalent cost rule. This authoring tool is not a physics solver or human
playability certification.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
PROFILE_PATH = ROOT / "data/campaign/content_generation_profiles_m33.json"
ISLANDS_PATH = ROOT / "data/campaign/islands.json"
LEVELS_DIR = ROOT / "data/campaign/levels"
SUNNY_PATH = LEVELS_DIR / "sunny_cove.json"
TIKI_SEED_PATH = LEVELS_DIR / "tiki_island.json"
REPORT_PATH = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R05-R02/generation_report.json"
MANIFEST_PATH = ROOT / "data/campaign/content_manifest_m33.json"
CONTENT_VERSION = "BCM-M33.5"
TABLETOP_LAYOUTS_VERSION = 1


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def _read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _digest_int(seed: int, island_id: str, level_id: int, attempt: int, field: str) -> int:
    material = f"BCM-M33|{seed}|{island_id}|{level_id}|{attempt}|{field}".encode("utf-8")
    return int.from_bytes(hashlib.sha256(material).digest()[:8], "big")


def _choose(values: list[Any], seed: int, island_id: str, level_id: int, attempt: int, field: str) -> Any:
    return values[_digest_int(seed, island_id, level_id, attempt, field) % len(values)]


def _signature(level: dict[str, Any]) -> str:
    vip = level.get("vip")
    normalized_vip = {"enabled": False, "cocktail_level": 0, "quantity": 0}
    if isinstance(vip, dict) and vip.get("enabled", True):
        normalized_vip = {
            "enabled": True,
            "cocktail_level": int(vip["cocktail_level"]),
            "quantity": int(vip["quantity"]),
        }
    return json.dumps(
        {
            "orders": [
                {"cocktail_level": int(row["cocktail_level"]), "quantity": int(row["quantity"])}
                for row in level["orders"]
            ],
            "time_limit_sec": float(level.get("time_limit_sec", 0)),
            "vip": normalized_vip,
        },
        separators=(",", ":"),
        sort_keys=True,
    )


def _normal_signature(level: dict[str, Any]) -> str:
    return json.dumps(
        [{"cocktail_level": int(row["cocktail_level"]), "quantity": int(row["quantity"])} for row in level["orders"]],
        separators=(",", ":"),
        sort_keys=True,
    )


def _theoretical_shots(level: dict[str, Any]) -> int:
    total = 0
    for row in level["orders"]:
        target = int(row["cocktail_level"])
        quantity = int(row["quantity"])
        if target < 3 or target > 12 or quantity <= 0:
            raise ValueError(f"illegal To-Go target: {level.get('island_id')}/{level.get('level_id')}")
        total += (1 << (target - 3)) * quantity
    vip = level.get("vip")
    if isinstance(vip, dict) and vip.get("enabled", True):
        target = int(vip["cocktail_level"])
        quantity = int(vip["quantity"])
        if target < 3 or target > 12 or quantity <= 0:
            raise ValueError(f"illegal VIP target: {level.get('island_id')}/{level.get('level_id')}")
        total += (1 << (target - 3)) * quantity
    return total


def _normal_t(level: dict[str, Any]) -> int:
    return sum((1 << (int(row["cocktail_level"]) - 3)) * int(row["quantity"]) for row in level["orders"])


def _initial_tabletop_drinks(level: dict[str, Any], island_id: str, level_id: int, seed: int) -> list[dict[str, Any]]:
    """Build deterministic, goal-compatible starting stock; legacy rows omit this field."""
    if level_id == 1 or level_id % 17 == 0:
        return []
    orders = level["orders"]
    total_required = sum(int(row["quantity"]) for row in orders)
    if total_required <= 1:
        return []

    # Every stocked drink corresponds to a normal objective level. Leave at
    # least one required normal drink unstocked, and never seed a VIP level.
    # Keep starting stock in the HUD-clear tabletop band with a clear center
    # launch lane and visible margin above the danger line. Paired layouts use
    # symmetric lateral positions with a wide gap.
    position_sets = [
        [[0.28, 0.56]], [[0.72, 0.56]], [[0.28, 0.56]],
        [[0.72, 0.56]], [[0.28, 0.56]], [[0.72, 0.56]],
        [[0.28, 0.56], [0.72, 0.56]],
        [[0.29, 0.56], [0.71, 0.56]],
    ]
    island_phase = _digest_int(seed, island_id, 0, 0, "tabletop-layout-phase") % len(position_sets)
    layout_index = (level_id + island_phase) % len(position_sets)
    positions = position_sets[layout_index]
    drink_count = min(len(positions), total_required - 1)

    order_indices = sorted(
        range(len(orders)),
        key=lambda index: _digest_int(seed, island_id, level_id, 0, f"stock-order:{index}"),
    )
    lowest_normal_target = min(int(order["cocktail_level"]) for order in orders)
    order_indices = [index for index in order_indices if int(orders[index]["cocktail_level"]) == lowest_normal_target]
    remaining_by_order = {index: int(orders[index]["quantity"]) for index in range(len(orders))}
    result: list[dict[str, Any]] = []
    for slot in range(drink_count):
        available = [index for index in order_indices if remaining_by_order[index] > 0]
        if not available:
            break
        order_index = available[slot % len(available)]
        order = orders[order_index]
        result.append({
            # A starter is always one step below the lowest normal target, so
            # it stays on the table and cannot auto-deliver into another order.
            "cocktail_level": int(order["cocktail_level"]) - 1,
            "position": positions[slot],
        })
        remaining_by_order[order_index] -= 1
    return result


def _preserve_m32_tiki_rows(tiki_seed: dict[str, Any]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for seed_row in tiki_seed["levels"]:
        level_id = int(seed_row["level_id"])
        if level_id > 12:
            break
        row = json.loads(json.dumps(seed_row))
        row["global_level_id"] = 101 + level_id - 1
        row["difficulty_tier"] = "PRESERVED_M32_SEED"
        theoretical = _theoretical_shots(row)
        row["theoretical_shots_total"] = theoretical
        row["move_limit"] = theoretical * 4
        rows.append(row)
    if [int(row["level_id"]) for row in rows] != list(range(1, 13)):
        raise ValueError("M32 Tiki source must provide unchanged local levels 1-12")
    return rows


def _band_for(profile: dict[str, Any], level_id: int) -> dict[str, Any]:
    for band in profile["bands"]:
        if int(band["first_level"]) <= level_id <= int(band["last_level"]):
            return band
    raise ValueError(f"profile has no band for local level {level_id}")


def _candidate(
    island_id: str,
    level_id: int,
    global_level_id: int,
    band: dict[str, Any],
    seed: int,
    attempt: int,
    rewards: dict[str, int],
) -> dict[str, Any]:
    raw_targets = band.get("target_levels")
    if raw_targets is None:
        raw_targets = range(int(band["target_min"]), int(band["target_max"]) + 1)
    targets = [int(x) for x in raw_targets]
    bridge_target = int(band.get("bridge_target_level", 0))
    if bridge_target in targets and _digest_int(seed, island_id, level_id, attempt, "bridge_target") % 100 >= int(band.get("bridge_target_percent", 0)):
        targets = [target for target in targets if target != bridge_target]
    order_count = int(_choose(list(range(int(band["orders_min"]), int(band["orders_max"]) + 1)), seed, island_id, level_id, attempt, "order_count"))
    required_targets = [int(x) for x in band.get("required_target_levels", [])]
    if order_count < len(required_targets) or any(target not in targets for target in required_targets):
        raise ValueError(f"required target policy is infeasible for {island_id}/{level_id}")
    ranked_targets = sorted(targets, key=lambda target: _digest_int(seed, island_id, level_id, attempt, f"target:{target}"))
    chosen_targets = list(required_targets)
    for target in ranked_targets:
        if len(chosen_targets) >= order_count:
            break
        if target not in chosen_targets:
            chosen_targets.append(target)
    if not bool(band.get("prestige_capstone", False)):
        minimum_level = int(band.get("minimum_normal_target_level", 6))
        maximum_below_minimum = int(band.get("maximum_targets_below_minimum", 1))
        high_targets = [target for target in ranked_targets if target >= minimum_level]
        if not high_targets:
            raise ValueError(f"ordinary recipe has no target at or above L{minimum_level}")
        while not any(target >= minimum_level for target in chosen_targets):
            low_index = next(index for index, target in enumerate(chosen_targets) if target < minimum_level)
            replacement = next(target for target in high_targets if target not in chosen_targets)
            chosen_targets[low_index] = replacement
        while sum(target < minimum_level for target in chosen_targets) > maximum_below_minimum:
            low_index = next(index for index, target in enumerate(chosen_targets) if target < minimum_level)
            replacement = next(target for target in high_targets if target not in chosen_targets)
            chosen_targets[low_index] = replacement
    order_rows: list[dict[str, int]] = []
    for slot, target in enumerate(chosen_targets):
        quantity = 2 if _digest_int(seed, island_id, level_id, attempt, f"quantity:{slot}") % 100 < int(band["quantity_two_percent"]) else 1
        order_rows.append({"cocktail_level": target, "quantity": quantity})
    order_rows.sort(key=lambda row: _digest_int(seed, island_id, level_id, attempt, f"order-sequence:{row['cocktail_level']}:{row['quantity']}"))

    vip: dict[str, Any] | None = None
    normal_max_target = max(row["cocktail_level"] for row in order_rows)
    if _digest_int(seed, island_id, level_id, attempt, "vip") % 100 < int(band["vip_percent"]):
        remaining = [
            int(target) for target in band.get("vip_target_levels", [])
            if int(target) not in {row["cocktail_level"] for row in order_rows} and int(target) > normal_max_target
        ]
        if remaining:
            vip_target = int(_choose(remaining, seed, island_id, level_id, attempt, "vip_target"))
            vip = {"enabled": True, "cocktail_level": vip_target, "quantity": 1, "reward": {}}

    return {
        "island_id": island_id,
        "level_id": level_id,
        "global_level_id": global_level_id,
        "difficulty_tier": str(band["tier"]),
        "level_type": "PRESTIGE_CAPSTONE" if bool(band.get("prestige_capstone", False)) else "ORDINARY",
        "prestige_capstone": bool(band.get("prestige_capstone", False)),
        "time_limit_sec": 0,
        "orders": order_rows,
        "vip": vip,
        "rewards": rewards,
        "score_star_thresholds": {"one_star": 0, "two_stars": 0, "three_stars": 0},
        "feature_flags": {"timed": False, "vip": vip is not None, "boosters": False},
    }


def _generate_one(
    island_id: str,
    level_id: int,
    global_level_id: int,
    band: dict[str, Any],
    seed: int,
    used_island_signatures: set[str],
    used_island_normal_signatures: set[str],
    used_global_signatures: set[str],
    used_normal_signatures: set[str],
    rewards: dict[str, int],
    previous_normal_t: int,
    max_normal_t_step: int,
) -> dict[str, Any]:
    max_attempts = int(band.get("candidate_attempt_limit", 4096))
    for attempt in range(max_attempts):
        row = _candidate(island_id, level_id, global_level_id, band, seed, attempt, rewards)
        signature = _signature(row)
        theoretical = _theoretical_shots(row)
        if len(row["orders"]) < 2:
            continue
        normal_t = _normal_t(row)
        if not int(band["min_normal_T"]) <= normal_t <= int(band["max_normal_T"]):
            continue
        if previous_normal_t > 0 and abs(normal_t - previous_normal_t) > max_normal_t_step:
            continue
        row["initial_tabletop_drinks_version"] = 1
        row["initial_tabletop_drinks"] = _initial_tabletop_drinks(row, island_id, level_id, seed)
        row["theoretical_shots_total"] = theoretical
        row["move_limit"] = theoretical * 4
        used_island_signatures.add(signature)
        used_island_normal_signatures.add(_normal_signature(row))
        used_global_signatures.add(signature)
        return row
    raise RuntimeError(
        f"exhausted {max_attempts} deterministic candidate attempts: {island_id}/{level_id} tier={band['tier']} "
        f"previous_normal_T={previous_normal_t} allowed_normal_T={band['min_normal_T']}..{band['max_normal_T']} "
        f"max_adjacent_delta={max_normal_t_step} used_full_signatures={len(used_signatures)}"
    )


def generate() -> tuple[dict[str, dict[str, Any]], dict[str, Any]]:
    profiles = _read_json(PROFILE_PATH)
    islands_root = _read_json(ISLANDS_PATH)
    sunny_root = _read_json(SUNNY_PATH)
    tiki_seed = _read_json(TIKI_SEED_PATH)
    seed = int(profiles["batch_seed"])
    generator_version = str(profiles["generator_version"])
    profile_sha = _sha256(PROFILE_PATH.read_bytes())
    island_order = [str(row["id"]) for row in islands_root["islands"]]
    island_by_id = {str(row["id"]): row for row in islands_root["islands"]}

    preserved_tiki_rows = _preserve_m32_tiki_rows(tiki_seed)
    used_normal_signatures: set[str] = set()
    sunny_intro_normal = {_normal_signature(row) for row in sunny_root["levels"][:10]}
    used_normal_signatures.update(sunny_intro_normal)
    used_normal_signatures.update(_normal_signature(row) for row in preserved_tiki_rows)

    outputs: dict[str, dict[str, Any]] = {}
    island_reports: list[dict[str, Any]] = []
    used_global_signatures: set[str] = {_signature(row) for row in preserved_tiki_rows}
    previous_normal_t = _normal_t(preserved_tiki_rows[-1])
    max_normal_t_step = int(profiles["design_contract"]["max_adjacent_normal_T_delta"])
    for island_id in island_order[1:]:
        profile = profiles["islands"][island_id]
        rows: list[dict[str, Any]] = list(preserved_tiki_rows) if island_id == "tiki_island" else []
        first_new_level = 13 if island_id == "tiki_island" else 1
        first_global = (island_order.index(island_id) * 100) + 1
        island_policy = island_by_id[island_id]["target_policy"]
        min_policy = int(island_policy["min_level"])
        max_policy = int(island_policy["max_level"])
        used_island_signatures: set[str] = {_signature(row) for row in preserved_tiki_rows} if island_id == "tiki_island" else set()
        used_island_normal_signatures: set[str] = {_normal_signature(row) for row in preserved_tiki_rows} if island_id == "tiki_island" else set()
        for level_id in range(first_new_level, 101):
            band = _band_for(profile, level_id)
            targets = [int(x) for x in band["target_levels"]]
            vip_targets = [int(x) for x in band.get("vip_target_levels", [])]
            if any(target < min_policy or target > max_policy for target in targets + vip_targets):
                raise ValueError(f"profile target range exceeds policy for {island_id}/{level_id}")
            generated = _generate_one(
                island_id=island_id,
                level_id=level_id,
                global_level_id=first_global + level_id - 1,
                band=band,
                seed=seed,
                used_island_signatures=used_island_signatures,
                used_island_normal_signatures=used_island_normal_signatures,
                used_global_signatures=used_global_signatures,
                used_normal_signatures=used_normal_signatures,
                rewards={"coins": 10, "gems": 1} if island_id == "tiki_island" else {"coins": 0},
                previous_normal_t=previous_normal_t,
                max_normal_t_step=max_normal_t_step,
            )
            rows.append(generated)
            previous_normal_t = _normal_t(generated)

        if len(rows) != 100 or [int(row["level_id"]) for row in rows] != list(range(1, 101)):
            raise ValueError(f"generated output is not exactly 100 contiguous records: {island_id}")
        root = {
            "schema_version": 1,
            "island_id": island_id,
            "campaign_generation": {
                "generator_version": generator_version,
                "seed": seed,
                "profile_set_path": "res://data/campaign/content_generation_profiles_m33.json",
                "profile_set_sha256": profile_sha,
                "profile_id": island_id,
                "global_level_range": profiles["island_global_ranges"][island_id],
                "preserved_m32_seed_levels": len(preserved_tiki_rows) if island_id == "tiki_island" else 0,
            },
            "levels": rows,
        }
        outputs[island_id] = root

        normal_signatures = [_normal_signature(row) for row in rows]
        normal_signature_counts = Counter(normal_signatures)
        objective_counts = Counter(str(len(row["orders"])) for row in rows)
        target_counts: Counter[str] = Counter()
        vip_count = 0
        theoretical: list[int] = []
        normal_theoretical: list[int] = []
        adjacent_normal_steps: list[int] = []
        for row in rows:
            for order in row["orders"]:
                target_counts[str(order["cocktail_level"])] += int(order["quantity"])
            if isinstance(row.get("vip"), dict) and row["vip"].get("enabled", True):
                vip_count += 1
                target_counts[f"VIP_L{row['vip']['cocktail_level']}"] += int(row["vip"]["quantity"])
            theoretical.append(_theoretical_shots(row))
            normal_theoretical.append(_normal_t(row))
        for left, right in zip(rows, rows[1:]):
            adjacent_normal_steps.append(abs(_normal_t(right) - _normal_t(left)))
        island_reports.append(
            {
                "island_id": island_id,
                "global_level_range": profiles["island_global_ranges"][island_id],
                "record_count": len(rows),
                "first_m32_levels_preserved": len(preserved_tiki_rows) if island_id == "tiki_island" else 0,
                "newly_generated_record_count": len(rows) - (len(preserved_tiki_rows) if island_id == "tiki_island" else 0),
                "unique_full_challenge_signatures": len({_signature(row) for row in rows}),
                "unique_normal_objective_templates": len(set(normal_signatures)),
                "normal_template_repeat_records": sum(count - 1 for count in normal_signature_counts.values()),
                "normal_template_repeat_rate": round((len(rows) - len(set(normal_signatures))) / len(rows), 4),
                "max_repetition_of_one_normal_template": max(normal_signature_counts.values()),
                "normal_order_count_distribution": dict(sorted(objective_counts.items())),
                "vip_enabled_levels": vip_count,
                "target_quantity_histogram": dict(sorted(target_counts.items())),
                "theoretical_shots_min": min(theoretical),
                "theoretical_shots_median": sorted(theoretical)[len(theoretical) // 2],
                "theoretical_shots_max": max(theoretical),
                "normal_T_min": min(normal_theoretical),
                "normal_T_median": sorted(normal_theoretical)[len(normal_theoretical) // 2],
                "normal_T_p90": sorted(normal_theoretical)[int(len(normal_theoretical) * 0.9) - 1],
                "normal_T_max": max(normal_theoretical),
                "normal_T_at_most_56_count": sum(value <= 56 for value in normal_theoretical if value is not None),
                "max_within_island_adjacent_normal_T_delta": max(adjacent_normal_steps, default=0),
                "prestige_capstone_levels": [int(row["level_id"]) for row in rows if bool(row.get("prestige_capstone", False))],
                "prestige_capstone_normal_T": [_normal_t(row) for row in rows if bool(row.get("prestige_capstone", False))],
                "generated_sunny_intro_template_collisions": sum(
                    _normal_signature(row) in sunny_intro_normal for row in rows if int(row["level_id"]) >= first_new_level
                ),
                "initial_tabletop_levels": sum(bool(row.get("initial_tabletop_drinks", [])) for row in rows if int(row["level_id"]) >= first_new_level),
                "initial_tabletop_empty_levels": sum(not row.get("initial_tabletop_drinks", []) for row in rows if int(row["level_id"]) >= first_new_level),
                "preserved_m32_levels_colliding_with_sunny_intro_1_10": sum(
                    _normal_signature(row) in sunny_intro_normal for row in rows if int(row["level_id"]) < first_new_level
                ),
            }
        )

    generated_rows = [
        row
        for island_id in island_order[1:]
        for row in outputs[island_id]["levels"]
        if not (island_id == "tiki_island" and int(row["level_id"]) <= 12)
    ]
    normal_counts = Counter(_normal_signature(row) for row in generated_rows)
    full_counts = Counter(_signature(row) for row in generated_rows)
    layout_counts = Counter(
        json.dumps({"recipe": _signature(row), "starting_drinks": row.get("initial_tabletop_drinks", [])}, sort_keys=True, separators=(",", ":"))
        for row in generated_rows
    )
    locations_by_full_recipe: dict[str, set[str]] = {}
    locations_by_normal_recipe: dict[str, set[str]] = {}
    for row in generated_rows:
        locations_by_full_recipe.setdefault(_signature(row), set()).add(str(row["island_id"]))
        locations_by_normal_recipe.setdefault(_normal_signature(row), set()).add(str(row["island_id"]))
    cross_island_records = sum(
        len(group) - 1 for group in locations_by_full_recipe.values() if len(group) > 1
    )
    adjacent_full_recipe_repeats = 0
    adjacent_layout_repeats = 0
    nearby_full_recipe_pairs = {5: 0, 10: 0}
    nearby_layout_pairs = {5: 0, 10: 0}
    layout_signatures = [
        json.dumps({"recipe": _signature(row), "starting_drinks": row.get("initial_tabletop_drinks", [])}, sort_keys=True, separators=(",", ":"))
        for row in generated_rows
    ]
    full_signatures = [_signature(row) for row in generated_rows]
    for index in range(len(generated_rows)):
        if index and full_signatures[index] == full_signatures[index - 1]:
            adjacent_full_recipe_repeats += 1
        if index and layout_signatures[index] == layout_signatures[index - 1]:
            adjacent_layout_repeats += 1
        for window in (5, 10):
            for prior in range(max(0, index - window), index):
                if full_signatures[index] == full_signatures[prior]:
                    nearby_full_recipe_pairs[window] += 1
                if layout_signatures[index] == layout_signatures[prior]:
                    nearby_layout_pairs[window] += 1

    report = {
        "result": "OWNER_APPROVED_DIFFICULTY_CANDIDATES_PENDING_PHYSICS_AND_HUMAN_VALIDATION",
        "content_version": CONTENT_VERSION,
        "generator_version": generator_version,
        "seed": seed,
        "profile_set_sha256": profile_sha,
        "sunny_cove_source_sha256": _sha256(SUNNY_PATH.read_bytes()),
        "m32_tiki_seed_source_sha256": _sha256(TIKI_SEED_PATH.read_bytes()),
        "required_campaign_records": 900,
        "preserved_m32_tiki_records": 12,
        "required_generated_records": 888,
        "output_record_count": sum(len(root["levels"]) for root in outputs.values()),
        "newly_generated_record_count": sum(
            len(root["levels"]) - int(root["campaign_generation"]["preserved_m32_seed_levels"])
            for root in outputs.values()
        ),
        "unique_full_challenge_signatures_global": len(used_global_signatures),
        "global_full_recipe_duplicate_records_including_within_island": sum(len(root["levels"]) for root in outputs.values()) - len(used_global_signatures),
        "controlled_repetition_metrics": {
            "generated_record_count": len(generated_rows),
            "within_island_normal_repeat_records": sum(len(root["levels"]) - int(root["campaign_generation"]["preserved_m32_seed_levels"]) - len({_normal_signature(row) for row in root["levels"][int(root["campaign_generation"]["preserved_m32_seed_levels"]):]}) for root in outputs.values()),
            "within_island_full_recipe_repeat_records": sum(
                len(rows) - len({_signature(row) for row in rows})
                for island_id, root in outputs.items()
                for rows in [root["levels"][int(root["campaign_generation"]["preserved_m32_seed_levels"]):]]
            ),
            "global_normal_duplicate_records_including_within_island": len(generated_rows) - len(normal_counts),
            "global_full_recipe_duplicate_records_including_within_island": len(generated_rows) - len(full_counts),
            "cross_island_normal_recipe_repeat_records": sum(
                len(group) - 1 for group in locations_by_normal_recipe.values() if len(group) > 1
            ),
            "cross_island_full_recipe_repeat_records": cross_island_records,
            "unique_full_recipe_signatures": len(full_counts),
            "unique_recipe_and_tabletop_layout_signatures": len(layout_counts),
            "recipe_and_tabletop_layout_repeat_records": len(generated_rows) - len(layout_counts),
            "adjacent_full_recipe_repeats": adjacent_full_recipe_repeats,
            "adjacent_recipe_and_tabletop_layout_repeats": adjacent_layout_repeats,
            "same_full_recipe_pairs_within_previous_5_records": nearby_full_recipe_pairs[5],
            "same_full_recipe_pairs_within_previous_10_records": nearby_full_recipe_pairs[10],
            "same_recipe_and_tabletop_layout_pairs_within_previous_5_records": nearby_layout_pairs[5],
            "same_recipe_and_tabletop_layout_pairs_within_previous_10_records": nearby_layout_pairs[10],
        },
        "sunny_intro_template_collision_count_in_new_records": 0,
        "preserved_m32_tiki_sunny_intro_template_collision_count": island_reports[0]["preserved_m32_levels_colliding_with_sunny_intro_1_10"],
        "islands": island_reports,
        "limitations": [
            "Deterministic generation and static rule checks do not certify physics reachability or human playability.",
            "The M32 Tiki seed file remains byte-identical and its L1-L12 gameplay records are preserved in the M33 runtime package; only M33 global IDs and derived T/move-budget metadata are added.",
            "The preserved M32 Tiki L1-L12 records are an explicit exception to the no-Sunny-intro-template-reuse rule; generation applies to Tiki L13-L100 and the other 800 campaign records.",
            "Automated content is not owner visual approval or human playtesting.",
        ],
    }
    return outputs, report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="write the deterministic level files and evidence report")
    args = parser.parse_args()
    outputs, report = generate()
    if args.write:
        for island_id, root in outputs.items():
            output_name = str(_read_json(PROFILE_PATH)["islands"][island_id]["output_file"])
            path = LEVELS_DIR / output_name
            path.write_text(json.dumps(root, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        island_rows = [{"id": "sunny_cove", "path": "res://data/campaign/levels/sunny_cove.json"}]
        for island_id, root in outputs.items():
            output_name = str(_read_json(PROFILE_PATH)["islands"][island_id]["output_file"])
            island_rows.append({"id": island_id, "path": f"res://data/campaign/levels/{output_name}"})
        manifest = {
            "schema_version": 1,
            "content_version": CONTENT_VERSION,
            "supported_game_version": "4.7.x",
            "delivery_mode": "versioned_bundled_app_update",
            "read_only": True,
            "island_count": 10,
            "levels_per_island": 100,
            "total_levels": 1000,
            "ordered_island_ids": [row["id"] for row in island_rows],
            "islands": [
                {
                    "id": row["id"],
                    "level_count": 100,
                    "path": row["path"],
                    "sha256": _sha256((ROOT / row["path"].removeprefix("res://")).read_bytes()),
                }
                for row in island_rows
            ],
        }
        MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
        REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["output_record_count"] == 900 and report["newly_generated_record_count"] == 888 else 2


if __name__ == "__main__":
    raise SystemExit(main())
