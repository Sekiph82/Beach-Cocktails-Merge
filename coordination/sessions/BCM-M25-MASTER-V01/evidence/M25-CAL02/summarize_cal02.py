#!/usr/bin/env python3
"""Summarize checkpointed CAL02 trials without dropping per-trial evidence."""
from __future__ import annotations

import csv
import json
import math
import statistics
import sys
from collections import defaultdict
from pathlib import Path


def wilson(successes: int, total: int, z: float = 1.959963984540054) -> tuple[float, float]:
    if total <= 0:
        return (math.nan, math.nan)
    p = successes / total
    denom = 1.0 + z * z / total
    center = (p + z * z / (2.0 * total)) / denom
    margin = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / denom
    return (max(0.0, center - margin), min(1.0, center + margin))


def quantile(values: list[int], q: float) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    pos = (len(ordered) - 1) * q
    lo, hi = math.floor(pos), math.ceil(pos)
    if lo == hi:
        return float(ordered[lo])
    return ordered[lo] * (hi - pos) + ordered[hi] * (pos - lo)


def main() -> int:
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "runs"
    raw = out / "trials.jsonl"
    if not raw.exists():
        raise SystemExit(f"missing trial checkpoint: {raw}")
    trials: list[dict] = []
    seen: set[tuple[str, str, int]] = set()
    duplicates: list[tuple[str, str, int]] = []
    with raw.open(encoding="utf-8") as src:
        for line_number, line in enumerate(src, 1):
            if not line.strip():
                continue
            row = json.loads(line)
            key = (row["class_id"], row["policy"], int(row["seed"]))
            if key in seen:
                duplicates.append(key)
            seen.add(key)
            row["_line"] = line_number
            trials.append(row)

    groups: dict[tuple[str, bool], list[dict]] = defaultdict(list)
    class_groups: dict[tuple[str, str], list[dict]] = defaultdict(list)
    vip_trials: list[dict] = []
    for row in trials:
        groups[(row["policy"], bool(row["vip_enabled"]))].append(row)
        class_groups[(row["class_id"], row["policy"])].append(row)
        if row["vip_enabled"]:
            vip_trials.append(row)

    summary_rows = []
    for (policy, vip_enabled), rows in sorted(groups.items()):
        valid = [r for r in rows if r["outcome"] != "harness_abort"]
        wins = [r for r in valid if r["outcome"] == "completed" and r["normal_objective_complete"]]
        lo, hi = wilson(len(wins), len(valid))
        winning_moves = [int(r["moves"]) for r in wins]
        summary_rows.append({
            "policy": policy,
            "vip_enabled": vip_enabled,
            "trials": len(rows),
            "valid_trials": len(valid),
            "wins": len(wins),
            "win_rate": len(wins) / len(valid) if valid else None,
            "wilson95_low": lo if valid else None,
            "wilson95_high": hi if valid else None,
            "completed_moves_min": min(winning_moves) if winning_moves else None,
            "completed_moves_p10": quantile(winning_moves, .10),
            "completed_moves_median": statistics.median(winning_moves) if winning_moves else None,
            "completed_moves_p90": quantile(winning_moves, .90),
            "completed_moves_max": max(winning_moves) if winning_moves else None,
            "total_wall_sec": sum(int(r["wall_ms"]) for r in rows) / 1000.0,
            "median_wall_sec": statistics.median(int(r["wall_ms"]) for r in rows) / 1000.0 if rows else None,
        })

    class_rows = []
    class_gaps = []
    for (class_id, policy), rows in sorted(class_groups.items()):
        valid = [r for r in rows if r["outcome"] != "harness_abort"]
        wins = [r for r in valid if r["outcome"] == "completed" and r["normal_objective_complete"]]
        lo, hi = wilson(len(wins), len(valid))
        moves = [int(r["moves"]) for r in wins]
        seeds = sorted({int(r["seed"]) for r in rows})
        row = {
            "class_id": class_id,
            "policy": policy,
            "representative_level_id": rows[0]["representative_level_id"],
            "vip_enabled": bool(rows[0]["vip_enabled"]),
            "trial_count": len(rows),
            "valid_count": len(valid),
            "win_count": len(wins),
            "win_rate": len(wins) / len(valid) if valid else None,
            "wilson95_low": lo if valid else None,
            "wilson95_high": hi if valid else None,
            "completed_moves": ";".join(str(v) for v in sorted(moves)),
            "completed_moves_median": statistics.median(moves) if moves else None,
            "seeds": ";".join(map(str, seeds)),
            "outcomes": ";".join(f'{r["seed"]}:{r["outcome"]}/{r["moves"]}' for r in rows),
            "median_wall_sec": statistics.median(int(r["wall_ms"]) for r in rows) / 1000.0,
        }
        class_rows.append(row)
        if len(wins) == 0:
            class_gaps.append({"class_id": class_id, "policy": policy, "representative_level_id": row["representative_level_id"], "trials": len(rows), "vip_enabled": row["vip_enabled"]})

    vip_valid = [r for r in vip_trials if r["outcome"] != "harness_abort"]
    vip_wins = [r for r in vip_valid if r["outcome"] == "completed" and r["normal_objective_complete"]]
    vip_completed = [r for r in vip_wins if r["vip_complete"]]
    report = {
        "schema_version": 1,
        "source": str(raw),
        "run_mode": "fixed_fps_60_exploratory_only",
        "accepted_for_move_threshold_calibration": False,
        "trial_count": len(trials),
        "unique_trial_keys": len(seen),
        "duplicate_keys": [list(k) for k in duplicates],
        "class_count_seen": len({r["class_id"] for r in trials}),
        "class_coverage_expected": 45,
        "classes_with_trials": sorted({r["class_id"] for r in trials}),
        "summary_by_policy_and_vip": summary_rows,
        "vip_only": {
            "trials": len(vip_trials), "valid_trials": len(vip_valid), "normal_wins": len(vip_wins),
            "normal_win_wilson95": list(wilson(len(vip_wins), len(vip_valid))) if vip_valid else None,
            "wins_with_vip_complete": len(vip_completed),
            "vip_optional_basic_completion_observed": any(r["normal_objective_complete"] and not r["vip_complete"] for r in vip_wins),
        },
        "class_policy_rows": class_rows,
        "class_policy_zero_win_gaps": class_gaps,
        "interpretation": "Per-class samples are discovery evidence, not sufficient move-cap or star-cutoff acceptance. Wilson intervals describe this solver mix only; no human skill or player-population claim is inferred.",
    }

    with (out / "class_policy_summary.csv").open("w", newline="", encoding="utf-8") as dst:
        writer = csv.DictWriter(dst, fieldnames=list(class_rows[0].keys()) if class_rows else ["class_id"])
        writer.writeheader()
        writer.writerows(class_rows)
    with (out / "calibration_summary.json").open("w", encoding="utf-8") as dst:
        json.dump(report, dst, indent=2)
        dst.write("\n")
    print(json.dumps({"trial_count": len(trials), "class_count_seen": report["class_count_seen"], "duplicate_keys": report["duplicate_keys"], "vip_only": report["vip_only"], "summary_by_policy_and_vip": summary_rows}, indent=2))
    return 1 if duplicates else 0


if __name__ == "__main__":
    raise SystemExit(main())
