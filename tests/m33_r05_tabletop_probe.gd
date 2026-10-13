extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_R05 PASS: %s" % label)
	else:
		failures.append(label)
		print("M33_R05 FAIL: %s" % label)


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("campaign data loads with backward-compatible tabletop schema", loaded)
	if not loaded:
		print("M33_R05_DATABASE_ERROR=%s" % database.get_last_error())
		quit(1)
		return

	var empty := await _launch(database, "azure_bay", 1)
	var empty_game = empty.get("game")
	_check("empty level opening contains no initial settled cocktail", _settled_drinks(empty_game).is_empty())
	await _dispose(empty_game)

	var component := await _launch(database, "azure_bay", 13)
	var component_bridge = component.get("bridge")
	var component_game = component.get("game")
	var starters: Array = _settled_drinks(component_game)
	var component_level: Dictionary = database.get_level("azure_bay", 13)
	_check("component opening creates a real settled Drink node", starters.size() == 1 and starters[0] is RigidBody2D and starters[0].level == int(component_level["initial_tabletop_drinks"][0]["cocktail_level"]) and starters[0].collision_layer > 0)
	var start_move_state: Dictionary = component_bridge.get_move_budget_state()
	var start_pos: Vector2 = starters[0].position if starters.size() == 1 else Vector2.ZERO
	var pause_ok: bool = component_bridge.pause_session("R05_TABLETOP_PROBE") and component_bridge.resume_session()
	_check("pause and resume retain the same unmodified starting cocktail", pause_ok and starters.size() == 1 and is_instance_valid(starters[0]) and starters[0].position == start_pos and component_bridge.get_move_budget_state() == start_move_state)

	var starter: RigidBody2D = starters[0] if starters.size() == 1 else null
	var merge_level := int(component_level["initial_tabletop_drinks"][0]["cocktail_level"])
	if starter != null:
		var incoming = component_game.spawn_drink(merge_level, starter.position + Vector2(0.0, starter.radius * 1.72), false)
		incoming.start_sliding(Vector2(0.0, -700.0))
		await create_timer(1.5).timeout
	var merged_delivery_state: Dictionary = component_bridge.get_objective_state()
	var merged_target_delivered := int(merged_delivery_state["normal_completed"].get(merge_level + 1, 0)) >= 1
	_check("bounded production physics merges a moving real drink with preplaced stock and delivers the real To-Go result", merged_target_delivered and component_game.score >= 1)
	component_bridge.resolve_lose("R05_RETRY_PROBE", component_game.score)
	var retry_configuration: Dictionary = component_bridge.retry_session()
	await _dispose(component_game)
	var retry_game = GAMEPLAY_SCENE.instantiate()
	get_root().add_child(retry_game)
	var retry_configured: bool = retry_game.configure_campaign_session(component_bridge)
	await process_frame
	await process_frame
	var retry_starters: Array = _settled_drinks(retry_game)
	var expected_retry_positions: Array = []
	for placement in retry_configuration.get("level_definition", {}).get("initial_tabletop_drinks", []):
		expected_retry_positions.append(Vector2(float(placement["position"][0]) * retry_game.get_board_size().x, float(placement["position"][1]) * retry_game.get_board_size().y))
	var retry_matches := retry_configured and retry_starters.size() == expected_retry_positions.size()
	for index in mini(retry_starters.size(), expected_retry_positions.size()):
		retry_matches = retry_matches and retry_starters[index].position.distance_to(expected_retry_positions[index]) <= 1.0
	_check("retry respawns the same deterministic initial tabletop layout", retry_matches)
	await _dispose(retry_game)

	var direct := await _launch(database, "azure_bay", 6)
	var direct_bridge = direct.get("bridge")
	var direct_game = direct.get("game")
	var direct_level: Dictionary = database.get_level("azure_bay", 6)
	var first_target := int(direct_level["orders"][0]["cocktail_level"])
	await create_timer(0.8).timeout
	var objective_state: Dictionary = direct_bridge.get_objective_state()
	var budget_state: Dictionary = direct_bridge.get_move_budget_state()
	_check("a compatible preplaced target is physically delivered through To-Go", int(objective_state["normal_completed"].get(first_target, 0)) >= 1)
	_check("free preplaced delivery leaves the exact existing 4T budget and star denominator untouched", int(budget_state.get("moves_used", -1)) == 0 and int(budget_state.get("move_limit", -1)) == int(direct_level["move_limit"]) and int(direct_level["move_limit"]) == int(direct_level["theoretical_shots_total"]) * 4)
	_check("preplaced delivery cannot auto-complete the whole normal objective", not direct_bridge.is_terminal())
	await _dispose(direct_game)

	if failures.is_empty():
		print("M33_R05_TABLETOP_RESULT=PASS")
		quit(0)
	else:
		print("M33_R05_TABLETOP_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)


func _launch(database, island_id: String, level_id: int) -> Dictionary:
	var bridge = BRIDGE_SCRIPT.new()
	bridge.configure(database, null)
	var configuration: Dictionary = bridge.start_session(island_id, level_id)
	if configuration.is_empty():
		return {"bridge": bridge, "game": null}
	var game = GAMEPLAY_SCENE.instantiate()
	get_root().add_child(game)
	var configured: bool = game.configure_campaign_session(bridge)
	_check("production gameplay scene configures %s/%d" % [island_id, level_id], configured)
	await process_frame
	await process_frame
	return {"bridge": bridge, "game": game}


func _dispose(game) -> void:
	if is_instance_valid(game):
		game.queue_free()
		await process_frame
		await process_frame


func _all_drinks(game) -> Array:
	var result: Array = []
	if not is_instance_valid(game) or not is_instance_valid(game.world):
		return result
	for child in game.world.get_children():
		if child is RigidBody2D and child.get("level") != null:
			result.append(child)
	return result


func _settled_drinks(game) -> Array:
	var result: Array = []
	for drink in _all_drinks(game):
		if drink.motion_state != drink.MotionState.HELD:
			result.append(drink)
	return result
