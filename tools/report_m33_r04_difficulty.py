#!/usr/bin/env python3
"""Build comparative, explicitly non-certifying M33 R04 difficulty evidence."""

from __future__ import annotations

import csv
import json
import math
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parents[1]
SESSION = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01"
BEFORE = SESSION / "evidence/M33-R03/all_1000_levels.csv"
OUT = SESSION / "evidence/M33-R04"
ISLANDS = [
    "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach",
    "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]


def normal_t(row: dict) -> int:
    return sum((1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"]) for order in row["orders"])


def total_t(row: dict) -> int:
    total = normal_t(row)
    vip = row.get("vip")
    if isinstance(vip, dict) and vip.get("enabled", True):
        total += (1 << (int(vip["cocktail_level"]) - 3)) * int(vip["quantity"])
    return total


def percentile90(values: list[int]) -> int:
    ordered = sorted(values)
    return ordered[math.ceil(len(ordered) * 0.9) - 1]


def read_before() -> dict[str, list[dict]]:
    grouped: dict[str, list[dict]] = {island: [] for island in ["sunny_cove", *ISLANDS]}
    with BEFORE.open(encoding="utf-8", newline="") as source:
        for row in csv.DictReader(source):
            if row["island_id"] in grouped:
                grouped[row["island_id"]].append(row)
    return grouped


def read_after() -> dict[str, list[dict]]:
    grouped: dict[str, list[dict]] = {}
    for island in ISLANDS:
        path = ROOT / "data/campaign/levels" / ("tiki_island_full.json" if island == "tiki_island" else f"{island}.json")
        grouped[island] = json.loads(path.read_text(encoding="utf-8"))["levels"]
    return grouped


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    before, after = read_before(), read_after()
    summary = []
    examples = []
    for island in ISLANDS:
        examples_for_island = [13 if island == "tiki_island" else 1, 50, 90, 100]
        prior = [row for row in before[island] if island != "tiki_island" or int(row["local_level_id"]) >= 13]
        current = [row for row in after[island] if island != "tiki_island" or int(row["level_id"]) >= 13]
        prior_t = [int(row["normal_T"]) for row in prior]
        current_t = [normal_t(row) for row in current]
        prior_vips = sum(row["vip"] != "NONE" for row in prior)
        current_vips = sum(isinstance(row.get("vip"), dict) and row["vip"].get("enabled", True) for row in current)
        prior_dupes = len(prior) - len({(row["normal_orders"], row["vip"]) for row in prior})
        current_dupes = len(current) - len({(json.dumps(row["orders"], sort_keys=True), json.dumps(row.get("vip"), sort_keys=True)) for row in current})
        summary.append({
            "island_id": island,
            "generated_rows": len(current),
            "before_normal_T_median": int(median(prior_t)),
            "after_normal_T_median": int(median(current_t)),
            "before_normal_T_p90": percentile90(prior_t),
            "after_normal_T_p90": percentile90(current_t),
            "before_normal_T_max": max(prior_t),
            "after_normal_T_max": max(current_t),
            "before_rows_over_T56": sum(t > 56 for t in prior_t),
            "after_ordinary_rows_over_T56": sum(normal_t(row) > 56 for row in current if not row.get("prestige_capstone", False)),
            "before_vip_rows": prior_vips,
            "after_vip_rows_optional": current_vips,
            "before_full_recipe_repeat_rows": prior_dupes,
            "after_intra_island_full_recipe_repeat_rows": current_dupes,
            "after_generated_normal_T_step_max": max(abs(normal_t(b) - normal_t(a)) for a, b in zip(current, current[1:])),
            "after_generated_normal_T56_or_less": sum(t <= 56 for t in current_t),
            "after_capstone_normal_T": normal_t(after[island][-1]),
        })
        for level in examples_for_island:
            row = after[island][level - 1]
            vip = row.get("vip") if isinstance(row.get("vip"), dict) else None
            examples.append({
                "island_id": island,
                "local_level_id": level,
                "global_level_id": row["global_level_id"],
                "type": row["level_type"],
                "normal_orders": ";".join(f"L{o['cocktail_level']}x{o['quantity']}" for o in row["orders"]),
                "normal_T": normal_t(row),
                "vip_optional": f"L{vip['cocktail_level']}x{vip['quantity']}" if vip and vip.get("enabled", True) else "NONE",
                "inclusive_total_T": total_t(row),
                "move_limit_4T_unchanged": row["move_limit"],
                "stars_thresholds_unchanged": json.dumps(row["score_star_thresholds"], sort_keys=True),
            })

    with (OUT / "before_after_island_metrics.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(summary[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(summary)
    with (OUT / "representative_level_examples.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(examples[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(examples)

    total_prior = [int(row["normal_T"]) for island in ISLANDS for row in before[island] if island != "tiki_island" or int(row["local_level_id"]) >= 13]
    total_after = [normal_t(row) for island in ISLANDS for row in after[island] if island != "tiki_island" or int(row["level_id"]) >= 13]
    duration = lambda t, sec: round((12 * t / 7) * sec / 60, 2)
    lines = [
        "# BCM-M33 R04 difficulty evidence",
        "",
        "This report compares the R03 analytic baseline with the deterministic R04 candidate data for the 888 generated rows only. Sunny Cove 1–100 and Tiki L1–L12 are excluded from the before/after population. Static legality and launch-count estimates are not physics or human-playability certification.",
        "",
        "## Summary",
        "",
        f"- Generated rows: {len(total_after)}; ordinary rows with normal T ≤56: {sum(t <= 56 for t in total_after) - 9}/{len(total_after)-9}; nine marked level-100 capstones exceed the ordinary ceiling.",
        f"- Normal T median/p90/max: {int(median(total_prior))}/{percentile90(total_prior)}/{max(total_prior)} before; {int(median(total_after))}/{percentile90(total_after)}/{max(total_after)} after (capstones included).",
        f"- Planning-only expected normal launches use 12T/7: median duration at 1.5–3 seconds/launch is {duration(int(median(total_after)),1.5)}–{duration(int(median(total_after)),3)} minutes after. This estimate omits human variance, physics failures, merges, interruptions, and retries.",
        "- The 2–5 minute typical and ≤8 minute p90 human targets remain unmeasured; schedule the playtest below before claiming fairness.",
        "- `move_limit = 4 × inclusive total T` and all three score-star thresholds remain unchanged; optional VIP T remains in the denominator. See examples for its optional budget impact.",
        "- Full recipes are unique within each generated island. Global full-recipe repeats are allowed and explicitly counted in `generation_report.json`; cross-island matches are not treated as intra-island repetition.",
        "",
        "## Per-island comparison",
        "",
        "See `before_after_island_metrics.csv` for medians, p90, maxima, VIP counts, duplicate counts, step maxima, ordinary ceilings, and capstone T by island. `representative_level_examples.csv` gives generated-entry (Tiki 13; other islands 1), middle (50), late ordinary (90), and capstone (100) examples for all nine islands.",
        "",
        "## Bounded human playtest proposal (not performed)",
        "",
        "After owner review of the candidate content, recruit 3 players and run three ordinary samples per island (generated-entry, local level 50, and local level 90): 81 level attempts maximum, one attempt per sample/player, no timer or coaching, record wall time, committed shots, wins/losses/retries, objective comprehension, frustration rating, and observed physics dead ends. Stop after 90 minutes per player or any reproducible softlock. Review the 27 sample-level p90 only as exploratory evidence; it is too small to establish population p90. Test the nine marked capstones separately as optional prestige content, one attempt per player per capstone, with no effect on ordinary completion estimates. No human sessions were run for this handoff.",
        "",
        "## Limits and open evidence",
        "",
        "The analytic conversion 12T/7 derives from the R03 planning model. It is a scenario estimate, not gameplay telemetry. Bounded deterministic physics probes cover a small fixed sample only; neither those probes nor this report certify all 888 recipes or human fairness. Preserve the disclosed 361 cross-island recipe repeats reported by the generator.",
    ]
    (OUT / "README.md").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    (OUT / "before_after_summary.json").write_text(json.dumps({"islands": summary, "generated_rows": len(total_after), "before_normal_T_median": int(median(total_prior)), "before_normal_T_p90": percentile90(total_prior), "after_normal_T_median": int(median(total_after)), "after_normal_T_p90": percentile90(total_after), "after_normal_T_max_including_capstones": max(total_after)}, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"M33_R04_REPORT=PASS rows={len(total_after)} island_metrics={len(summary)} examples={len(examples)}")


if __name__ == "__main__":
    main()
