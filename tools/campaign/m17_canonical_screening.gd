extends SceneTree

## BCM-M17 V04 full canonical screening runner.
##
## This runner flags the current 100-level Sunny Cove data. It never edits
## campaign data and never changes the qualified MERGE_AWARE_V01 policy.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const DIFFICULTY_MODEL = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const GAME_MANAGER_SCRIPT = preload("res://scripts/game_manager.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")

const SESSION_DIR := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION"
const CANONICAL_LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const V03_REPORT_PATH := SESSION_DIR + "/M17_SOLVER_QUALIFICATION_V03.json"
const REPORT_JSON_PATH := SESSION_DIR + "/M17_CANONICAL_SCREENING_V04.json"
const REPORT_MD_PATH := SESSION_DIR + "/M17_CANONICAL_SCREENING_V04.md"
const POLICY_NAME := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const QUALIFICATION_SCALE := 1.0
const V04_SEED_BASE := 17400000
const V03A_SOURCE_LEVELS: Array[int] = [1, 10, 11, 50, 51, 100]
const EXPECTED_LEVEL_COUNT := 100
const EXPECTED_CLASS_COUNT := 45

var validation_errors: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M17 V04 database load failed: %s" % database.get_last_error())
		quit(1)
		return
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	var canonical_sha := _sha256(CANONICAL_LEVELS_PATH)
	if levels.size() != EXPECTED_LEVEL_COUNT:
		validation_errors.append("expected %d levels, found %d" % [EXPECTED_LEVEL_COUNT, levels.size()])
	var classes: Array[Dictionary] = MODEL_SCRIPT.build_challenge_classes(levels)
	if classes.size() != EXPECTED_CLASS_COUNT:
		validation_errors.append("expected %d challenge classes, found %d" % [EXPECTED_CLASS_COUNT, classes.size()])
		_write_discrepancy_report(canonical_sha, levels, classes)
		print("M17_CANONICAL_SCREENING_RESULT=FAIL discrepancy=%s" % "; ".join(validation_errors))
		quit(1)
		return

	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(QUALIFICATION_SCALE)
	var v03_report: Dictionary = _load_json(V03_REPORT_PATH)
	var v03_levels: Dictionary = _index_v03_levels(v03_report)
	var class_records: Array[Dictionary] = []
	var reused_trial_count := 0
	var new_trial_count := 0
	for class_record in classes:
		var source_level := _v03_source_for_class(class_record, v03_levels)
		var trials: Array[Dictionary] = []
		var evidence_source := "V04_SINGLE_TRIAL_SCREEN"
		var evidence_source_level := 0
		if source_level > 0:
			evidence_source = "V03A_5_TRIAL"
			evidence_source_level = source_level
			var source_record: Dictionary = v03_levels.get(source_level, {})
			for trial in source_record.get("trials", []):
				trials.append(trial)
			reused_trial_count += trials.size()
		else:
			var representative := int(class_record["representative"])
			var seed_value := V04_SEED_BASE + representative * 1000
			print("M17 V04 screening C%s representative L%d seed=%d time_scale=%.1f" % [str(class_record["class_id"]), representative, seed_value, harness.get_time_scale()])
			var result: Dictionary = await harness.run_trial(database, "sunny_cove", representative, seed_value, [], POLICY_NAME)
			trials.append(result)
			new_trial_count += 1
			if not harness.validate_telemetry(result).is_empty():
				validation_errors.append("C%s telemetry schema invalid" % str(class_record["class_id"]))
			if str(result.get("policy_name", "")) != POLICY_NAME:
				validation_errors.append("C%s used unexpected policy" % str(class_record["class_id"]))
			if not _action_log_is_legal(result.get("action_log", [])):
				validation_errors.append("C%s action log missing legal decision evidence" % str(class_record["class_id"]))
			if not is_equal_approx(harness.get_time_scale(), QUALIFICATION_SCALE):
				validation_errors.append("C%s was not screened at time scale 1.0" % str(class_record["class_id"]))
			print("  outcome=%s shots=%d merges=%d" % [result.get("outcome", ""), int(result.get("shot_count", 0)), int(result.get("merge_count", 0))])
		var summary := _summarize_class(class_record, evidence_source, evidence_source_level, trials)
		class_records.append(summary)

	var timer_scan := MODEL_SCRIPT.timer_scan(levels)
	var timer_by_level: Dictionary = {}
	for record in timer_scan["levels"]:
		timer_by_level[int(record["level_id"])] = record
	var max_level := _drink_max_level()
	var level_records: Array[Dictionary] = []
	var class_by_id: Dictionary = {}
	for class_record in class_records:
		class_by_id[str(class_record["class_id"])] = class_record
	var class_for_level: Dictionary = {}
	for class_record in classes:
		var class_id := str(class_record["class_id"])
		for member_level in class_record["member_level_ids"]:
			class_for_level[int(member_level)] = class_id
	for level_definition in levels:
		var level_id := int(level_definition["level_id"])
		var class_id := str(class_for_level.get(level_id, ""))
		var class_record: Dictionary = class_by_id.get(class_id, {})
		var reachability := MODEL_SCRIPT.level_reachability(level_definition, max_level)
		var vip_analysis := MODEL_SCRIPT.vip_interception_analysis(level_definition)
		var timer_record: Dictionary = timer_by_level.get(level_id, {})
		var flags: Array = []
		if str(reachability["classification"]) != "NONE":
			flags.append("MATHEMATICALLY_UNREACHABLE")
		if bool(timer_record.get("analytical_timer_ratio_outlier", false)):
			flags.append("ANALYTICAL_TIMER_RATIO_OUTLIER")
		if bool(vip_analysis["vip_interception_risk"]):
			flags.append("VIP_INTERCEPTION_RISK")
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
			"vip_interception": vip_analysis,
			"physical_screening_flags": flags,
		})

	var spatial_candidates := _find_spatial_mix_candidates(class_records)
	_apply_spatial_flags(class_records, level_records, spatial_candidates)
	var precedence_fixtures: Dictionary = await _run_production_precedence_fixtures(database)
	var report := {
		"schema_version": 1,
		"milestone": "BCM-M17",
		"report_version": "V04",
		"island_id": "sunny_cove",
		"canonical_data_path": CANONICAL_LEVELS_PATH,
		"canonical_data_sha256": canonical_sha,
		"policy_name": POLICY_NAME,
		"physics_scale": QUALIFICATION_SCALE,
		"historical_4x_excluded_from_classification": true,
		"level_count": levels.size(),
		"challenge_class_count": classes.size(),
		"challenge_signature_definition": "ordered normal orders with quantity + time_limit_sec + VIP enabled/cocktail_level/quantity; score thresholds and rewards excluded",
		"classification_definitions": _classification_definitions(),
		"normal_spawn_levels": [1, 2, 3],
		"maximum_drink_level": max_level,
		"reachable_closure": MODEL_SCRIPT.reachable_closure(max_level),
		"timer_scan": timer_scan,
		"challenge_classes": class_records,
		"levels": level_records,
		"production_precedence_fixtures": precedence_fixtures,
		"spatial_mix_outlier_candidates": spatial_candidates,
		"v03a_reused_trial_count": reused_trial_count,
		"v04_new_trial_count": new_trial_count,
		"v03a_reused_source_levels": V03A_SOURCE_LEVELS,
		"interpretation_boundary": [
			"One qualified-solver completion proves at least one solver-feasible path, not human difficulty.",
			"One failed screening seed does not prove impossibility.",
			"0/5 qualified-solver evidence is a high-risk candidate, not proof no human can complete.",
			"Historical 4x results are excluded from decision classifications.",
			"V04 authorizes no timer, objective, VIP, physics, or canonical data change.",
		],
		"validation_errors": validation_errors,
	}
	_write_report(report)
	if validation_errors.is_empty() and _report_integrity(report):
		print("M17_CANONICAL_SCREENING_RESULT=PASS levels=%d classes=%d reused_trials=%d new_trials=%d" % [levels.size(), classes.size(), reused_trial_count, new_trial_count])
		quit(0)
		return
	print("M17_CANONICAL_SCREENING_RESULT=FAIL errors=%s" % "; ".join(validation_errors))
	quit(1)


func _summarize_class(class_record: Dictionary, evidence_source: String, evidence_source_level: int, trials: Array[Dictionary]) -> Dictionary:
	var counts := {"completed": 0, "timeout": 0, "danger": 0, "harness_abort": 0}
	var merges: Array = []
	var peak_live: Array = []
	var occupancy: Array = []
	var rail: Array = []
	var contacts: Array = []
	var completion_times: Array = []
	for trial in trials:
		var outcome := str(trial.get("outcome", ""))
		if counts.has(outcome):
			counts[outcome] = int(counts[outcome]) + 1
		if outcome == "completed":
			completion_times.append(float(trial.get("elapsed_sec", 0.0)))
		merges.append(float(trial.get("merge_count", 0)))
		peak_live.append(float(trial.get("peak_live_drinks", 0)))
		occupancy.append(float(trial.get("peak_board_occupancy", 0.0)))
		rail.append(float(trial.get("rail_contact_count", 0)))
		contacts.append(float(trial.get("contact_count", 0)))
	var physical_flags: Array = []
	if int(counts["completed"]) > 0:
		physical_flags.append("SOLVER_FEASIBLE")
	elif trials.size() >= 5:
		physical_flags.append("HIGH_RISK_SOLVER_FAILURE")
	else:
		physical_flags.append("SCREENING_FAILURE_NEEDS_CONFIRMATION")
	return {
		"class_id": str(class_record["class_id"]),
		"signature": class_record["signature"],
		"representative": int(class_record["representative"]),
		"member_level_ids": class_record["member_level_ids"],
		"evidence_source": evidence_source,
		"evidence_source_level": evidence_source_level,
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
		"physical_screening_flags": physical_flags,
		"trials": trials,
	}


func _v03_source_for_class(class_record: Dictionary, v03_levels: Dictionary) -> int:
	for source_level in V03A_SOURCE_LEVELS:
		if not class_record["member_level_ids"].has(source_level):
			continue
		if not v03_levels.has(source_level):
			validation_errors.append("missing V03A source record for L%d" % source_level)
			continue
		var v03_signature: Dictionary = v03_levels[source_level].get("challenge_signature", {})
		var current_signature: Dictionary = class_record["signature"]
		if v03_signature.is_empty() or MODEL_SCRIPT.signature_key(v03_signature) == MODEL_SCRIPT.signature_key(current_signature):
			return source_level
		validation_errors.append("V03A source L%d signature mismatch" % source_level)
	return 0


func _index_v03_levels(report: Dictionary) -> Dictionary:
	var indexed: Dictionary = {}
	for level_record in report.get("levels", []):
		indexed[int(level_record.get("level_id", 0))] = level_record
	return indexed


func _action_log_is_legal(action_log: Array) -> bool:
	if action_log.is_empty():
		return false
	for action in action_log:
		if not action.has_all(["x_position", "lane_index", "decision_reason", "same_level_target_found", "target_instance_id"]):
			return false
		if int(action["lane_index"]) < 0 or int(action["lane_index"]) >= HARNESS_SCRIPT.LANE_X_POSITIONS.size():
			return false
		var known_x := false
		for lane_x in HARNESS_SCRIPT.LANE_X_POSITIONS:
			if is_equal_approx(float(action["x_position"]), float(lane_x)):
				known_x = true
				break
		if not known_x:
			return false
	return true


func _find_spatial_mix_candidates(class_records: Array[Dictionary]) -> Array[Dictionary]:
	var groups: Dictionary = {}
	for class_record in class_records:
		var signature: Dictionary = class_record["signature"]
		var cost := _signature_cost(signature)
		var timer := float(signature.get("time_limit_sec", 0.0))
		var key := "%d|%.3f" % [cost, timer]
		if not groups.has(key):
			groups[key] = []
		groups[key].append(class_record)
	var candidates: Array[Dictionary] = []
	for group in groups.values():
		if group.size() < 2:
			continue
		for left_index in range(group.size()):
			for right_index in range(left_index + 1, group.size()):
				var left: Dictionary = group[left_index]
				var right: Dictionary = group[right_index]
				var left_danger_rate := float(left["danger_count"]) / float(maxi(1, int(left["trial_count"])))
				var right_danger_rate := float(right["danger_count"]) / float(maxi(1, int(right["trial_count"])))
				var feasibility_diff: bool = (left["completed_count"] > 0) != (right["completed_count"] > 0)
				var danger_diff := absf(left_danger_rate - right_danger_rate) >= 0.5
				if not feasibility_diff and not danger_diff:
					continue
				candidates.append({
					"class_a": left["class_id"],
					"class_b": right["class_id"],
					"normal_objective_cost": _signature_cost(left["signature"]),
					"canonical_timer_sec": float(left["signature"]["time_limit_sec"]),
					"feasibility_difference": feasibility_diff,
					"danger_rate_a": left_danger_rate,
					"danger_rate_b": right_danger_rate,
					"danger_rate_difference": absf(left_danger_rate - right_danger_rate),
					"interpretation": "candidate signal only; sample sizes are small and not statistical proof",
				})
	return candidates


func _apply_spatial_flags(class_records: Array[Dictionary], level_records: Array[Dictionary], candidates: Array[Dictionary]) -> void:
	var candidate_classes: Dictionary = {}
	for candidate in candidates:
		candidate_classes[candidate["class_a"]] = true
		candidate_classes[candidate["class_b"]] = true
	for class_record in class_records:
		if candidate_classes.has(class_record["class_id"]):
			class_record["physical_screening_flags"].append("SPATIAL_MIX_OUTLIER_CANDIDATE")
	for level_record in level_records:
		var class_record_id := str(level_record["class_id"])
		if candidate_classes.has(class_record_id) and not level_record["physical_screening_flags"].has("SPATIAL_MIX_OUTLIER_CANDIDATE"):
			level_record["physical_screening_flags"].append("SPATIAL_MIX_OUTLIER_CANDIDATE")


func _signature_cost(signature: Dictionary) -> int:
	var total := 0
	for order in signature.get("orders", []):
		total += int(order.get("quantity", 0)) * DIFFICULTY_MODEL.cocktail_cost(int(order.get("cocktail_level", 0)))
	return total


func _run_production_precedence_fixtures(database) -> Dictionary:
	var fixtures: Dictionary = {}
	for level_id in [4, 60, 100]:
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		var vip_analysis := MODEL_SCRIPT.vip_interception_analysis(definition)
		var normal_route: Dictionary = await _run_route_fixture(database, level_id, "normal")
		var vip_route: Dictionary = await _run_route_fixture(database, level_id, "vip")
		fixtures[str(level_id)] = {
			"analytical_forced_capture_count": int(vip_analysis["minimum_forced_vip_captures"]),
			"analytical_vip_interception_risk": bool(vip_analysis["vip_interception_risk"]),
			"normal_first_fixture": normal_route,
			"vip_second_fixture": vip_route,
			"consistent": bool(normal_route.get("observed_normal_capture", false)) and bool(vip_route.get("observed_vip_capture", false)) and int(vip_analysis["minimum_forced_vip_captures"]) > 0,
		}
		if not bool(fixtures[str(level_id)]["consistent"]):
			validation_errors.append("production precedence fixture failed for L%d" % level_id)
	return fixtures


func _run_route_fixture(database, level_id: int, route_kind: String) -> Dictionary:
	var manager = GAME_MANAGER_SCRIPT.new()
	root.add_child(manager)
	await root.get_tree().process_frame
	var bridge = BRIDGE_SCRIPT.new()
	var configured := bridge.configure(database) and not bridge.start_session("sunny_cove", level_id).is_empty() and manager.configure_campaign_session(bridge)
	if not configured:
		manager.queue_free()
		await root.get_tree().process_frame
		return {"configured": false}
	var normal_target := int(manager._target_level)
	var vip_state: Dictionary = bridge.get_vip_state()
	var vip_level := int(vip_state.get("cocktail_level", 0))
	var merged_level := normal_target if route_kind == "normal" else vip_level
	var expected_route := MODEL_SCRIPT.production_route_for_merge(normal_target, vip_level, merged_level)
	var drink = manager.spawn_drink(merged_level, Vector2(360.0, 650.0), false)
	manager.on_merged(merged_level, drink)
	await root.get_tree().create_timer(0.5).timeout
	var objective_state: Dictionary = bridge.get_objective_state()
	var after_vip_state: Dictionary = bridge.get_vip_state()
	var normal_captured := int(objective_state.get("normal_completed", {}).get(normal_target, 0)) > 0
	var vip_captured := int(after_vip_state.get("delivered", 0)) > 0
	var result := {
		"configured": true,
		"normal_target_level": normal_target,
		"vip_level": vip_level,
		"merged_level": merged_level,
		"expected_route": expected_route,
		"observed_normal_capture": normal_captured if route_kind == "normal" else false,
		"observed_vip_capture": vip_captured if route_kind == "vip" else false,
		"normal_completed": objective_state.get("normal_completed", {}),
		"vip_delivered": int(after_vip_state.get("delivered", 0)),
	}
	manager.queue_free()
	await root.get_tree().process_frame
	return result


func _classification_definitions() -> Dictionary:
	return {
		"SOLVER_FEASIBLE": "at least one canonical-scale qualified-solver trial for the class completed",
		"HIGH_RISK_SOLVER_FAILURE": "at least five canonical-scale audited trials for the exact class with zero completions",
		"SCREENING_FAILURE_NEEDS_CONFIRMATION": "the single V04 broad-screen trial failed and fewer than five audited canonical-scale trials exist",
		"SPATIAL_MIX_OUTLIER_CANDIDATE": "same normal cost/timer but materially different feasibility or danger signal; candidate only because samples are small",
		"MATHEMATICALLY_UNREACHABLE": "mandatory target cannot be built from legal L1/L2/L3 spawn and equal-merge closure or record is structurally invalid",
		"ANALYTICAL_TIMER_RATIO_OUTLIER": "absolute timer/cost ratio deviation from cohort median is greater than 5 percent",
		"VIP_INTERCEPTION_RISK": "minimum forced VIP captures before mandatory completion is greater than zero",
	}


func _report_integrity(report: Dictionary) -> bool:
	if int(report.get("level_count", 0)) != EXPECTED_LEVEL_COUNT or int(report.get("challenge_class_count", 0)) != EXPECTED_CLASS_COUNT:
		return false
	if int(report.get("v03a_reused_trial_count", 0)) != V03A_SOURCE_LEVELS.size() * 5:
		return false
	if int(report.get("v04_new_trial_count", 0)) != EXPECTED_CLASS_COUNT - V03A_SOURCE_LEVELS.size():
		return false
	if report.get("levels", []).size() != EXPECTED_LEVEL_COUNT or report.get("challenge_classes", []).size() != EXPECTED_CLASS_COUNT:
		return false
	for level in report.get("levels", []):
		if str(level.get("class_id", "")).is_empty() or level.get("physical_screening_flags", []).is_empty():
			return false
	for class_record in report.get("challenge_classes", []):
		if class_record.get("trial_count", 0) <= 0 or class_record.get("physical_screening_flags", []).is_empty():
			return false
	return true


func _write_discrepancy_report(canonical_sha: String, levels: Array[Dictionary], classes: Array[Dictionary]) -> void:
	var report := {
		"report_version": "V04_DISCREPANCY",
		"canonical_data_sha256": canonical_sha,
		"level_count": levels.size(),
		"challenge_class_count": classes.size(),
		"expected_level_count": EXPECTED_LEVEL_COUNT,
		"expected_class_count": EXPECTED_CLASS_COUNT,
		"validation_errors": validation_errors,
	}
	var file := FileAccess.open(REPORT_JSON_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		validation_errors.append("missing report %s" % path)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode()


func _drink_max_level() -> int:
	var drink_script = preload("res://scripts/drink.gd")
	return drink_script.max_level()


func _write_report(report: Dictionary) -> void:
	var json_file := FileAccess.open(REPORT_JSON_PATH, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "  "))
	json_file.close()
	var markdown := "# M17 V04 Full Canonical Sunny Cove Screening\n\n"
	markdown += "Policy: `%s`; physics scale: `%.1fx`; canonical data SHA-256: `%s`. V04 is flagging evidence only; no tuning is authorized.\n\n" % [str(report["policy_name"]), float(report["physics_scale"]), str(report["canonical_data_sha256"])]
	markdown += "Levels: `%d`; challenge classes: `%d`; reused V03A trials: `%d`; new V04 trials: `%d`.\n\n" % [int(report["level_count"]), int(report["challenge_class_count"]), int(report["v03a_reused_trial_count"]), int(report["v04_new_trial_count"])]
	markdown += "## Screening interpretation\n\n"
	markdown += "- One successful qualified-solver completion proves one solver-feasible path, not human difficulty.\n"
	markdown += "- One failed seed does not prove impossibility; one-trial failures require confirmation.\n"
	markdown += "- 0/5 qualified-solver evidence is high-risk evidence, not proof no human can win.\n"
	markdown += "- Historical 4x results are excluded from V04 classifications.\n"
	markdown += "- V04 authorizes no timer, objective, VIP, physics, or canonical data change.\n\n"
	markdown += "## Challenge classes\n\n"
	markdown += "| Class | Representative | Members | Evidence | Trials | Complete | Danger | Timeout | Abort | Flags |\n|---|---:|---|---|---:|---:|---:|---:|---:|---|\n"
	for class_record in report["challenge_classes"]:
		markdown += "| %s | L%d | %s | %s" % [str(class_record["class_id"]), int(class_record["representative"]), ", ".join(class_record["member_level_ids"].map(func(value): return "L%d" % int(value))), str(class_record["evidence_source"])]
		markdown += " | %d | %d | %d | %d | %d | %s |\n" % [int(class_record["trial_count"]), int(class_record["completed_count"]), int(class_record["danger_count"]), int(class_record["timeout_count"]), int(class_record["harness_abort_count"]), ", ".join(class_record["physical_screening_flags"])]
	markdown += "\n## Required classification tables\n\n"
	markdown += _markdown_level_list(report["levels"], "MATHEMATICALLY_UNREACHABLE", "Mathematically unreachable levels")
	markdown += _markdown_level_list(report["levels"], "ANALYTICAL_TIMER_RATIO_OUTLIER", "Analytical timer-ratio outliers")
	markdown += _markdown_level_list(report["levels"], "VIP_INTERCEPTION_RISK", "VIP-interception-risk levels")
	markdown += _markdown_class_list(report["challenge_classes"], "SOLVER_FEASIBLE", "Solver-feasible classes")
	markdown += _markdown_class_list(report["challenge_classes"], "HIGH_RISK_SOLVER_FAILURE", "High-risk 0/5 classes")
	markdown += _markdown_class_list(report["challenge_classes"], "SCREENING_FAILURE_NEEDS_CONFIRMATION", "One-trial failures needing confirmation")
	markdown += "## Spatial-mix outlier candidates\n\n"
	if report["spatial_mix_outlier_candidates"].is_empty():
		markdown += "NONE\n\n"
	else:
		markdown += "| Class A | Class B | Cost | Timer | Feasibility difference | Danger-rate difference | Interpretation |\n|---|---|---:|---:|---|---:|---|\n"
		for candidate in report["spatial_mix_outlier_candidates"]:
			markdown += "| %s | %s | %d | %.0f | %s | %.2f | %s |\n" % [str(candidate["class_a"]), str(candidate["class_b"]), int(candidate["normal_objective_cost"]), float(candidate["canonical_timer_sec"]), str(candidate["feasibility_difference"]), float(candidate["danger_rate_difference"]), str(candidate["interpretation"])]
		markdown += "\n"
	markdown += "## VIP precedence fixtures\n\n"
	for level_id in [4, 60, 100]:
		var fixture: Dictionary = report["production_precedence_fixtures"].get(str(level_id), {})
		markdown += "- L%d: forced captures `%d`; normal-first `%s`; VIP-second `%s`; consistent `%s`.\n" % [level_id, int(fixture.get("analytical_forced_capture_count", 0)), str(fixture.get("normal_first_fixture", {}).get("observed_normal_capture", false)), str(fixture.get("vip_second_fixture", {}).get("observed_vip_capture", false)), str(fixture.get("consistent", false))]
	markdown += "\n## Timer scan\n\n"
	markdown += "Cohort median timer/cost ratio: `%.6f`; outlier threshold: absolute deviation `>5%%`.\n\n" % float(report["timer_scan"]["cohort_median_timer_cost_ratio"])
	markdown += "## Validation\n\n"
	markdown += "- Report integrity: `%s`\n" % str(_report_integrity(report))
	markdown += "- Validation errors: `%s`\n" % str(report["validation_errors"])
	markdown += "- Canonical-data SHA is recorded; the focused V04 probe separately proves byte-for-byte immutability.\n"
	var md_file := FileAccess.open(REPORT_MD_PATH, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()


func _markdown_level_list(levels: Array, flag: String, title: String) -> String:
	var selected: Array = []
	for level in levels:
		if level.get("physical_screening_flags", []).has(flag):
			selected.append("L%d" % int(level["level_id"]))
	var result := "### %s\n\n" % title
	result += "NONE\n\n" if selected.is_empty() else "%s\n\n" % ", ".join(selected)
	return result


func _markdown_class_list(classes: Array, flag: String, title: String) -> String:
	var selected: Array = []
	for class_record in classes:
		if class_record.get("physical_screening_flags", []).has(flag):
			selected.append("%s (rep L%d)" % [str(class_record["class_id"]), int(class_record["representative"])])
	var result := "### %s\n\n" % title
	result += "NONE\n\n" if selected.is_empty() else "%s\n\n" % ", ".join(selected)
	return result
