extends SceneTree

## BCM-M17 V06-R01 fresh post-V05 canonical-scale screening runner.
## It is evidence-only: no campaign data or gameplay tuning is written.
## The report is produced directly by this runner; no repair pass is used.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const DIFFICULTY_MODEL = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const VIP_MODEL = preload("res://scripts/campaign/m17_vip_optionality_model.gd")

const SESSION_DIR := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION"
const LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const V04_PATH := SESSION_DIR + "/M17_CANONICAL_SCREENING_V04.json"
const V05_PATH := SESSION_DIR + "/M17_VIP_OPTIONALITY_V05.json"
const OUT_JSON := SESSION_DIR + "/M17_CANONICAL_SCREENING_V06_R01.json"
const OUT_MD := SESSION_DIR + "/M17_CANONICAL_SCREENING_V06_R01.md"
const POLICY_NAME := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const TIME_SCALE := 1.0
const SEED_BASE := 17600000
const TRIALS_PER_CLASS := 1
const HIGH_RISK_TRIAL_COUNT := 5
const EXPECTED_LEVEL_COUNT := 100
const EXPECTED_CLASS_COUNT := 45

var validation_errors: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL):
		validation_errors.append("canonical database failed: %s" % database.get_last_error())
		_write_minimal_failure()
		quit(1)
		return
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	var classes: Array[Dictionary] = MODEL_SCRIPT.build_challenge_classes(levels)
	if levels.size() != EXPECTED_LEVEL_COUNT:
		validation_errors.append("expected %d levels, found %d" % [EXPECTED_LEVEL_COUNT, levels.size()])
	if classes.size() != EXPECTED_CLASS_COUNT:
		validation_errors.append("expected %d classes, found %d" % [EXPECTED_CLASS_COUNT, classes.size()])
	if not validation_errors.is_empty():
		_write_minimal_failure()
		quit(1)
		return

	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(TIME_SCALE)
	var class_records: Array[Dictionary] = []
	for class_record in classes:
		var representative := int(class_record["representative"])
		var trials: Array[Dictionary] = []
		for trial_index in range(TRIALS_PER_CLASS):
			var seed_value := SEED_BASE + representative * 100 + trial_index
			print("M17 V06-R01 screening %s representative L%d trial=%d seed=%d time_scale=%.1f" % [str(class_record["class_id"]), representative, trial_index + 1, seed_value, harness.get_time_scale()])
			var result: Dictionary = await harness.run_trial(database, "sunny_cove", representative, seed_value, [], POLICY_NAME)
			trials.append(result)
			if not harness.validate_telemetry(result).is_empty():
				validation_errors.append("%s trial %d telemetry schema invalid" % [str(class_record["class_id"]), trial_index + 1])
			if str(result.get("policy_name", "")) != POLICY_NAME:
				validation_errors.append("%s trial %d used unexpected policy" % [str(class_record["class_id"]), trial_index + 1])
			if not _action_log_is_legal(result.get("action_log", [])):
				validation_errors.append("%s trial %d action log invalid" % [str(class_record["class_id"]), trial_index + 1])
			if not is_equal_approx(harness.get_time_scale(), TIME_SCALE):
				validation_errors.append("%s trial %d was not at time scale 1.0" % [str(class_record["class_id"]), trial_index + 1])
		class_records.append(_summarize_class(class_record, trials))

	var timer_scan := MODEL_SCRIPT.timer_scan(levels)
	var timer_by_level: Dictionary = {}
	for timer_record in timer_scan["levels"]:
		timer_by_level[int(timer_record["level_id"])] = timer_record
	var class_by_level: Dictionary = {}
	for class_record in classes:
		for level_id in class_record["member_level_ids"]:
			class_by_level[int(level_id)] = str(class_record["class_id"])
	var class_by_id: Dictionary = {}
	for class_record in class_records:
		class_by_id[str(class_record["class_id"])] = class_record
	var level_records: Array[Dictionary] = []
	var max_level := _drink_max_level()
	var vip_forced_count := 0
	var vip_surplus_count := 0
	for level_definition in levels:
		var level_id := int(level_definition["level_id"])
		var class_id := str(class_by_level.get(level_id, ""))
		var class_record: Dictionary = class_by_id.get(class_id, {})
		var reachability := MODEL_SCRIPT.level_reachability(level_definition, max_level)
		var timer_record: Dictionary = timer_by_level.get(level_id, {})
		var vip_semantics := _post_v05_vip_semantics(level_definition)
		if bool(vip_semantics["enabled"]):
			if int(vip_semantics["forced_capture_count"]) > 0:
				vip_forced_count += 1
			if bool(vip_semantics["surplus_possible"]):
				vip_surplus_count += 1
		var flags: Array = []
		if str(reachability["classification"]) != "NONE":
			flags.append("MATHEMATICALLY_UNREACHABLE")
		if bool(timer_record.get("analytical_timer_ratio_outlier", false)):
			flags.append("ANALYTICAL_TIMER_RATIO_OUTLIER")
		if int(vip_semantics["forced_capture_count"]) > 0:
			flags.append("VIP_INTERCEPTION_RISK_HISTORICAL_ONLY")
		for flag in class_record.get("physical_screening_flags", []):
			flags.append(flag)
		level_records.append({
			"level_id": level_id,
			"class_id": class_id,
			"challenge_signature": MODEL_SCRIPT.challenge_signature(level_definition),
			"normal_objective_cost": int(timer_record.get("normal_objective_cost", 0)),
			"canonical_timer_sec": float(timer_record.get("canonical_timer_sec", 0.0)),
			"timer_cost_ratio": float(timer_record.get("timer_cost_ratio", 0.0)),
			"timer_cost_ratio_deviation_percent": float(timer_record.get("timer_cost_ratio_deviation_percent", 0.0)),
			"planning_target_time_sec": float(timer_record.get("planning_target_time_sec", 0.0)),
			"planning_target_minus_canonical_timer_sec": float(timer_record.get("planning_target_minus_canonical_timer_sec", 0.0)),
			"reachability": reachability,
			"post_v05_vip_optionality": vip_semantics,
			"physical_screening_flags": flags,
		})

	var v05: Dictionary = _load_json(V05_PATH)
	if vip_forced_count != 0 or vip_surplus_count != 25:
		validation_errors.append("post-V05 V06-R01 aggregate was forced=%d/25 surplus=%d/25" % [vip_forced_count, vip_surplus_count])
	var report := {
		"schema_version": 1,
		"milestone": "BCM-M17",
		"report_version": "V06-R01",
		"status": "PASS" if validation_errors.is_empty() else "FAIL",
		"island_id": "sunny_cove",
		"canonical_data_path": "res://data/campaign/levels/sunny_cove.json",
		"canonical_data_sha256": _sha256(LEVELS_PATH),
		"v04_report_sha256": _sha256(V04_PATH),
		"v05_report_sha256": _sha256(V05_PATH),
		"policy_name": POLICY_NAME,
		"engine_time_scale": TIME_SCALE,
		"trial_count_per_class": TRIALS_PER_CLASS,
		"seed_base": SEED_BASE,
		"level_count": levels.size(),
		"challenge_class_count": classes.size(),
		"challenge_signature_definition": "ordered normal objectives/quantities + timer + VIP enabled/level/quantity",
		"classification_definitions": _classification_definitions(),
		"normal_spawn_levels": [1, 2, 3],
		"maximum_drink_level": max_level,
		"reachable_closure": MODEL_SCRIPT.reachable_closure(max_level),
		"timer_scan": timer_scan,
		"post_v05_vip_summary": {
			"forced_capture_count": vip_forced_count,
			"forced_capture_denominator": 25,
			"surplus_path_count": vip_surplus_count,
			"surplus_path_denominator": 25,
			"historical_v04_risk_label": "historical only; never reclassified as post-V05 mandatory",
			"v05_report_summary": {
				"forced_capture_count": int(v05.get("post_v05_forced_capture_count", -1)),
				"surplus_path_count": int(v05.get("post_v05_surplus_path_count", -1)),
			},
		},
		"challenge_classes": class_records,
		"levels": level_records,
		"interpretation_boundary": [
			"Every V06-R01 decision trial uses MERGE_AWARE_V01 at Engine.time_scale = 1.0.",
			"One completion demonstrates one solver-feasible path, not human difficulty or owner acceptance.",
			"A failed single trial is SCREENING_FAILURE_NEEDS_CONFIRMATION; exact-class 0/5 is HIGH_RISK_SOLVER_FAILURE, not proof of impossibility.",
			"Post-V05 reserve evidence uses bridge-authoritative normal_remaining and indivisible equal-level reserve semantics.",
			"Historical V04 VIP interception risk remains historical and is excluded from post-V05 mandatory classification.",
			"No timer, normal objective, VIP content, or canonical data tuning is authorized by this report.",
		],
		"validation_errors": validation_errors,
	}
	_write_report(report)
	if validation_errors.is_empty() and _report_integrity(report):
		print("M17_CANONICAL_SCREENING_V06_R01_RESULT=PASS levels=%d classes=%d trials=%d forced=%d/25 surplus=%d/25" % [levels.size(), classes.size(), classes.size() * TRIALS_PER_CLASS, vip_forced_count, vip_surplus_count])
		quit(0)
		return
	print("M17_CANONICAL_SCREENING_V06_R01_RESULT=FAIL errors=%s" % "; ".join(validation_errors))
	quit(1)


func _summarize_class(class_record: Dictionary, trials: Array[Dictionary]) -> Dictionary:
	var counts := {"completed": 0, "timeout": 0, "danger": 0, "harness_abort": 0}
	var completion_times: Array = []
	var merges: Array = []
	var peak_live: Array = []
	var occupancy: Array = []
	var rail: Array = []
	var contacts: Array = []
	for trial in trials:
		var outcome := str(trial.get("outcome", ""))
		if counts.has(outcome):
			counts[outcome] = int(counts[outcome]) + 1
		if outcome == HARNESS_SCRIPT.OUTCOME_COMPLETED:
			completion_times.append(float(trial.get("elapsed_sec", 0.0)))
		merges.append(float(trial.get("merge_count", 0)))
		peak_live.append(float(trial.get("peak_live_drinks", 0)))
		occupancy.append(float(trial.get("peak_board_occupancy", 0.0)))
		rail.append(float(trial.get("rail_contact_count", 0)))
		contacts.append(float(trial.get("contact_count", 0)))
	var flags: Array = []
	if int(counts["completed"]) > 0:
		flags.append("SOLVER_FEASIBLE")
	elif trials.size() == HIGH_RISK_TRIAL_COUNT:
		flags.append("HIGH_RISK_SOLVER_FAILURE")
	else:
		flags.append("SCREENING_FAILURE_NEEDS_CONFIRMATION")
	return {
		"class_id": str(class_record["class_id"]),
		"signature": class_record["signature"],
		"representative": int(class_record["representative"]),
		"member_level_ids": class_record["member_level_ids"],
		"evidence_source": "V06_R01_FRESH_1_TRIAL_CANONICAL_SCALE",
		"evidence_source_level": int(class_record["representative"]),
		"policy_name": POLICY_NAME,
		"engine_time_scale": TIME_SCALE,
		"trial_count": trials.size(),
		"completed_count": int(counts["completed"]),
		"danger_count": int(counts["danger"]),
		"timeout_count": int(counts["timeout"]),
		"harness_abort_count": int(counts["harness_abort"]),
		"completion_rate": float(counts["completed"]) / float(maxi(1, trials.size())),
		"median_completion_time_sec": DIFFICULTY_MODEL.percentile(completion_times, 0.5),
		"median_merge_count": DIFFICULTY_MODEL.percentile(merges, 0.5),
		"median_peak_live_drinks": DIFFICULTY_MODEL.percentile(peak_live, 0.5),
		"median_peak_occupancy": DIFFICULTY_MODEL.percentile(occupancy, 0.5),
		"median_rail_proxy_events": DIFFICULTY_MODEL.percentile(rail, 0.5),
		"median_contact_count": DIFFICULTY_MODEL.percentile(contacts, 0.5),
		"physical_screening_flags": flags,
		"trials": trials,
	}


func _normal_remaining(level_definition: Dictionary) -> Dictionary:
	var remaining: Dictionary = {}
	for order in level_definition.get("orders", []):
		var level := int(order.get("cocktail_level", 0))
		remaining[level] = int(remaining.get(level, 0)) + maxi(0, int(order.get("quantity", 0)))
	return remaining


func _minimal_vip_intermediate_board(level_definition: Dictionary, vip_level: int) -> Array[int]:
	var board: Array[int] = []
	for order in level_definition.get("orders", []):
		var normal_level := int(order.get("cocktail_level", 0))
		var quantity := maxi(0, int(order.get("quantity", 0)))
		if normal_level < vip_level:
			continue
		for _order_index in quantity:
			for _piece_index in (1 << (normal_level - vip_level)):
				board.append(vip_level)
	return board


func _forced_capture_count(normal_remaining: Dictionary, minimal_board: Array[int], vip_level: int) -> int:
	var working := minimal_board.duplicate()
	var captures := 0
	while working.has(vip_level):
		if not VIP_MODEL.candidate_is_surplus(normal_remaining, working, vip_level):
			break
		working.erase(vip_level)
		captures += 1
	return captures


func _post_v05_vip_semantics(level_definition: Dictionary) -> Dictionary:
	var vip_value: Variant = level_definition.get("vip", null)
	if not vip_value is Dictionary or not bool(vip_value.get("enabled", false)):
		return {"enabled": false, "vip_level": 0, "vip_quantity": 0, "forced_capture_count": 0, "surplus_possible": false, "classification": "NONE"}
	var vip_level := int(vip_value.get("cocktail_level", 0))
	var remaining := _normal_remaining(level_definition)
	var minimal_board := _minimal_vip_intermediate_board(level_definition, vip_level)
	var surplus_board := minimal_board.duplicate()
	surplus_board.append(vip_level)
	return {
		"enabled": true,
		"vip_level": vip_level,
		"vip_quantity": int(vip_value.get("quantity", 0)),
		"normal_remaining": remaining,
		"minimal_mandatory_board": minimal_board,
		"forced_capture_count": _forced_capture_count(remaining, minimal_board, vip_level),
		"surplus_possible": VIP_MODEL.candidate_is_surplus(remaining, surplus_board, vip_level),
		"classification": "POST_V05_OPTIONAL_SURPLUS_ONLY",
	}


func _action_log_is_legal(action_log: Array) -> bool:
	if action_log.is_empty():
		return false
	for action in action_log:
		if not action.has_all(["x_position", "lane_index", "decision_reason", "same_level_target_found", "target_instance_id"]):
			return false
		var lane_index := int(action["lane_index"])
		if lane_index < 0 or lane_index >= HARNESS_SCRIPT.LANE_X_POSITIONS.size():
			return false
		var known_x := false
		for lane_x in HARNESS_SCRIPT.LANE_X_POSITIONS:
			if is_equal_approx(float(action["x_position"]), float(lane_x)):
				known_x = true
				break
		if not known_x:
			return false
	return true


func _classification_definitions() -> Dictionary:
	return {
		"SOLVER_FEASIBLE": "at least one of one fresh canonical-scale MERGE_AWARE_V01 trials completed",
		"HIGH_RISK_SOLVER_FAILURE": "exact class received five fresh canonical-scale trials and zero completed; this V06-R01 one-trial screen does not assign it",
		"SCREENING_FAILURE_NEEDS_CONFIRMATION": "one canonical-scale trial failed to complete; not an impossibility claim",
		"MATHEMATICALLY_UNREACHABLE": "mandatory target is outside legal L1-L3 equal-merge closure or structurally invalid",
		"ANALYTICAL_TIMER_RATIO_OUTLIER": "absolute timer/cost ratio deviation from cohort median is greater than 5 percent",
		"VIP_INTERCEPTION_RISK_HISTORICAL_ONLY": "historical V04 analytical risk retained as a labeled non-post-fix classification",
	}


func _report_integrity(report: Dictionary) -> bool:
	if str(report.get("report_version", "")) != "V06-R01":
		return false
	if int(report.get("level_count", 0)) != EXPECTED_LEVEL_COUNT or int(report.get("challenge_class_count", 0)) != EXPECTED_CLASS_COUNT:
		return false
	if float(report.get("engine_time_scale", 0.0)) != TIME_SCALE or str(report.get("policy_name", "")) != POLICY_NAME:
		return false
	if report.get("levels", []).size() != EXPECTED_LEVEL_COUNT or report.get("challenge_classes", []).size() != EXPECTED_CLASS_COUNT:
		return false
	for class_record in report.get("challenge_classes", []):
		if int(class_record.get("trial_count", 0)) != TRIALS_PER_CLASS or class_record.get("trials", []).size() != TRIALS_PER_CLASS:
			return false
		if class_record.get("physical_screening_flags", []).is_empty():
			return false
		for trial in class_record.get("trials", []):
			if str(trial.get("policy_name", "")) != POLICY_NAME or not is_equal_approx(float(trial.get("engine_time_scale", 0.0)), TIME_SCALE):
				return false
			if trial.get("telemetry", {}).is_empty() or trial.get("action_log", []).is_empty():
				return false
	for level_record in report.get("levels", []):
		if str(level_record.get("class_id", "")).is_empty() or level_record.get("physical_screening_flags", []).is_empty():
			return false
	return true


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode().to_upper()


func _drink_max_level() -> int:
	var drink_script = preload("res://scripts/drink.gd")
	return drink_script.max_level()


func _write_minimal_failure() -> void:
	var report := {"report_version": "V06-R01_FAILURE", "validation_errors": validation_errors, "canonical_data_sha256": _sha256(LEVELS_PATH)}
	var file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()


func _write_report(report: Dictionary) -> void:
	var json_file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "\t"))
	json_file.close()
	var markdown := "# BCM-M17 V06-R01 Post-V05 Canonical Sunny Cove Rescreen\n\n"
	markdown += "Status: **%s**; policy: `%s`; Engine.time_scale: `%.1f`; canonical data SHA-256: `%s`.\n\n" % [str(report["status"]), str(report["policy_name"]), float(report["engine_time_scale"]), str(report["canonical_data_sha256"])]
	markdown += "V04 SHA-256: `%s`; V05 SHA-256: `%s`.\n\n" % [str(report["v04_report_sha256"]), str(report["v05_report_sha256"])]
	markdown += "Fresh evidence: `%d` classes x `%d` trial = `%d` trials; levels: `%d`.\n\n" % [int(report["challenge_class_count"]), int(report["trial_count_per_class"]), int(report["challenge_class_count"]) * int(report["trial_count_per_class"]), int(report["level_count"])]
	markdown += "## Interpretation boundary\n\n"
	for boundary in report["interpretation_boundary"]:
		markdown += "- %s\n" % str(boundary)
	markdown += "\n## Post-V05 VIP semantics\n\n"
	markdown += "- Forced captures on minimal mandatory paths: `%d/25`.\n" % int(report["post_v05_vip_summary"]["forced_capture_count"])
	markdown += "- Surplus VIP paths: `%d/25`.\n\n" % int(report["post_v05_vip_summary"]["surplus_path_count"])
	markdown += "## Challenge classes\n\n"
	markdown += "| Class | Representative | Members | Trial count | Complete | Danger | Timeout | Abort | Flags |\n|---|---:|---|---:|---:|---:|---:|---:|---|\n"
	for class_record in report["challenge_classes"]:
		markdown += "| %s | L%d | %s | %d | %d | %d | %d | %d | %s |\n" % [str(class_record["class_id"]), int(class_record["representative"]), ", ".join(class_record["member_level_ids"].map(func(value): return "L%d" % int(value))), int(class_record["trial_count"]), int(class_record["completed_count"]), int(class_record["danger_count"]), int(class_record["timeout_count"]), int(class_record["harness_abort_count"]), ", ".join(class_record["physical_screening_flags"])]
	markdown += "\n## All 100 levels\n\n"
	markdown += "| Level | Class | Cost | Timer | Reachability | Post-V05 VIP | Physical flags |\n|---:|---|---:|---:|---|---|---|\n"
	for level_record in report["levels"]:
		var vip: Dictionary = level_record["post_v05_vip_optionality"]
		var vip_text := "none" if not bool(vip["enabled"]) else "L%d x%d forced=%d surplus=%s" % [int(vip["vip_level"]), int(vip["vip_quantity"]), int(vip["forced_capture_count"]), str(vip["surplus_possible"])]
		markdown += "| %d | %s | %d | %.1f | %s | %s | %s |\n" % [int(level_record["level_id"]), str(level_record["class_id"]), int(level_record["normal_objective_cost"]), float(level_record["canonical_timer_sec"]), str(level_record["reachability"]["classification"]), vip_text, ", ".join(level_record["physical_screening_flags"])]
	markdown += "\n## Validation\n\n- Report integrity: `%s`.\n- Validation errors: `%s`.\n- This is builder screening evidence for independent GPT audit, not owner acceptance.\n" % [str(_report_integrity(report)), str(report["validation_errors"])]
	var md_file := FileAccess.open(OUT_MD, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()
