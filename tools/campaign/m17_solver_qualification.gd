extends SceneTree

## M17 V03A decision-grade merge-aware solver qualification runner.
## The qualification cohort is intentionally canonical-scale only: Engine.time_scale
## remains 1.0 for all 30 decision-grade trials. A small 4x replay is recorded
## separately as historical telemetry-fidelity evidence.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")

const SESSION_DIR := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION"
const V02_REPORT_PATH := SESSION_DIR + "/M17_BASELINE_REPORT_V02.json"
const REPORT_JSON_PATH := SESSION_DIR + "/M17_SOLVER_QUALIFICATION_V03.json"
const REPORT_MD_PATH := SESSION_DIR + "/M17_SOLVER_QUALIFICATION_V03.md"
const QUALIFICATION_LEVELS: Array[int] = [1, 10, 11, 50, 51, 100]
const TRIALS_PER_LEVEL := 5
const SEED_BASE := 17300000


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M17 V03 database load failed: %s" % database.get_last_error())
		quit(1)
		return

	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(1.0)
	var report := {
		"schema_version": 1,
		"milestone": "BCM-M17",
		"report_version": "V03A",
		"policy_name": HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
		"policy_algorithm": "same-level target first; otherwise deterministic weighted lower-board congestion scoring; objective-level tie label; nearest legal lane then center-distance/lower-index tie-break",
		"island_id": "sunny_cove",
		"qualification_time_scale": 1.0,
		"qualification_levels": QUALIFICATION_LEVELS,
		"trial_count_per_level": TRIALS_PER_LEVEL,
		"total_qualification_trials": QUALIFICATION_LEVELS.size() * TRIALS_PER_LEVEL,
		"seed_schedule": {"base": SEED_BASE, "formula": "base + level_id * 1000 + trial_index"},
		"physics_hook": "production GameManager.spawn_drink + Drink.launch_up + Godot physics frames",
		"rail_contact_metric": HARNESS_SCRIPT.RAIL_CONTACT_METRIC,
		"rail_enter_threshold_px": HARNESS_SCRIPT.RAIL_ENTER_THRESHOLD_PX,
		"rail_release_threshold_px": HARNESS_SCRIPT.RAIL_RELEASE_THRESHOLD_PX,
		"levels": [],
	}
	var results_by_level: Dictionary = {}
	var validation_errors: Array[String] = []
	for level_id in QUALIFICATION_LEVELS:
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		if definition.is_empty():
			validation_errors.append("missing canonical level %d" % level_id)
			continue
		var trial_results: Array[Dictionary] = []
		print("M17 V03A qualification L%d (%d trials, time_scale=%.1f)" % [level_id, TRIALS_PER_LEVEL, harness.get_time_scale()])
		for trial_index in range(TRIALS_PER_LEVEL):
			var seed_value := SEED_BASE + level_id * 1000 + trial_index
			var result: Dictionary = await harness.run_trial(database, "sunny_cove", level_id, seed_value, [], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
			trial_results.append(result)
			if not harness.validate_telemetry(result).is_empty():
				validation_errors.append("L%d seed %d telemetry schema invalid" % [level_id, seed_value])
			if not _action_log_is_legal(result.get("action_log", [])):
				validation_errors.append("L%d seed %d action log is missing legal decision evidence" % [level_id, seed_value])
			print("  trial %d seed=%d outcome=%s shots=%d merges=%d unique_x=%d" % [trial_index + 1, seed_value, result["outcome"], result["shot_count"], result["merge_count"], result["unique_x_positions"]])
		var level_record := _summarize_level(definition, trial_results)
		report["levels"].append(level_record)
		results_by_level[level_id] = trial_results

	var focused: Dictionary = await _run_focused_qualification_checks(database, harness, results_by_level)
	var spot_checks: Dictionary = await _run_time_scale_spot_checks(database, harness, results_by_level)
	var lateral_gate := _lateral_gate(report["levels"])
	var comparison := _compare_v02(report["levels"])
	var no_aborts := _count_outcomes(report["levels"], "harness_abort") == 0
	var l1_completed := _level_count(report["levels"], 1, "completed_count")
	var l10_completed := _level_count(report["levels"], 10, "completed_count")
	var l11_completed := _level_count(report["levels"], 11, "completed_count")
	var telemetry_valid := validation_errors.is_empty() and bool(focused.get("telemetry_valid", false))
	var solver_qualified := no_aborts and l1_completed >= 3 and (l10_completed >= 1 or l11_completed >= 1) and bool(focused.get("same_seed_action_log_reproduces", false)) and bool(focused.get("replay_reproduces_logical_outcome", false)) and telemetry_valid and not bool(lateral_gate["FIXED_LANE_FAILURE"])
	report["qualification"] = {
		"verdict": "SOLVER_QUALIFIED_FOR_M17_007" if solver_qualified else "SOLVER_NOT_QUALIFIED",
		"no_harness_aborts": no_aborts,
		"l1_completion_count": l1_completed,
		"l10_completion_count": l10_completed,
		"l11_completion_count": l11_completed,
		"same_seed_action_log_reproduces": bool(focused.get("same_seed_action_log_reproduces", false)),
		"replay_reproduces_logical_outcome": bool(focused.get("replay_reproduces_logical_outcome", false)),
		"telemetry_valid": telemetry_valid,
		"policy_fixture_responsive": bool(focused.get("policy_fixture_responsive", false)),
		"fixed_lane_failure": bool(lateral_gate["FIXED_LANE_FAILURE"]),
		"lateral_gate": lateral_gate,
		"validation_errors": validation_errors,
	}
	report["focused_checks"] = focused
	report["time_scale_fidelity"] = spot_checks
	report["comparison_v02_weak_policy"] = comparison
	report["historical_4x_telemetry_only_not_decision_grade"] = bool(spot_checks.get("historical_4x_telemetry_only_not_decision_grade", false))
	_write_report(report)
	if validation_errors.is_empty():
		print("M17_SOLVER_QUALIFICATION_RESULT=%s" % report["qualification"]["verdict"])
		quit(0)
		return
	print("M17_SOLVER_QUALIFICATION_RESULT=SOLVER_NOT_QUALIFIED errors=%s" % "; ".join(validation_errors))
	quit(1)


func _summarize_level(definition: Dictionary, trials: Array[Dictionary]) -> Dictionary:
	var completion_times: Array = []
	var merges: Array = []
	var peak_live: Array = []
	var occupancy: Array = []
	var rail_events: Array = []
	var contacts: Array = []
	var failed_merges: Array = []
	var counts := {"completed": 0, "timeout": 0, "danger": 0, "harness_abort": 0}
	var decision_reason_counts: Dictionary = {}
	for trial in trials:
		var outcome := str(trial.get("outcome", ""))
		if counts.has(outcome):
			counts[outcome] = int(counts[outcome]) + 1
		if outcome == "completed":
			completion_times.append(float(trial.get("elapsed_sec", 0.0)))
		merges.append(float(trial.get("merge_count", 0)))
		peak_live.append(float(trial.get("peak_live_drinks", 0)))
		occupancy.append(float(trial.get("peak_board_occupancy", 0.0)))
		rail_events.append(float(trial.get("rail_contact_count", 0)))
		contacts.append(float(trial.get("contact_count", 0)))
		failed_merges.append(float(trial.get("failed_merge_approach_count", 0)))
		for reason in trial.get("decision_reason_counts", {}).keys():
			decision_reason_counts[reason] = int(decision_reason_counts.get(reason, 0)) + int(trial["decision_reason_counts"][reason])
	return {
		"level_id": int(definition["level_id"]),
		"trial_count": trials.size(),
		"completed_count": int(counts["completed"]),
		"timeout_count": int(counts["timeout"]),
		"danger_count": int(counts["danger"]),
		"harness_abort_count": int(counts["harness_abort"]),
		"completion_rate": float(counts["completed"]) / float(maxi(1, trials.size())),
		"median_completion_time_sec": MODEL_SCRIPT.percentile(completion_times, 0.5),
		"median_merge_count": MODEL_SCRIPT.percentile(merges, 0.5),
		"median_peak_live_drinks": MODEL_SCRIPT.percentile(peak_live, 0.5),
		"median_peak_occupancy": MODEL_SCRIPT.percentile(occupancy, 0.5),
		"median_rail_proxy_events": MODEL_SCRIPT.percentile(rail_events, 0.5),
		"median_contact_count": MODEL_SCRIPT.percentile(contacts, 0.5),
		"median_failed_merge_proxy": MODEL_SCRIPT.percentile(failed_merges, 0.5),
		"canonical_timer_sec": float(definition.get("time_limit_sec", 0.0)),
		"normal_objective_cost": MODEL_SCRIPT.normal_objective_cost(definition),
		"decision_reason_counts": decision_reason_counts,
		"trials": trials,
	}


func _action_log_is_legal(action_log: Array) -> bool:
	for action in action_log:
		if not action.has_all(["x_position", "lane_index", "decision_reason", "same_level_target_found", "target_instance_id"]):
			return false
		if int(action["lane_index"]) < 0 or int(action["lane_index"]) >= HARNESS_SCRIPT.LANE_X_POSITIONS.size():
			return false
		var is_known_x := false
		for lane_x in HARNESS_SCRIPT.LANE_X_POSITIONS:
			if is_equal_approx(float(action["x_position"]), float(lane_x)):
				is_known_x = true
				break
		if not is_known_x:
			return false
	return true


func _run_focused_qualification_checks(database, harness, results_by_level: Dictionary) -> Dictionary:
	var first: Dictionary = results_by_level.get(1, [])[0] if results_by_level.has(1) and not results_by_level[1].is_empty() else {}
	var second: Dictionary = {}
	var replay: Dictionary = {}
	if not first.is_empty():
		second = await harness.run_trial(database, "sunny_cove", 1, int(first["seed"]), [], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
		replay = await harness.run_trial(database, "sunny_cove", 1, int(first["seed"]), first["action_log"], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
	var left_target: Dictionary = harness.choose_action_from_observations(2, [{"level": 2, "x": 150.0, "y": 760.0, "instance_id": 101}], 6)
	var right_target: Dictionary = harness.choose_action_from_observations(2, [{"level": 2, "x": 570.0, "y": 760.0, "instance_id": 202}], 6)
	var left_congestion: Dictionary = harness.choose_action_from_observations(2, [{"level": 1, "x": 150.0, "y": 820.0, "instance_id": 301}, {"level": 3, "x": 150.0, "y": 760.0, "instance_id": 302}], 6)
	var repeated_left: Dictionary = harness.choose_action_from_observations(2, [{"level": 2, "x": 150.0, "y": 760.0, "instance_id": 101}], 6)
	var fixtures_pass: bool = left_target["x_position"] < 360.0 and right_target["x_position"] > 360.0 and left_congestion["lane_index"] > 0 and left_target == repeated_left
	return {
		"policy_fixture_responsive": fixtures_pass,
		"left_target_action": left_target,
		"right_target_action": right_target,
		"left_congestion_action": left_congestion,
		"same_seed_action_log_reproduces": not first.is_empty() and first.get("action_log", []) == second.get("action_log", []),
		"same_seed_logical_outcome_reproduces": not first.is_empty() and first.get("outcome", "") == second.get("outcome", ""),
		"replay_reproduces_logical_outcome": not first.is_empty() and first.get("outcome", "") == replay.get("outcome", "") and int(first.get("merge_count", 0)) == int(replay.get("merge_count", 0)),
		"telemetry_valid": not first.is_empty() and harness.validate_telemetry(first).is_empty() and harness.validate_telemetry(second).is_empty() and harness.validate_telemetry(replay).is_empty(),
	}


func _run_time_scale_spot_checks(database, harness, results_by_level: Dictionary) -> Dictionary:
	var spot_results: Array[Dictionary] = []
	var diverged := false
	for level_id in [1, 50]:
		if not results_by_level.has(level_id) or results_by_level[level_id].is_empty():
			continue
		var canonical: Dictionary = results_by_level[level_id][0]
		harness.set_time_scale(4.0)
		var accelerated: Dictionary = await harness.run_trial(database, "sunny_cove", level_id, int(canonical["seed"]), canonical["action_log"], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
		harness.set_time_scale(1.0)
		var outcome_same := str(canonical["outcome"]) == str(accelerated["outcome"])
		var merge_same := int(canonical["merge_count"]) == int(accelerated["merge_count"])
		diverged = diverged or not outcome_same or not merge_same
		spot_results.append({
			"level_id": level_id,
			"seed": canonical["seed"],
			"action_log_replayed_identically": true,
			"one_x": _spot_trial_values(canonical),
			"four_x": _spot_trial_values(accelerated),
			"outcome_same": outcome_same,
			"merge_count_same": merge_same,
			"telemetry_only_not_decision_grade": not outcome_same or not merge_same,
		})
	return {
		"qualification_scale": 1.0,
		"spot_scale": 4.0,
		"results": spot_results,
		"historical_4x_telemetry_only_not_decision_grade": diverged,
	}


func _spot_trial_values(trial: Dictionary) -> Dictionary:
	return {
		"outcome": trial.get("outcome", ""),
		"merge_count": trial.get("merge_count", 0),
		"terminal_reason": trial.get("terminal_reason", ""),
		"elapsed_sec": trial.get("elapsed_sec", 0.0),
		"peak_live_drinks": trial.get("peak_live_drinks", 0),
	}


func _lateral_gate(levels: Array) -> Dictionary:
	var eligible := 0
	var varying := 0
	var level_failures: Array[int] = []
	for level in levels:
		var level_eligible := 0
		var level_varying := 0
		for trial in level.get("trials", []):
			if int(trial.get("shot_count", 0)) < 5:
				continue
			level_eligible += 1
			eligible += 1
			if int(trial.get("unique_x_positions", 0)) >= 2:
				level_varying += 1
				varying += 1
		if level_eligible > 0 and level_varying == 0:
			level_failures.append(int(level["level_id"]))
	var fraction := float(varying) / float(maxi(1, eligible))
	return {
		"qualifying_trial_count": eligible,
		"lateral_variation_trial_count": varying,
		"lateral_variation_fraction": fraction,
		"minimum_fraction": 0.8,
		"levels_without_lateral_variation": level_failures,
		"FIXED_LANE_FAILURE": eligible == 0 or fraction < 0.8 or not level_failures.is_empty(),
	}


func _compare_v02(v03_levels: Array) -> Array:
	var comparison: Array = []
	if not FileAccess.file_exists(V02_REPORT_PATH):
		return comparison
	var v02 = JSON.parse_string(FileAccess.get_file_as_string(V02_REPORT_PATH))
	if not v02 is Dictionary:
		return comparison
	for v03_level in v03_levels:
		var level_id := int(v03_level["level_id"])
		var v02_level: Dictionary = {}
		for candidate in v02.get("levels", []):
			if int(candidate.get("level_id", 0)) == level_id:
				v02_level = candidate
				break
		if v02_level.is_empty():
			continue
		comparison.append({
			"level_id": level_id,
			"v02_weak_policy": _comparison_metrics(v02_level.get("trials", [])),
			"v03_merge_aware_policy": _comparison_metrics(v03_level.get("trials", [])),
			"interpretation": "small diagnostic comparison; five trials per level is not statistically significant",
		})
	return comparison


func _comparison_metrics(trials: Array) -> Dictionary:
	var merges: Array = []
	var peak_live: Array = []
	var occupancy: Array = []
	var rail: Array = []
	var counts := {"completed": 0, "danger": 0, "timeout": 0, "harness_abort": 0}
	for trial in trials:
		var outcome := str(trial.get("outcome", ""))
		if counts.has(outcome):
			counts[outcome] = int(counts[outcome]) + 1
		merges.append(float(trial.get("merge_count", 0)))
		peak_live.append(float(trial.get("peak_live_drinks", 0)))
		occupancy.append(float(trial.get("peak_board_occupancy", 0.0)))
		rail.append(float(trial.get("rail_contact_count", 0)))
	return {
		"completed_count": counts["completed"],
		"danger_count": counts["danger"],
		"timeout_count": counts["timeout"],
		"harness_abort_count": counts["harness_abort"],
		"median_merge_count": MODEL_SCRIPT.percentile(merges, 0.5),
		"median_peak_live_drinks": MODEL_SCRIPT.percentile(peak_live, 0.5),
		"median_peak_occupancy": MODEL_SCRIPT.percentile(occupancy, 0.5),
		"median_rail_proxy_events": MODEL_SCRIPT.percentile(rail, 0.5),
	}


func _count_outcomes(levels: Array, outcome: String) -> int:
	var total := 0
	for level in levels:
		var key := "harness_abort_count" if outcome == "harness_abort" else "%s_count" % outcome
		total += int(level.get(key, 0))
	return total


func _level_count(levels: Array, level_id: int, key: String) -> int:
	for level in levels:
		if int(level.get("level_id", 0)) == level_id:
			return int(level.get(key, 0))
	return 0


func _write_report(report: Dictionary) -> void:
	var json_file := FileAccess.open(REPORT_JSON_PATH, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "  "))
	json_file.close()
	var markdown := "# M17 V03A Merge-Aware Solver Qualification\n\n"
	markdown += "Policy: `%s`; canonical qualification scale: `1.0x`; this is validation evidence only and does not tune canonical data.\n\n" % str(report["policy_name"])
	markdown += "Seed schedule: `%s`; cohort: `%d` trials (`%s`).\n\n" % [str(report["seed_schedule"]["formula"]), int(report["total_qualification_trials"]), str(report["qualification_levels"])]
	markdown += "| Level | Trials | Complete | Timeout | Danger | Abort | Completion | Median sec | Median merges | Peak live | Median occ. | Rail proxy | Contacts | Failed merge | Timer | Cost |\n|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
	for level in report["levels"]:
		markdown += "| L%d | %d | %d | %d | %d | %d | %.2f | %.2f | %.1f | %.1f | %.4f | %.1f | %.1f | %.1f | %.0f | %d |\n" % [
			int(level["level_id"]), int(level["trial_count"]), int(level["completed_count"]), int(level["timeout_count"]), int(level["danger_count"]), int(level["harness_abort_count"]), float(level["completion_rate"]), float(level["median_completion_time_sec"]), float(level["median_merge_count"]), float(level["median_peak_live_drinks"]), float(level["median_peak_occupancy"]), float(level["median_rail_proxy_events"]), float(level["median_contact_count"]), float(level["median_failed_merge_proxy"]), float(level["canonical_timer_sec"]), int(level["normal_objective_cost"]),
		]
	markdown += "\n## Machine-readable qualification\n\n"
	markdown += "- Verdict: `%s`\n" % str(report["qualification"]["verdict"])
	markdown += "- `FIXED_LANE_FAILURE = %s`\n" % str(report["qualification"]["fixed_lane_failure"])
	markdown += "- L1 completion: `%d/5`; L10: `%d/5`; L11: `%d/5`.\n" % [int(report["qualification"]["l1_completion_count"]), int(report["qualification"]["l10_completion_count"]), int(report["qualification"]["l11_completion_count"])]
	markdown += "- Lateral variation: `%d/%d = %.2f`; minimum `0.80`.\n" % [int(report["qualification"]["lateral_gate"]["lateral_variation_trial_count"]), int(report["qualification"]["lateral_gate"]["qualifying_trial_count"]), float(report["qualification"]["lateral_gate"]["lateral_variation_fraction"])]
	markdown += "- Focused fixture result: `%s`; same-seed log: `%s`; replay: `%s`.\n" % [str(report["focused_checks"]["policy_fixture_responsive"]), str(report["focused_checks"]["same_seed_action_log_reproduces"]), str(report["focused_checks"]["replay_reproduces_logical_outcome"])]
	markdown += "- 4x spot-check historical telemetry-only flag: `%s`.\n\n" % str(report["historical_4x_telemetry_only_not_decision_grade"])
	markdown += "## Interpretation boundary\n\n"
	markdown += "This is a small deterministic diagnostic cohort, not statistical significance and not a player difficulty rating. No M17-007 final classification, M17-008 tuning, timer change, objective change, physics change, or canonical data change is authorized by this report.\n"
	var md_file := FileAccess.open(REPORT_MD_PATH, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()
