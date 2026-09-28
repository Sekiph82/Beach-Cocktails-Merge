extends SceneTree

## M17 cohort runner. Optional user arguments:
## --m17-trials=N, --m17-seed-base=N, --m17-levels=1,10,11,
## --m17-report-version=V01|V02, --m17-append

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const SESSION_DIR := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION"
const DEFAULT_LEVELS: Array[int] = [1, 10, 11, 20, 21, 30, 31, 40, 41, 50, 51, 60, 61, 70, 71, 80, 81, 90, 91, 100]
const DEFAULT_SEED_BASE := 17000000


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := _parse_args()
	var report_version := str(args["report_version"])
	var report_json_path := SESSION_DIR + "/M17_BASELINE_REPORT_%s.json" % report_version
	var report_md_path := SESSION_DIR + "/M17_BASELINE_REPORT_%s.md" % report_version
	var trials := int(args["trials"])
	var seed_base := int(args["seed_base"])
	var selected_levels: Array[int] = args["levels"]
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M17 database load failed: %s" % database.get_last_error())
		quit(1)
		return
	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(float(args["time_scale"]))
	var report := {
		"schema_version": 1,
		"milestone": "BCM-M17",
		"report_version": report_version,
		"island_id": "sunny_cove",
		"trial_count_per_level": trials,
		"seed_schedule": {"base": seed_base, "formula": "base + level_id * 1000 + trial_index"},
		"calibration_seconds_per_launch": MODEL_SCRIPT.DEFAULT_SECONDS_PER_LAUNCH,
		"planning_multiplier": MODEL_SCRIPT.PLANNING_MULTIPLIER,
		"percentile_method": "R7 linear interpolation over sorted completion times",
		"analytical_metrics_are_not_runtime_guarantees": true,
		"physics_hook": "production GameManager.spawn_drink + Drink.launch_up + Godot physics frames",
		"physics_time_scale": float(args["time_scale"]),
		"rail_contact_metric": HARNESS_SCRIPT.RAIL_CONTACT_METRIC,
		"rail_enter_threshold_px": HARNESS_SCRIPT.RAIL_ENTER_THRESHOLD_PX,
		"rail_release_threshold_px": HARNESS_SCRIPT.RAIL_RELEASE_THRESHOLD_PX,
		"runtime_limit_note": "10 trials were impractical at canonical scale after a measured L1 timeout took approximately 20 seconds wall time; this cohort uses the prompt-authorized minimum of 3 trials per required level with explicit accelerated Godot physics timing. The focused M17 probe remains canonical scale 1.0.",
		"levels": [],
	}
	if bool(args["append"]) and FileAccess.file_exists(report_json_path):
		var existing = JSON.parse_string(FileAccess.get_file_as_string(report_json_path))
		if existing is Dictionary and existing.has("levels"):
			report = existing
			report["trial_count_per_level"] = trials
			report["seed_schedule"] = {"base": seed_base, "formula": "base + level_id * 1000 + trial_index"}
			report["calibration_seconds_per_launch"] = MODEL_SCRIPT.DEFAULT_SECONDS_PER_LAUNCH
			report["planning_multiplier"] = MODEL_SCRIPT.PLANNING_MULTIPLIER
			report["physics_time_scale"] = float(args["time_scale"])
			report["report_version"] = report_version
			report["rail_contact_metric"] = HARNESS_SCRIPT.RAIL_CONTACT_METRIC
			report["rail_enter_threshold_px"] = HARNESS_SCRIPT.RAIL_ENTER_THRESHOLD_PX
			report["rail_release_threshold_px"] = HARNESS_SCRIPT.RAIL_RELEASE_THRESHOLD_PX
			report["runtime_limit_note"] = "10 trials were impractical at canonical scale after a measured L1 timeout took approximately 20 seconds wall time; this cohort uses the prompt-authorized minimum of 3 trials per required level with explicit accelerated Godot physics timing. The focused M17 probe remains canonical scale 1.0."
	for level_id in selected_levels:
		var already_reported := false
		for existing_level in report["levels"]:
			if int(existing_level.get("level_id", 0)) == level_id:
				already_reported = true
				break
		if already_reported:
			continue
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		if definition.is_empty():
			push_error("missing canonical level %d" % level_id)
			quit(1)
			return
		var analytical: Dictionary = MODEL_SCRIPT.level_summary(definition)
		var trials_out: Array[Dictionary] = []
		print("M17 baseline L%d (%d trials)" % [level_id, trials])
		for trial_index in range(trials):
			var seed_value := seed_base + level_id * 1000 + trial_index
			var result: Dictionary = await harness.run_trial(database, "sunny_cove", level_id, seed_value)
			trials_out.append(result)
			print("  trial %d seed=%d outcome=%s shots=%d merges=%d" % [trial_index + 1, seed_value, result["outcome"], result["shot_count"], result["merge_count"]])
		var cohort := _summarize_cohort(trials_out)
		cohort.merge(analytical)
		cohort["trials"] = trials_out
		cohort["notes"] = _level_note(cohort)
		report["levels"].append(cohort)
		_write_report(report, report_json_path, report_md_path)
	_write_report(report, report_json_path, report_md_path)
	if report_version == "V02":
		var validation_errors := _validate_v02_report(report, selected_levels, trials, seed_base)
		if not validation_errors.is_empty():
			push_error("M17 V02 report validation failed: %s" % "; ".join(validation_errors))
			quit(1)
			return
	print("M17_BASELINE_REPORT_RESULT=PASS levels=%d trials=%d" % [selected_levels.size(), selected_levels.size() * trials])
	quit(0)


func _summarize_cohort(trials: Array[Dictionary]) -> Dictionary:
	var completion_times: Array = []
	var peak_occupancy: Array = []
	var peak_live: Array = []
	var mean_live: Array = []
	var large_piece: Array = []
	var contacts: Array = []
	var rail_contacts: Array = []
	var completion_count := 0
	var timeout_count := 0
	var danger_count := 0
	var abort_count := 0
	for trial in trials:
		var outcome := str(trial.get("outcome", ""))
		if outcome == "completed":
			completion_count += 1
			completion_times.append(float(trial.get("elapsed_sec", 0.0)))
		elif outcome == "timeout":
			timeout_count += 1
		elif outcome == "danger":
			danger_count += 1
		elif outcome == "harness_abort":
			abort_count += 1
		peak_occupancy.append(float(trial.get("peak_board_occupancy", 0.0)))
		peak_live.append(float(trial.get("peak_live_drinks", 0)))
		mean_live.append(float(trial.get("mean_live_drinks", 0.0)))
		large_piece.append(float(trial.get("large_piece_coexistence_peak", 0)))
		contacts.append(float(trial.get("contact_count", 0)))
		rail_contacts.append(float(trial.get("rail_contact_count", 0)))
	return {
		"trial_count": trials.size(),
		"completed_count": completion_count,
		"completion_rate": float(completion_count) / float(maxi(1, trials.size())),
		"median_completion_time_sec": MODEL_SCRIPT.percentile(completion_times, 0.5),
		"p75_completion_time_sec": MODEL_SCRIPT.percentile(completion_times, 0.75),
		"p90_completion_time_sec": MODEL_SCRIPT.percentile(completion_times, 0.90),
		"timeout_count": timeout_count,
		"danger_count": danger_count,
		"harness_abort_count": abort_count,
		"median_peak_occupancy": MODEL_SCRIPT.percentile(peak_occupancy, 0.5),
		"peak_occupancy": _max_value(peak_occupancy),
		"median_peak_live_drinks": MODEL_SCRIPT.percentile(peak_live, 0.5),
		"mean_live_drinks_median": MODEL_SCRIPT.percentile(mean_live, 0.5),
		"median_large_piece_coexistence_peak": MODEL_SCRIPT.percentile(large_piece, 0.5),
		"contact_count_median": MODEL_SCRIPT.percentile(contacts, 0.5),
		"rail_contact_count_median": MODEL_SCRIPT.percentile(rail_contacts, 0.5),
		"candidate_flag": "baseline outlier; needs further validation" if completion_count < trials.size() else "none",
	}


func _max_value(values: Array) -> float:
	var maximum := 0.0
	for value in values:
		maximum = maxf(maximum, float(value))
	return maximum


func _level_note(cohort: Dictionary) -> String:
	if int(cohort.get("harness_abort_count", 0)) > 0:
		return "Harness abort present; runtime evidence is incomplete and needs further validation."
	if int(cohort.get("danger_count", 0)) > 0:
		return "Danger-line outcomes observed; this is baseline-bot evidence, not a final gameplay judgment."
	return "Analytical planning metrics and seeded runtime evidence are reported separately; no tuning decision is made in this report."


func _write_report(report: Dictionary, report_json_path: String, report_md_path: String) -> void:
	var json_file := FileAccess.open(report_json_path, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "  "))
	json_file.close()
	var markdown := "# M17 %s Seeded Difficulty Baseline\n\n" % str(report.get("report_version", "V01"))
	markdown += "This is tooling/evidence only. The planning model is not a physical guarantee, and no canonical level, timer, VIP, reward, HUD, table, or physics data was tuned.\n\n"
	markdown += "- Calibration: `%.3f` seconds per launch (named provisional planning assumption; overrideable).\n" % float(report["calibration_seconds_per_launch"])
	markdown += "- Target multiplier: `×%.1f`.\n" % float(report["planning_multiplier"])
	markdown += "- Percentiles: R7 linear interpolation over sorted completion times.\n"
	markdown += "- Physics time scale: `%.1f`; the focused reproducibility probe uses canonical scale `1.0`.\n" % float(report["physics_time_scale"])
	markdown += "- Runtime limit: %s\n" % str(report["runtime_limit_note"])
	markdown += "- Seed schedule: `%s`.\n" % str(report["seed_schedule"]["formula"])
	markdown += "- Rail metric: `%s`; enter `<= %.1f px`, release `> %.1f px`; this is a footprint-to-authoritative-boundary transition proxy, not a body collision callback.\n\n" % [str(report.get("rail_contact_metric", "not declared")), float(report.get("rail_enter_threshold_px", 0.0)), float(report.get("rail_release_threshold_px", 0.0))]
	markdown += "| Level | Trials | Completion | Median sec | P75 sec | P90 sec | Timeout | Danger | Abort | Median occ. | Peak live | Large coexist. | Rail events | Cost | Plan target sec | Timer sec | Flag |\n|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|\n"
	for level in report["levels"]:
		markdown += "| L%d | %d | %.2f | %.2f | %.2f | %.2f | %d | %d | %d | %.4f | %.1f | %.1f | %.1f | %d | %.2f | %.0f | %s |\n" % [
			int(level["level_id"]), int(level["trial_count"]), float(level["completion_rate"]),
			float(level["median_completion_time_sec"]), float(level["p75_completion_time_sec"]), float(level["p90_completion_time_sec"]),
			int(level["timeout_count"]), int(level["danger_count"]), int(level["harness_abort_count"]),
			float(level["median_peak_occupancy"]), float(level["median_peak_live_drinks"]), float(level["median_large_piece_coexistence_peak"]), float(level["rail_contact_count_median"]),
			int(level["normal_objective_cost"]), float(level["planning_target_time_sec"]), float(level["canonical_timer_sec"]), str(level["candidate_flag"]),
		]
	markdown += "\n## Interpretation boundary\n\n"
	markdown += "The baseline bot is a deterministic lane-placement policy, not an optimal human. A low completion rate, timeout, danger result, or candidate flag is an observation requiring further validation, not a final impossible-level or tuning decision. A TABLE_DANGER trial is counted as danger, never timeout; timeout is reserved for actual time-limit exhaustion. `contact_count` is a body collision callback count, while `rail_contact_count` is the documented proximity transition proxy. Spatial metrics are telemetry from the production Drink/GameManager physics hook; theoretical cost and timer planning are analytical values.\n"
	var md_file := FileAccess.open(report_md_path, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()


func _validate_v02_report(report: Dictionary, selected_levels: Array[int], expected_trials: int, seed_base: int) -> Array[String]:
	var errors: Array[String] = []
	var required: Array[int] = DEFAULT_LEVELS.duplicate()
	var actual_ids: Array[int] = []
	var total_trials := 0
	var nonzero_rail_events := 0
	for level in report.get("levels", []):
		var level_id := int(level.get("level_id", 0))
		actual_ids.append(level_id)
		var trials: Array = level.get("trials", [])
		total_trials += trials.size()
		if trials.size() != expected_trials:
			errors.append("L%d trial count is %d, expected %d" % [level_id, trials.size(), expected_trials])
		var counts := {"completed": 0, "timeout": 0, "danger": 0, "harness_abort": 0}
		for trial in trials:
			var outcome := str(trial.get("outcome", ""))
			if counts.has(outcome):
				counts[outcome] = int(counts[outcome]) + 1
			else:
				errors.append("L%d has invalid trial outcome %s" % [level_id, outcome])
			if str(trial.get("terminal_reason", "")) == "TABLE_DANGER" and outcome != "danger":
				errors.append("L%d TABLE_DANGER trial is not danger" % level_id)
			if str(trial.get("terminal_reason", "")) == "TABLE_DANGER" and outcome == "timeout":
				errors.append("L%d TABLE_DANGER trial counted as timeout" % level_id)
			if int(trial.get("rail_contact_count", 0)) > 0:
				nonzero_rail_events += 1
		var total := int(counts["completed"]) + int(counts["timeout"]) + int(counts["danger"]) + int(counts["harness_abort"])
		if total != trials.size():
			errors.append("L%d outcome count total does not match trials" % level_id)
		for key in ["completed", "timeout", "danger", "harness_abort"]:
			var report_key := "completed_count" if key == "completed" else ("%s_count" % key)
			if int(level.get(report_key, -1)) != int(counts[key]):
				errors.append("L%d %s summary does not match trials" % [level_id, report_key])
	if actual_ids != required:
		errors.append("required level cohort mismatch: %s" % str(actual_ids))
	if total_trials != required.size() * expected_trials:
		errors.append("total trial count is %d, expected %d" % [total_trials, required.size() * expected_trials])
	if str(report.get("rail_contact_metric", "")) != HARNESS_SCRIPT.RAIL_CONTACT_METRIC:
		errors.append("report rail metric metadata is missing or incorrect")
	if nonzero_rail_events <= 0:
		errors.append("report has no nonzero rail-proxy events")
	if int(report.get("seed_schedule", {}).get("base", -1)) != seed_base:
		errors.append("report seed base mismatch")
	return errors


func _parse_args() -> Dictionary:
	var result := {"trials": 3, "seed_base": DEFAULT_SEED_BASE, "time_scale": 4.0, "append": false, "report_version": "V01", "levels": DEFAULT_LEVELS.duplicate()}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--m17-trials="):
			result["trials"] = maxi(1, int(arg.trim_prefix("--m17-trials=")))
		elif arg.begins_with("--m17-seed-base="):
			result["seed_base"] = int(arg.trim_prefix("--m17-seed-base="))
		elif arg.begins_with("--m17-time-scale="):
			result["time_scale"] = maxf(1.0, float(arg.trim_prefix("--m17-time-scale=")))
		elif arg == "--m17-append":
			result["append"] = true
		elif arg.begins_with("--m17-report-version="):
			result["report_version"] = arg.trim_prefix("--m17-report-version=").to_upper()
		elif arg.begins_with("--m17-levels="):
			var parsed: Array[int] = []
			for token in arg.trim_prefix("--m17-levels=").split(","):
				var level_id := int(token)
				if level_id > 0:
					parsed.append(level_id)
			if not parsed.is_empty():
				result["levels"] = parsed
	return result
