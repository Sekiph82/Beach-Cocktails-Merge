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
const RAIL_PROXIMITY_PROXY_PX := 1.0
const LANE_X_POSITIONS: Array[float] = [150.0, 220.0, 290.0, 360.0, 430.0, 500.0, 570.0]

var _root: Node
var time_scale := 1.0


func _init(root: Node) -> void:
	_root = root


func set_time_scale(value: float) -> void:
	time_scale = maxf(1.0, value)


func telemetry_schema_keys() -> Array[String]:
	return [
		"island_id", "level_id", "seed", "outcome", "elapsed_sec", "remaining_sec",
		"shot_count", "merge_count", "failed_merge_approach_count",
		"peak_live_drinks", "mean_live_drinks", "peak_board_occupancy",
		"large_piece_coexistence_peak", "contact_count", "rail_contact_count",
		"danger_line_exposure_sec", "normal_objective_complete", "vip_complete",
		"action_log", "terminal_reason", "physics_hook",
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
		"danger_line_exposure_sec": 0.0,
		"normal_objective_complete": false,
		"vip_complete": false,
		"action_log": [],
		"terminal_reason": "",
		"physics_hook": "production GameManager.spawn_drink + Drink.launch_up + Godot physics frames",
	}


func validate_telemetry(telemetry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key in telemetry_schema_keys():
		if not telemetry.has(key):
			errors.append("missing telemetry key: %s" % key)
	var outcome := str(telemetry.get("outcome", ""))
	if not [OUTCOME_COMPLETED, OUTCOME_TIMEOUT, OUTCOME_DANGER, OUTCOME_HARNESS_ABORT].has(outcome):
		errors.append("invalid outcome: %s" % outcome)
	return errors


func run_trial(database, island_id: String, level_id: int, seed_value: int, action_log_override: Array = []) -> Dictionary:
	var telemetry := new_telemetry(island_id, level_id, seed_value)
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
	var action_index := 0
	var elapsed := 0.0
	var replaying := not action_log_override.is_empty()
	while not bridge.is_terminal() and not manager.game_over and elapsed < float(level_definition.get("time_limit_sec", 0.0)) + 1.0 and action_index < max_shots:
		var spawn_level: int
		var lane_index: int
		var x_position: float
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
			var lane_choice := _choose_lane(manager, spawn_level, action_index, seed_value)
			lane_index = int(lane_choice["lane_index"])
			x_position = float(lane_choice["x_position"])

		var same_level_before := _has_same_level(manager, spawn_level)
		var action_record := {
			"step": action_index,
			"spawn_level": spawn_level,
			"lane_index": lane_index,
			"x_position": x_position,
		}
		telemetry["action_log"].append(action_record)
		var launched = manager.spawn_drink(spawn_level, Vector2(x_position, manager.launch_y), true)
		if launched == null:
			telemetry["terminal_reason"] = "SPAWN_FAILED"
			break
		_attach_drink(launched, state)
		launched.position.x = x_position
		launched.launch_up(SHOT_SPEED)
		telemetry["shot_count"] = int(telemetry["shot_count"]) + 1
		var merges_before := int(state["merge_count"])
		for _frame in range(FRAMES_PER_ACTION):
			await _root.get_tree().physics_frame
			elapsed += float(state["step_sec"])
			_sample(manager, state)
			if bridge.is_terminal() or manager.game_over:
				break
		if same_level_before and int(state["merge_count"]) == merges_before:
			# Bounded proxy: a same-level approach existed at launch but no merge
			# request resolved during this action's physics window.
			state["failed_merge_approach_count"] = int(state.get("failed_merge_approach_count", 0)) + 1
		action_index += 1

	if not bridge.is_terminal() and not manager.game_over:
		for _frame in range(MAX_EXTRA_SETTLE_FRAMES):
			await _root.get_tree().physics_frame
			elapsed += float(state["step_sec"])
			_sample(manager, state)
			if bridge.is_terminal() or manager.game_over:
				break

	if bridge.is_terminal():
		var terminal: Dictionary = bridge.get_terminal_result()
		var terminal_outcome := str(terminal.get("outcome", ""))
		telemetry["outcome"] = OUTCOME_COMPLETED if terminal_outcome == "WIN" else OUTCOME_TIMEOUT
		telemetry["terminal_reason"] = str(terminal.get("reason", ""))
	elif manager.game_over:
		telemetry["outcome"] = OUTCOME_DANGER
		telemetry["terminal_reason"] = "DANGER_LINE"
	else:
		telemetry["outcome"] = OUTCOME_TIMEOUT if elapsed >= float(level_definition.get("time_limit_sec", 0.0)) else OUTCOME_HARNESS_ABORT
		telemetry["terminal_reason"] = "TIME_LIMIT" if telemetry["outcome"] == OUTCOME_TIMEOUT else "ACTION_BUDGET"

	telemetry["elapsed_sec"] = elapsed
	telemetry["remaining_sec"] = maxf(0.0, float(bridge.timer_remaining_sec))
	telemetry["merge_count"] = int(state["merge_count"])
	telemetry["failed_merge_approach_count"] = int(state.get("failed_merge_approach_count", 0))
	telemetry["peak_live_drinks"] = int(state["peak_live_drinks"])
	telemetry["mean_live_drinks"] = float(state["live_sum"]) / float(maxi(1, int(state["sample_count"])))
	telemetry["peak_board_occupancy"] = float(state["peak_board_occupancy"])
	telemetry["large_piece_coexistence_peak"] = int(state["large_piece_coexistence_peak"])
	telemetry["contact_count"] = int(state["contact_count"])
	telemetry["rail_contact_count"] = int(state["rail_contact_count"])
	telemetry["danger_line_exposure_sec"] = float(state["danger_line_exposure_sec"])
	var objective_state: Dictionary = bridge.get_objective_state()
	telemetry["normal_objective_complete"] = bridge.is_terminal() and str(bridge.get_terminal_result().get("outcome", "")) == "WIN"
	telemetry["vip_complete"] = bool(objective_state.get("vip_completed", false))

	manager.queue_free()
	await _root.get_tree().process_frame
	Engine.time_scale = previous_time_scale
	return telemetry


func _attach_drink(drink: Drink, state: Dictionary) -> void:
	if not drink.merged.is_connected(_on_drink_merge):
		drink.merged.connect(_on_drink_merge.bind(state))
	if not drink.body_entered.is_connected(_on_drink_contact):
		drink.body_entered.connect(_on_drink_contact.bind(state))


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


func _on_drink_contact(body: Node, state: Dictionary) -> void:
	state["contact_count"] = int(state["contact_count"]) + 1
	if body != null and (str(body.name).contains("Rail") or str(body.name).contains("TopRail")):
		state["rail_contact_count"] = int(state["rail_contact_count"]) + 1


func _sample(manager, state: Dictionary) -> void:
	if manager.world == null:
		return
	var live_count := 0
	var large_count := 0
	var occupied_area := 0.0
	var danger := false
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
		# Rail contacts are counted from the production body_entered callback.
		# This read-only projection is an additional deterministic proximity proxy.
		var footprint := drink.get_table_footprint_local()
		for edge in manager.get_playable_boundary_edges():
			var minimum_distance := INF
			for point in footprint:
				minimum_distance = minf(minimum_distance, edge["inward_normal"].dot(drink.position + point - edge["a"]))
			if minimum_distance <= RAIL_PROXIMITY_PROXY_PX:
				break
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


func _choose_lane(manager, level: int, action_index: int, seed_value: int) -> Dictionary:
	var matching: Array[Drink] = []
	var lane_counts: Array[int] = []
	for _lane in LANE_X_POSITIONS:
		lane_counts.append(0)
	if manager.world != null:
		for child in manager.world.get_children():
			if not child is Drink or child.is_queued_for_deletion() or child.motion_state == Drink.MotionState.HELD:
				continue
			var drink: Drink = child
			var nearest_lane := 0
			var nearest_distance := INF
			for lane_index in range(LANE_X_POSITIONS.size()):
				var distance := absf(drink.position.x - LANE_X_POSITIONS[lane_index])
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_lane = lane_index
				lane_counts[nearest_lane] += 1
				if drink.level == level:
					matching.append(drink)
	if not matching.is_empty():
		matching.sort_custom(func(a: Drink, b: Drink) -> bool:
			return a.position.y < b.position.y if not is_equal_approx(a.position.y, b.position.y) else a.get_instance_id() < b.get_instance_id()
		)
		return {"lane_index": 0, "x_position": matching[0].position.x}
	# A central fallback keeps the baseline policy deterministic and makes the
	# physical tradeoff visible: unlike an optimal player it deliberately accepts
	# central congestion when no same-level merge target exists.
	var chosen_lane := LANE_X_POSITIONS.size() / 2
	return {"lane_index": chosen_lane, "x_position": LANE_X_POSITIONS[chosen_lane]}
