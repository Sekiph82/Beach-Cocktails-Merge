#!/usr/bin/env python3
"""Build CAL02 coverage and physics-optimization qualification artifacts."""
from __future__ import annotations

import csv
import json
import math
from pathlib import Path

ROOT = Path(__file__).parent
REPO = ROOT.parents[4]
CLASS_REPORT = REPO / "coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.json"
CANONICAL_LEVELS = REPO / "data/campaign/levels/sunny_cove.json"


def read_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def get_one(path: Path) -> dict:
    rows = read_jsonl(path)
    if len(rows) != 1:
        raise ValueError(f"expected exactly one row in {path}, got {len(rows)}")
    return rows[0]


def selected(row: dict) -> dict:
    return {key: row.get(key) for key in (
        "class_id", "representative_level_id", "seed", "policy", "outcome",
        "terminal_reason", "moves", "merge_count", "normal_objective_complete", "vip_complete",
    )}


def compare(reference: dict, candidate: dict, label: str) -> dict:
    exact_fields = (
        "class_id", "representative_level_id", "seed", "policy", "outcome",
        "terminal_reason", "moves", "merge_count", "normal_objective_complete", "vip_complete",
    )
    differences = [field for field in exact_fields if reference.get(field) != candidate.get(field)]
    action_exact = reference.get("action_log") == candidate.get("action_log")
    elapsed_delta = abs(float(reference.get("simulated_elapsed_sec", 0.0)) - float(candidate.get("simulated_elapsed_sec", 0.0)))
    return {
        "comparison": label,
        "reference": selected(reference),
        "candidate": selected(candidate),
        "different_gameplay_fields": differences,
        "action_log_exact": action_exact,
        "simulated_elapsed_delta_sec": elapsed_delta,
        "elapsed_delta_at_most_one_60hz_tick": elapsed_delta <= (1.0 / 60.0 + 1e-9),
        "gameplay_equivalent": not differences and action_exact and elapsed_delta <= (1.0 / 60.0 + 1e-9),
        "reference_wall_ms": reference.get("wall_ms"),
        "candidate_wall_ms": candidate.get("wall_ms"),
    }


def main() -> int:
    classes = json.loads(CLASS_REPORT.read_text(encoding="utf-8"))["challenge_classes"]
    level_data = json.loads(CANONICAL_LEVELS.read_text(encoding="utf-8"))
    levels = level_data.get("levels", [])
    level_by_id = {int(row["level_id"]): row for row in levels}

    rt_paths = [
        ROOT / "evidence-runs-pilot/trials.jsonl",
        ROOT / "evidence-runs-realtime-weak2/trials.jsonl",
        ROOT / "evidence-runs-realtime-mergeaware/trials.jsonl",
        ROOT / "evidence-runs-realtime-c20/trials.jsonl",
    ]
    trusted = [row for path in rt_paths for row in read_jsonl(path)]
    with (ROOT / "trusted_realtime_trials.jsonl").open("w", encoding="utf-8", newline="\n") as dst:
        for row in trusted:
            dst.write(json.dumps(row, separators=(",", ":"), ensure_ascii=False) + "\n")

    exploratory = read_jsonl(ROOT / "runs/trials.jsonl")
    exploratory_counts: dict[str, int] = {}
    for row in exploratory:
        exploratory_counts[row["class_id"]] = exploratory_counts.get(row["class_id"], 0) + 1
    final_checkpoint = {
        "work_item": "BCM-M25-CAL02",
        "checkpoint_file": "trials.jsonl",
        "candidate_mode": "fixed_fps_60_exploratory_only",
        "physics_frames_per_action": 60,
        "engine_time_scale": 1.0,
        "requested_classes": 45,
        "requested_policies": ["WEAK_V02", "MERGE_AWARE_V01"],
        "requested_seeds": [31001, 31002],
        "checkpointed_trial_records": len(exploratory),
        "unique_trial_keys": len({(r["class_id"], r["policy"], int(r["seed"])) for r in exploratory}),
        "classes_with_candidate_records": len(exploratory_counts),
        "latest_invocation": "interrupted during C24 MERGE_AWARE_V01/31001; the incomplete trial was not appended and will rerun on resume",
        "calibration_disposition": "all candidate records excluded after high-order equivalence failure",
    }
    (ROOT / "runs/run_status_final.json").write_text(json.dumps(final_checkpoint, indent=2) + "\n", encoding="utf-8")
    trusted_counts: dict[str, list[dict]] = {}
    for row in trusted:
        trusted_counts.setdefault(row["class_id"], []).append(row)

    class_rows = []
    for cls in classes:
        representative = int(cls["representative"])
        current = level_by_id[representative]
        vip = current.get("vip") or {}
        valid_rows = trusted_counts.get(cls["class_id"], [])
        class_rows.append({
            "class_id": cls["class_id"],
            "representative_level_id": representative,
            "member_level_ids": ";".join(str(v) for v in cls.get("member_level_ids", [])),
            "order_contract": ";".join(f'L{int(o["cocktail_level"])}x{int(o["quantity"])}' for o in current.get("orders", [])),
            "vip_enabled": bool(vip.get("enabled", False)),
            "vip_contract": (f'L{vip.get("cocktail_level")}x{vip.get("quantity")}' if vip.get("enabled", False) else ""),
            "historical_M17_trials_timed": int(cls.get("trial_count", 0)),
            "trusted_realtime_trials": len(valid_rows),
            "trusted_realtime_outcomes": ";".join(f'{r["policy"]}/{r["seed"]}:{r["outcome"]}/{r["moves"]}' for r in valid_rows),
            "fixed60_exploratory_trials_excluded": exploratory_counts.get(cls["class_id"], 0),
            "disposition": "LIMITED_REALTIME_SAMPLE" if valid_rows else ("EXPLORATORY_ONLY_FIXED60" if exploratory_counts.get(cls["class_id"], 0) else "NO_FRESH_REALTIME_TRIAL"),
        })

    with (ROOT / "class_coverage_status.csv").open("w", newline="", encoding="utf-8") as dst:
        writer = csv.DictWriter(dst, fieldnames=list(class_rows[0].keys()))
        writer.writeheader()
        writer.writerows(class_rows)

    weak_a = get_one(ROOT / "evidence-runs-pilot/trials.jsonl")
    weak_b = get_one(ROOT / "evidence-runs-realtime-weak2/trials.jsonl")
    merge_a = get_one(ROOT / "evidence-runs-realtime-mergeaware/trials.jsonl")
    weak_a_fast = get_one(ROOT / "evidence-runs-fixed60/trials.jsonl")
    weak_b_fast = get_one(ROOT / "evidence-runs-fixed60-weak2/trials.jsonl")
    merge_a_fast = get_one(ROOT / "evidence-runs-fixed60-mergeaware/trials.jsonl")
    c20_rt = get_one(ROOT / "evidence-runs-realtime-c20/trials.jsonl")
    c20_fast = next(row for row in exploratory if row["class_id"] == "C20" and row["seed"] == 31001 and row["policy"] == "MERGE_AWARE_V01")
    c23_60 = next(row for row in exploratory if row["class_id"] == "C23" and row["seed"] == 31001 and row["policy"] == "MERGE_AWARE_V01")
    c23_240 = get_one(ROOT / "evidence-runs-fixed240-c23/trials.jsonl")
    equivalence = [
        compare(weak_a, weak_a_fast, "C01 weak seed31001 realtime vs fixed60"),
        compare(weak_b, weak_b_fast, "C01 weak seed31002 realtime vs fixed60"),
        compare(merge_a, merge_a_fast, "C01 merge-aware seed31001 realtime vs fixed60"),
        compare(c20_rt, c20_fast, "C20 merge-aware seed31001 realtime vs fixed60"),
        compare(c23_60, c23_240, "C23 merge-aware seed31001 fixed60 vs fixed240"),
    ]
    qualification = {
        "physics_authority": "unchanged task-local copy drives production GameManager.spawn_drink, Drink.launch_up, collision/merge code, and Godot physics with 60 physics frames per action and Engine.time_scale=1.0",
        "fixed60_qualification": "REJECTED_FOR_CALIBRATION_USE",
        "fixed240_qualification": "REJECTED_FOR_CALIBRATION_USE",
        "equivalence_rule": "same policy/seed/class, identical gameplay outcome and action log; simulated duration may differ by no more than one 1/60-second settling tick",
        "comparisons": equivalence,
        "reason": "C20 fixed60 changes the same-seed route from 78 to 101 moves and changes the action log; C23 fixed240 changes the same-seed route from 120 to 73 moves. Those outcomes disqualify both acceleration modes for calibration, despite low-level C01 matches.",
    }
    (ROOT / "physics_optimization_qualification.json").write_text(json.dumps(qualification, indent=2) + "\n", encoding="utf-8")
    (ROOT / "fixed60_equivalence.json").write_text(json.dumps(qualification, indent=2) + "\n", encoding="utf-8")

    valid_class_ids = sorted(trusted_counts)
    report = {
        "work_item": "BCM-M25-CAL02",
        "canonical_order_class_count": len(classes),
        "current_canonical_level_count": len(levels),
        "trusted_realtime_trial_count": len(trusted),
        "trusted_realtime_class_coverage": len(valid_class_ids),
        "trusted_realtime_class_ids": valid_class_ids,
        "fixed60_exploratory_trial_count_excluded": len(exploratory),
        "fixed60_exploratory_class_coverage_excluded": len(exploratory_counts),
        "trusted_vip_enabled_representative_trials": sum(1 for row in trusted if row["vip_enabled"]),
        "historical_M17_trials_are_timed_and_not_current_no_timer_distribution": True,
        "move_limit_or_star_cutoff_enabled": False,
        "product_files_changed": False,
        "task_tracker_changed": False,
        "coverage_csv": "class_coverage_status.csv",
        "raw_realtime_trials": "trusted_realtime_trials.jsonl",
        "excluded_candidate_runs": "runs/trials.jsonl",
        "physics_qualification": "physics_optimization_qualification.json",
        "decision": "OWNER_CALIBRATION_REQUIRED",
        "decision_reason": "Only two of 45 classes have fresh time-scale-1.0 real-time samples, with four total trials and no valid VIP-enabled class sample. Fixed-FPS candidate runs are excluded after class-dependent same-seed divergence. The current sample cannot establish class-level win distributions, move caps, or 2/3-star thresholds.",
    }
    (ROOT / "cal02_status.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
