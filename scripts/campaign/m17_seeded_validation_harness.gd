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
	physics_trace_interval_frames: int = DETERMINISM_TRACE_INTERVAL_FRAMES
) -> Dictionary:
	var telemetry := new_telemetry(island_id, level_id, seed_value)
	telemetry["policy_name"] = policy_name
	var level_definition: Dictionary = database.get_level(island_id, level_id)
	if level_definition.is_empty():
		telemetry["terminal_reason"] = "LEVEL_NOT_FOUND"
		return telemetry

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
		"step_sec": PHYSICS_STEP_SEC * time_scale,
	}

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
		telemetry["action_log"].append(action_record)
		var shot_commit_start_usec := Time.get_ticks_usec() if profile_enabled else 0
		var launched = manager.spawn_drink(spawn_level, Vector2(x_position, manager.launch_y), true)
		if launched == null:
			telemetry["terminal_reason"] = "SPAWN_FAILED"
			break
		_attach_drink(launched, state)
		launched.position.x = x_position
		if use_production_shot_controller:
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
		"result_level": new_level,
	})


func _on_drink_contact(body: Node, source: Drink, state: Dictionary) -> void:
	state["contact_count"] = int(state["contact_count"]) + 1
	if body is Drink and is_instance_valid(source):
		var source_id := _ensure_stable_instance_id(source, state)
		var target_id := _ensure_stable_instance_id(body, state)
		state["contact_events"].append({
			"frame": int(state["physics_frame_index"]),
			"source_instance_id": source_id,
			"target_instance_id": target_id,
			"source_level": source.level,
			"target_level": body.level,
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
	if policy_name == POLICY_MERGE_AWARE_V01:
		return _select_merge_aware_action(level, observations, objective_level, legal_x_positions)
	if policy_name == POLICY_CHEAP_MERGE_CENTER_V01:
		return _select_cheap_merge_center_action(level, observations, legal_x_positions)
	return _select_weak_v02_action(level, observations, legal_x_positions)


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
