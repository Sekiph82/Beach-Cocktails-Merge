#!/usr/bin/env python3
"""Build the exact R01 899-level coverage matrix from resumable JSONL trials."""

from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path
from statistics import mean

ISLANDS = [
    "sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
    "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
CANDIDATES = range(102, 1001)
CONTROL_LEVEL = 101
ROOT = Path(__file__).resolve().parents[2]
LEVEL_FILES = [
    "sunny_cove.json", "tiki_island_full.json", "azure_bay.json", "coconut_beach.json",
    "sunset_island.json", "party_beach.json", "frozen_paradise.json", "volcano_bay.json",
    "billionaire_island.json", "final_island.json",
]
CATALOG: dict[int, dict] = {}


def read_rows(path: Path) -> list[dict]:
    rows = []
    if not path.exists():
        return rows
    with path.open(encoding="utf-8") as source:
        for number, line in enumerate(source, 1):
            if not line.strip():
                continue
            try:
                value = json.loads(line)
            except json.JSONDecodeError as exc:
                raise SystemExit(f"invalid JSONL at {path}:{number}: {exc}") from exc
            if not isinstance(value, dict):
                raise SystemExit(f"non-object JSONL row at {path}:{number}")
            rows.append(value)
    return rows


def island_for(global_id: int) -> str:
    return ISLANDS[(global_id - 1) // 100]


def read_catalog() -> dict[int, dict]:
    catalog = {}
    for island_index, relative in enumerate(LEVEL_FILES):
        path = ROOT / "data/campaign/levels" / relative
        root = json.loads(path.read_text(encoding="utf-8"))
        for level in root["levels"]:
            local_id = int(level["level_id"])
            global_id = int(level.get("global_level_id", island_index * 100 + local_id))
            orders = level.get("orders", [])
            vip = level.get("vip")
            normal_t = sum((1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"]) for order in orders)
            vip_t = 0
            if isinstance(vip, dict) and vip.get("enabled", True):
                vip_t = (1 << (int(vip["cocktail_level"]) - 3)) * int(vip.get("quantity", 1))
            total_t = int(level.get("theoretical_shots_total", normal_t + vip_t))
            catalog[global_id] = {
                "difficulty_band": str(level.get("difficulty_tier", "UNSPECIFIED")),
                "theoretical_shots_to_go": int(level.get("theoretical_shots_to_go", normal_t)),
                "theoretical_shots_vip": int(level.get("theoretical_shots_vip", vip_t)),
                "theoretical_shots_total": total_t,
                "move_limit": int(level.get("move_limit", 0)),
                "time_limit_sec": int(level.get("time_limit_sec", 0)),
                "normal_order_count": len(orders),
                "vip_optional_enabled": bool(vip.get("enabled", True)) if isinstance(vip, dict) else False,
                "vip_cocktail_level": int(vip.get("cocktail_level", 0)) if isinstance(vip, dict) else 0,
                "vip_quantity": int(vip.get("quantity", 0)) if isinstance(vip, dict) else 0,
            }
    return catalog


def classify(trials: list[dict]) -> str:
    if any(row.get("data_valid") is False for row in trials):
        return "VERIFIED_DATA_INVALID"
    if any(row.get("trial_outcome") == "completed" and row.get("telemetry_valid", False) for row in trials):
        return "PROVEN_REACHABLE_IN_BOUNDED_TRIAL"
    if any(row.get("trial_outcome") == "exhausted-budget" for row in trials):
        return "NOT_COMPLETED_WITHIN_BUDGET"
    return "NOT_RUN/ERROR"


def summarize_level(global_id: int, trials: list[dict]) -> dict:
    catalog = CATALOG.get(global_id, {})
    outcomes = Counter(str(row.get("trial_outcome", "error")) for row in trials)
    shots = [int(row.get("shot_count", 0)) for row in trials]
    wall_ms = [int(row.get("wall_milliseconds", 0)) for row in trials]
    sim_sec = [float(row.get("simulated_seconds", 0.0)) for row in trials]
    wins = [row for row in trials if row.get("trial_outcome") == "completed" and row.get("telemetry_valid", False)]
    return {
        "global_level_id": global_id,
        "island_id": island_for(global_id),
        "local_level_id": (global_id - 1) % 100 + 1,
        "coverage_status": classify(trials),
        "known_impossible": False,
        "trial_count": len(trials),
        "seed_count": len({row.get("seed") for row in trials if row.get("seed") is not None}),
        "trial_outcomes": dict(sorted(outcomes.items())),
        "successful_seed_rate": len(wins) / len(trials) if trials else None,
        "difficulty_band": catalog.get("difficulty_band", "VERIFIED_DATA_INVALID"),
        "theoretical_shots_to_go_T": catalog.get("theoretical_shots_to_go", 0),
        "theoretical_shots_vip": catalog.get("theoretical_shots_vip", 0),
        "theoretical_shots_total_for_4T": catalog.get("theoretical_shots_total", 0),
        "canonical_move_limit_4T": catalog.get("move_limit", 0),
        "canonical_time_limit_sec": catalog.get("time_limit_sec", 0),
        "normal_order_count": catalog.get("normal_order_count", 0),
        "vip_optional_enabled": catalog.get("vip_optional_enabled", False),
        "vip_cocktail_level": catalog.get("vip_cocktail_level", 0),
        "vip_quantity": catalog.get("vip_quantity", 0),
        "shot_budget_per_trial": next((row.get("max_shots") for row in trials if row.get("max_shots") is not None), None),
        "wall_budget_sec_by_trial": [row.get("per_trial_wall_budget_sec") for row in trials],
        "shots_total": sum(shots),
        "wall_seconds_total": round(sum(wall_ms) / 1000.0, 3),
        "wall_seconds_mean": round(mean(wall_ms) / 1000.0, 3) if wall_ms else None,
        "simulated_seconds_total": round(sum(sim_sec), 3),
        "to_go_completed_by_success": [row.get("to_go_completed", {}) for row in wins],
        "vip_optional_status_by_trial": [row.get("vip_optional", {}) for row in trials],
        "moves_remaining_by_trial": [row.get("moves_remaining", 0) for row in trials],
        "star_result_by_success": [row.get("star_result", 0) for row in wins],
        "terminal_reasons": [row.get("terminal_reason", "") for row in trials],
        "action_log_sha256": [row.get("action_log_sha256", "") for row in trials],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("trials_jsonl", type=Path)
    parser.add_argument("output_json", type=Path)
    args = parser.parse_args()
    global CATALOG
    CATALOG = read_catalog()
    rows = read_rows(args.trials_jsonl)
    by_level: dict[int, list[dict]] = defaultdict(list)
    seen: set[tuple] = set()
    for row in rows:
        global_id = int(row.get("global_level_id", 0))
        if global_id < 101 or global_id > 1000:
            raise SystemExit(f"out-of-range global_level_id in evidence: {global_id}")
        key = (str(row.get("runner_version", "")), global_id, int(row.get("seed", 0)), int(row.get("max_shots", 0)), float(row.get("per_trial_wall_budget_sec", 0.0)), str(row.get("manifest_sha256", "")), str(row.get("policy_name", "")))
        if key in seen:
            raise SystemExit(f"duplicate trial key: {key}")
        seen.add(key)
        by_level[global_id].append(row)
    candidate_records = [summarize_level(level_id, by_level[level_id]) for level_id in CANDIDATES]
    counts = Counter(row["coverage_status"] for row in candidate_records)
    per_island = {}
    for island in ISLANDS[1:]:
        members = [row for row in candidate_records if row["island_id"] == island]
        per_island[island] = {
            "candidate_level_count": len(members),
            "coverage_counts": dict(sorted(Counter(row["coverage_status"] for row in members).items())),
            "trials": sum(row["trial_count"] for row in members),
            "seeds": sum(row["seed_count"] for row in members),
            "shots": sum(row["shots_total"] for row in members),
            "wall_seconds": round(sum(row["wall_seconds_total"] for row in members), 3),
            "successful_trials": sum(row["trial_outcomes"].get("completed", 0) for row in members),
            "difficulty_bands": dict(sorted(Counter(str(row["difficulty_band"]) for row in members).items())),
        }
    control_trials = by_level[CONTROL_LEVEL]
    report = {
        "schema_version": 1,
        "milestone": "BCM-M33-R01",
        "coverage_scope": {"first_candidate_global_level": 102, "last_candidate_global_level": 1000, "candidate_count": 899},
        "coverage_definitions": {
            "PROVEN_REACHABLE_IN_BOUNDED_TRIAL": "At least one telemetry-valid production-physics trial completed all normal To-Go objectives.",
            "NOT_COMPLETED_WITHIN_BUDGET": "One or more physical trials ran but no successful trial has been observed; this does not establish impossibility.",
            "VERIFIED_DATA_INVALID": "The canonical runtime database did not provide the expected candidate record or explicit validation failed.",
            "NOT_RUN/ERROR": "No usable completed physical trial exists for the level.",
        },
        "known_impossible_count": 0,
        "candidate_coverage_counts": dict(sorted(counts.items())),
        "aggregate": {
            "trial_count": len(rows),
            "seed_count": len({row.get("seed") for row in rows if row.get("seed") is not None}),
            "shot_count": sum(int(row.get("shot_count", 0)) for row in rows),
            "wall_seconds": round(sum(int(row.get("wall_milliseconds", 0)) for row in rows) / 1000.0, 3),
            "simulated_seconds": round(sum(float(row.get("simulated_seconds", 0.0)) for row in rows), 3),
        },
        "control_level_101": summarize_level(CONTROL_LEVEL, control_trials),
        "by_island": per_island,
        "levels": candidate_records,
        "interpretation": "A successful bounded solver trial demonstrates reachability for that scenario, not human fairness. Failed seeds are not proofs of impossibility. No difficulty or player-quality acceptance is inferred.",
    }
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"M33_R01_COVERAGE_RESULT=PASS trials={len(rows)} candidate_levels={len(candidate_records)} counts={json.dumps(dict(counts), sort_keys=True)} output={args.output_json}")


if __name__ == "__main__":
    main()
