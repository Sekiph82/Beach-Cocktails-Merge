extends SceneTree

const HARNESS = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const GAME_MANAGER = preload("res://scripts/game_manager.gd")
const DATABASE = preload("res://scripts/campaign/level_database.gd")
const BRIDGE = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const MAIN_SCENE = preload("res://scenes/main.tscn")

var failures: Array[String] = []
var assertions := 0

func _init() -> void:
	call_deferred("_run")

func _check(label: String, condition: bool) -> void:
	assertions += 1
	if condition:
		print("R20_PROBE_PASS: %s" % label)
	else:
		failures.append(label)
		push_error("R20_PROBE_FAIL: %s" % label)

func _run() -> void:
	var harness = HARNESS.new(root)
	var observations := [
		{"level": 4, "x": 220.0, "y": 850.0, "radius": 40.0, "instance_id": 11},
		{"level": 5, "x": 220.0, "y": 780.0, "radius": 44.0, "instance_id": 12},
		{"level": 8, "x": 540.0, "y": 900.0, "radius": 54.0, "instance_id": 13},
	]
	var lanes := [120.0, 220.0, 320.0, 420.0, 520.0, 620.0]
	var first: Dictionary = harness.choose_r20_action_from_observations(4, observations, [6, 8], lanes, 960.0)
	var replay: Dictionary = harness.choose_r20_action_from_observations(4, observations, [6, 8], lanes, 960.0)
	_check("candidate evaluates every legal lane", first.get("r20_candidate_evaluations", []).size() == lanes.size())
	_check("each lane checks 27 depth-three spawn sequences", _all_sequences(first.get("r20_candidate_evaluations", [])))
	_check("selected lane is legal and tie-breaking deterministic", lanes.has(float(first.get("x_position", -1.0))) and first == replay)
	_check("decision declares optimistic estimate, not physics proof", first.get("r20_selected_candidate", {}).get("model_label", "") == "optimistic_lane_inventory_estimate_not_physical_proof")
	_check("observed level inventory and target orders are retained", first.get("r20_selected_candidate", {}).get("local_level_inventory", {}).has(4) and first.get("r20_selected_candidate", {}).get("target_order_levels", []) == [6, 8])

	var database = DATABASE.new()
	_check("canonical campaign loads for production parity", database.load_canonical(DATABASE.DEFAULT_ISLANDS_PATH, DATABASE.DEFAULT_LEVEL_PATHS, DATABASE.ValidationMode.SEED))
	if failures.is_empty():
		var feasibility_harness = HARNESS.new(root)
		var feasibility_trial: Dictionary = await feasibility_harness.run_trial(database, "sunny_cove", 1, 34117001, [], HARNESS.POLICY_R20_OBJECTIVE_LOOKAHEAD_V01, 1, true, true, 0.0, "", false, true, false, 0, HARNESS.DETERMINISM_TRACE_INTERVAL_FRAMES, "", {}, true)
		var feasibility_action: Dictionary = feasibility_trial.get("action_log", [{}])[0] if not feasibility_trial.get("action_log", []).is_empty() else {}
		_check("per-shot trace records the T-based 4T budget floor without claiming reachability", feasibility_action.has("within_remaining_4t_budget_floor_before") and feasibility_action.has("within_remaining_4t_budget_floor_after") and str(feasibility_action.get("feasibility_scope", "")).contains("not a proof"))
	if failures.is_empty():
		var production = MAIN_SCENE.instantiate()
		root.add_child(production)
		await process_frame
		var production_bridge = BRIDGE.new()
		var production_ready: bool = production.world != null and production.shot_controller != null and production_bridge.configure(database) and not production_bridge.start_session("sunny_cove", 1).is_empty() and production.configure_campaign_session(production_bridge)
		_check("production main scene configures a canonical gameplay session", production_ready)
		if production_ready:
			var production_snapshot := _snapshot(production)
			production.queue_free()
			await process_frame
			var harness_manager = GAME_MANAGER.new()
			root.add_child(harness_manager)
			await process_frame
			var harness_bridge = BRIDGE.new()
			var harness_ready: bool = harness_manager.world != null and harness_manager.shot_controller != null and harness_bridge.configure(database) and not harness_bridge.start_session("sunny_cove", 1).is_empty() and harness_manager.configure_campaign_session(harness_bridge)
			_check("bare harness manager configures the same canonical session", harness_ready)
			if harness_ready:
				var harness_snapshot := _snapshot(harness_manager)
				_check("production and harness viewports match", production_snapshot.viewport == harness_snapshot.viewport)
				_check("production and harness R04 theme paths match", production_snapshot.theme == harness_snapshot.theme)
				_check("production and harness playable edges match", production_snapshot.edges == harness_snapshot.edges)
				_check("production and harness launch/death boundaries match", is_equal_approx(production_snapshot.launch_y, harness_snapshot.launch_y) and is_equal_approx(production_snapshot.death_y, harness_snapshot.death_y))
				_check("production ShotController retains 700 px/s", is_equal_approx(float(production_snapshot.launch_speed), 700.0) and is_equal_approx(float(harness_snapshot.launch_speed), 700.0))
			harness_manager.queue_free()
			await process_frame
	else:
		failures.append("production parity skipped after earlier probe failure")

	if failures.is_empty():
		print("M34_R20_OBJECTIVE_LOOKAHEAD_RESULT=PASS assertions=%d" % assertions)
		quit(0)
	else:
		print("M34_R20_OBJECTIVE_LOOKAHEAD_RESULT=FAIL assertions=%d failures=%s" % [assertions, str(failures)])
		quit(1)

func _all_sequences(evaluations: Array) -> bool:
	if evaluations.size() != 6:
		return false
	for evaluation in evaluations:
		if int(evaluation.get("sequence_count", 0)) != 27 or int(evaluation.get("lookahead_depth", 0)) != 3:
			return false
	return true

func _snapshot(manager) -> Dictionary:
	var edges: Array = []
	for edge in manager.get_playable_boundary_edges():
		edges.append({"name": edge.name, "a": edge.a, "b": edge.b, "inward_normal": edge.inward_normal})
	return {"viewport": manager.get_board_size(), "theme": manager.get_active_theme_paths(), "edges": edges, "launch_y": manager.launch_y, "death_y": manager.death_line_y, "launch_speed": manager.shot_controller.launch_speed}
