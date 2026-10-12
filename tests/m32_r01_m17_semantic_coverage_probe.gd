extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const GAME_MANAGER_SCRIPT = preload("res://scripts/game_manager.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const V04_REPORT_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.json"
const V03_REPORT_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.json"

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M32_R01_M17_SEMANTIC PASS: %s" % label)
	else:
		failures.append(label)
		print("M32_R01_M17_SEMANTIC FAIL: %s" % label)


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.SEED)
	_check("canonical campaign data loads", loaded)
	if not loaded:
		_finish()
		return
	_run_historical_signature_checks(database)
	await _run_surplus_fixtures(database)
	_finish()


func _run_historical_signature_checks(database) -> void:
	var current_by_level: Dictionary = {}
	for level in database.get_levels_for_island("sunny_cove"):
		current_by_level[int(level["level_id"])] = level
	var v03: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(V03_REPORT_PATH))
	var v04: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(V04_REPORT_PATH))
	_check("historical V03 and V04 reports are readable", not v03.is_empty() and not v04.is_empty())
	var v03_by_level: Dictionary = {}
	for record in v03.get("levels", []):
		v03_by_level[int(record.get("level_id", 0))] = record
	for source_level in [1, 10, 11, 50, 51, 100]:
		var class_record: Dictionary = {}
		for candidate in v04.get("challenge_classes", []):
			if int(candidate.get("evidence_source_level", 0)) == source_level:
				class_record = candidate
				break
		var current_level: Dictionary = current_by_level.get(source_level, {})
		var v03_record: Dictionary = v03_by_level.get(source_level, {})
		var historical_signature: Dictionary = class_record.get("signature", {})
		var current_signature: Dictionary = MODEL_SCRIPT.challenge_signature(current_level) if not current_level.is_empty() else {}
		var normalized_historical := historical_signature.duplicate(true)
		if normalized_historical.has("time_limit_sec") and current_signature.has("time_limit_sec"):
			normalized_historical["time_limit_sec"] = current_signature["time_limit_sec"]
		var source_ok := str(class_record.get("evidence_source", "")) == "V03A_5_TRIAL" \
			and int(class_record.get("trial_count", 0)) == 5 \
			and (class_record.get("trials", []) as Array).size() == 5 \
			and int(v03_record.get("trial_count", 0)) == 5 \
			and is_equal_approx(float(historical_signature.get("time_limit_sec", -1.0)), float(v03_record.get("canonical_timer_sec", -2.0)))
		_check("L%d V04 preserves its historical five-trial V03A source record" % source_level, source_ok)
		_check("L%d V04 trial payload exactly reuses V03A rows" % source_level, class_record.get("trials", []) == v03_record.get("trials", []))
		_check("L%d current campaign obeys the untimed owner contract" % source_level, is_equal_approx(float(current_level.get("time_limit_sec", -1.0)), 0.0))
		_check("L%d historical signature differs from current only by retired timer" % source_level, not current_signature.is_empty() and MODEL_SCRIPT.signature_key(normalized_historical) == MODEL_SCRIPT.signature_key(current_signature))


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


func _reserve_levels(level_id: int) -> Array[int]:
	match level_id:
		4:
			return [5, 5]
		60:
			return [7, 7, 6, 5]
		100:
			return [7, 7, 7, 6, 5]
	return []


func _run_surplus_fixtures(database) -> void:
	for level_id in [4, 60, 100]:
		var vip_fixture: Dictionary = await _configure_fixture(database, level_id)
		var protected_manager = vip_fixture["manager"]
		var protected_bridge = vip_fixture["bridge"]
		var vip_level := int(protected_bridge.get_vip_state().get("cocktail_level", 0))
		var protected_candidate = protected_manager.spawn_drink(vip_level, Vector2(360.0, 650.0), false)
		var protected_before: Dictionary = protected_bridge.get_objective_state().get("normal_remaining", {}).duplicate(true)
		var protected_reserve: bool = not protected_manager._vip_candidate_is_surplus(protected_candidate)
		protected_manager.on_merged(vip_level, protected_candidate)
		await root.get_tree().create_timer(0.6).timeout
		var protected_state: Dictionary = protected_bridge.get_vip_state()
		var protected_after: Dictionary = protected_bridge.get_objective_state().get("normal_remaining", {})
		print("M32_R01_VIP_DETAIL protected level=%d vip=%d normal_remaining=%s candidate_surplus=%s delivered=%d unchanged=%s" % [level_id, vip_level, protected_before, str(not protected_reserve), int(protected_state.get("delivered", 0)), str(protected_after == protected_before)])
		_check("L%d reserve-contributing VIP candidate remains uncaptured" % level_id, bool(vip_fixture["configured"]) and protected_reserve and int(protected_state.get("delivered", 0)) == 0 and protected_after == protected_before)
		await _cleanup_fixture(protected_manager)

		var surplus_fixture: Dictionary = await _configure_fixture(database, level_id)
		var surplus_manager = surplus_fixture["manager"]
		var surplus_bridge = surplus_fixture["bridge"]
		var reserve_levels := _reserve_levels(level_id)
		for index in reserve_levels.size():
			surplus_manager.spawn_drink(reserve_levels[index], Vector2(70.0 + float(index) * 90.0, 610.0), false)
		var surplus_level := int(surplus_bridge.get_vip_state().get("cocktail_level", 0))
		var surplus_candidate = surplus_manager.spawn_drink(surplus_level, Vector2(660.0, 650.0), false)
		var normal_before: Dictionary = surplus_bridge.get_objective_state().get("normal_remaining", {}).duplicate(true)
		var surplus_decision: bool = bool(surplus_fixture["configured"]) and surplus_manager._vip_candidate_is_surplus(surplus_candidate)
		surplus_manager.on_merged(surplus_level, surplus_candidate)
		var direct_route_started: bool = surplus_manager._vip_target_transition and surplus_manager._vip_target_drink == surplus_candidate
		await root.get_tree().create_timer(0.6).timeout
		var surplus_state: Dictionary = surplus_bridge.get_vip_state()
		var normal_after: Dictionary = surplus_bridge.get_objective_state().get("normal_remaining", {})
		print("M32_R01_VIP_DETAIL surplus level=%d vip=%d reserve=%s normal_remaining=%s candidate_surplus=%s direct_route=%s delivered=%d unchanged=%s" % [level_id, surplus_level, reserve_levels, normal_before, str(surplus_decision), str(direct_route_started), int(surplus_state.get("delivered", 0)), str(normal_after == normal_before)])
		_check("L%d distinct VIP candidate is captured on the real merged-surplus route" % level_id, surplus_decision and direct_route_started and int(surplus_state.get("delivered", 0)) == 1 and normal_after == normal_before)
		await _cleanup_fixture(surplus_manager)


func _finish() -> void:
	if failures.is_empty():
		print("M32_R01_M17_SEMANTIC_RESULT=PASS")
		quit(0)
	else:
		print("M32_R01_M17_SEMANTIC_RESULT=FAIL failures=%s" % str(failures))
		quit(1)
