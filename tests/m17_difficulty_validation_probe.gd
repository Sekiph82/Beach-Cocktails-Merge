extends SceneTree

## Focused M17 model, schema, replay, and immutability probe.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const GAME_MANAGER_SCRIPT = preload("res://scripts/game_manager.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const CANONICAL_LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M17_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M17_PROBE FAIL: %s" % label)


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode()


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove loads in FULL validation mode", database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL))
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	_check("canonical Sunny Cove has 100 levels", levels.size() == 100)
	if levels.size() < 100:
		print("M17_DIFFICULTY_VALIDATION_RESULT=FAIL failures=%s" % str(failures))
		quit(1)
		return
	_check("L1 objective cost is 16", MODEL_SCRIPT.normal_objective_cost(levels[0]) == 16)
	_check("L100 objective cost is 240", MODEL_SCRIPT.normal_objective_cost(levels[99]) == 240)
	_check("VIP cost is separate", MODEL_SCRIPT.vip_objective_cost(levels[3]) == 16 and MODEL_SCRIPT.normal_objective_cost(levels[3]) == 32)
	_check("expected L1-equivalent spawn value is 7/3", is_equal_approx(MODEL_SCRIPT.EXPECTED_SPAWN_VALUE_L1_EQUIVALENT, 7.0 / 3.0))
	var default_timer := MODEL_SCRIPT.timer_calculation(levels[0])
	var override_timer := MODEL_SCRIPT.timer_calculation(levels[0], 2.0)
	_check("timer exposes named calibration", is_equal_approx(float(default_timer["seconds_per_launch_calibration"]), MODEL_SCRIPT.DEFAULT_SECONDS_PER_LAUNCH))
	_check("timer calibration override changes raw and target time", not is_equal_approx(float(default_timer["raw_calculated_production_time_sec"]), float(override_timer["raw_calculated_production_time_sec"])) and not is_equal_approx(float(default_timer["planning_target_time_sec"]), float(override_timer["planning_target_time_sec"])))
	_check("percentile uses deterministic R7 interpolation", is_equal_approx(MODEL_SCRIPT.percentile([1, 2, 3, 4], 0.75), 3.25))

	var before_hash := _sha256(CANONICAL_LEVELS_PATH)
	var harness = HARNESS_SCRIPT.new(root)
	var schema_record: Dictionary = harness.new_telemetry("sunny_cove", 1, 17017001)
	_check("telemetry schema is complete", harness.validate_telemetry(schema_record).is_empty())
	_run_policy_fixtures(harness)
	await _run_outcome_fixtures(database, harness)
	_run_rail_proxy_fixtures(harness)
	harness.set_time_scale(1.0)
	_check("qualification runner policy time scale is canonical", is_equal_approx(harness.get_time_scale(), 1.0))
	var first: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017001, [], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
	var second: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017001, [], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
	_check("same seed produces the same action log", first["action_log"] == second["action_log"])
	_check("same seed preserves logical outcome", first["outcome"] == second["outcome"])
	var replay: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017001, first["action_log"], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
	_check("exact action-log replay preserves logical result", replay["outcome"] == first["outcome"] and replay["merge_count"] == first["merge_count"])
	var different: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017002, [], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
	_check("different seed changes the seeded action sequence", different["action_log"] != first["action_log"])
	_check("focused trial telemetry validates", harness.validate_telemetry(first).is_empty())
	_check("merge-aware actions carry decision evidence", _action_logs_have_decision_evidence(first["action_log"]))
	_check("canonical Sunny Cove JSON is byte-for-byte unchanged", _sha256(CANONICAL_LEVELS_PATH) == before_hash)

	if failures.is_empty():
		print("M17_DIFFICULTY_VALIDATION_RESULT=PASS")
		quit(0)
		return
	print("M17_DIFFICULTY_VALIDATION_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _action_logs_have_decision_evidence(action_log: Array) -> bool:
	if action_log.is_empty():
		return false
	for action in action_log:
		if not action.has("x_position") or not action.has("lane_index") or not action.has("decision_reason") or not action.has("same_level_target_found") or not action.has("target_instance_id"):
			return false
	return true


func _run_policy_fixtures(harness) -> void:
	var left_target: Dictionary = harness.choose_action_from_observations(2, [{"level": 2, "x": 150.0, "y": 760.0, "instance_id": 101}], 6)
	var right_target: Dictionary = harness.choose_action_from_observations(2, [{"level": 2, "x": 570.0, "y": 760.0, "instance_id": 202}], 6)
	var left_congestion: Dictionary = harness.choose_action_from_observations(2, [
		{"level": 1, "x": 150.0, "y": 820.0, "instance_id": 301},
		{"level": 3, "x": 150.0, "y": 760.0, "instance_id": 302},
	], 6)
	var repeated_left: Dictionary = harness.choose_action_from_observations(2, [{"level": 2, "x": 150.0, "y": 760.0, "instance_id": 101}], 6)
	_check("same-level left target shifts action left", left_target["same_level_target_found"] and float(left_target["x_position"]) < 360.0 and left_target["target_instance_id"] == 101)
	_check("same-level right target shifts action right", right_target["same_level_target_found"] and float(right_target["x_position"]) > 360.0 and right_target["target_instance_id"] == 202)
	_check("left-side congestion selects a safer non-left lane", not left_congestion["same_level_target_found"] and int(left_congestion["lane_index"]) > 0 and left_congestion["decision_reason"] == "low_congestion_lane")
	_check("identical board state produces identical action", left_target == repeated_left)
	_check("policy has no future-RNG input", not left_target.has("future_seed") and not left_target.has("rng_value"))
	_check("policy returns a legal horizontal bucket", int(left_target["lane_index"]) >= 0 and int(left_target["lane_index"]) < 7 and int(right_target["lane_index"]) >= 0 and int(right_target["lane_index"]) < 7)


func _configure_fixture(database) -> Dictionary:
	var manager = GAME_MANAGER_SCRIPT.new()
	root.add_child(manager)
	await root.get_tree().process_frame
	var bridge = BRIDGE_SCRIPT.new()
	_check("fixture GameManager is ready", manager.world != null and manager.shot_controller != null)
	_check("fixture campaign bridge starts", bridge.configure(database) and not bridge.start_session("sunny_cove", 1).is_empty() and manager.configure_campaign_session(bridge))
	return {"manager": manager, "bridge": bridge}


func _cleanup_fixture(manager) -> void:
	manager.queue_free()
	await root.get_tree().process_frame


func _run_outcome_fixtures(database, harness) -> void:
	var danger_fixture: Dictionary = await _configure_fixture(database)
	var danger_manager = danger_fixture["manager"]
	var danger_bridge = danger_fixture["bridge"]
	var danger_drink = danger_manager.spawn_drink(1, Vector2(360.0, danger_manager.death_line_y + 10.0), false)
	danger_manager._process(0.50)
	var before_tolerance: bool = not danger_manager.game_over
	danger_manager._process(0.50)
	var danger_terminal: Dictionary = danger_bridge.get_terminal_result()
	var danger_classification: Dictionary = harness.classify_trial_outcome(danger_terminal, danger_manager.game_over, 1.0, 20.0)
	_check("danger fixture uses production danger-line/game-over path", danger_manager.game_over and danger_drink.freeze and before_tolerance)
	_check("TABLE_DANGER fixture terminal reason is preserved", danger_terminal.get("reason", "") == "TABLE_DANGER")
	_check("TABLE_DANGER fixture outcome is danger", danger_classification["outcome"] == "danger" and danger_classification["terminal_reason"] == "TABLE_DANGER")
	_check("TABLE_DANGER fixture is not timeout", danger_classification["outcome"] != "timeout")
	await _cleanup_fixture(danger_manager)

	var timeout_fixture: Dictionary = await _configure_fixture(database)
	var timeout_manager = timeout_fixture["manager"]
	var timeout_bridge = timeout_fixture["bridge"]
	var time_limit := float(timeout_bridge.get_session_configuration().get("time_limit_sec", 0.0))
	timeout_bridge.tick(time_limit)
	var timeout_terminal: Dictionary = timeout_bridge.get_terminal_result()
	var timeout_classification: Dictionary = harness.classify_trial_outcome(timeout_terminal, timeout_manager.game_over, time_limit, time_limit)
	_check("timeout fixture expires the production campaign timer", timeout_terminal.get("reason", "") == "TIMEOUT")
	_check("TIMEOUT fixture outcome is timeout and not danger", timeout_classification["outcome"] == "timeout" and timeout_classification["terminal_reason"] == "TIMEOUT")
	await _cleanup_fixture(timeout_manager)


func _run_rail_proxy_fixtures(harness) -> void:
	var state: Dictionary = harness.new_rail_proxy_state()
	harness.begin_rail_proxy_sample(state)
	var first_event: bool = harness.update_rail_proximity(state, 101, "LeftRail_0", 1.0)
	harness.end_rail_proxy_sample(state)
	_check("controlled near-rail footprint creates one proxy event", first_event and int(state["rail_contact_count"]) == 1)
	for _sample in range(4):
		harness.begin_rail_proxy_sample(state)
		harness.update_rail_proximity(state, 101, "LeftRail_0", 0.25)
		harness.end_rail_proxy_sample(state)
	_check("continuous proximity does not inflate the same edge event", int(state["rail_contact_count"]) == 1)
	harness.begin_rail_proxy_sample(state)
	harness.update_rail_proximity(state, 202, "LeftRail_0", 40.0)
	harness.end_rail_proxy_sample(state)
	_check("centered footprint does not create a false rail event", int(state["rail_contact_count"]) == 1)
	harness.begin_rail_proxy_sample(state)
	harness.update_rail_proximity(state, 101, "LeftRail_0", 3.01)
	harness.end_rail_proxy_sample(state)
	harness.begin_rail_proxy_sample(state)
	var reentry_event: bool = harness.update_rail_proximity(state, 101, "LeftRail_0", 0.5)
	harness.end_rail_proxy_sample(state)
	_check("release beyond 3px then re-entry creates a second event", reentry_event and int(state["rail_contact_count"]) == 2)
