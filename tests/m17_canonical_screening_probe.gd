extends SceneTree

## Focused V04 challenge-class, analytical, VIP-precedence, and report probe.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const GAME_MANAGER_SCRIPT = preload("res://scripts/game_manager.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const REPORT_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.json"
const V03_REPORT_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M17_V04_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M17_V04_PROBE FAIL: %s" % label)


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode()


func _run() -> void:
	var before_hash := _sha256(LEVELS_PATH)
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove loads in FULL validation mode", database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL))
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	var classes: Array[Dictionary] = MODEL_SCRIPT.build_challenge_classes(levels)
	_check("canonical dataset has exactly 100 levels", levels.size() == 100)
	_check("canonical dataset has exactly 45 challenge classes", classes.size() == 45)
	_check("all 100 levels map to exactly one class", _class_mapping_is_one_to_one(classes, levels))
	_check("each class representative is its lowest level id", _representatives_are_lowest(classes))
	var closure := MODEL_SCRIPT.reachable_closure(12)
	_check("spawn/merge reachability closure contains L1-L12", closure == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
	var all_reachable := true
	for level in levels:
		all_reachable = all_reachable and str(MODEL_SCRIPT.level_reachability(level, 12)["classification"]) == "NONE"
	_check("all normal objectives are mathematically reachable with positive quantity/timer", all_reachable)
	var timer_scan := MODEL_SCRIPT.timer_scan(levels)
	_check("timer scan covers all 100 levels", timer_scan["levels"].size() == 100)
	var no_fabricated_timer_impossibility := true
	for level in timer_scan["levels"]:
		no_fabricated_timer_impossibility = no_fabricated_timer_impossibility and not bool(level.get("mathematically_unreachable_from_timer", false))
	_check("timer planning does not fabricate mathematical impossibility", no_fabricated_timer_impossibility)
	for level_id in [4, 60, 100]:
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		var vip_analysis := MODEL_SCRIPT.vip_interception_analysis(definition)
		_check("L%d analytical VIP interception risk is positive" % level_id, bool(vip_analysis["vip_interception_risk"]) and int(vip_analysis["minimum_forced_vip_captures"]) > 0)
		_check("L%d normal-first route is authoritative" % level_id, MODEL_SCRIPT.production_route_for_merge(6 if level_id == 4 else 5, int(vip_analysis["vip_level"]), 6 if level_id == 4 else 5) == "NORMAL")
		_check("L%d VIP-second route is authoritative" % level_id, MODEL_SCRIPT.production_route_for_merge(6 if level_id == 4 else 5, int(vip_analysis["vip_level"]), int(vip_analysis["vip_level"])) == "VIP")
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(REPORT_PATH))
	_check("V04 report is present and machine-readable", not report.is_empty())
	_check("V04 report records 100 levels and 45 classes", int(report.get("level_count", 0)) == 100 and int(report.get("challenge_class_count", 0)) == 45)
	_check("V04 report reuses six V03A five-trial sources", int(report.get("v03a_reused_trial_count", 0)) == 30)
	_check("V04 report runs 39 new one-trial class screens", int(report.get("v04_new_trial_count", 0)) == 39)
	_check("V04 report uses canonical physics scale 1.0", is_equal_approx(float(report.get("physics_scale", 0.0)), 1.0))
	_check("every reported level has a classification", _reported_levels_classified(report.get("levels", [])))
	_check("every reported class has evidence and a classification", _reported_classes_classified(report.get("challenge_classes", [])))
	_check("V03A source levels are exact-signature reuse", _v03_reuse_matches(report, levels))
	await _run_production_precedence_fixtures(database)
	_check("canonical Sunny Cove JSON is byte-for-byte unchanged", _sha256(LEVELS_PATH) == before_hash)
	if failures.is_empty():
		print("M17_CANONICAL_SCREENING_RESULT=PASS")
		quit(0)
		return
	print("M17_CANONICAL_SCREENING_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _class_mapping_is_one_to_one(classes: Array[Dictionary], levels: Array[Dictionary]) -> bool:
	var seen: Dictionary = {}
	for class_record in classes:
		for level_id in class_record["member_level_ids"]:
			if seen.has(int(level_id)):
				return false
			seen[int(level_id)] = str(class_record["class_id"])
	return seen.size() == levels.size()


func _representatives_are_lowest(classes: Array[Dictionary]) -> bool:
	for class_record in classes:
		var members: Array = class_record["member_level_ids"]
		if members.is_empty() or int(class_record["representative"]) != int(members[0]):
			return false
	return true


func _reported_levels_classified(levels: Array) -> bool:
	if levels.size() != 100:
		return false
	for level in levels:
		if str(level.get("class_id", "")).is_empty() or level.get("physical_screening_flags", []).is_empty():
			return false
	return true


func _reported_classes_classified(classes: Array) -> bool:
	if classes.size() != 45:
		return false
	for class_record in classes:
		if int(class_record.get("trial_count", 0)) <= 0 or class_record.get("physical_screening_flags", []).is_empty():
			return false
	return true


func _v03_reuse_matches(report: Dictionary, levels: Array[Dictionary]) -> bool:
	var v03: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(V03_REPORT_PATH))
	var v03_by_level: Dictionary = {}
	for level_record in v03.get("levels", []):
		v03_by_level[int(level_record.get("level_id", 0))] = level_record
	var current_by_level: Dictionary = {}
	for level in levels:
		current_by_level[int(level["level_id"])] = level
	for source_level in [1, 10, 11, 50, 51, 100]:
		var found := false
		for class_record in report.get("challenge_classes", []):
			if int(class_record.get("evidence_source_level", 0)) == source_level:
				var expected_key := MODEL_SCRIPT.signature_key(MODEL_SCRIPT.challenge_signature(current_by_level[source_level]))
				var reported_key := MODEL_SCRIPT.signature_key(class_record.get("signature", {}))
				found = reported_key == expected_key \
					and int(class_record.get("trial_count", 0)) == 5 \
					and class_record.get("evidence_source", "") == "V03A_5_TRIAL" \
					and (class_record.get("trials", []) as Array).size() == 5 \
					and v03_by_level.has(source_level)
				break
		if not found:
			return false
	return true


func _configure_fixture(database, level_id: int) -> Dictionary:
	var manager = GAME_MANAGER_SCRIPT.new()
	root.add_child(manager)
	await root.get_tree().process_frame
	var bridge = BRIDGE_SCRIPT.new()
	var configured := bridge.configure(database) and not bridge.start_session("sunny_cove", level_id).is_empty() and manager.configure_campaign_session(bridge)
	return {"manager": manager, "bridge": bridge, "configured": configured}


func _cleanup_fixture(manager) -> void:
	manager.queue_free()
	await root.get_tree().process_frame


func _run_production_precedence_fixtures(database) -> void:
	for level_id in [4, 60, 100]:
		var normal_fixture: Dictionary = await _configure_fixture(database, level_id)
		var normal_manager = normal_fixture["manager"]
		var normal_bridge = normal_fixture["bridge"]
		var normal_ok := bool(normal_fixture["configured"])
		var normal_target := int(normal_manager._target_level)
		var normal_drink = normal_manager.spawn_drink(normal_target, Vector2(360.0, 650.0), false)
		normal_manager.on_merged(normal_target, normal_drink)
		await root.get_tree().create_timer(0.5).timeout
		var normal_state: Dictionary = normal_bridge.get_objective_state()
		var normal_completed := int(normal_state.get("normal_completed", {}).get(normal_target, 0)) > 0
		_check("L%d production normal-first fixture routes the mandatory target normally" % level_id, normal_ok and normal_completed)
		await _cleanup_fixture(normal_manager)

		var vip_fixture: Dictionary = await _configure_fixture(database, level_id)
		var vip_manager = vip_fixture["manager"]
		var vip_bridge = vip_fixture["bridge"]
		var vip_ok := bool(vip_fixture["configured"])
		var vip_level := int(vip_bridge.get_vip_state().get("cocktail_level", 0))
		var vip_drink = vip_manager.spawn_drink(vip_level, Vector2(360.0, 650.0), false)
		vip_manager.on_merged(vip_level, vip_drink)
		await root.get_tree().create_timer(0.5).timeout
		var vip_state: Dictionary = vip_bridge.get_vip_state()
		_check("L%d production VIP-second fixture captures the distinct VIP target" % level_id, vip_ok and int(vip_state.get("delivered", 0)) > 0)
		await _cleanup_fixture(vip_manager)
