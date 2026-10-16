class_name M17SeededValidationHarness
extends RefCounted

## Seeded M17 trial runner.
##
## The harness drives the production GameManager/Drink physics through a
## bounded test hook: it creates the same Drink bodies, launches them at the
## production 700 px/s speed, and lets Godot's physics/merge queue resolve
## contacts.  It does not call objective-completion APIs.  The hook supplies a
## deterministic lane policy and records every spawn/lane action so a trial can
## be replayed.  It is intentionally not an optimal-human-play model.

const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAME_MANAGER_SCRIPT = preload("res://scripts/game_manager.gd")
const DRINK_SCRIPT = preload("res://scripts/drink.gd")

const OUTCOME_COMPLETED := "completed"
const OUTCOME_TIMEOUT := "timeout"
const OUTCOME_DANGER := "danger"
const OUTCOME_HARNESS_ABORT := "harness_abort"

const SHOT_SPEED := 700.0
const PHYSICS_STEP_SEC := 1.0 / 60.0
const FRAMES_PER_ACTION := 60
const MAX_EXTRA_SETTLE_FRAMES := 90
const MAX_SHOTS_MULTIPLIER := 3.0
const LARGE_PIECE_LEVEL := 7
const BOARD_OCCUPANCY_AREA_PX2 := 360000.0
const RAIL_ENTER_THRESHOLD_PX := 1.0
const RAIL_RELEASE_THRESHOLD_PX := 3.0
const RAIL_CONTACT_METRIC := "footprint_proximity_transition_proxy"
const DETERMINISM_TRACE_INTERVAL_FRAMES := 15
const LANE_X_POSITIONS: Array[float] = [150.0, 220.0, 290.0, 360.0, 430.0, 500.0, 570.0]
const POLICY_WEAK_V02 := "WEAK_V02"
const POLICY_MERGE_AWARE_V01 := "MERGE_AWARE_V01"
const POLICY_CHEAP_MERGE_CENTER_V01 := "CHEAP_MERGE_CENTER_V01"
const POLICY_R19_FEEDBACK_AWARE_V01 := "R19_FEEDBACK_AWARE_V01"
const POLICY_R20_OBJECTIVE_LOOKAHEAD_V01 := "R20_OBJECTIVE_LOOKAHEAD_V01"
const POLICY_R21_SPATIAL_LANE_V01 := "R21_SPATIAL_LANE_V01"

var _root: Node
var time_scale := 1.0


func _init(root: Node) -> void:
	_root = root


func set_time_scale(value: float) -> void:
	time_scale = maxf(1.0, value)


func get_time_scale() -> float:
	return time_scale


func telemetry_schema_keys() -> Array[String]:
	return [
		"island_id", "level_id", "seed", "outcome", "elapsed_sec", "remaining_sec",
		"shot_count", "merge_count", "failed_merge_approach_count",
		"peak_live_drinks", "mean_live_drinks", "peak_board_occupancy",
		"large_piece_coexistence_peak", "contact_count", "rail_contact_count",
		"rail_contact_metric", "rail_enter_threshold_px", "rail_release_threshold_px",
		"danger_line_exposure_sec", "normal_objective_complete", "vip_complete",
		"action_log", "policy_name", "unique_x_positions", "lateral_variation_eligible",
		"lateral_variation", "decision_reason_counts", "terminal_reason", "physics_hook",
		"moves_used", "move_limit", "moves_remaining", "stars", "normal_orders_completed",
	"normal_orders_remaining", "vip_state",
	"physics_mode", "fixed_fps", "time_scale", "normal_theoretical_shots_T", "normal_4t_shot_cap",
		"progress_curve",
	]


func new_telemetry(island_id: String, level_id: int, seed_value: int) -> Dictionary:
	return {
		"island_id": island_id,
		"level_id": level_id,
		"seed": seed_value,
		"outcome": OUTCOME_HARNESS_ABORT,
		"elapsed_sec": 0.0,
		"remaining_sec": 0.0,
		"shot_count": 0,
		"merge_count": 0,
		"failed_merge_approach_count": 0,
		"peak_live_drinks": 0,
		"mean_live_drinks": 0.0,
		"peak_board_occupancy": 0.0,
		"large_piece_coexistence_peak": 0,
		"contact_count": 0,
		"rail_contact_count": 0,
		"rail_contact_metric": RAIL_CONTACT_METRIC,
		"rail_enter_threshold_px": RAIL_ENTER_THRESHOLD_PX,
		"rail_release_threshold_px": RAIL_RELEASE_THRESHOLD_PX,
		"danger_line_exposure_sec": 0.0,
		"normal_objective_complete": false,
		"vip_complete": false,
		"action_log": [],
		"policy_name": POLICY_WEAK_V02,
		"unique_x_positions": 0,
		"lateral_variation_eligible": false,
		"lateral_variation": false,
		"decision_reason_counts": {},
		"terminal_reason": "",
		"physics_hook": "production GameManager.spawn_drink + Drink.launch_up + Godot physics frames",
		"physics_mode": "standard_fps_production_physics",
		"fixed_fps": false,
		"time_scale": time_scale,
		"normal_theoretical_shots_T": 0,
		"normal_4t_shot_cap": 0,
		"moves_used": 0,
		"move_limit": 0,
		"moves_remaining": 0,
		"stars": 0,
		"normal_orders_completed": {},
		"normal_orders_remaining": {},
		"vip_state": {"enabled": false, "status": "HIDDEN", "completed": false},
		"progress_curve": [],
		"physics_trace": [],
	}


func validate_telemetry(telemetry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key in telemetry_schema_keys():
		if not telemetry.has(key):
			errors.append("missing telemetry key: %s" % key)
	var outcome := str(telemetry.get("outcome", ""))
	if not [OUTCOME_COMPLETED, OUTCOME_TIMEOUT, OUTCOME_DANGER, OUTCOME_HARNESS_ABORT].has(outcome):
		errors.append("invalid outcome: %s" % outcome)
	if str(telemetry.get("rail_contact_metric", "")) != RAIL_CONTACT_METRIC:
		errors.append("rail_contact_metric must document the proximity transition proxy")
	if not is_equal_approx(float(telemetry.get("rail_enter_threshold_px", -1.0)), RAIL_ENTER_THRESHOLD_PX):
		errors.append("rail enter threshold must be 1.0 px")
	if not is_equal_approx(float(telemetry.get("rail_release_threshold_px", -1.0)), RAIL_RELEASE_THRESHOLD_PX):
		errors.append("rail release threshold must be 3.0 px")
	return errors


func new_rail_proxy_state() -> Dictionary:
	return {
		"rail_near": {},
		"rail_seen_keys": {},
		"rail_contact_count": 0,
	}


func begin_rail_proxy_sample(state: Dictionary) -> void:
	state["rail_seen_keys"] = {}


func update_rail_proximity(state: Dictionary, drink_instance_id: int, edge_name: String, minimum_signed_distance: float) -> bool:
	## Count one enter transition per drink instance and authoritative edge.
	## Hysteresis prevents repeated events while the footprint remains near.
	var key := "%d|%s" % [drink_instance_id, edge_name]
	state["rail_seen_keys"][key] = true
	var was_near := bool(state["rail_near"].get(key, false))
	if was_near:
		if minimum_signed_distance > RAIL_RELEASE_THRESHOLD_PX:
			state["rail_near"].erase(key)
		return false
	if minimum_signed_distance <= RAIL_ENTER_THRESHOLD_PX:
		state["rail_near"][key] = true
		state["rail_contact_count"] = int(state["rail_contact_count"]) + 1
		return true
	return false


func end_rail_proxy_sample(state: Dictionary) -> void:
	## Remove drink/edge pairs that were not present in this sample.
	for key in state["rail_near"].keys().duplicate():
		if not state["rail_seen_keys"].has(key):
			state["rail_near"].erase(key)
	state["rail_seen_keys"].clear()


func classify_trial_outcome(terminal: Dictionary, manager_game_over: bool, elapsed_sec: float, time_limit_sec: float) -> Dictionary:
	## Required precedence: WIN, danger/game-over, actual timeout, bounded abort.
	var terminal_outcome := str(terminal.get("outcome", ""))
	var terminal_reason := str(terminal.get("reason", ""))
	if terminal_outcome == "WIN":
		return {"outcome": OUTCOME_COMPLETED, "terminal_reason": terminal_reason}
	if terminal_reason == "TABLE_DANGER":
		return {"outcome": OUTCOME_DANGER, "terminal_reason": terminal_reason if not terminal_reason.is_empty() else "DANGER_LINE"}
	if terminal_reason == "TIMEOUT" or (time_limit_sec > 0.0 and elapsed_sec >= time_limit_sec):
		return {"outcome": OUTCOME_TIMEOUT, "terminal_reason": terminal_reason if not terminal_reason.is_empty() else "TIME_LIMIT"}
	if manager_game_over:
		return {"outcome": OUTCOME_DANGER, "terminal_reason": terminal_reason if not terminal_reason.is_empty() else "DANGER_LINE"}
	return {"outcome": OUTCOME_HARNESS_ABORT, "terminal_reason": terminal_reason if not terminal_reason.is_empty() else "ACTION_BUDGET"}


func run_trial(
	database,
	island_id: String,
	level_id: int,
	seed_value: int,
	action_log_override: Array = [],
	policy_name: String = POLICY_WEAK_V02,
	max_shots_override: int = 0,
	use_production_shot_controller: bool = false,
	no_timer: bool = false,
	max_wall_time_sec: float = 0.0,
	stop_flag_path: String = "",
	profile_enabled: bool = false,
	cache_legal_launch_lanes: bool = false,
	capture_physics_trace: bool = false,
	max_physics_frames: int = 0,
	physics_trace_interval_frames: int = DETERMINISM_TRACE_INTERVAL_FRAMES,
	progress_checkpoint_path: String = "",
	progress_checkpoint_metadata: Dictionary = {},
	use_production_input_path: bool = false,
	initial_lane_feedback: Dictionary = {}
) -> Dictionary:
	var telemetry := new_telemetry(island_id, level_id, seed_value)
	telemetry["policy_name"] = policy_name
	telemetry["physics_mode"] = "standard_fps_production_physics"
	telemetry["fixed_fps"] = false
	telemetry["time_scale"] = time_scale
	var level_definition: Dictionary = database.get_level(island_id, level_id)
	if level_definition.is_empty():
		telemetry["terminal_reason"] = "LEVEL_NOT_FOUND"
		return telemetry
	telemetry["normal_theoretical_shots_T"] = int(level_definition.get("theoretical_shots_to_go", 0))
	telemetry["normal_4t_shot_cap"] = int(level_definition.get("theoretical_shots_to_go", 0)) * 4

	var manager = GAME_MANAGER_SCRIPT.new()
	_root.add_child(manager)
	await _root.get_tree().process_frame
	if manager.world == null or manager.shot_controller == null:
		telemetry["terminal_reason"] = "GAME_MANAGER_NOT_READY"
		manager.queue_free()
		await _root.get_tree().process_frame
		return telemetry

	manager.shot_controller.stop_shooting()
	if cache_legal_launch_lanes:
		manager.set_meta("m17_legal_launch_lane_cache", {})
	manager.set_meta("m34_r21_seed", seed_value)
	manager.set_meta("m34_r21_lane_history", {})
	manager.set_meta("m34_r21_decision_index", 0)
	var profile := {
		"enabled": profile_enabled,
		"frame_count": 0,
		"decision_count": 0,
		"decision_wall_usec": 0,
		"shot_commit_wall_usec": 0,
		"physics_frame_wait_wall_usec": 0,
		"sample_wall_usec": 0,
		"engine_performance_monitor": "not_sampled; frame wall timers are used because built-in monitors may be stale",
		"geometry_cache_misses": 0,
	}
	if profile_enabled:
		manager.set_meta("m17_profile", profile)
	var bridge = BRIDGE_SCRIPT.new()
	if not bridge.configure(database):
		telemetry["terminal_reason"] = "DATABASE_NOT_CONFIGURED"
		manager.queue_free()
		await _root.get_tree().process_frame
		return telemetry
	if bridge.start_session(island_id, level_id).is_empty() or not manager.configure_campaign_session(bridge):
		telemetry["terminal_reason"] = "SESSION_NOT_STARTED"
		manager.queue_free()
		await _root.get_tree().process_frame
		return telemetry

	var previous_time_scale := Engine.time_scale
	Engine.time_scale = time_scale
	seed(seed_value)
	var production_edges: Array[Dictionary] = []
	for edge in manager.get_playable_boundary_edges():
		production_edges.append({
			"name": str(edge.get("name", "")),
			"a": [edge["a"].x, edge["a"].y],
			"b": [edge["b"].x, edge["b"].y],
			"inward_normal": [edge["inward_normal"].x, edge["inward_normal"].y],
		})
	telemetry["production_geometry_snapshot"] = {
		"viewport_size": [manager.get_board_size().x, manager.get_board_size().y],
		"launch_y": manager.launch_y,
		"death_line_y": manager.death_line_y,
		"playable_edges": production_edges,
		"active_theme_paths": manager.get_active_theme_paths().duplicate(true),
		"main_scene_setting": str(ProjectSettings.get_setting("application/run/main_scene", "")),
		"manager_script": str(manager.get_script().resource_path) if manager.get_script() != null else "",
		"standard_physics_ticks_per_second": int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)),
	}
	var state := {
		"merge_pairs": {},
		"merge_count": 0,
		"contact_count": 0,
		"rail_contact_count": 0,
		"rail_near": {},
		"rail_seen_keys": {},
		"next_drink_instance_id": 1,
		"physics_frame_index": 0,
		"contact_events": [],
		"merge_events": [],
		"peak_live_drinks": 0,
		"live_sum": 0.0,
		"sample_count": 0,
		"peak_board_occupancy": 0.0,
		"large_piece_coexistence_peak": 0,
		"danger_line_exposure_sec": 0.0,
		"r19_lane_feedback": initial_lane_feedback.duplicate(true),
		"step_sec": PHYSICS_STEP_SEC * time_scale,
	}
	manager.set_meta("m34_r19_lane_feedback", initial_lane_feedback.duplicate(true))

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var expected_spawns := MODEL_SCRIPT.expected_spawn_count(MODEL_SCRIPT.normal_objective_cost(level_definition))
	var max_shots := maxi(12, int(ceil(expected_spawns * MAX_SHOTS_MULTIPLIER)) + 8)
	if max_shots_override > 0:
		max_shots = mini(max_shots, max_shots_override)
	var time_limit_sec := 0.0 if no_timer else float(level_definition.get("time_limit_sec", 0.0))
	var wall_start_msec := Time.get_ticks_msec()
	var action_index := 0
	var elapsed := 0.0
	var physics_frame_index := 0
	var replaying := not action_log_override.is_empty()
	while not bridge.is_terminal() and not manager.game_over and (time_limit_sec <= 0.0 or elapsed < time_limit_sec + 1.0) and action_index < max_shots and (max_physics_frames <= 0 or physics_frame_index < max_physics_frames) and (not use_production_shot_controller or bridge.can_commit_shot()) and (max_wall_time_sec <= 0.0 or float(Time.get_ticks_msec() - wall_start_msec) / 1000.0 < max_wall_time_sec) and not _stop_requested(stop_flag_path):
		var spawn_level: int
		var lane_index: int
		var x_position: float
		var lane_choice: Dictionary = {}
		if replaying:
			if action_index >= action_log_override.size():
				telemetry["terminal_reason"] = "REPLAY_ACTION_LOG_EXHAUSTED"
				break
			var action: Dictionary = action_log_override[action_index]
			spawn_level = int(action.get("spawn_level", 0))
			lane_index = int(action.get("lane_index", 0))
			x_position = float(action.get("x_position", LANE_X_POSITIONS[clampi(lane_index, 0, LANE_X_POSITIONS.size() - 1)]))
		else:
			spawn_level = rng.randi_range(1, 3)
			_assign_missing_stable_instance_ids(manager, state)
			var decision_start_usec := Time.get_ticks_usec() if profile_enabled else 0
			lane_choice = choose_action(manager, spawn_level, policy_name)
			if profile_enabled:
				profile["decision_count"] = int(profile["decision_count"]) + 1
				profile["decision_wall_usec"] = int(profile["decision_wall_usec"]) + Time.get_ticks_usec() - decision_start_usec
			lane_index = int(lane_choice["lane_index"])
			x_position = float(lane_choice["x_position"])

		var same_level_before := _has_same_level(manager, spawn_level)
		var action_record: Dictionary
		if replaying:
			action_record = {
				"step": action_index,
				"spawn_level": spawn_level,
				"lane_index": lane_index,
				"x_position": x_position,
				"decision_reason": str(action_log_override[action_index].get("decision_reason", "replay_action")),
				"same_level_target_found": bool(action_log_override[action_index].get("same_level_target_found", false)),
				"target_instance_id": action_log_override[action_index].get("target_instance_id", null),
			}
		else:
			action_record = {
				"step": action_index,
				"spawn_level": spawn_level,
				"lane_index": lane_index,
				"x_position": x_position,
				"decision_reason": str(lane_choice.get("decision_reason", "unspecified")),
				"same_level_target_found": bool(lane_choice.get("same_level_target_found", false)),
				"target_instance_id": lane_choice.get("target_instance_id", null),
			}
		if lane_choice.has("r20_candidate_evaluations"):
			action_record["candidate_lane_evaluations"] = lane_choice["r20_candidate_evaluations"].duplicate(true)
			action_record["selected_candidate_evaluation"] = lane_choice.get("r20_selected_candidate", {}).duplicate(true)
		elif lane_choice.has("r21_candidate_evaluations"):
			action_record["candidate_lane_evaluations"] = lane_choice["r21_candidate_evaluations"].duplicate(true)
			action_record["selected_candidate_evaluation"] = lane_choice.get("r21_selected_candidate", {}).duplicate(true)
			action_record["selected_candidate_rank"] = int(lane_choice.get("r21_selected_candidate", {}).get("rank", 0))
		action_record["physics_frame_start"] = physics_frame_index
		action_record["launch_y"] = manager.launch_y
		action_record["normal_orders_before"] = bridge.get_objective_state().get("normal_remaining", {}).duplicate(true)
		action_record["normal_T_before"] = _remaining_normal_t(action_record["normal_orders_before"])
		action_record["shots_used_before"] = int(telemetry["shot_count"])
		action_record["remaining_4t_shot_budget_before"] = maxi(0, int(telemetry["normal_4t_shot_cap"]) - int(telemetry["shot_count"]))
		action_record["objective_theoretical_shot_floor_before"] = int(action_record["normal_T_before"])
		action_record["within_remaining_4t_budget_floor_before"] = int(action_record["objective_theoretical_shot_floor_before"]) <= int(action_record["remaining_4t_shot_budget_before"])
		action_record["feasibility_scope"] = "T-based shot-budget floor only; not a proof of physical or stochastic reachability"
		action_record["board_before"] = _board_observations(manager)
		var contact_event_start: int = state["contact_events"].size()
		var merge_event_start: int = state["merge_events"].size()
		telemetry["action_log"].append(action_record)
		if not progress_checkpoint_path.is_empty():
			_write_progress_checkpoint(progress_checkpoint_path, telemetry, bridge, state, physics_frame_index, action_index + 1, "ACTION_COMMITTED", progress_checkpoint_metadata)
		var shot_commit_start_usec := Time.get_ticks_usec() if profile_enabled else 0
		var launched = manager.spawn_drink(spawn_level, Vector2(x_position, manager.launch_y), true)
		if launched == null:
			telemetry["terminal_reason"] = "SPAWN_FAILED"
			break
		_attach_drink(launched, state)
		launched.position.x = x_position
		if use_production_input_path:
			# Drive the exact production mouse-drag handler: press at the held
			# launch anchor and release at the selected viewport x coordinate.
			if is_instance_valid(manager.shot_controller._current_drink):
				manager.shot_controller._current_drink.queue_free()
			manager.shot_controller._current_drink = launched
			manager.shot_controller._can_shoot = true
			var input_press := InputEventMouseButton.new()
			input_press.button_index = MOUSE_BUTTON_LEFT
			input_press.pressed = true
			input_press.position = Vector2(manager.get_board_size().x * 0.5, launched.position.y)
			action_record["input_press_viewport"] = [input_press.position.x, input_press.position.y]
			manager.shot_controller._unhandled_input(input_press)
			var input_release := InputEventMouseButton.new()
			input_release.button_index = MOUSE_BUTTON_LEFT
			input_release.pressed = false
			input_release.position = Vector2(x_position, launched.position.y)
			action_record["input_release_viewport"] = [input_release.position.x, input_release.position.y]
			manager.shot_controller._unhandled_input(input_release)
			action_record["input_path"] = "ShotController._unhandled_input"
			action_record["requested_viewport_x"] = x_position
			action_record["fired_position"] = [launched.position.x, launched.position.y]
			action_record["fired_velocity"] = [launched.linear_velocity.x, launched.linear_velocity.y]
			telemetry["action_log"][action_index] = action_record
		elif use_production_shot_controller:
			# Exercise ShotController's actual launch path. It emits shot_fired,
			# which records the committed move through GameManager, then replaces
			# the held preview exactly as a normal launch does.
			manager.shot_controller.stop_shooting()
			manager.shot_controller._current_drink = launched
			manager.shot_controller._launch()
		else:
			launched.launch_up(SHOT_SPEED)
		if profile_enabled:
			profile["shot_commit_wall_usec"] = int(profile["shot_commit_wall_usec"]) + Time.get_ticks_usec() - shot_commit_start_usec
		telemetry["shot_count"] = int(telemetry["shot_count"]) + 1
		var merges_before := int(state["merge_count"])
		var contacts_before := int(state["contact_count"])
		var objective_before := _remaining_normal_t(bridge.get_objective_state().get("normal_remaining", {}))
		for _frame in range(FRAMES_PER_ACTION):
			if max_physics_frames > 0 and physics_frame_index >= max_physics_frames:
				break
			state["physics_frame_index"] = physics_frame_index + 1
			var frame_start_usec := Time.get_ticks_usec() if profile_enabled else 0
			await _root.get_tree().physics_frame
			if profile_enabled:
				profile["frame_count"] = int(profile["frame_count"]) + 1
				profile["physics_frame_wait_wall_usec"] = int(profile["physics_frame_wait_wall_usec"]) + Time.get_ticks_usec() - frame_start_usec
			elapsed += float(state["step_sec"])
			var sample_start_usec := Time.get_ticks_usec() if profile_enabled else 0
			_sample(manager, state)
			physics_frame_index += 1
			if not progress_checkpoint_path.is_empty() and physics_frame_index % DETERMINISM_TRACE_INTERVAL_FRAMES == 0:
				_write_progress_checkpoint(progress_checkpoint_path, telemetry, bridge, state, physics_frame_index, action_index + 1, "ACTION_IN_PHYSICS", progress_checkpoint_metadata)
			if capture_physics_trace and physics_frame_index % maxi(1, physics_trace_interval_frames) == 0:
				_append_physics_trace(telemetry, manager, bridge, state, physics_frame_index)
			if profile_enabled:
				profile["sample_wall_usec"] = int(profile["sample_wall_usec"]) + Time.get_ticks_usec() - sample_start_usec
			if bridge.is_terminal() or manager.game_over:
				break
			if _stop_requested(stop_flag_path):
				break
			if max_wall_time_sec > 0.0 and float(Time.get_ticks_msec() - wall_start_msec) / 1000.0 >= max_wall_time_sec:
				break
		if same_level_before and int(state["merge_count"]) == merges_before:
			# Bounded proxy: a same-level approach existed at launch but no merge
			# request resolved during this action's physics window.
			state["failed_merge_approach_count"] = int(state.get("failed_merge_approach_count", 0)) + 1
		action_index += 1
		var progress_state: Dictionary = bridge.get_objective_state()
		var normal_remaining: Dictionary = progress_state.get("normal_remaining", {})
		var remaining_t := _remaining_normal_t(normal_remaining)
		if policy_name == POLICY_R19_FEEDBACK_AWARE_V01:
			_record_r19_lane_feedback(state, x_position, objective_before - remaining_t, int(state["merge_count"]) - merges_before, int(state["contact_count"]) - contacts_before)
			manager.set_meta("m34_r19_lane_feedback", state["r19_lane_feedback"].duplicate(true))
		action_record["physics_frame_end"] = physics_frame_index
		action_record["contacts_delta"] = int(state["contact_count"]) - contacts_before
		action_record["contact_events"] = state["contact_events"].slice(contact_event_start)
		action_record["merges_delta"] = int(state["merge_count"]) - merges_before
		action_record["merge_chain"] = state["merge_events"].slice(merge_event_start)
		action_record["normal_orders_after"] = progress_state.get("normal_remaining", {}).duplicate(true)
		action_record["normal_T_after"] = remaining_t
		action_record["normal_objective_progress_delta"] = objective_before - remaining_t
		action_record["shots_used_after"] = int(telemetry["shot_count"])
		action_record["remaining_4t_shot_budget_after"] = maxi(0, int(telemetry["normal_4t_shot_cap"]) - int(telemetry["shot_count"]))
		action_record["objective_theoretical_shot_floor_after"] = remaining_t
		action_record["within_remaining_4t_budget_floor_after"] = remaining_t <= int(action_record["remaining_4t_shot_budget_after"])
		action_record["board_after"] = _board_observations(manager)
		action_record["actual_production_physics"] = true
		if action_record.has("selected_candidate_evaluation"):
			var forecast: Dictionary = action_record["selected_candidate_evaluation"]
			var observed_result_level := int(action_record["spawn_level"])
			for merge_event in action_record["merge_chain"]:
				observed_result_level = maxi(observed_result_level, int(merge_event.get("result_level", 0)))
			action_record["observed_result_level_from_merges"] = observed_result_level
			action_record["predicted_result_level"] = int(forecast.get("predicted_result_level", action_record["spawn_level"]))
			action_record["predicted_vs_observed_result_level_delta"] = observed_result_level - int(forecast.get("predicted_result_level", action_record["spawn_level"]))
			action_record["forecast_merge_count"] = forecast.get("predicted_merge_chain", []).size()
			action_record["observed_merge_count"] = int(action_record["merges_delta"])
			action_record["forecast_matched_any_merge"] = (int(action_record["merges_delta"]) > 0) == (action_record["forecast_merge_count"] > 0)
			action_record["forecast_objective_progress"] = "heuristic_candidate_rank_only"
			action_record["observed_objective_progress_delta"] = int(action_record["normal_objective_progress_delta"])
			action_record["candidate_x_to_requested_x_delta"] = snappedf(float(action_record.get("requested_viewport_x", x_position)) - float(action_record.get("selected_candidate_evaluation", {}).get("candidate_x", x_position)), 0.001)
			action_record["requested_x_to_fired_x_delta"] = snappedf(float(action_record.get("fired_position", [x_position, 0.0])[0]) - float(action_record.get("requested_viewport_x", x_position)), 0.001)
		telemetry["action_log"][action_index - 1] = action_record
		var normal_t_start := int(ceil(float(MODEL_SCRIPT.normal_objective_cost(level_definition)) / 4.0))
		var move_state: Dictionary = bridge.get_move_budget_state()
		var moves_used := int(move_state.get("moves_used", 0))
		telemetry["progress_curve"].append({
			"action_count": action_index,
			"simulated_seconds": snappedf(elapsed, 0.001),
			"normal_T_start": normal_t_start,
			"normal_T_remaining": remaining_t,
			"normal_T_progressed": maxi(0, normal_t_start - remaining_t),
			"moves_used": moves_used,
			"normal_T_progress_per_move": snappedf(float(maxi(0, normal_t_start - remaining_t)) / float(maxi(1, moves_used)), 0.001),
			"merge_count": int(state["merge_count"]),
			"normal_orders_completed": progress_state.get("normal_completed", {}).duplicate(true),
			"vip_state": bridge.get_vip_state().duplicate(true),
		})
		if not progress_checkpoint_path.is_empty():
			_write_progress_checkpoint(progress_checkpoint_path, telemetry, bridge, state, physics_frame_index, action_index, "ACTION_SETTLED", progress_checkpoint_metadata)

	if not bridge.is_terminal() and not manager.game_over and (max_physics_frames <= 0 or physics_frame_index < max_physics_frames):
		for _frame in range(MAX_EXTRA_SETTLE_FRAMES):
			if max_physics_frames > 0 and physics_frame_index >= max_physics_frames:
				break
			state["physics_frame_index"] = physics_frame_index + 1
			var frame_start_usec := Time.get_ticks_usec() if profile_enabled else 0
			await _root.get_tree().physics_frame
			if profile_enabled:
				profile["frame_count"] = int(profile["frame_count"]) + 1
				profile["physics_frame_wait_wall_usec"] = int(profile["physics_frame_wait_wall_usec"]) + Time.get_ticks_usec() - frame_start_usec
			elapsed += float(state["step_sec"])
			var sample_start_usec := Time.get_ticks_usec() if profile_enabled else 0
			_sample(manager, state)
			physics_frame_index += 1
			if not progress_checkpoint_path.is_empty() and physics_frame_index % DETERMINISM_TRACE_INTERVAL_FRAMES == 0:
				_write_progress_checkpoint(progress_checkpoint_path, telemetry, bridge, state, physics_frame_index, action_index, "SETTLE_IN_PHYSICS", progress_checkpoint_metadata)
			if capture_physics_trace and physics_frame_index % maxi(1, physics_trace_interval_frames) == 0:
				_append_physics_trace(telemetry, manager, bridge, state, physics_frame_index)
			if profile_enabled:
				profile["sample_wall_usec"] = int(profile["sample_wall_usec"]) + Time.get_ticks_usec() - sample_start_usec
			if bridge.is_terminal() or manager.game_over:
				break
			if _stop_requested(stop_flag_path):
				break
			if max_wall_time_sec > 0.0 and float(Time.get_ticks_msec() - wall_start_msec) / 1000.0 >= max_wall_time_sec:
				break

	if bridge.is_terminal():
		var terminal: Dictionary = bridge.get_terminal_result()
		var classified := classify_trial_outcome(terminal, manager.game_over, elapsed, time_limit_sec)
		telemetry["outcome"] = classified["outcome"]
		telemetry["terminal_reason"] = classified["terminal_reason"]
	else:
		var classified := classify_trial_outcome({}, manager.game_over, elapsed, time_limit_sec)
		telemetry["outcome"] = classified["outcome"]
		if max_physics_frames > 0 and physics_frame_index >= max_physics_frames:
			telemetry["terminal_reason"] = "PHYSICS_FRAME_BUDGET"
		elif use_production_shot_controller and not bridge.can_commit_shot():
			telemetry["terminal_reason"] = "MOVE_BUDGET_EXHAUSTED"
		elif _stop_requested(stop_flag_path):
			telemetry["terminal_reason"] = "STOP_SIGNAL"
		elif action_index >= max_shots:
			telemetry["terminal_reason"] = "PER_LEVEL_SHOT_BUDGET"
		elif max_wall_time_sec > 0.0 and float(Time.get_ticks_msec() - wall_start_msec) / 1000.0 >= max_wall_time_sec:
			telemetry["terminal_reason"] = "PER_LEVEL_WALL_BUDGET"
		else:
			telemetry["terminal_reason"] = classified["terminal_reason"]

	telemetry["elapsed_sec"] = elapsed
	telemetry["remaining_sec"] = maxf(0.0, float(bridge.timer_remaining_sec))
	telemetry["merge_count"] = int(state["merge_count"])
	telemetry["failed_merge_approach_count"] = int(state.get("failed_merge_approach_count", 0))
	telemetry["peak_live_drinks"] = int(state["peak_live_drinks"])
	telemetry["mean_live_drinks"] = float(state["live_sum"]) / float(maxi(1, int(state["sample_count"])))
	telemetry["peak_board_occupancy"] = float(state["peak_board_occupancy"])
	telemetry["large_piece_coexistence_peak"] = int(state["large_piece_coexistence_peak"])
	telemetry["contact_count"] = int(state["contact_count"])
	telemetry["contact_events"] = state["contact_events"].duplicate(true)
	telemetry["merge_events"] = state["merge_events"].duplicate(true)
	telemetry["rail_contact_count"] = int(state["rail_contact_count"])
	telemetry["danger_line_exposure_sec"] = float(state["danger_line_exposure_sec"])
	var unique_x: Dictionary = {}
	var decision_reasons: Dictionary = {}
	for action in telemetry["action_log"]:
		unique_x[String.num(float(action.get("x_position", 0.0)), 3)] = true
		var reason := str(action.get("decision_reason", "unspecified"))
		decision_reasons[reason] = int(decision_reasons.get(reason, 0)) + 1
	telemetry["unique_x_positions"] = unique_x.size()
	telemetry["lateral_variation_eligible"] = int(telemetry["shot_count"]) >= 5
	telemetry["lateral_variation"] = bool(telemetry["lateral_variation_eligible"]) and int(telemetry["unique_x_positions"]) >= 2
	telemetry["decision_reason_counts"] = decision_reasons
	var objective_state: Dictionary = bridge.get_objective_state()
	telemetry["normal_objective_complete"] = bridge.is_terminal() and str(bridge.get_terminal_result().get("outcome", "")) == "WIN"
	telemetry["vip_complete"] = bool(objective_state.get("vip_completed", false))
	var move_state: Dictionary = bridge.get_move_budget_state()
	telemetry["moves_used"] = int(move_state.get("moves_used", 0))
	telemetry["move_limit"] = int(move_state.get("move_limit", 0))
	telemetry["moves_remaining"] = int(move_state.get("moves_remaining", 0))
	telemetry["normal_orders_completed"] = objective_state.get("normal_completed", {}).duplicate(true)
	telemetry["normal_orders_remaining"] = objective_state.get("normal_remaining", {}).duplicate(true)
	telemetry["vip_state"] = bridge.get_vip_state().duplicate(true)
	telemetry["r19_lane_feedback"] = state.get("r19_lane_feedback", {}).duplicate(true)
	telemetry["stars"] = int(bridge.get_terminal_result().get("stars", 0)) if bridge.is_terminal() else 0
	if profile_enabled:
		profile["decision_wall_usec_per_action"] = snappedf(float(profile["decision_wall_usec"]) / float(maxi(1, int(profile["decision_count"]))), 0.01)
		profile["sample_wall_usec_per_frame"] = snappedf(float(profile["sample_wall_usec"]) / float(maxi(1, int(profile["frame_count"]))), 0.01)
		telemetry["profile"] = profile.duplicate(true)

	manager.queue_free()
	await _root.get_tree().process_frame
	Engine.time_scale = previous_time_scale
	return telemetry


func _append_physics_trace(telemetry: Dictionary, manager, bridge, state: Dictionary, frame_index: int) -> void:
	var bodies: Array[Dictionary] = []
	if manager.world != null:
		for child in manager.world.get_children():
			if not child is Drink or child.is_queued_for_deletion() or child.motion_state == Drink.MotionState.HELD:
				continue
			var drink: Drink = child
			bodies.append({
				"instance_id": _stable_instance_id(drink),
				"level": drink.level,
				"motion_state": int(drink.motion_state),
				"sleeping": drink.sleeping,
				"position": [drink.position.x, drink.position.y],
				"velocity": [drink.linear_velocity.x, drink.linear_velocity.y],
			})
	bodies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.instance_id) < int(b.instance_id)
	)
	var progress: Dictionary = bridge.get_objective_state()
	var moves: Dictionary = bridge.get_move_budget_state()
	var spawns: Array[int] = []
	for action in telemetry["action_log"]:
		spawns.append(int(action.get("spawn_level", 0)))
	var trace_state := {
		"frame": frame_index,
		"bodies": bodies,
		"spawn_levels": spawns,
		"merge_count": int(state["merge_count"]),
		"contact_count": int(state["contact_count"]),
		"moves_used": int(moves.get("moves_used", 0)),
		"normal_completed": progress.get("normal_completed", {}).duplicate(true),
		"normal_remaining": progress.get("normal_remaining", {}).duplicate(true),
		"vip_state": bridge.get_vip_state().duplicate(true),
		"terminal": bridge.get_terminal_result().duplicate(true) if bridge.is_terminal() else {},
		"contact_event_count": state["contact_events"].size(),
		"merge_event_count": state["merge_events"].size(),
		"action_log": telemetry["action_log"].duplicate(true),
	}
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(JSON.stringify(trace_state).to_utf8_buffer())
	telemetry["physics_trace"].append({"frame": frame_index, "sha256": context.finish().hex_encode(), "state": trace_state})


func _write_progress_checkpoint(path: String, telemetry: Dictionary, bridge, state: Dictionary, frame_index: int, completed_actions: int, phase: String, metadata: Dictionary = {}) -> void:
	var objectives: Dictionary = bridge.get_objective_state()
	var moves: Dictionary = bridge.get_move_budget_state()
	var checkpoint := {
		"schema_version": 1,
		"status": "CASE_RUNNING",
		"phase": phase,
		"island_id": str(telemetry.get("island_id", "")),
		"level_id": int(telemetry.get("level_id", 0)),
		"seed": int(telemetry.get("seed", 0)),
		"policy_name": str(telemetry.get("policy_name", "")),
		"physics_frame": frame_index,
		"completed_actions": completed_actions,
		"action_log": telemetry.get("action_log", []).duplicate(true),
		"progress_curve": telemetry.get("progress_curve", []).duplicate(true),
		"merge_count": int(state.get("merge_count", 0)),
		"merge_events": state.get("merge_events", []).duplicate(true),
		"contact_count": int(state.get("contact_count", 0)),
		"moves_used": int(moves.get("moves_used", 0)),
		"normal_orders_completed": objectives.get("normal_completed", {}).duplicate(true),
		"normal_orders_remaining": objectives.get("normal_remaining", {}).duplicate(true),
		"vip_state": bridge.get_vip_state().duplicate(true),
	}
	checkpoint.merge(metadata, true)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(checkpoint) + "\n")
	file.flush()
	file.close()


func _attach_drink(drink: Drink, state: Dictionary) -> void:
	drink.set_meta("m17_instance_id", int(state["next_drink_instance_id"]))
	state["next_drink_instance_id"] = int(state["next_drink_instance_id"]) + 1
	if not drink.merged.is_connected(_on_drink_merge):
		drink.merged.connect(_on_drink_merge.bind(state))
	if not drink.body_entered.is_connected(_on_drink_contact):
		drink.body_entered.connect(_on_drink_contact.bind(drink, state))


func _assign_missing_stable_instance_ids(manager, state: Dictionary) -> void:
	if manager.world == null:
		return
	for child in manager.world.get_children():
		if child is Drink and not child.is_queued_for_deletion():
			_ensure_stable_instance_id(child, state)


func _ensure_stable_instance_id(drink: Drink, state: Dictionary) -> int:
	if not drink.has_meta("m17_instance_id"):
		drink.set_meta("m17_instance_id", int(state["next_drink_instance_id"]))
		state["next_drink_instance_id"] = int(state["next_drink_instance_id"]) + 1
	return int(drink.get_meta("m17_instance_id"))


func _on_drink_merge(a: Drink, b: Drink, new_level: int, state: Dictionary) -> void:
	if not is_instance_valid(a) or not is_instance_valid(b):
		return
	var first := mini(a.get_instance_id(), b.get_instance_id())
	var second := maxi(a.get_instance_id(), b.get_instance_id())
	var pair_key := "%d:%d:%d" % [first, second, new_level]
	if state["merge_pairs"].has(pair_key):
		return
	state["merge_pairs"][pair_key] = true
	state["merge_count"] = int(state["merge_count"]) + 1
	var a_stable := _ensure_stable_instance_id(a, state)
	var b_stable := _ensure_stable_instance_id(b, state)
	var first_stable := mini(a_stable, b_stable)
	var second_stable := maxi(a_stable, b_stable)
	state["merge_events"].append({
		"frame": int(state["physics_frame_index"]),
		"first_instance_id": first_stable,
		"second_instance_id": second_stable,
		"first_level": a.level,
		"second_level": b.level,
		"result_level": new_level,
		"first_position": [a.position.x, a.position.y],
		"second_position": [b.position.x, b.position.y],
		"first_velocity": [a.linear_velocity.x, a.linear_velocity.y],
		"second_velocity": [b.linear_velocity.x, b.linear_velocity.y],
	})


func _on_drink_contact(body: Node, source: Drink, state: Dictionary) -> void:
	state["contact_count"] = int(state["contact_count"]) + 1
	if not is_instance_valid(source):
		return
	var source_id := _ensure_stable_instance_id(source, state)
	var target_is_drink := body is Drink
	var target_id = _ensure_stable_instance_id(body, state) if target_is_drink else null
	state["contact_events"].append({
		"frame": int(state["physics_frame_index"]),
		"source_instance_id": source_id,
		"source_level": source.level,
		"source_motion_state": int(source.motion_state),
		"source_position": [source.position.x, source.position.y],
		"source_velocity": [source.linear_velocity.x, source.linear_velocity.y],
		"target_kind": "drink" if target_is_drink else ("static_body" if body is StaticBody2D else "other"),
		"target_instance_id": target_id,
		"target_name": str(body.name) if is_instance_valid(body) else "freed",
		"target_level": body.level if target_is_drink else 0,
		"target_motion_state": int(body.motion_state) if target_is_drink else -1,
		"target_position": [body.position.x, body.position.y] if body is Node2D else [],
		"target_velocity": [body.linear_velocity.x, body.linear_velocity.y] if body is RigidBody2D else [],
	})


func _sample(manager, state: Dictionary) -> void:
	if manager.world == null:
		return
	_assign_missing_stable_instance_ids(manager, state)
	var live_count := 0
	var large_count := 0
	var occupied_area := 0.0
	var danger := false
	begin_rail_proxy_sample(state)
	var edges: Array[Dictionary] = manager.get_playable_boundary_edges()
	for child in manager.world.get_children():
		if not child is Drink or child.is_queued_for_deletion() or child.motion_state == Drink.MotionState.HELD:
			continue
		var drink: Drink = child
		live_count += 1
		occupied_area += PI * drink.radius * drink.radius
		if drink.level >= LARGE_PIECE_LEVEL:
			large_count += 1
		if drink.is_settled() and drink.position.y + drink.radius > manager.death_line_y:
			danger = true
		var drink_id := drink.get_instance_id()
		var footprint := drink.get_table_footprint_local()
		for edge in edges:
			var edge_name := str(edge["name"])
			var minimum_distance := INF
			for point in footprint:
				minimum_distance = minf(minimum_distance, edge["inward_normal"].dot(drink.position + point - edge["a"]))
			update_rail_proximity(state, drink_id, edge_name, minimum_distance)
	end_rail_proxy_sample(state)
	if danger:
		state["danger_line_exposure_sec"] = float(state["danger_line_exposure_sec"]) + float(state["step_sec"])
	state["peak_live_drinks"] = maxi(int(state["peak_live_drinks"]), live_count)
	state["live_sum"] = float(state["live_sum"]) + float(live_count)
	state["sample_count"] = int(state["sample_count"]) + 1
	state["peak_board_occupancy"] = maxf(float(state["peak_board_occupancy"]), occupied_area / BOARD_OCCUPANCY_AREA_PX2)
	state["large_piece_coexistence_peak"] = maxi(int(state["large_piece_coexistence_peak"]), large_count)


func _has_same_level(manager, level: int) -> bool:
	if manager.world == null:
		return false
	for child in manager.world.get_children():
		if child is Drink and not child.is_queued_for_deletion() and child.motion_state != Drink.MotionState.HELD and child.level == level:
			return true
	return false


func _remaining_normal_t(normal_remaining: Dictionary) -> int:
	var remaining := 0
	for raw_level in normal_remaining:
		var level := int(raw_level)
		if level >= 3:
			remaining += (1 << (level - 3)) * int(normal_remaining[raw_level])
	return remaining


func tag_drink_instance(drink: Drink, stable_id: int) -> void:
	if drink != null:
		drink.set_meta("m17_instance_id", stable_id)


func choose_action(manager, level: int, policy_name: String = POLICY_WEAK_V02) -> Dictionary:
	var observations := _board_observations(manager)
	var objective_level := 0
	var bridge = manager.get_campaign_session_bridge()
	if bridge != null and bridge.is_session_active():
		objective_level = bridge.get_next_required_order_level()
	var legal_x_positions := _cached_or_legal_launch_x_positions(manager, level)
	if policy_name == POLICY_R20_OBJECTIVE_LOOKAHEAD_V01:
		return _select_r20_objective_lookahead_action(manager, level, observations, objective_level, legal_x_positions)
	if policy_name == POLICY_R21_SPATIAL_LANE_V01:
		return _select_r21_spatial_lane_action(manager, level, observations, objective_level, legal_x_positions)
	if policy_name == POLICY_R19_FEEDBACK_AWARE_V01:
		return _select_r19_feedback_action(manager, level, observations, objective_level, legal_x_positions)
	if policy_name == POLICY_MERGE_AWARE_V01:
		return _select_merge_aware_action(level, observations, objective_level, legal_x_positions)
	if policy_name == POLICY_CHEAP_MERGE_CENTER_V01:
		return _select_cheap_merge_center_action(level, observations, legal_x_positions)
	return _select_weak_v02_action(level, observations, legal_x_positions)


func _record_r19_lane_feedback(state: Dictionary, x_position: float, objective_gain: int, merge_gain: int, contact_gain: int) -> void:
	var feedback: Dictionary = state.get("r19_lane_feedback", {})
	var key := _r19_lane_key(x_position)
	var lane: Dictionary = feedback.get(key, {"trials": 0, "objective_gain": 0, "merge_gain": 0, "contact_gain": 0, "no_progress": 0})
	lane["trials"] = int(lane.get("trials", 0)) + 1
	lane["objective_gain"] = int(lane.get("objective_gain", 0)) + maxi(0, objective_gain)
	lane["merge_gain"] = int(lane.get("merge_gain", 0)) + maxi(0, merge_gain)
	lane["contact_gain"] = int(lane.get("contact_gain", 0)) + maxi(0, contact_gain)
	if objective_gain <= 0:
		lane["no_progress"] = int(lane.get("no_progress", 0)) + 1
	feedback[key] = lane
	state["r19_lane_feedback"] = feedback


func _select_r19_feedback_action(manager, level: int, observations: Array, objective_level: int, legal_x_positions: Array) -> Dictionary:
	## Greedy online policy. It reacts only to observed board/objective state and
	## prior outcomes for launch lanes; it never inspects future RNG values.
	var feedback: Dictionary = manager.get_meta("m34_r19_lane_feedback", {})
	return choose_r19_action_from_observations(level, observations, objective_level, legal_x_positions, feedback)


func choose_r19_action_from_observations(level: int, observations: Array, objective_level: int, legal_x_positions: Array, feedback: Dictionary) -> Dictionary:
	## Deterministic pure seam used by the input/bot contract test.
	var targets: Array[Dictionary] = []
	for observation in observations:
		if int(observation.get("level", 0)) == level:
			targets.append(observation)
	var candidates: Array[float] = []
	if not targets.is_empty():
		for target in targets:
			candidates.append(_nearest_legal_x(float(target.get("x", 360.0)), legal_x_positions))
	else:
		for x_value in (legal_x_positions if not legal_x_positions.is_empty() else LANE_X_POSITIONS):
			candidates.append(float(x_value))
	if candidates.is_empty():
		candidates.append(_nearest_legal_x(360.0, legal_x_positions))
	var best_x := candidates[0]
	var best_score := -INF
	var best_target_id := 0
	for candidate in candidates:
		var key := _r19_lane_key(candidate)
		var lane: Dictionary = feedback.get(key, {})
		var trials := int(lane.get("trials", 0))
		var observed_gain := float(lane.get("objective_gain", 0)) * 5.0 + float(lane.get("merge_gain", 0)) * 0.5 + float(lane.get("contact_gain", 0)) * 0.03
		var score := (observed_gain / float(maxi(1, trials))) - float(lane.get("no_progress", 0)) * 0.35
		var center_distance := absf(candidate - 360.0)
		if targets.is_empty():
			var congestion := 0.0
			for observation in observations:
				var dx := absf(float(observation.get("x", 0.0)) - candidate)
				if dx <= 105.0:
					congestion += 1.0 - dx / 210.0
			score -= congestion
		if objective_level > 0 and level + 1 == objective_level:
			score += 0.15
		score -= center_distance * 0.0001
		var candidate_target_id := 0
		for target in targets:
			if is_equal_approx(_nearest_legal_x(float(target.get("x", 360.0)), legal_x_positions), candidate):
				candidate_target_id = int(target.get("instance_id", 0))
				break
		if score > best_score or (is_equal_approx(score, best_score) and candidate_target_id > 0 and (best_target_id == 0 or candidate_target_id < best_target_id)):
			best_score = score
			best_x = candidate
			best_target_id = candidate_target_id
	var reason := "feedback_same_level_target" if best_target_id > 0 else "feedback_objective_and_lane_history"
	return _action_result(best_x, best_target_id > 0, best_target_id if best_target_id > 0 else null, reason)


func _r19_lane_key(x_position: float) -> String:
	return str(int(round(x_position * 1000.0)))


func _select_r20_objective_lookahead_action(manager, level: int, observations: Array, objective_level: int, legal_x_positions: Array) -> Dictionary:
	var target_levels: Array[int] = []
	var bridge = manager.get_campaign_session_bridge()
	if bridge != null and bridge.is_session_active():
		var objective_state: Dictionary = bridge.get_objective_state()
		var normal_remaining: Dictionary = objective_state.get("normal_remaining", {})
		for raw_level in normal_remaining.keys():
			if int(normal_remaining[raw_level]) > 0:
				target_levels.append(int(raw_level))
	if target_levels.is_empty() and objective_level > 0:
		target_levels.append(objective_level)
	return choose_r20_action_from_observations(level, observations, target_levels, legal_x_positions, manager.launch_y)


func choose_r20_action_from_observations(level: int, observations: Array, target_levels: Array, legal_x_positions: Array, launch_y: float = 960.0) -> Dictionary:
	## Bounded, optimistic three-spawn inventory lookahead. It enumerates every
	## legal candidate lane and all 27 possible future L1-L3 spawn sequences;
	## it never reads the seeded RNG or claims that the inventory model proves
	## physical reachability. Production collision/merge events validate picks.
	var candidates: Array = legal_x_positions if not legal_x_positions.is_empty() else LANE_X_POSITIONS.duplicate()
	if candidates.is_empty(): candidates = [_nearest_legal_x(360.0, [])]
	var evaluations: Array[Dictionary] = []
	var best_index := 0
	var best_score := -INF
	var best_center := INF
	for candidate_index in range(candidates.size()):
		var candidate_x := float(candidates[candidate_index])
		var predicted := _r20_predict_merge_chain(level, candidate_x, observations, launch_y)
		var inventory: Dictionary = {}
		for observation in observations:
			var dx := absf(float(observation.get("x", candidate_x)) - candidate_x)
			var y := float(observation.get("y", launch_y))
			if dx <= 165.0 and y <= launch_y + float(observation.get("radius", 30.0)):
				var observed_level := int(observation.get("level", 0))
				inventory[observed_level] = int(inventory.get(observed_level, 0)) + 1
		var expectation := 0.0
		for sequence_id in range(27):
			var state := inventory.duplicate(true)
			var result_level := _r20_add_virtual_spawn(state, level)
			for future_index in range(3):
				var divisor := int(round(pow(3.0, float(future_index))))
				var future_spawn := int(floor(float(sequence_id / divisor))) % 3 + 1
				result_level = maxi(result_level, _r20_add_virtual_spawn(state, future_spawn))
			expectation += _r20_objective_inventory_score(state, target_levels, result_level)
		expectation /= 27.0
		var chain: Array = predicted.get("merge_chain", [])
		var resulting_level := int(predicted.get("result_level", level))
		var direct_bonus := float(chain.size()) * 5.0
		for target_level in target_levels:
			if resulting_level == int(target_level): direct_bonus += 150.0
			elif resulting_level < int(target_level): direct_bonus += maxf(0.0, 8.0 - float(int(target_level) - resulting_level)) * 1.5
		var total_score := expectation + direct_bonus
		var evaluation := {
			"candidate_x": candidate_x,
			"score": snappedf(total_score, 0.001),
			"lookahead_mean": snappedf(expectation, 0.001),
			"lookahead_depth": 3,
			"future_spawn_support": [1, 2, 3],
			"sequence_count": 27,
			"local_level_inventory": inventory,
			"predicted_merge_chain": chain.duplicate(true),
			"predicted_result_level": resulting_level,
			"target_order_levels": target_levels.duplicate(),
			"model_label": "optimistic_lane_inventory_estimate_not_physical_proof",
		}
		evaluations.append(evaluation)
		var center_distance := absf(candidate_x - LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2])
		if total_score > best_score + 0.0001 or (is_equal_approx(total_score, best_score) and center_distance < best_center):
			best_index = candidate_index
			best_score = total_score
			best_center = center_distance
	var selected_x := float(candidates[best_index])
	var selected_eval: Dictionary = evaluations[best_index]
	var action := _action_result(selected_x, not selected_eval.predicted_merge_chain.is_empty(), null, "objective_candidate_lane_lookahead")
	action["r20_candidate_evaluations"] = evaluations
	action["r20_selected_candidate"] = selected_eval.duplicate(true)
	return action


func _select_r21_spatial_lane_action(manager, level: int, observations: Array, objective_level: int, legal_x_positions: Array) -> Dictionary:
	var target_levels: Array[int] = []
	var bridge = manager.get_campaign_session_bridge()
	if bridge != null and bridge.is_session_active():
		var objective_state: Dictionary = bridge.get_objective_state()
		var normal_remaining: Dictionary = objective_state.get("normal_remaining", {})
		for raw_level in normal_remaining.keys():
			if int(normal_remaining[raw_level]) > 0:
				target_levels.append(int(raw_level))
	if target_levels.is_empty() and objective_level > 0:
		target_levels.append(objective_level)
	var history: Dictionary = manager.get_meta("m34_r21_lane_history", {})
	var decision_index := int(manager.get_meta("m34_r21_decision_index", 0))
	var seed_value := int(manager.get_meta("m34_r21_seed", 0))
	var action := choose_r21_action_from_observations(
		level, observations, target_levels, legal_x_positions, manager.launch_y,
		manager.death_line_y, history, seed_value, decision_index
	)
	var chosen_key := _r21_lane_key(float(action.get("x_position", 0.0)))
	history[chosen_key] = int(history.get(chosen_key, 0)) + 1
	manager.set_meta("m34_r21_lane_history", history)
	manager.set_meta("m34_r21_decision_index", decision_index + 1)
	return action


func choose_r21_action_from_observations(
	level: int,
	observations: Array,
	target_levels: Array,
	legal_x_positions: Array,
	launch_y: float = 960.0,
	danger_line_y: float = 1060.0,
	lane_history: Dictionary = {},
	seed_value: int = 0,
	decision_index: int = 0
) -> Dictionary:
	## Spatial estimate and safe deterministic exploration. Scores are a ranking
	## heuristic; only the observed production physics below confirms outcomes.
	var candidates: Array = legal_x_positions.duplicate() if not legal_x_positions.is_empty() else LANE_X_POSITIONS.duplicate()
	if candidates.is_empty(): candidates = [_nearest_legal_x(360.0, [])]
	var evaluations: Array[Dictionary] = []
	var board_signature_parts: Array[String] = []
	for observation in observations:
		board_signature_parts.append("%d:%d:%d:%d" % [int(observation.get("level", 0)), int(round(float(observation.get("x", 0.0)))), int(round(float(observation.get("y", 0.0)))), int(observation.get("instance_id", 0))])
	board_signature_parts.sort()
	var board_signature := hash("|".join(board_signature_parts))
	for candidate_value in candidates:
		var candidate_x := float(candidate_value)
		var predicted := _r20_predict_merge_chain(level, candidate_x, observations, launch_y)
		var column_congestion := 0.0
		var danger_occupancy := 0.0
		var same_level_contact := 0.0
		var reachable_pair_proximity := 0.0
		var next_spawn_space := 0.0
		var spawn_radius := DRINK_SCRIPT.collider_radius_for_level(level)
		for observation in observations:
			var other_level := int(observation.get("level", 0))
			var other_x := float(observation.get("x", candidate_x))
			var other_y := float(observation.get("y", launch_y))
			var other_radius := float(observation.get("radius", DRINK_SCRIPT.collider_radius_for_level(other_level)))
			var dx := absf(other_x - candidate_x)
			var horizontal_clearance := spawn_radius + other_radius
			var same_level_contact_band := horizontal_clearance + 56.0
			if other_y <= launch_y + other_radius and dx <= same_level_contact_band:
				var proximity := 1.0 - clampf(maxf(0.0, dx - horizontal_clearance) / 56.0, 0.0, 1.0)
				var vertical_factor := clampf((launch_y - other_y + 80.0) / 280.0, 0.0, 1.0)
				var usefulness := proximity * maxf(0.25, vertical_factor)
				if other_level == level:
					same_level_contact = maxf(same_level_contact, usefulness)
				elif absi(other_level - level) <= 1:
					reachable_pair_proximity = maxf(reachable_pair_proximity, usefulness)
			var congestion_radius := horizontal_clearance + 95.0
			if dx < congestion_radius:
				var closeness := 1.0 - dx / congestion_radius
				var height_weight := clampf((other_y - (launch_y - 260.0)) / 260.0, 0.0, 1.0)
				column_congestion += closeness * (0.25 + height_weight)
				if other_y >= danger_line_y - 115.0:
					danger_occupancy += closeness * clampf((other_y - (danger_line_y - 115.0)) / 115.0, 0.0, 1.0)
			# Leave room for the immediate replacement drink and the next legal merge.
			if dx < horizontal_clearance + 72.0 and other_y <= launch_y + 20.0:
				next_spawn_space += 1.0 - dx / (horizontal_clearance + 72.0)
		var chain: Array = predicted.get("merge_chain", [])
		var resulting_level := int(predicted.get("result_level", level))
		var objective_chain_score := float(chain.size()) * 9.0
		for target_level_value in target_levels:
			var target_level := int(target_level_value)
			if resulting_level == target_level:
				objective_chain_score += 90.0
			elif resulting_level < target_level:
				objective_chain_score += maxf(0.0, 10.0 - float(target_level - resulting_level)) * 2.0
		var objective_proximity := 0.0
		for target_level_value in target_levels:
			var gap := int(target_level_value) - resulting_level
			if gap > 0 and gap <= 3:
				objective_proximity = maxf(objective_proximity, 4.0 - float(gap))
		var contact_score := same_level_contact * 24.0 + reachable_pair_proximity * 8.0
		var congestion_penalty := column_congestion * 13.0 + next_spawn_space * 11.0
		var danger_penalty := danger_occupancy * 100.0
		var spatial_score := objective_chain_score + objective_proximity * 3.0 + contact_score - congestion_penalty - danger_penalty
		evaluations.append({
			"candidate_x": candidate_x,
			"score": snappedf(spatial_score, 0.001),
			"base_score": snappedf(spatial_score, 0.001),
			"objective_chain_score": snappedf(objective_chain_score, 0.001),
			"objective_proximity": snappedf(objective_proximity, 0.001),
			"same_level_contact_proximity": snappedf(same_level_contact, 0.001),
			"reachable_pair_proximity": snappedf(reachable_pair_proximity, 0.001),
			"column_congestion": snappedf(column_congestion, 0.001),
			"next_spawn_space_pressure": snappedf(next_spawn_space, 0.001),
			"danger_occupancy": snappedf(danger_occupancy, 0.001),
			"predicted_merge_chain": chain.duplicate(true),
			"predicted_result_level": resulting_level,
			"target_order_levels": target_levels.duplicate(),
			"model_label": "spatial_occupancy_and_objective_heuristic_not_physics_proof",
		})
	# Rank each candidate and preserve all terms so later observations can be
	# compared against the exact forecast that selected this lane.
	var max_base_score := -INF
	for evaluation in evaluations:
		var score := float(evaluation.get("base_score", -INF))
		if is_finite(score):
			max_base_score = maxf(max_base_score, score)
	for evaluation in evaluations:
		evaluation["rank"] = 1
		for other in evaluations:
			if float(other.base_score) > float(evaluation.base_score) + 0.0001:
				evaluation["rank"] = int(evaluation.rank) + 1
	var tied_indices: Array[int] = []
	for index in range(evaluations.size()):
		var score := float(evaluations[index].get("base_score", -INF))
		if is_finite(score) and absf(score - max_base_score) <= 0.0001:
			tied_indices.append(index)
	# Fail-safe for malformed/non-finite runtime observations: preserve a legal
	# deterministic choice among the safest candidates, never among lower-scored
	# candidates when valid scores exist.
	var selection_fallback := false
	if tied_indices.is_empty():
		selection_fallback = true
		var best_danger := INF
		var best_congestion := INF
		for index in range(evaluations.size()):
			var danger := float(evaluations[index].get("danger_occupancy", INF))
			var congestion := float(evaluations[index].get("column_congestion", INF))
			if danger < best_danger - 0.0001 or (is_equal_approx(danger, best_danger) and congestion < best_congestion - 0.0001):
				best_danger = danger
				best_congestion = congestion
		for index in range(evaluations.size()):
			var danger := float(evaluations[index].get("danger_occupancy", INF))
			var congestion := float(evaluations[index].get("column_congestion", INF))
			if is_equal_approx(danger, best_danger) and is_equal_approx(congestion, best_congestion):
				tied_indices.append(index)
	var least_used := 2147483647
	for index in tied_indices:
		var count := int(lane_history.get(_r21_lane_key(float(candidates[index])), 0))
		least_used = mini(least_used, count)
	var eligible_indices: Array[int] = []
	for index in tied_indices:
		if int(lane_history.get(_r21_lane_key(float(candidates[index])), 0)) == least_used:
			eligible_indices.append(index)
	var rotation := posmod(seed_value + decision_index + board_signature, candidates.size())
	var best_index := eligible_indices[0]
	var best_rotation_distance := candidates.size()
	for index in eligible_indices:
		var distance := posmod(index - rotation, candidates.size())
		if distance < best_rotation_distance:
			best_index = index
			best_rotation_distance = distance
	var selected_x := float(candidates[best_index])
	var selected_eval: Dictionary = evaluations[best_index].duplicate(true)
	selected_eval["lane_visits_before"] = int(lane_history.get(_r21_lane_key(selected_x), 0))
	selected_eval["tie_candidate_count"] = tied_indices.size()
	selected_eval["decision_index"] = decision_index
	selected_eval["state_signature"] = board_signature
	selected_eval["selection_fallback"] = selection_fallback
	var action := _action_result(selected_x, not selected_eval.predicted_merge_chain.is_empty(), null, "spatial_objective_safe_lane_ranked")
	action["r21_candidate_evaluations"] = evaluations
	action["r21_selected_candidate"] = selected_eval
	return action


func _r21_lane_key(x_position: float) -> String:
	return str(int(round(x_position * 1000.0)))


func _r20_predict_merge_chain(spawn_level: int, candidate_x: float, observations: Array, launch_y: float) -> Dictionary:
	var remaining := observations.duplicate(true)
	var chain: Array[Dictionary] = []
	var result_level := spawn_level
	var result_position := Vector2(candidate_x, launch_y)
	var first_target := -1
	for index in range(remaining.size()):
		var target: Dictionary = remaining[index]
		if int(target.get("level", 0)) != result_level or float(target.get("y", launch_y)) > launch_y + float(target.get("radius", 30.0)):
			continue
		var horizontal_gap := absf(float(target.get("x", candidate_x)) - candidate_x) - DRINK_SCRIPT.collider_radius_for_level(spawn_level) - float(target.get("radius", 30.0))
		if horizontal_gap <= 0.0 and (first_target < 0 or float(target.get("y", 0.0)) > float(remaining[first_target].get("y", 0.0))):
			first_target = index
	if first_target >= 0:
		var target: Dictionary = remaining[first_target]
		chain.append({"source_level": spawn_level, "target_instance_id": int(target.get("instance_id", 0)), "result_level": spawn_level + 1, "estimated_horizontal_gap": snappedf(absf(float(target.get("x", candidate_x)) - candidate_x), 0.01)})
		result_level += 1
		result_position = Vector2(float(target.get("x", candidate_x)), float(target.get("y", launch_y)))
		remaining.remove_at(first_target)
	for depth in range(4):
		var selected := -1
		var nearest := INF
		for index in range(remaining.size()):
			var target: Dictionary = remaining[index]
			if int(target.get("level", 0)) != result_level: continue
			var distance := result_position.distance_to(Vector2(float(target.get("x", 0.0)), float(target.get("y", 0.0))))
			var contact_limit := DRINK_SCRIPT.collider_radius_for_level(result_level) + float(target.get("radius", 30.0)) + 18.0
			if distance <= contact_limit and distance < nearest:
				selected = index
				nearest = distance
		if selected < 0: break
		var target: Dictionary = remaining[selected]
		chain.append({"source_level": result_level, "target_instance_id": int(target.get("instance_id", 0)), "result_level": result_level + 1, "estimated_center_distance": snappedf(nearest, 0.01)})
		result_position = result_position.lerp(Vector2(float(target.get("x", 0.0)), float(target.get("y", 0.0))), 0.5)
		result_level += 1
		remaining.remove_at(selected)
	return {"result_level": result_level, "merge_chain": chain}


func _r20_add_virtual_spawn(inventory: Dictionary, spawn_level: int) -> int:
	var current := spawn_level
	if current <= 0 or current >= DRINK_SCRIPT.max_level(): return current
	inventory[current] = int(inventory.get(current, 0)) + 1
	while current < DRINK_SCRIPT.max_level() and int(inventory.get(current, 0)) >= 2:
		inventory[current] = int(inventory[current]) - 2
		current += 1
		inventory[current] = int(inventory.get(current, 0)) + 1
	return current


func _r20_objective_inventory_score(inventory: Dictionary, target_levels: Array, latest_result_level: int) -> float:
	var score := float(latest_result_level) * 0.2
	var highest_level := 0
	for raw_level in inventory.keys():
		var level := int(raw_level)
		if int(inventory[raw_level]) > 0: highest_level = maxi(highest_level, level)
	for target_level in target_levels:
		var target := int(target_level)
		if target <= 0: continue
		if int(inventory.get(target, 0)) > 0: score += 40.0
		else: score += maxf(0.0, 8.0 - absf(float(target - highest_level)))
	return score


func _cached_or_legal_launch_x_positions(manager, level: int) -> Array:
	if manager.has_meta("m17_legal_launch_lane_cache"):
		var cache: Dictionary = manager.get_meta("m17_legal_launch_lane_cache")
		var key := str(level)
		if cache.has(key):
			return cache[key].duplicate()
		var legal := _legal_launch_x_positions(manager, level)
		cache[key] = legal.duplicate()
		var profile: Dictionary = manager.get_meta("m17_profile", {})
		if bool(profile.get("enabled", false)):
			profile["geometry_cache_misses"] = int(profile.get("geometry_cache_misses", 0)) + 1
		return legal
	return _legal_launch_x_positions(manager, level)


func _select_cheap_merge_center_action(level: int, observations: Array, legal_x_positions: Array) -> Dictionary:
	var target: Dictionary = {}
	for observation in observations:
		if int(observation.get("level", 0)) != level:
			continue
		if target.is_empty() or float(observation.get("y", 0.0)) > float(target.get("y", 0.0)) or (
			is_equal_approx(float(observation.get("y", 0.0)), float(target.get("y", 0.0)))
			and int(observation.get("instance_id", 0)) < int(target.get("instance_id", 0))
		):
			target = observation
	if not target.is_empty():
		var target_x := _nearest_legal_x(float(target.get("x", LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2])), legal_x_positions)
		return _action_result(target_x, true, int(target.get("instance_id", 0)), "same_level_target_single_pass")
	var center_x := float(LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2])
	var selected_x := _nearest_legal_x(center_x, legal_x_positions)
	return _action_result(selected_x, false, null, "center_lane_fallback")


func _stop_requested(stop_flag_path: String) -> bool:
	return not stop_flag_path.is_empty() and FileAccess.file_exists(stop_flag_path)


func choose_action_from_observations(
	level: int,
	observations: Array,
	objective_level: int = 0,
	legal_x_positions: Array = []
) -> Dictionary:
	## Pure deterministic policy seam for focused qualification fixtures. It has
	## no seed/RNG argument and therefore cannot inspect future spawn values.
	return _select_merge_aware_action(level, observations, objective_level, legal_x_positions)


func _board_observations(manager) -> Array[Dictionary]:
	var observations: Array[Dictionary] = []
	if manager.world == null:
		return observations
	for child in manager.world.get_children():
		if not child is Drink or child.is_queued_for_deletion() or child.motion_state == Drink.MotionState.HELD:
			continue
		var drink: Drink = child
		observations.append({
			"level": drink.level,
			"x": drink.position.x,
			"y": drink.position.y,
			"radius": drink.radius,
			"velocity_x": drink.linear_velocity.x,
			"velocity_y": drink.linear_velocity.y,
			"motion_state": int(drink.motion_state),
			"instance_id": _stable_instance_id(drink),
		})
	return observations


func _stable_instance_id(drink: Drink) -> int:
	if drink.has_meta("m17_instance_id"):
		return int(drink.get_meta("m17_instance_id"))
	return drink.get_instance_id()


func _select_weak_v02_action(level: int, observations: Array, legal_x_positions: Array) -> Dictionary:
	var matching: Array = []
	for observation in observations:
		if int(observation.get("level", 0)) == level:
			matching.append(observation)
	if not matching.is_empty():
		matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return float(a.get("y", 0.0)) < float(b.get("y", 0.0)) if not is_equal_approx(float(a.get("y", 0.0)), float(b.get("y", 0.0))) else int(a.get("instance_id", 0)) < int(b.get("instance_id", 0))
		)
		var target: Dictionary = matching[0]
		var selected_x := _nearest_legal_x(float(target.get("x", LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2])), legal_x_positions)
		return _action_result(selected_x, true, int(target.get("instance_id", 0)), "legacy_fixed_lane")
	var fallback_x := _nearest_legal_x(LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2], legal_x_positions)
	return _action_result(fallback_x, false, null, "legacy_fixed_lane")


func _select_merge_aware_action(level: int, observations: Array, objective_level: int, legal_x_positions: Array = []) -> Dictionary:
	var matching: Array = []
	for observation in observations:
		if int(observation.get("level", 0)) == level:
			matching.append(observation)
	if not matching.is_empty():
		# Lower-board targets are reached first by the upward shot; instance ID
		# provides the stable tie-breaker when their heights are equal.
		matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return float(a.get("y", 0.0)) > float(b.get("y", 0.0)) if not is_equal_approx(float(a.get("y", 0.0)), float(b.get("y", 0.0))) else int(a.get("instance_id", 0)) < int(b.get("instance_id", 0))
		)
		var target: Dictionary = matching[0]
		var target_x := _nearest_legal_x(float(target.get("x", LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2])), legal_x_positions)
		return _action_result(target_x, true, int(target.get("instance_id", 0)), "same_level_target")

	var candidate_xs: Array = legal_x_positions if not legal_x_positions.is_empty() else LANE_X_POSITIONS.duplicate()
	var best_x := float(candidate_xs[0])
	var best_score := INF
	var best_center_distance := INF
	for candidate in candidate_xs:
		var x := float(candidate)
		var congestion := 0.0
		for observation in observations:
			var horizontal_distance := absf(float(observation.get("x", 0.0)) - x)
			var weight := 1.0
			if float(observation.get("y", 0.0)) >= 700.0:
				weight += 1.0
			if horizontal_distance <= 105.0:
				congestion += weight * (1.0 - horizontal_distance / 210.0)
		var center_distance := absf(x - LANE_X_POSITIONS[LANE_X_POSITIONS.size() / 2])
		if congestion < best_score - 0.0001 or (is_equal_approx(congestion, best_score) and center_distance < best_center_distance - 0.0001):
			best_score = congestion
			best_center_distance = center_distance
			best_x = x
	var reason := "objective_priority" if objective_level == level else "low_congestion_lane"
	return _action_result(best_x, false, null, reason)


func _action_result(x_position: float, same_level_target_found: bool, target_instance_id, decision_reason: String) -> Dictionary:
	return {
		"lane_index": _nearest_lane_index(x_position),
		"x_position": x_position,
		"decision_reason": decision_reason,
		"same_level_target_found": same_level_target_found,
		"target_instance_id": target_instance_id,
	}


func _nearest_lane_index(x_position: float) -> int:
	var selected := 0
	var distance := INF
	for lane_index in range(LANE_X_POSITIONS.size()):
		var candidate_distance := absf(x_position - LANE_X_POSITIONS[lane_index])
		if candidate_distance < distance:
			distance = candidate_distance
			selected = lane_index
	return selected


func _nearest_legal_x(desired_x: float, legal_x_positions: Array) -> float:
	if legal_x_positions.is_empty():
		return desired_x
	var selected := float(legal_x_positions[0])
	var distance := absf(desired_x - selected)
	for candidate in legal_x_positions:
		var candidate_distance := absf(desired_x - float(candidate))
		if candidate_distance < distance:
			distance = candidate_distance
			selected = float(candidate)
	return selected


func _legal_launch_x_positions(manager, level: int) -> Array:
	var legal: Array = []
	var probe: Drink = DRINK_SCRIPT.create(level)
	if probe == null:
		return LANE_X_POSITIONS.duplicate()
	var footprint := probe.get_table_footprint_local()
	for x_position in LANE_X_POSITIONS:
		var origin: Vector2 = manager.get_launch_position(float(x_position), probe.radius, level)
		var valid := true
		for edge in manager.get_playable_boundary_edges():
			for point in footprint:
				if edge["inward_normal"].dot(origin + point - edge["a"]) < -0.001:
					valid = false
					break
			if not valid:
				break
		if valid:
			legal.append(float(x_position))
	probe.free()
	return legal if not legal.is_empty() else LANE_X_POSITIONS.duplicate()
