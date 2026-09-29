extends SceneTree

## BCM-M17 V07 five-trial confirmation runner.
## Evidence-only: it imports and validates V06-R02 evidence, then runs exactly
## four new post-V05 trials for each audited confirmation candidate.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const DIFFICULTY_MODEL = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const VIP_MODEL = preload("res://scripts/campaign/m17_vip_optionality_model.gd")

const SESSION_DIR := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION"
const LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const V06_R02_PATH := SESSION_DIR + "/M17_CANONICAL_SCREENING_V06_R02.json"
const V05_PATH := SESSION_DIR + "/M17_VIP_OPTIONALITY_V05.json"
const OUT_JSON := SESSION_DIR + "/M17_CANONICAL_CONFIRMATION_V07.json"
const OUT_MD := SESSION_DIR + "/M17_CANONICAL_CONFIRMATION_V07.md"
const POLICY_NAME := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const TIME_SCALE := 1.0
const NEW_SEED_BASE := 17700000
const NEW_TRIALS_PER_CANDIDATE := 4
const CONFIRMATION_TRIAL_COUNT := 5
const EXPECTED_LEVEL_COUNT := 100
const EXPECTED_CLASS_COUNT := 45
const EXPECTED_CANDIDATE_COUNT := 42
const EXPECTED_NEW_TRIAL_COUNT := 168
const EXPECTED_V06_R02_SHA256 := "4A555D786A02EB1041A500316E007DD7F87E1C40DF8A28DE01739FC81B1AAA89"
const EXPECTED_CANONICAL_SHA256 := "9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495"
const EXPECTED_CANDIDATE_IDS := [
	"C01", "C03", "C04", "C06", "C07", "C08", "C09", "C11", "C12", "C13",
	"C14", "C15", "C16", "C17", "C18", "C19", "C20", "C21", "C22", "C23",
	"C24", "C25", "C26", "C27", "C28", "C29", "C30", "C31", "C32", "C33",
	"C34", "C35", "C36", "C37", "C38", "C39", "C40", "C41", "C42", "C43",
	"C44", "C45",
]
const EXPECTED_CARRIED_FORWARD_IDS := ["C02", "C05", "C10"]

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

	var canonical_sha := _sha256(LEVELS_PATH)
	if canonical_sha != EXPECTED_CANONICAL_SHA256:
		validation_errors.append("canonical data hash changed: %s" % canonical_sha)
	var source_sha := _sha256(V06_R02_PATH)
	if source_sha != EXPECTED_V06_R02_SHA256:
		validation_errors.append("V06-R02 source hash mismatch: %s" % source_sha)
	var source_report: Dictionary = _load_json(V06_R02_PATH)
	var v05: Dictionary = _load_json(V05_PATH)
	_validate_source_report(source_report, source_sha, v05)

	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	var canonical_classes: Array[Dictionary] = MODEL_SCRIPT.build_challenge_classes(levels)
	if levels.size() != EXPECTED_LEVEL_COUNT:
		validation_errors.append("expected %d levels, found %d" % [EXPECTED_LEVEL_COUNT, levels.size()])
	if canonical_classes.size() != EXPECTED_CLASS_COUNT:
		validation_errors.append("expected %d classes, found %d" % [EXPECTED_CLASS_COUNT, canonical_classes.size()])

	var source_classes_by_id: Dictionary = {}
	for source_class in source_report.get("challenge_classes", []):
		if source_class is Dictionary:
			source_classes_by_id[str(source_class.get("class_id", ""))] = source_class
	var canonical_by_id: Dictionary = {}
	for canonical_class in canonical_classes:
		canonical_by_id[str(canonical_class["class_id"])] = canonical_class
	var candidate_ids: Array[String] = []
	for source_class in source_report.get("challenge_classes", []):
		if source_class is Dictionary and source_class.get("physical_screening_flags", []).has("SCREENING_FAILURE_NEEDS_CONFIRMATION"):
			candidate_ids.append(str(source_class.get("class_id", "")))
	candidate_ids.sort()
	if candidate_ids != EXPECTED_CANDIDATE_IDS:
		validation_errors.append("derived candidate set mismatch: %s" % ",".join(candidate_ids))
	if candidate_ids.size() != EXPECTED_CANDIDATE_COUNT:
		validation_errors.append("expected %d candidates, found %d" % [EXPECTED_CANDIDATE_COUNT, candidate_ids.size()])

	var carried_ids: Array[String] = []
	for source_class in source_report.get("challenge_classes", []):
		if source_class is Dictionary and source_class.get("physical_screening_flags", []).has("SOLVER_FEASIBLE"):
			carried_ids.append(str(source_class.get("class_id", "")))
	carried_ids.sort()
	if carried_ids != EXPECTED_CARRIED_FORWARD_IDS:
		validation_errors.append("V06-R02 carried-forward feasible set mismatch: %s" % ",".join(carried_ids))
	if not validation_errors.is_empty():
		_write_minimal_failure()
		quit(1)
		return

	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(TIME_SCALE)
	var all_used_seeds: Dictionary = {}
	var class_records: Array[Dictionary] = []
	var new_trial_count := 0
	for canonical_class in canonical_classes:
		var class_id := str(canonical_class["class_id"])
		var source_class: Dictionary = source_classes_by_id.get(class_id, {})
		_validate_class_mapping(canonical_class, source_class)
		var source_trials: Array = source_class.get("trials", [])
		if source_trials.size() != 1:
			validation_errors.append("%s V06-R02 source trial count is %d" % [class_id, source_trials.size()])
			continue
		var source_trial: Dictionary = source_trials[0]
		_validate_trial(source_trial, class_id, int(canonical_class["representative"]), harness, all_used_seeds, "V06-R02")
		if candidate_ids.has(class_id):
			var aggregate: Array[Dictionary] = [source_trial]
			var new_seeds: Array[int] = []
			var representative := int(canonical_class["representative"])
			for new_trial_index in range(1, NEW_TRIALS_PER_CANDIDATE + 1):
				var seed_value := NEW_SEED_BASE + representative * 100 + new_trial_index
				if all_used_seeds.has(seed_value):
					validation_errors.append("duplicate V07 seed %d" % seed_value)
				all_used_seeds[seed_value] = true
				new_seeds.append(seed_value)
				print("M17 V07 confirmation %s representative L%d trial=%d seed=%d time_scale=%.1f" % [class_id, representative, new_trial_index, seed_value, harness.get_time_scale()])
				var result: Dictionary = await harness.run_trial(database, "sunny_cove", representative, seed_value, [], POLICY_NAME)
				_validate_trial(result, class_id, representative, harness, {}, "V07")
				aggregate.append(result)
				new_trial_count += 1
			class_records.append(_summarize_candidate(canonical_class, source_trial, aggregate, new_seeds))
		else:
			class_records.append(_summarize_carried_forward(canonical_class, source_trial))

	if new_trial_count != EXPECTED_NEW_TRIAL_COUNT:
		validation_errors.append("expected %d new trials, ran %d" % [EXPECTED_NEW_TRIAL_COUNT, new_trial_count])
	if all_used_seeds.size() != EXPECTED_NEW_TRIAL_COUNT + EXPECTED_CLASS_COUNT:
		validation_errors.append("expected %d unique aggregate seeds, found %d" % [EXPECTED_NEW_TRIAL_COUNT + EXPECTED_CLASS_COUNT, all_used_seeds.size()])

	var timer_scan := MODEL_SCRIPT.timer_scan(levels)
	var timer_by_level: Dictionary = {}
	for timer_record in timer_scan["levels"]:
		timer_by_level[int(timer_record["level_id"])] = timer_record
	var class_by_level: Dictionary = {}
	for canonical_class in canonical_classes:
		for level_id in canonical_class["member_level_ids"]:
			class_by_level[int(level_id)] = str(canonical_class["class_id"])
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

	if vip_forced_count != 0 or vip_surplus_count != 25:
		validation_errors.append("post-V05 VIP aggregate was forced=%d/25 surplus=%d/25" % [vip_forced_count, vip_surplus_count])
	if int(v05.get("post_v05_forced_capture_count", -1)) != 0 or int(v05.get("post_v05_surplus_path_count", -1)) != 25:
		validation_errors.append("V05 source semantics are not 0/25 and 25/25")

	var final_feasible_ids: Array[String] = []
	var final_high_risk_ids: Array[String] = []
	for class_record in class_records:
		var flags: Array = class_record["physical_screening_flags"]
		if flags.has("SOLVER_FEASIBLE"):
			final_feasible_ids.append(str(class_record["class_id"]))
		if flags.has("HIGH_RISK_SOLVER_FAILURE"):
			final_high_risk_ids.append(str(class_record["class_id"]))
	final_feasible_ids.sort()
	final_high_risk_ids.sort()
	var report := {
		"schema_version": 1,
		"milestone": "BCM-M17",
		"report_version": "V07",
		"status": "PASS" if validation_errors.is_empty() else "FAIL",
		"island_id": "sunny_cove",
		"canonical_data_path": LEVELS_PATH,
		"canonical_data_sha256": canonical_sha,
		"v06_r02_report_sha256": source_sha,
		"v05_report_sha256": _sha256(V05_PATH),
		"policy_name": POLICY_NAME,
		"engine_time_scale": TIME_SCALE,
		"new_seed_base": NEW_SEED_BASE,
		"new_trials_per_candidate": NEW_TRIALS_PER_CANDIDATE,
		"confirmation_trials_per_candidate": CONFIRMATION_TRIAL_COUNT,
		"level_count": levels.size(),
		"challenge_class_count": canonical_classes.size(),
		"confirmation_candidate_count": candidate_ids.size(),
		"new_trial_count": new_trial_count,
		"aggregate_confirmation_trial_count": candidate_ids.size() * CONFIRMATION_TRIAL_COUNT,
		"carried_forward_feasible_class_ids": EXPECTED_CARRIED_FORWARD_IDS,
		"final_solver_feasible_class_count": final_feasible_ids.size(),
		"final_solver_feasible_class_ids": final_feasible_ids,
		"final_high_risk_solver_failure_count": final_high_risk_ids.size(),
		"final_high_risk_solver_failure_class_ids": final_high_risk_ids,
		"challenge_signature_definition": "ordered normal objectives/quantities + timer + VIP enabled/level/quantity",
		"classification_definitions": _classification_definitions(),
		"normal_spawn_levels": [1, 2, 3],
		"maximum_drink_level": max_level,
		"reachable_closure": MODEL_SCRIPT.reachable_closure(max_level),
		"post_v05_vip_summary": {
			"forced_capture_count": vip_forced_count,
			"forced_capture_denominator": 25,
			"surplus_path_count": vip_surplus_count,
			"surplus_path_denominator": 25,
			"vip_cost_added_to_normal_timers": false,
			"v05_report_summary": {
				"forced_capture_count": int(v05.get("post_v05_forced_capture_count", -1)),
				"surplus_path_count": int(v05.get("post_v05_surplus_path_count", -1)),
			},
		},
		"challenge_classes": class_records,
		"levels": level_records,
		"interpretation_boundary": [
			"The 42 candidate aggregates contain the audited V06-R02 trial plus exactly four new post-V05 MERGE_AWARE_V01 trials at Engine.time_scale = 1.0.",
			"A completion demonstrates one solver-feasible path, not human difficulty or owner acceptance.",
			"HIGH_RISK_SOLVER_FAILURE is exact-class 0/5 solver evidence, not proof of human impossibility.",
			"No timer, normal objective, VIP content, reward, or canonical data tuning is authorized by this report.",
			"Historical pre-V05 V03A/V04 trials are not counted toward the V07 five-trial threshold.",
		],
		"validation_errors": validation_errors,
	}
	_write_report(report)
	var serialized_report: Dictionary = _load_json(OUT_JSON)
	var integrity_ok := validation_errors.is_empty() and _report_integrity(serialized_report, harness)
	if integrity_ok:
		print("M17_CANONICAL_CONFIRMATION_V07_RESULT=PASS levels=%d classes=%d candidates=%d new_trials=%d aggregate_candidate_trials=%d feasible=%d high_risk=%d forced=%d/25 surplus=%d/25" % [levels.size(), canonical_classes.size(), candidate_ids.size(), new_trial_count, candidate_ids.size() * CONFIRMATION_TRIAL_COUNT, final_feasible_ids.size(), final_high_risk_ids.size(), vip_forced_count, vip_surplus_count])
		quit(0)
		return
	print("M17_CANONICAL_CONFIRMATION_V07_RESULT=FAIL errors=%s integrity=%s" % ["; ".join(validation_errors), str(integrity_ok)])
	quit(1)


func _validate_source_report(source_report: Dictionary, source_sha: String, v05: Dictionary) -> void:
	if source_sha != EXPECTED_V06_R02_SHA256:
		return
	if str(source_report.get("report_version", "")) != "V06-R02" or str(source_report.get("status", "")) != "PASS":
		validation_errors.append("V06-R02 source version/status invalid")
	if int(source_report.get("level_count", 0)) != EXPECTED_LEVEL_COUNT or int(source_report.get("challenge_class_count", 0)) != EXPECTED_CLASS_COUNT:
		validation_errors.append("V06-R02 source shape invalid")
	if str(source_report.get("policy_name", "")) != POLICY_NAME or not is_equal_approx(float(source_report.get("engine_time_scale", 0.0)), TIME_SCALE):
		validation_errors.append("V06-R02 source policy/time scale invalid")
	if source_report.get("challenge_classes", []).size() != EXPECTED_CLASS_COUNT or source_report.get("levels", []).size() != EXPECTED_LEVEL_COUNT:
		validation_errors.append("V06-R02 source arrays invalid")
	if int(source_report.get("post_v05_vip_summary", {}).get("forced_capture_count", -1)) != 0 or int(source_report.get("post_v05_vip_summary", {}).get("surplus_path_count", -1)) != 25:
		validation_errors.append("V06-R02 source VIP summary invalid")
	if int(v05.get("post_v05_forced_capture_count", -1)) != 0 or int(v05.get("post_v05_surplus_path_count", -1)) != 25:
		validation_errors.append("V05 source report invalid")


func _validate_class_mapping(canonical_class: Dictionary, source_class: Dictionary) -> void:
	var class_id := str(canonical_class.get("class_id", ""))
	if source_class.is_empty():
		validation_errors.append("missing V06-R02 class %s" % class_id)
		return
	if int(source_class.get("representative", -1)) != int(canonical_class["representative"]):
		validation_errors.append("%s representative mapping changed" % class_id)
	if source_class.get("member_level_ids", []) != canonical_class.get("member_level_ids", []):
		validation_errors.append("%s member mapping changed" % class_id)
	if source_class.get("signature", {}) != canonical_class.get("signature", {}):
		validation_errors.append("%s signature mapping changed" % class_id)


func _validate_trial(trial: Dictionary, class_id: String, representative: int, harness, seed_registry: Dictionary, provenance: String) -> void:
	if str(trial.get("island_id", "")) != "sunny_cove" or int(trial.get("level_id", -1)) != representative:
		validation_errors.append("%s %s level/island mismatch" % [class_id, provenance])
	if str(trial.get("policy_name", "")) != POLICY_NAME:
		validation_errors.append("%s %s policy mismatch" % [class_id, provenance])
	if not harness.validate_telemetry(trial).is_empty():
		validation_errors.append("%s %s telemetry schema invalid" % [class_id, provenance])
	if not _action_log_is_legal(trial.get("action_log", [])):
		validation_errors.append("%s %s action log invalid" % [class_id, provenance])
	var trial_seed := int(trial.get("seed", 0))
	if trial_seed <= 0:
		validation_errors.append("%s %s invalid seed" % [class_id, provenance])
	if not seed_registry.is_empty():
		if seed_registry.has(trial_seed):
			validation_errors.append("duplicate source seed %d" % trial_seed)
		seed_registry[trial_seed] = true


func _summarize_candidate(class_record: Dictionary, source_trial: Dictionary, trials: Array[Dictionary], new_seeds: Array[int]) -> Dictionary:
	var summary := _trial_summary(trials)
	var flags: Array = ["SOLVER_FEASIBLE"] if int(summary["completed_count"]) > 0 else ["HIGH_RISK_SOLVER_FAILURE"]
	return {
		"class_id": str(class_record["class_id"]),
		"signature": class_record["signature"],
		"representative": int(class_record["representative"]),
		"member_level_ids": class_record["member_level_ids"],
		"evidence_source": "V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS",
		"evidence_source_level": int(class_record["representative"]),
		"carried_forward_from_v06_r02": false,
		"source_trial_provenance": "audited M17_CANONICAL_SCREENING_V06_R02 exact trial 1",
		"source_trial_seed": int(source_trial.get("seed", 0)),
		"v07_new_trial_seeds": new_seeds,
		"policy_name": POLICY_NAME,
		"engine_time_scale": TIME_SCALE,
		"trial_count": trials.size(),
		"confirmation_trial_count": trials.size(),
		"completed_count": summary["completed_count"],
		"danger_count": summary["danger_count"],
		"timeout_count": summary["timeout_count"],
		"harness_abort_count": summary["harness_abort_count"],
		"completion_rate": summary["completion_rate"],
		"median_completion_time_sec": summary["median_completion_time_sec"],
		"median_merge_count": summary["median_merge_count"],
		"median_peak_live_drinks": summary["median_peak_live_drinks"],
		"median_peak_occupancy": summary["median_peak_occupancy"],
		"median_rail_proxy_events": summary["median_rail_proxy_events"],
		"median_contact_count": summary["median_contact_count"],
		"physical_screening_flags": flags,
		"trials": trials,
	}


func _summarize_carried_forward(class_record: Dictionary, source_trial: Dictionary) -> Dictionary:
	var summary := _trial_summary([source_trial])
	return {
		"class_id": str(class_record["class_id"]),
		"signature": class_record["signature"],
		"representative": int(class_record["representative"]),
		"member_level_ids": class_record["member_level_ids"],
		"evidence_source": "V06_R02_CARRIED_FORWARD_1_TRIAL",
		"evidence_source_level": int(class_record["representative"]),
		"carried_forward_from_v06_r02": true,
		"source_trial_provenance": "audited M17_CANONICAL_SCREENING_V06_R02 exact trial 1",
		"source_trial_seed": int(source_trial.get("seed", 0)),
		"v07_new_trial_seeds": [],
		"policy_name": POLICY_NAME,
		"engine_time_scale": TIME_SCALE,
		"trial_count": 1,
		"confirmation_trial_count": 0,
		"completed_count": summary["completed_count"],
		"danger_count": summary["danger_count"],
		"timeout_count": summary["timeout_count"],
		"harness_abort_count": summary["harness_abort_count"],
		"completion_rate": summary["completion_rate"],
		"median_completion_time_sec": summary["median_completion_time_sec"],
		"median_merge_count": summary["median_merge_count"],
		"median_peak_live_drinks": summary["median_peak_live_drinks"],
		"median_peak_occupancy": summary["median_peak_occupancy"],
		"median_rail_proxy_events": summary["median_rail_proxy_events"],
		"median_contact_count": summary["median_contact_count"],
		"physical_screening_flags": ["SOLVER_FEASIBLE"],
		"trials": [source_trial],
	}


func _trial_summary(trials: Array[Dictionary]) -> Dictionary:
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
	return {
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
		"SOLVER_FEASIBLE": "at least one completion in the carried-forward V06-R02 trial or exact five-trial post-V05 aggregate",
		"HIGH_RISK_SOLVER_FAILURE": "exact candidate class received five post-V05 canonical-scale trials and zero completed; not proof of human impossibility",
		"MATHEMATICALLY_UNREACHABLE": "mandatory target is outside legal L1-L3 equal-merge closure or structurally invalid",
		"ANALYTICAL_TIMER_RATIO_OUTLIER": "absolute timer/cost ratio deviation from cohort median is greater than 5 percent",
		"VIP_INTERCEPTION_RISK_HISTORICAL_ONLY": "historical analytical risk retained as a labeled non-post-fix classification",
	}


func _report_integrity(report: Dictionary, harness) -> bool:
	if str(report.get("report_version", "")) != "V07" or str(report.get("status", "")) != "PASS":
		return false
	if int(report.get("level_count", 0)) != EXPECTED_LEVEL_COUNT or int(report.get("challenge_class_count", 0)) != EXPECTED_CLASS_COUNT:
		return false
	if int(report.get("confirmation_candidate_count", 0)) != EXPECTED_CANDIDATE_COUNT or int(report.get("new_trial_count", 0)) != EXPECTED_NEW_TRIAL_COUNT:
		return false
	if float(report.get("engine_time_scale", 0.0)) != TIME_SCALE or str(report.get("policy_name", "")) != POLICY_NAME:
		return false
	if report.get("levels", []).size() != EXPECTED_LEVEL_COUNT or report.get("challenge_classes", []).size() != EXPECTED_CLASS_COUNT:
		return false
	var all_seeds: Dictionary = {}
	for class_record in report.get("challenge_classes", []):
		var class_id := str(class_record.get("class_id", ""))
		var trials: Array = class_record.get("trials", [])
		var is_candidate := EXPECTED_CANDIDATE_IDS.has(class_id)
		if is_candidate and trials.size() != CONFIRMATION_TRIAL_COUNT:
			return false
		if not is_candidate and trials.size() != 1:
			return false
		if is_candidate and class_record.get("v07_new_trial_seeds", []).size() != NEW_TRIALS_PER_CANDIDATE:
			return false
		if not is_candidate and not bool(class_record.get("carried_forward_from_v06_r02", false)):
			return false
		if class_record.get("physical_screening_flags", []).has("SCREENING_FAILURE_NEEDS_CONFIRMATION"):
			return false
		for trial in trials:
			if not harness.validate_telemetry(trial).is_empty() or not _action_log_is_legal(trial.get("action_log", [])):
				return false
			var seed := int(trial.get("seed", 0))
			if all_seeds.has(seed):
				return false
			all_seeds[seed] = true
	if all_seeds.size() != EXPECTED_NEW_TRIAL_COUNT + EXPECTED_CLASS_COUNT:
		return false
	if int(report.get("post_v05_vip_summary", {}).get("forced_capture_count", -1)) != 0 or int(report.get("post_v05_vip_summary", {}).get("surplus_path_count", -1)) != 25:
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
	if not FileAccess.file_exists(path):
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode().to_upper()


func _drink_max_level() -> int:
	var drink_script = preload("res://scripts/drink.gd")
	return drink_script.max_level()


func _write_minimal_failure() -> void:
	var report := {"report_version": "V07_FAILURE", "status": "FAIL", "validation_errors": validation_errors, "canonical_data_sha256": _sha256(LEVELS_PATH), "v06_r02_report_sha256": _sha256(V06_R02_PATH)}
	var file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()


func _write_report(report: Dictionary) -> void:
	var json_file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "\t"))
	json_file.close()
	var markdown := "# BCM-M17 V07 Five-Trial Canonical Confirmation\n\n"
	markdown += "Status: **%s**; policy: `%s`; Engine.time_scale: `%.1f`; canonical SHA-256: `%s`.\n\n" % [str(report["status"]), str(report["policy_name"]), float(report["engine_time_scale"]), str(report["canonical_data_sha256"])]
	markdown += "V06-R02 source SHA-256: `%s`; V05 SHA-256: `%s`.\n\n" % [str(report["v06_r02_report_sha256"]), str(report["v05_report_sha256"])]
	markdown += "Confirmation candidates: `%d`; new trials: `%d`; candidate aggregates: `%d x 5`; levels: `%d`; classes: `%d`.\n\n" % [int(report["confirmation_candidate_count"]), int(report["new_trial_count"]), int(report["confirmation_candidate_count"]), int(report["level_count"]), int(report["challenge_class_count"])]
	markdown += "Final solver-feasible: `%d` (%s).\n\n" % [int(report["final_solver_feasible_class_count"]), ", ".join(report["final_solver_feasible_class_ids"])]
	markdown += "Final high-risk 0/5: `%d` (%s).\n\n" % [int(report["final_high_risk_solver_failure_count"]), ", ".join(report["final_high_risk_solver_failure_class_ids"])]
	markdown += "## Interpretation boundary\n\n"
	for boundary in report["interpretation_boundary"]:
		markdown += "- %s\n" % str(boundary)
	markdown += "\n## Post-V05 VIP semantics\n\n- Forced captures: `%d/25`.\n- Surplus paths: `%d/25`.\n- VIP cost added to normal timers: `%s`.\n\n" % [int(report["post_v05_vip_summary"]["forced_capture_count"]), int(report["post_v05_vip_summary"]["surplus_path_count"]), str(report["post_v05_vip_summary"]["vip_cost_added_to_normal_timers"])]
	markdown += "## Challenge classes\n\n| Class | Representative | Members | Evidence | Trials | Complete | Danger | Timeout | Abort | Flags |\n|---|---:|---|---|---:|---:|---:|---:|---:|---|\n"
	for class_record in report["challenge_classes"]:
		markdown += "| %s | L%d | %s | %s | %d | %d | %d | %d | %d | %s |\n" % [str(class_record["class_id"]), int(class_record["representative"]), ", ".join(class_record["member_level_ids"].map(func(value): return "L%d" % int(value))), str(class_record["evidence_source"]), int(class_record["trial_count"]), int(class_record["completed_count"]), int(class_record["danger_count"]), int(class_record["timeout_count"]), int(class_record["harness_abort_count"]), ", ".join(class_record["physical_screening_flags"])]
	markdown += "\n## All 100 levels\n\n| Level | Class | Cost | Timer | Reachability | Post-V05 VIP | Physical flags |\n|---:|---|---:|---:|---|---|---|\n"
	for level_record in report["levels"]:
		var vip: Dictionary = level_record["post_v05_vip_optionality"]
		var vip_text := "none" if not bool(vip["enabled"]) else "L%d x%d forced=%d surplus=%s" % [int(vip["vip_level"]), int(vip["vip_quantity"]), int(vip["forced_capture_count"]), str(vip["surplus_possible"])]
		markdown += "| %d | %s | %d | %.1f | %s | %s | %s |\n" % [int(level_record["level_id"]), str(level_record["class_id"]), int(level_record["normal_objective_cost"]), float(level_record["canonical_timer_sec"]), str(level_record["reachability"]["classification"]), vip_text, ", ".join(level_record["physical_screening_flags"])]
	markdown += "\n## Validation\n\n- Validation errors: `%s`.\n- Report is builder evidence for independent ChatGPT audit, not owner acceptance.\n" % str(report["validation_errors"])
	var md_file := FileAccess.open(OUT_MD, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()
