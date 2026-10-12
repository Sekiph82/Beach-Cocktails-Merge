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
REPORT_PATH = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-005-TIKI-CONTINUITY/continuity_preservation_report.json"
MANIFEST_PATH = ROOT / "data/campaign/content_manifest_m33.json"
CONTENT_VERSION = "BCM-M33.2"


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
    targets = list(range(int(band["target_min"]), int(band["target_max"]) + 1))
    order_count = int(_choose(list(range(int(band["orders_min"]), int(band["orders_max"]) + 1)), seed, island_id, level_id, attempt, "order_count"))
    ranked_targets = sorted(targets, key=lambda target: _digest_int(seed, island_id, level_id, attempt, f"target:{target}"))
    chosen_targets = ranked_targets[:order_count]
    order_rows: list[dict[str, int]] = []
    for slot, target in enumerate(chosen_targets):
        quantity = 2 if _digest_int(seed, island_id, level_id, attempt, f"quantity:{slot}") % 100 < int(band["quantity_two_percent"]) else 1
        order_rows.append({"cocktail_level": target, "quantity": quantity})
    order_rows.sort(key=lambda row: _digest_int(seed, island_id, level_id, attempt, f"order-sequence:{row['cocktail_level']}:{row['quantity']}"))

    vip: dict[str, Any] | None = None
    if _digest_int(seed, island_id, level_id, attempt, "vip") % 100 < int(band["vip_percent"]):
        remaining = [target for target in targets if target not in {row["cocktail_level"] for row in order_rows}]
        if remaining:
            vip_target = int(_choose(remaining, seed, island_id, level_id, attempt, "vip_target"))
            vip = {"enabled": True, "cocktail_level": vip_target, "quantity": 1, "reward": {}}

    return {
        "island_id": island_id,
        "level_id": level_id,
        "global_level_id": global_level_id,
        "difficulty_tier": str(band["tier"]),
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
    used_signatures: set[str],
    used_normal_signatures: set[str],
    rewards: dict[str, int],
) -> dict[str, Any]:
    for attempt in range(100_000):
        row = _candidate(island_id, level_id, global_level_id, band, seed, attempt, rewards)
        signature = _signature(row)
        theoretical = _theoretical_shots(row)
        if len(row["orders"]) < 2:
            continue
        if theoretical > int(band["max_theoretical_shots"]):
            continue
        if _normal_signature(row) in used_normal_signatures:
            continue
        if signature in used_signatures:
            continue
        row["theoretical_shots_total"] = theoretical
        row["move_limit"] = theoretical * 4
        used_signatures.add(signature)
        return row
    raise RuntimeError(f"exhausted deterministic unique candidates: {island_id}/{level_id} tier={band['tier']}")


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
    used_signatures: set[str] = {_signature(row) for row in preserved_tiki_rows}
    for island_id in island_order[1:]:
        profile = profiles["islands"][island_id]
        rows: list[dict[str, Any]] = list(preserved_tiki_rows) if island_id == "tiki_island" else []
        first_new_level = 13 if island_id == "tiki_island" else 1
        first_global = (island_order.index(island_id) * 100) + 1
        island_policy = island_by_id[island_id]["target_policy"]
        min_policy = int(island_policy["min_level"])
        max_policy = int(island_policy["max_level"])
        for level_id in range(first_new_level, 101):
            band = _band_for(profile, level_id)
            if int(band["target_min"]) < min_policy or int(band["target_max"]) > max_policy:
                raise ValueError(f"profile target range exceeds policy for {island_id}/{level_id}")
            generated = _generate_one(
                island_id=island_id,
                level_id=level_id,
                global_level_id=first_global + level_id - 1,
                band=band,
                seed=seed,
                used_signatures=used_signatures,
                used_normal_signatures=used_normal_signatures,
                rewards={"coins": 10, "gems": 1} if island_id == "tiki_island" else {"coins": 0},
            )
            rows.append(generated)

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
        for row in rows:
            for order in row["orders"]:
                target_counts[str(order["cocktail_level"])] += int(order["quantity"])
            if isinstance(row.get("vip"), dict) and row["vip"].get("enabled", True):
                vip_count += 1
                target_counts[f"VIP_L{row['vip']['cocktail_level']}"] += int(row["vip"]["quantity"])
            theoretical.append(_theoretical_shots(row))
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
                "all_generated_normal_templates_avoid_sunny_intro_1_10": all(
                    _normal_signature(row) not in sunny_intro_normal for row in rows if int(row["level_id"]) >= first_new_level
                ),
                "preserved_m32_levels_colliding_with_sunny_intro_1_10": sum(
                    _normal_signature(row) in sunny_intro_normal for row in rows if int(row["level_id"]) < first_new_level
                ),
            }
        )

    report = {
        "result": "GENERATED_STATIC_CANDIDATES_PENDING_GODOT_AND_PHYSICS_SCREENING",
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
        "unique_full_challenge_signatures_global": len(used_signatures),
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
