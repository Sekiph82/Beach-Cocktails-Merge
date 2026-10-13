#!/usr/bin/env python3
"""Create deterministic before/after and owner sample evidence for BCM-M33 R05."""

from __future__ import annotations

import csv
import hashlib
import json
import statistics
import subprocess
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R05"
BASE = "c62be113dd93adf5fe7c9e96627036cf74411286"
ISLANDS = [
    "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach",
    "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]


def old_rows(island: str) -> list[dict]:
    name = "tiki_island_full.json" if island == "tiki_island" else f"{island}.json"
    raw = subprocess.check_output(["git", "show", f"{BASE}:data/campaign/levels/{name}"], cwd=ROOT)
    rows = json.loads(raw)["levels"]
    return rows[12:] if island == "tiki_island" else rows


def new_rows(island: str) -> list[dict]:
    path = ROOT / "data/campaign/levels" / ("tiki_island_full.json" if island == "tiki_island" else f"{island}.json")
    rows = json.loads(path.read_text(encoding="utf-8"))["levels"]
    return rows[12:] if island == "tiki_island" else rows


def normal_t(row: dict) -> int:
    return sum((1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"]) for order in row["orders"])


def normal_signature(row: dict) -> str:
    return json.dumps(row["orders"], sort_keys=True, separators=(",", ":"))


def full_signature(row: dict) -> str:
    return json.dumps({"orders": row["orders"], "vip": row.get("vip"), "time_limit_sec": row.get("time_limit_sec", 0)}, sort_keys=True, separators=(",", ":"))


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def summarize(rows: list[dict]) -> dict:
    costs = [normal_t(row) for row in rows]
    normal_counts = Counter(normal_signature(row) for row in rows)
    full_counts = Counter(full_signature(row) for row in rows)
    return {
        "records": len(rows),
        "normal_T_mean": round(statistics.mean(costs), 2),
        "normal_T_median": statistics.median(costs),
        "normal_T_p90": sorted(costs)[int(len(costs) * 0.9) - 1],
        "normal_T_max": max(costs),
        "normal_T_at_most_56_count": sum(cost <= 56 for row, cost in zip(rows, costs) if not row.get("prestige_capstone", False)),
        "ordinary_records": sum(not row.get("prestige_capstone", False) for row in rows),
        "ordinary_L6_plus_records": sum(not row.get("prestige_capstone", False) and all(int(order["cocktail_level"]) >= 6 for order in row["orders"]) for row in rows),
        "unique_normal_objectives": len(normal_counts),
        "within_island_normal_repeat_records": len(rows) - len(normal_counts),
        "max_normal_objective_repetitions": max(normal_counts.values()),
        "unique_full_recipes": len(full_counts),
        "within_island_full_recipe_repeat_records": len(rows) - len(full_counts),
        "adjacent_full_recipe_repeats": sum(full_signature(a) == full_signature(b) for a, b in zip(rows, rows[1:])),
        "starting_drink_levels": sum(len(row.get("initial_tabletop_drinks", [])) for row in rows),
        "empty_start_records": sum(not row.get("initial_tabletop_drinks", []) for row in rows),
    }


def main() -> None:
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    rows_out: list[dict] = []
    all_new: list[dict] = []
    for island in ISLANDS:
        before, after = old_rows(island), new_rows(island)
        rows_out.append({"island_id": island, "before": summarize(before), "after": summarize(after)})
        all_new.extend(after)

    csv_path = EVIDENCE / "nine_island_before_after_difficulty_and_repetition.csv"
    fields = ["island_id", "period", *summarize(new_rows(ISLANDS[0])).keys()]
    with csv_path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for row in rows_out:
            for period in ("before", "after"):
                writer.writerow({"island_id": row["island_id"], "period": period, **row[period]})

    sample_path = EVIDENCE / "sample_36_recipes_and_tabletop_layouts.csv"
    with sample_path.open("w", newline="", encoding="utf-8") as stream:
        fields = ["island_id", "local_level_id", "global_level_id", "type", "normal_orders", "normal_T", "vip_optional", "move_limit_4T_unchanged", "initial_tabletop_drinks_version", "initial_tabletop_drinks"]
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for island in ISLANDS:
            rows = new_rows(island)
            ids = [13, 50, 75, 100] if island == "tiki_island" else [1, 50, 75, 100]
            for level_id in ids:
                row = next(item for item in rows if int(item["level_id"]) == level_id)
                writer.writerow({
                    "island_id": island,
                    "local_level_id": level_id,
                    "global_level_id": row["global_level_id"],
                    "type": row["level_type"],
                    "normal_orders": ";".join(f"L{int(o['cocktail_level'])}x{int(o['quantity'])}" for o in row["orders"]),
                    "normal_T": normal_t(row),
                    "vip_optional": "NONE" if not row.get("vip") else f"L{row['vip']['cocktail_level']}x{row['vip']['quantity']}",
                    "move_limit_4T_unchanged": row["move_limit"],
                    "initial_tabletop_drinks_version": row.get("initial_tabletop_drinks_version", "legacy-v0"),
                    "initial_tabletop_drinks": json.dumps(row.get("initial_tabletop_drinks", []), separators=(",", ":")),
                })

    normal_counts = Counter(normal_signature(row) for row in all_new)
    full_counts = Counter(full_signature(row) for row in all_new)
    normal_islands: dict[str, set[str]] = {}
    full_islands: dict[str, set[str]] = {}
    for row in all_new:
        normal_islands.setdefault(normal_signature(row), set()).add(str(row["island_id"]))
        full_islands.setdefault(full_signature(row), set()).add(str(row["island_id"]))
    layouts = [json.dumps({"recipe": full_signature(row), "initial_tabletop_drinks": row.get("initial_tabletop_drinks", [])}, sort_keys=True, separators=(",", ":")) for row in all_new]
    repeat_report = {
        "baseline_commit": BASE,
        "generated_level_count": len(all_new),
        "within_island_normal_repeat_records": sum(int(row["after"]["within_island_normal_repeat_records"]) for row in rows_out),
        "within_island_full_recipe_repeat_records": sum(int(row["after"]["within_island_full_recipe_repeat_records"]) for row in rows_out),
        "global_normal_duplicate_records_including_within_island": len(all_new) - len(normal_counts),
        "global_full_recipe_duplicate_records_including_within_island": len(all_new) - len(full_counts),
        "cross_island_normal_repeat_records": sum(len(islands) - 1 for islands in normal_islands.values() if len(islands) > 1),
        "cross_island_full_recipe_repeat_records": sum(len(islands) - 1 for islands in full_islands.values() if len(islands) > 1),
        "adjacent_full_recipe_repeats_in_global_order": sum(full_signature(a) == full_signature(b) for a, b in zip(all_new, all_new[1:])),
        "adjacent_recipe_and_tabletop_layout_repeats_in_global_order": sum(a == b for a, b in zip(layouts, layouts[1:])),
        "same_full_recipe_pairs_within_previous_5_global_records": sum(full_signature(all_new[i]) == full_signature(all_new[j]) for i in range(len(all_new)) for j in range(max(0, i - 5), i)),
        "same_full_recipe_pairs_within_previous_10_global_records": sum(full_signature(all_new[i]) == full_signature(all_new[j]) for i in range(len(all_new)) for j in range(max(0, i - 10), i)),
        "same_recipe_and_tabletop_layout_pairs_within_previous_5_global_records": sum(layouts[i] == layouts[j] for i in range(len(layouts)) for j in range(max(0, i - 5), i)),
        "same_recipe_and_tabletop_layout_pairs_within_previous_10_global_records": sum(layouts[i] == layouts[j] for i in range(len(layouts)) for j in range(max(0, i - 10), i)),
        "nine_island_metrics": rows_out,
        "source_sha256": {
            "generator": sha256(ROOT / "tools/generate_m33_campaign_content.py"),
            "content_validator": sha256(ROOT / "tools/validate_m33_campaign_content.py"),
            "r05_content_reporter": sha256(ROOT / "tools/report_m33_r05_content.py"),
            "profile": sha256(ROOT / "data/campaign/content_generation_profiles_m33.json"),
            "manifest": sha256(ROOT / "data/campaign/content_manifest_m33.json"),
            "level_database": sha256(ROOT / "scripts/campaign/level_database.gd"),
            "game_manager": sha256(ROOT / "scripts/game_manager.gd"),
            "campaign_manifest_runtime": sha256(ROOT / "scripts/campaign/campaign_content_manifest.gd"),
            "drink_runtime": sha256(ROOT / "scripts/drink.gd"),
            "campaign_content_probe": sha256(ROOT / "tests/m33_campaign_content_probe.gd"),
            "tabletop_runtime_probe": sha256(ROOT / "tests/m33_r05_tabletop_probe.gd"),
            "capture_probe": sha256(ROOT / "tests/m33_r05_capture_tabletops.gd"),
            **{island: sha256(ROOT / "data/campaign/levels" / ("tiki_island_full.json" if island == "tiki_island" else f"{island}.json")) for island in ISLANDS},
            **{
                f"surface_{island['id']}": sha256(ROOT / str(island["theme"]["gameplay_surface"]).removeprefix("res://"))
                for island in json.loads((ROOT / "data/campaign/islands.json").read_text(encoding="utf-8"))["islands"]
            },
        },
    }
    (EVIDENCE / "controlled_repetition_and_hash_report.json").write_text(json.dumps(repeat_report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps({"result": "PASS", "levels": len(all_new), "sample_rows": 36, "report": str(EVIDENCE)}, indent=2))


if __name__ == "__main__":
    main()
