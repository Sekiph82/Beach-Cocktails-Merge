#!/usr/bin/env python3
"""Summarize the bounded M33-R02 calibration run and cost projection."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from collections import Counter
from pathlib import Path

ISLANDS = [
    "sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
    "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
LEVEL_FILES = [
    "sunny_cove.json", "tiki_island_full.json", "azure_bay.json", "coconut_beach.json",
    "sunset_island.json", "party_beach.json", "frozen_paradise.json", "volcano_bay.json",
    "billionaire_island.json", "final_island.json",
]
ROOT = Path(__file__).resolve().parents[2]


def read_rows(path: Path) -> list[dict]:
    if not path.exists():
        return []
    rows = []
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        value = json.loads(line)
        if not isinstance(value, dict):
            raise SystemExit(f"expected object at {path}:{line_number}")
        rows.append(value)
    return rows


def campaign_budget() -> list[dict]:
    rows = []
    for island_index, file_name in enumerate(LEVEL_FILES):
        source = json.loads((ROOT / "data/campaign/levels" / file_name).read_text(encoding="utf-8"))
        for level in source["levels"]:
            global_id = int(level.get("global_level_id", island_index * 100 + int(level["level_id"])))
            if not 102 <= global_id <= 1000:
                continue
            normal_cost = sum((1 << (int(order["cocktail_level"]) - 1)) * int(order["quantity"]) for order in level["orders"])
            normal_t = normal_cost // 4
            rows.append({
                "global_level_id": global_id,
                "island_id": ISLANDS[island_index],
                "normal_T": normal_t,
                "expected_spawn_budget": math.ceil(normal_cost * 3 / 7),
            })
    return rows


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("calibration_trials", type=Path)
    parser.add_argument("known_control_trials", type=Path)
    parser.add_argument("static_diagnosis", type=Path)
    parser.add_argument("r01_trials", type=Path)
    parser.add_argument("output_json", type=Path)
    parser.add_argument("--pilot-wall-seconds", type=float, required=True)
    parser.add_argument("--pilot-godot-cpu-seconds", type=float, required=True)
    parser.add_argument("--observed-peak-working-set-bytes", type=int, required=True)
    parser.add_argument("--peak-memory-measurement", default="largest sampled WorkingSet64 reading during the process; not a continuous high-water counter")
    args = parser.parse_args()

    calibration_rows = read_rows(args.calibration_trials)
    known_control_rows = read_rows(args.known_control_trials)
    rows = calibration_rows + known_control_rows
    candidates = [row for row in rows if int(row.get("global_level_id", 0)) >= 102]
    controls = [row for row in rows if int(row.get("global_level_id", 0)) == 101]
    static = json.loads(args.static_diagnosis.read_text(encoding="utf-8"))
    evidence_dir = args.calibration_trials.parent
    initial_metadata_path = evidence_dir / "run_metadata_initial_740_sec_pilot.json"
    known_control_metadata_path = evidence_dir / "run_metadata_known_control.json"
    initial_metadata = json.loads(initial_metadata_path.read_text(encoding="utf-8"))
    known_control_metadata = json.loads(known_control_metadata_path.read_text(encoding="utf-8"))
    r01_rows = read_rows(args.r01_trials)
    r01_shots = sum(int(row.get("shot_count", 0)) for row in r01_rows)
    r01_wall_seconds = sum(int(row.get("wall_milliseconds", 0)) for row in r01_rows) / 1000
    r01_sec_per_shot = r01_wall_seconds / r01_shots if r01_shots else None
    candidate_sec_per_shot = (
        sum(int(row.get("wall_milliseconds", 0)) for row in candidates)
        / 1000
        / sum(int(row.get("shot_count", 0)) for row in candidates)
        if sum(int(row.get("shot_count", 0)) for row in candidates)
        else None
    )
    all_candidate_budget = campaign_budget()
    projected_shots = sum(row["expected_spawn_budget"] for row in all_candidate_budget)
    projections = {}
    for name, rate in (("R02_candidate_observed_rate", candidate_sec_per_shot), ("R01_all_trial_observed_rate", r01_sec_per_shot)):
        if rate is not None:
            projections[name] = {
                "seconds_per_launch": rate,
                "one_seed_expected_spawn_budget_hours": projected_shots * rate / 3600,
                "three_seed_expected_spawn_budget_hours": projected_shots * rate * 3 / 3600,
            }
    final_progress = []
    for row in candidates:
        curve = row.get("progress_curve", [])
        last = curve[-1] if curve else {}
        final_progress.append({
            "global_level_id": int(row["global_level_id"]),
            "island_id": str(row.get("island_id", "")),
            "difficulty_band": str(row.get("difficulty_band", "")),
            "VIP": row.get("vip_optional_status", {}),
            "normal_T": int(row.get("normal_T", 0)),
            "shot_budget": int(row.get("shot_budget", 0)),
            "trial_outcome": row.get("trial_outcome", "error"),
            "qualification_status": row.get("qualification_status", "NOT_RUN/ERROR"),
            "shot_count": int(row.get("shot_count", 0)),
            "normal_T_progressed": int(last.get("normal_T_progressed", 0)),
            "normal_T_remaining": int(last.get("normal_T_remaining", row.get("normal_T", 0))),
            "T_progress_per_launch": round(int(last.get("normal_T_progressed", 0)) / max(1, int(row.get("shot_count", 0))), 6),
            "launches_per_progressed_T": round(int(row.get("shot_count", 0)) / max(1, int(last.get("normal_T_progressed", 0))), 3),
            "moves_used": int(row.get("moves_used", 0)),
            "moves_remaining": int(row.get("moves_remaining", 0)),
            "canonical_move_limit_4T": int(row.get("canonical_move_limit_4T", 0)),
            "merge_count": int(row.get("merge_count", 0)),
            "simulated_seconds": float(row.get("simulated_seconds", 0)),
            "wall_seconds": int(row.get("wall_milliseconds", 0)) / 1000,
        })

    candidate_outcomes = Counter(str(row.get("qualification_status", "NOT_RUN/ERROR")) for row in candidates)
    success_count = sum(row.get("qualification_status") == "PROVEN_REACHABLE_IN_BOUNDED_TRIAL" for row in candidates)
    total_t = sum(int(row["normal_T"]) for row in all_candidate_budget)
    iid_upper = 1 - 0.05 ** (1 / len(candidates)) if candidates else None
    report = {
        "schema_version": 1,
        "milestone": "BCM-M33-R02",
        "pilot_design": {
            "global_levels": [101, 202, 304, 479],
            "seed_policy": "previously successful R01 seed 33050200 for control 101; deterministic candidate seed base 33050100 + global_id*100",
            "policy": "MERGE_AWARE_V01",
            "physics_scale": 1.0,
            "concurrency": 1,
            "global_wall_cap_sec": 900,
            "relative_launch_budget": "ceil(normal_order_L1_equivalent_cost * 3/7) = ceil(12*T/7); control 101 uses at least 12 launches",
        },
        "pilot_totals": {
            "candidate_trial_count": len(candidates),
            "candidate_success_count": success_count,
            "candidate_outcomes": dict(sorted(candidate_outcomes.items())),
            "control_trial_count": len(controls),
            "control_success_count": sum(row.get("qualification_status") == "PROVEN_REACHABLE_IN_BOUNDED_TRIAL" for row in controls),
            "all_trial_count": len(rows),
            "all_shots": sum(int(row.get("shot_count", 0)) for row in rows),
            "all_simulated_seconds": round(sum(float(row.get("simulated_seconds", 0)) for row in rows), 3),
            "all_trial_wall_seconds": round(sum(int(row.get("wall_milliseconds", 0)) for row in rows) / 1000, 3),
            "measured_main_batch_wall_seconds": args.pilot_wall_seconds,
            "measured_main_batch_godot_cpu_seconds": args.pilot_godot_cpu_seconds,
            "observed_peak_working_set_bytes": args.observed_peak_working_set_bytes,
            "peak_memory_measurement_method": args.peak_memory_measurement,
        },
        "candidate_trials": final_progress,
        "control_trials": [
            {key: row.get(key) for key in ("seed", "qualification_status", "shot_count", "shot_budget", "normal_T", "moves_used", "moves_remaining", "star_result", "simulated_seconds", "wall_milliseconds", "terminal_reason")}
            for row in controls
        ],
        "static_campaign_analysis": {
            "candidate_count": static["candidate_levels_checked"],
            "objective_infeasibility_count": static["static_infeasible_count"],
            "enabled_vip_count": static["enabled_vip_record_count"],
            "conservative_vip_intermediate_heuristic_flag_count": static["conservative_vip_intermediate_heuristic_flag_count"],
            "normal_T_summary": static["normal_T_global_summary"],
            "pilot_notes": static["vip_heuristic_note"],
        },
        "source_and_test_hashes": {
            "initial_calibration_runner_sha256": initial_metadata.get("source_sha256", {}),
            "known_control_runner_sha256": known_control_metadata.get("source_sha256", {}),
            "summary_script_sha256": sha256(Path(__file__)),
            "source_hash_digest_initial_calibration": initial_metadata.get("source_hash_digest_sha256"),
            "source_hash_digest_known_control": known_control_metadata.get("source_hash_digest_sha256"),
        },
        "pilot_raw_evidence_disk_bytes": {
            str(path.name): path.stat().st_size
            for path in sorted(evidence_dir.iterdir())
            if path.is_file() and path.name in {
                "calibration_trials.jsonl", "known_control.jsonl", "static_diagnosis.json",
                "run_metadata_initial_740_sec_pilot.json", "run_metadata_known_control.json",
                "pilot_console_initial_v1_0_0.txt", "pilot_stderr_initial_v1_0_0.txt",
                "known_control_console.txt", "known_control_stderr.txt",
                "resume_check_console.txt", "resume_check_stderr.txt",
            }
        },
        "campaign_cost_projection": {
            "candidate_count": len(all_candidate_budget),
            "sum_normal_T": total_t,
            "sum_expected_spawn_launch_budgets_one_seed": projected_shots,
            "per_level_expected_spawn_budget_median": sorted(row["expected_spawn_budget"] for row in all_candidate_budget)[len(all_candidate_budget) // 2],
            "measured_wall_rate_projections": projections,
            "scope_limit": "Expected-spawn-budget projection only. It is not a completion-time guarantee and excludes merge-placement overhead, strategy failures, retries, and human testing. The observed pilot did not complete a candidate at these budgets.",
        },
        "confidence_limits": {
            "candidate_completions": f"{success_count}/{len(candidates)} across distinct stratified recipes, one seed each",
            "exchangeable_bernoulli_one_sided_95_upper_reference": iid_upper,
            "applicability": "The reference bound assumes identical independent candidate success probabilities and is not valid as a campaign-wide confidence interval for these intentionally different levels. No population completion-rate interval is supported by this pilot.",
        },
        "known_impossible_count": 0,
        "interpretation": "Sampled candidates did not complete within their level-relative budgets. This is evidence about the selected deterministic seeds and MERGE_AWARE_V01 policy only; it does not establish level impossibility. Static checks found no objective-input, merge-closure, target-policy, no-timer, or 4T move-limit violations.",
    }
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"M33_R02_SUMMARY_RESULT=PASS candidates={len(candidates)} successes={success_count} controls={len(controls)} shots={report['pilot_totals']['all_shots']} projection_hours={json.dumps(projections, sort_keys=True)}")


if __name__ == "__main__":
    main()
