#!/usr/bin/env python3
"""Bound the M33 R04-R01 recipe space without running gameplay simulations.

This is an evidence tool for the owner-decision gate. It computes an upper
bound that is deliberately generous: stored order permutations count as
distinct full signatures even when they describe the same objective set.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import importlib.util
import itertools
import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
PROFILE_PATH = ROOT / "data/campaign/content_generation_profiles_m33.json"
SUNNY_PATH = ROOT / "data/campaign/levels/sunny_cove.json"
TIKI_SEED_PATH = ROOT / "data/campaign/levels/tiki_island.json"
R04_EVIDENCE = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R04"
OUTPUT_DIR = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R04-R01"


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def _load_generator():
    path = ROOT / "tools/generate_m33_campaign_content.py"
    spec = importlib.util.spec_from_file_location("m33_r04_generator", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not import generator from {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _json_signature(orders: list[tuple[int, int]], vip_target: int | None) -> str:
    vip = {"enabled": False, "cocktail_level": 0, "quantity": 0}
    if vip_target is not None:
        vip = {"enabled": True, "cocktail_level": vip_target, "quantity": 1}
    return json.dumps(
        {
            "orders": [
                {"cocktail_level": level, "quantity": quantity}
                for level, quantity in orders
            ],
            "time_limit_sec": 0.0,
            "vip": vip,
        },
        separators=(",", ":"),
        sort_keys=True,
    )


def enumerate_recipe_space(profile: dict[str, Any]) -> dict[str, Any]:
    semantic_normals: set[tuple[tuple[int, int], ...]] = set()
    ordered_normals: set[tuple[tuple[int, int], ...]] = set()
    semantic_full: set[tuple[tuple[tuple[int, int], ...], int | None]] = set()
    ordered_full: set[str] = set()
    per_band: list[dict[str, Any]] = []

    ordinary_t_max = int(profile["design_contract"]["ordinary_normal_T_max"])
    for island_id, island in profile["islands"].items():
        for band in island["bands"]:
            if bool(band.get("prestige_capstone", False)):
                continue
            targets = sorted(
                {
                    int(target)
                    for target in band["target_levels"]
                    if int(target) >= 6
                    and (1 << (int(target) - 3)) <= ordinary_t_max
                }
            )
            band_semantic: set[tuple[tuple[int, int], ...]] = set()
            band_ordered: set[tuple[tuple[int, int], ...]] = set()
            band_full_semantic: set[tuple[tuple[tuple[int, int], ...], int | None]] = set()
            band_full_ordered: set[str] = set()
            required = {int(target) for target in band.get("required_target_levels", [])}
            for order_count in range(int(band["orders_min"]), int(band["orders_max"]) + 1):
                for target_set in itertools.combinations(targets, order_count):
                    if not required.issubset(target_set):
                        continue
                    for quantities in itertools.product((1, 2), repeat=order_count):
                        normal_t = sum(
                            (1 << (target - 3)) * quantity
                            for target, quantity in zip(target_set, quantities, strict=True)
                        )
                        if not int(band["min_normal_T"]) <= normal_t <= min(int(band["max_normal_T"]), ordinary_t_max):
                            continue
                        pairs = tuple(zip(target_set, quantities, strict=True))
                        canonical_pairs = tuple(sorted(pairs))
                        band_semantic.add(canonical_pairs)
                        vip_targets = sorted(
                            {
                                int(target)
                                for target in band.get("vip_target_levels", [])
                                if int(band.get("vip_percent", 0)) > 0 and int(target) > max(target_set)
                            }
                        )
                        vip_options: list[int | None] = [None, *vip_targets]
                        for permutation in itertools.permutations(pairs):
                            band_ordered.add(tuple(permutation))
                            for vip_target in vip_options:
                                band_full_ordered.add(_json_signature(list(permutation), vip_target))
                        for vip_target in vip_options:
                            band_full_semantic.add((canonical_pairs, vip_target))

            semantic_normals.update(band_semantic)
            ordered_normals.update(band_ordered)
            semantic_full.update(band_full_semantic)
            ordered_full.update(band_full_ordered)
            per_band.append(
                {
                    "island_id": island_id,
                    "tier": str(band["tier"]),
                    "eligible_normal_targets_after_L6_floor_and_T56": targets,
                    "max_semantic_normal_recipes": len(band_semantic),
                    "max_order_sensitive_normal_signatures": len(band_ordered),
                    "max_semantic_full_recipes_with_VIP": len(band_full_semantic),
                    "max_order_sensitive_full_signatures_with_VIP": len(band_full_ordered),
                }
            )

    return {
        "canonical_normal_recipe_sets_ignoring_display_order": len(semantic_normals),
        "normal_signatures_counting_order_array_positions": len(ordered_normals),
        "full_recipe_sets_including_optional_VIP_ignoring_display_order": len(semantic_full),
        "full_signatures_counting_order_array_positions_and_VIP": len(ordered_full),
        "per_band": per_band,
    }


def inspect_current_package(generator: Any) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    outputs_a, report_a = generator.generate()
    outputs_b, report_b = generator.generate()
    if outputs_a != outputs_b or report_a != report_b:
        raise AssertionError("same profile and seed did not regenerate byte-equivalent objects")

    all_generated = [
        (island_id, row)
        for island_id, root in outputs_a.items()
        for row in root["levels"]
        if not (island_id == "tiki_island" and int(row["level_id"]) <= 12)
    ]
    ordinary = [(island_id, row) for island_id, row in all_generated if not bool(row.get("prestige_capstone", False))]
    l5_levels: set[tuple[str, int]] = set()
    l5_target_rows = 0
    ordinary_over_t56: list[tuple[str, int, int]] = []
    signature_rows: dict[str, list[tuple[str, int, dict[str, Any]]]] = defaultdict(list)
    for island_id, row in all_generated:
        if bool(row.get("prestige_capstone", False)):
            continue
        if any(int(order["cocktail_level"]) == 5 for order in row["orders"]):
            l5_levels.add((island_id, int(row["level_id"])))
        l5_target_rows += sum(int(order["cocktail_level"]) == 5 for order in row["orders"])
        normal_t = generator._normal_t(row)
        if normal_t > 56:
            ordinary_over_t56.append((island_id, int(row["level_id"]), normal_t))
    for island_id, row in all_generated:
        signature_rows[generator._signature(row)].append((island_id, int(row["level_id"]), row))
    duplicate_groups = [rows for rows in signature_rows.values() if len(rows) > 1]
    duplicate_records = sum(len(rows) - 1 for rows in duplicate_groups)
    examples: list[dict[str, Any]] = []
    for signature, rows in sorted(signature_rows.items()):
        if len(rows) < 2:
            continue
        first = rows[0]
        for repeated in rows[1:]:
            island_id, level_id, recipe = repeated
            examples.append(
                {
                    "signature": signature,
                    "first_location": f"{first[0]}/L{first[1]}",
                    "duplicate_location": f"{island_id}/L{level_id}",
                    "repeat_group_size": len(rows),
                    "has_L5_normal_target": any(int(order["cocktail_level"]) == 5 for order in recipe["orders"]),
                }
            )

    report = {
        "current_content_version": str(report_a["content_version"]),
        "generator_version": str(report_a["generator_version"]),
        "batch_seed": int(report_a["seed"]),
        "deterministic_regeneration_matches": True,
        "generated_records": len(all_generated),
        "ordinary_generated_records": len(ordinary),
        "marked_capstones": sum(bool(row.get("prestige_capstone", False)) for _, row in all_generated),
        "ordinary_generated_records_with_at_least_one_L5": len(l5_levels),
        "ordinary_generated_L5_target_rows": l5_target_rows,
        "ordinary_generated_records_over_T56": len(ordinary_over_t56),
        "current_generated_unique_full_signatures": len(signature_rows),
        "current_generated_duplicate_groups": len(duplicate_groups),
        "current_generated_duplicate_records": duplicate_records,
        "source_hashes": {
            "sunny_cove_sha256": _sha256(SUNNY_PATH.read_bytes()),
            "m32_tiki_seed_sha256": _sha256(TIKI_SEED_PATH.read_bytes()),
        },
        "existing_36_recipe_examples": str((R04_EVIDENCE / "representative_level_examples.csv").relative_to(ROOT)).replace("\\", "/"),
        "cross_island_duplicate_examples_csv": "cross_island_duplicate_examples.csv",
    }
    return report, examples


def build_report() -> tuple[dict[str, Any], list[dict[str, Any]]]:
    profile = json.loads(PROFILE_PATH.read_text(encoding="utf-8"))
    generator = _load_generator()
    current, duplicates = inspect_current_package(generator)
    recipe_space = enumerate_recipe_space(profile)
    ordinary_required = 888 - 9
    maximum_full = int(recipe_space["full_signatures_counting_order_array_positions_and_VIP"])
    report = {
        "result": "BLOCKED_OWNER_DESIGN_DECISION_REQUIRED",
        "work_item": "BCM-M33-R04-R01",
        "scope_note": "No regenerated campaign package is published because the requested uniqueness and L6+/T56 design constraints are mutually infeasible.",
        "locked_constraints": {
            "newly_generated_records": 888,
            "ordinary_records": ordinary_required,
            "marked_level_100_capstones": 9,
            "ordinary_normal_T_max": int(profile["design_contract"]["ordinary_normal_T_max"]),
            "minimum_ordinary_normal_target_level": 6,
            "normal_order_count": "2..3 distinct target levels",
            "quantity_per_target": "1..2",
            "optional_VIP": "only listed higher-level targets; quantity 1",
        },
        "shot_costs": {f"L{level}": 1 << (level - 3) for level in range(6, 13)},
        "recipe_space_upper_bound": recipe_space,
        "infeasibility": {
            "ordinary_records_requiring_unique_full_signatures": ordinary_required,
            "maximum_order_sensitive_full_signatures_even_counting_every_VIP_and_order_permutation": maximum_full,
            "unique_signature_shortfall": ordinary_required - maximum_full,
            "meaningful_normal_recipe_ceiling_counting_order_array_permutations_but_not_VIP": int(recipe_space["normal_signatures_counting_order_array_positions"]),
            "meaningful_normal_recipe_ceiling_ignoring_order_array_permutations": int(recipe_space["canonical_normal_recipe_sets_ignoring_display_order"]),
            "proof": "L9 costs 64 T, exceeding the ordinary T56 ceiling; L6-L8 are the only possible normal targets. Exhaustive enumeration of all distinct 2- and 3-target combinations, quantities 1 or 2, profile bands, and every permitted optional VIP yields the stated strict upper bound, already counting order-array permutations as distinct.",
        },
        "current_package_audit": current,
        "owner_decision_options": [
            "Keep L6+ and T56, then explicitly permit campaign-wide normal-recipe repeats and define an approved variety/pacing measure that does not count VIP-only changes as distinct gameplay.",
            "Raise the ordinary T ceiling enough to admit additional mandatory target levels (L9 paired with minimum L6 requires at least T72), then approve the resulting difficulty and measured-playtest risk before regeneration.",
            "Change the recipe schema/design space (for example, goal-count or repeat-target rules) and approve its gameplay consequences before regeneration.",
            "Reduce or rescope the number of newly generated ordinary records.",
        ],
        "not_performed": [
            "No campaign regeneration or content-version/manifest change.",
            "No physics sweeps or mass gameplay simulations.",
            "No owner visual review or human playtest.",
        ],
    }
    return report, duplicates


def write_evidence(report: dict[str, Any], duplicates: list[dict[str, Any]]) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / "design_space_and_baseline_audit.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n"
    )
    with (OUTPUT_DIR / "cross_island_duplicate_examples.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(
            stream,
            fieldnames=["signature", "first_location", "duplicate_location", "repeat_group_size", "has_L5_normal_target"],
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(duplicates)
    readme = """# BCM-M33 R04-R01 bounded design-space evidence

`design_space_and_baseline_audit.json` records the deterministic recipe-space upper bound and the current R04 package audit. `cross_island_duplicate_examples.csv` enumerates each repeated generated full signature and its locations. The existing 36 baseline recipe examples remain in `../M33-R04/representative_level_examples.csv`.

The upper bound already counts different order-array permutations and every listed optional VIP target as different full recipes. Even under that generous counting rule, the current L6+/T56 rules yield far fewer than the 879 ordinary records that R01 requires to be campaign-wide unique. No regenerated content is supplied pending an owner decision on the design space.
"""
    (OUTPUT_DIR / "README.md").write_text(readme, encoding="utf-8", newline="\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="write bounded design-space evidence under the R01 evidence folder")
    args = parser.parse_args()
    report, duplicates = build_report()
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if args.write:
        write_evidence(report, duplicates)
        print(f"evidence_written={OUTPUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
