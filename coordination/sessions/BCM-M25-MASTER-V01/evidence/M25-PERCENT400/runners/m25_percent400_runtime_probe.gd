extends SceneTree

## GL production-flow trial: genuine mouse shot inputs, natural movement-limit
## terminal resolution, then pointer/touch use of Retry and Island Map.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var shell
var navigation
var gameplay: GameManager
var bridge
var out_dir := ""
var failures: Array[String] = []
var shot_count := 0
var input_events := 0
var results: Array[Dictionary] = []
var captures: Array[Dictionary] = []
var retry_pointer: Dictionary = {}
var map_pointer: Dictionary = {}
var target_strategy := "SPREAD"
var presentation_mode := "FULL"
var expected_move_limit := 0


func _init() -> void:
	out_dir = OS.get_environment("BCM_M25_MOVE_CAPTURE_DIR").strip_edges()
	target_strategy = OS.get_environment("BCM_M25_MOVE_STRATEGY").to_upper()
	if not ["SPREAD", "OBJECTIVE", "MAX_SPREAD"].has(target_strategy):
		target_strategy = "SPREAD"
	presentation_mode = OS.get_environment("BCM_M25_MOVE_MODE").to_upper()
	if not ["FULL", "REDUCED"].has(presentation_mode):
		presentation_mode = "FULL"
	if not out_dir.begins_with("res://") or out_dir.contains(".."):
		out_dir = "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-LIMIT-001/runtime_full"
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M25_MOVE_RUNTIME PASS: %s" % label)
	else:
		failures.append(label)
		print("M25_MOVE_RUNTIME FAIL: %s" % label)


func _frames(count: int = 1) -> void:
	for _i in range(count):
		await process_frame


func _capture(label: String) -> Dictionary:
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [out_dir, label]
	var error := image.save_png(path) if image != null else ERR_CANT_CREATE
	return {"name": label, "path": path, "width": image.get_width() if image != null else 0, "height": image.get_height() if image != null else 0, "error": error}


func _shoot(target_x: float) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(100.0, 200.0)
	Input.parse_input_event(press)
	input_events += 1
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = Vector2(target_x, 200.0)
	Input.parse_input_event(release)
	input_events += 1
	await process_frame


func _choose_spread_lane(level: int) -> float:
	var lanes: Array[float] = [72.0, 216.0, 360.0, 504.0, 648.0]
	var best_lane := lanes[0]
	var best_penalty := INF
	for lane in lanes:
		var nearby := 0
		var same_level := 0
		for item in gameplay.world.get_children():
			if not item is Drink or item.is_queued_for_deletion():
				continue
			var drink := item as Drink
			if absf(drink.position.x - lane) < 132.0:
				nearby += 1
				if drink.level == level:
					same_level += 1
		var penalty := nearby * 10.0 + same_level * 1000.0
		if penalty < best_penalty:
			best_penalty = penalty
			best_lane = lane
	return clampf(best_lane, 35.0, gameplay.get_board_size().x - 35.0)


func _choose_objective_lane(level: int) -> float:
	var target: Drink
	var best_distance := INF
	for item in gameplay.world.get_children():
		if not item is Drink or item.is_queued_for_deletion():
			continue
		var drink := item as Drink
		if drink.level != level or not drink.is_settled():
			continue
		var distance := absf(drink.position.x - gameplay.get_board_size().x * 0.5)
		if distance < best_distance:
			best_distance = distance
			target = drink
	if is_instance_valid(target):
		return target.position.x
	var lanes: Array[float] = [60.0, 150.0, 240.0, 330.0, 420.0, 510.0, 600.0, 680.0]
	return clampf(lanes[posmod(level - 1, lanes.size())], 35.0, gameplay.get_board_size().x - 35.0)


func _choose_max_spread_lane(level: int) -> float:
	var lanes: Array[float] = [48.0, 132.0, 216.0, 300.0, 384.0, 468.0, 552.0, 636.0, 696.0]
	var best_lane := lanes[0]
	var best_score := -INF
	for lane in lanes:
		var nearest_distance := INF
		var same_level_penalty := 0.0
		for item in gameplay.world.get_children():
			if not item is Drink or item.is_queued_for_deletion():
				continue
			var drink := item as Drink
			var distance := absf(drink.position.x - lane)
			nearest_distance = minf(nearest_distance, distance)
			if drink.level == level and distance < 160.0:
				same_level_penalty += (160.0 - distance) * 2.0
		var score := nearest_distance - same_level_penalty
		if score > best_score:
			best_score = score
			best_lane = lane
	return clampf(best_lane, 35.0, gameplay.get_board_size().x - 35.0)


func _fire_until_terminal() -> void:
	var attempts := 0
	while attempts < expected_move_limit + 12 and int(bridge.get_move_budget_state().get("moves_used", 0)) < expected_move_limit:
		if bridge.is_terminal() or gameplay.game_over:
			break
		var held: Drink = gameplay.shot_controller._current_drink
		if not is_instance_valid(held):
			await _frames(2)
			continue
		var shots_before := shot_count
		var lane := _choose_spread_lane(held.level)
		if target_strategy == "OBJECTIVE":
			lane = _choose_objective_lane(held.level)
		elif target_strategy == "MAX_SPREAD":
			lane = _choose_max_spread_lane(held.level)
		await _shoot(lane)
		attempts += 1
		if shot_count == shots_before:
			await _frames(3)
			continue
		for _settle in range(180):
			if bridge.is_terminal() or not is_instance_valid(held) or held.is_queued_for_deletion() or held.is_settled():
				break
			await process_frame
		await _frames(2)
		var budget: Dictionary = bridge.get_move_budget_state()
		if int(budget.get("moves_remaining", 99)) == 5 and captures.all(func(row: Dictionary) -> bool: return row.get("name", "") != "moves_05"):
			captures.append(await _capture("moves_05"))
	for _settle in range(600):
		if bridge.is_terminal():
			return
		await process_frame


func _send_button_pointer(action: String, touch: bool) -> Dictionary:
	var overlay = navigation.get_result_feedback_overlay()
	if overlay == null or not overlay.visible:
		return {"ok": false, "reason": "RESULT_OVERLAY_NOT_VISIBLE"}
	var button: Button
	for child in overlay._actions.get_children():
		if child is Button and str(child.text).to_upper().replace(" ", "_") == action:
			button = child
			break
	if button == null:
		return {"ok": false, "reason": "ACTION_BUTTON_MISSING"}
	var center := button.get_global_rect().get_center()
	var rendered: Vector2i = root.get_viewport().get_texture().get_size()
	var viewport_size: Vector2i = root.get_viewport().size
	var event_center := Vector2(center.x * viewport_size.x / maxf(1.0, rendered.x), center.y * viewport_size.y / maxf(1.0, rendered.y))
	if touch:
		var down := InputEventScreenTouch.new()
		down.index = 0
		down.pressed = true
		down.position = event_center
		Input.parse_input_event(down)
		await process_frame
		var up := InputEventScreenTouch.new()
		up.index = 0
		up.pressed = false
		up.position = event_center
		Input.parse_input_event(up)
	else:
		var down := InputEventMouseButton.new()
		down.button_index = MOUSE_BUTTON_LEFT
		down.pressed = true
		down.position = event_center
		Input.parse_input_event(down)
		await process_frame
		var up := InputEventMouseButton.new()
		up.button_index = MOUSE_BUTTON_LEFT
		up.pressed = false
		up.position = event_center
		Input.parse_input_event(up)
	await _frames(5)
	return {"ok": true, "button_text": button.text, "center": [center.x, center.y], "event_position": [event_center.x, event_center.y], "viewport": [viewport_size.x, viewport_size.y], "rendered": [rendered.x, rendered.y], "touch": touch}


func _mount_l6() -> bool:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical():
		return false
	var state: Dictionary = SAVE_SCRIPT.new().create_default_state()
	state["islands"]["sunny_cove"]["highest_unlocked_level"] = 6
	var campaign = CAMPAIGN_SCRIPT.new()
	if not campaign.configure(database, state):
		return false
	navigation = shell.get_campaign_navigation()
	if not navigation.configure_campaign(database, campaign):
		return false
	var play: BaseButton = shell.get_menu_controls().get("play")
	if play == null:
		return false
	play.pressed.emit()
	await _frames(8)
	gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	bridge = navigation.get_session_bridge()
	if gameplay != null:
		gameplay.shot_controller.shot_fired.connect(func(_drink: Drink, _velocity: Vector2) -> void: shot_count += 1)
	return gameplay != null and bridge != null and navigation.get_current_view() == navigation.VIEW_GAMEPLAY


func _run() -> void:
	var requested_height := int(OS.get_environment("BCM_M25_MOVE_VIEWPORT_HEIGHT"))
	if requested_height == 1440:
		root.get_window().content_scale_size = Vector2i(720, 1440)
		root.get_window().size = Vector2i(800, 1600)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m25_move_onboarding.json"
	shell.settings_storage_path = "user://m25_move_settings.json"
	root.add_child(shell)
	await _frames(6)
	shell.set_setting("reduced_motion", presentation_mode == "REDUCED")
	shell.skip_onboarding()
	await _frames(2)
	_check("production Home shell mounts", await _mount_l6())
	expected_move_limit = int(bridge.get_move_budget_state().get("move_limit", 0))
	_check("L6 session starts with the derived 48-move budget", expected_move_limit == 48 and int(bridge.get_move_budget_state().get("moves_remaining", 0)) == expected_move_limit)
	var moves_rect: Rect2 = gameplay._move_limit_label.get_global_rect()
	var order_rect: Rect2 = gameplay._to_go_panel.get_global_rect()
	var order_art_rect: Rect2 = gameplay._visible_artwork_bounds("res://assets/ui/panel_to_go_vip_orders.png", order_rect)
	_check("move label clears visible order artwork and stays above the playable board", not moves_rect.intersects(order_art_rect) and moves_rect.end.y <= gameplay.table_top_y)
	captures.append(await _capture("before"))
	if OS.get_environment("BCM_M25_MOVE_CAPTURE_ONLY") == "1":
		var layout_report := {"work_item": "BCM-M25-PERCENT400", "renderer": "Godot 4.7.2 GL Compatibility", "presentation_mode": presentation_mode, "target_strategy": target_strategy, "requested_viewport_height": requested_height, "level_id": 6, "move_limit": expected_move_limit, "move_label_rect": [moves_rect.position.x, moves_rect.position.y, moves_rect.size.x, moves_rect.size.y], "playable_board_top_y": gameplay.table_top_y, "order_panel_rect": [order_rect.position.x, order_rect.position.y, order_rect.size.x, order_rect.size.y], "order_artwork_rect": [order_art_rect.position.x, order_art_rect.position.y, order_art_rect.size.x, order_art_rect.size.y], "captures": captures, "failures": failures}
		var layout_file := FileAccess.open(ProjectSettings.globalize_path("%s/layout_metadata.json" % out_dir), FileAccess.WRITE)
		if layout_file != null:
			layout_file.store_string(JSON.stringify(layout_report, "\t") + "\n")
			layout_file.close()
		if is_instance_valid(shell): shell.queue_free()
		await _frames(3)
		quit(0 if failures.is_empty() else 1)
		return
	await _fire_until_terminal()
	var first_terminal: Dictionary = bridge.get_terminal_result()
	if target_strategy != "OBJECTIVE":
		_check("real mouse shots produce natural MOVES_EXHAUSTED LOSE", first_terminal.get("outcome", "") == "LOSE" and first_terminal.get("reason", "") == "MOVES_EXHAUSTED")
		_check("exactly 48 successful shots were committed", int(bridge.get_move_budget_state().get("moves_used", 0)) == expected_move_limit)
	else:
		_check("objective-focused real mouse route reaches a natural WIN within budget", first_terminal.get("outcome", "") == "WIN" and int(bridge.get_move_budget_state().get("moves_used", 99)) <= expected_move_limit)
	_check("no session accepted more than 4T shots", int(bridge.get_move_budget_state().get("moves_used", 99)) <= expected_move_limit)
	await _frames(2)
	captures.append(await _capture("lose_result"))
	var overlay = navigation.get_result_feedback_overlay()
	if first_terminal.get("outcome", "") == "LOSE":
		_check("LOSE offers Retry and Island Map", overlay != null and overlay.get_visible_actions().has("RETRY") and overlay.get_visible_actions().has("ISLAND_MAP"))
	var second_terminal: Dictionary = {}
	if first_terminal.get("outcome", "") == "LOSE":
		retry_pointer = await _send_button_pointer("RETRY", true)
		_check("touch Retry returns to gameplay exactly once", retry_pointer.get("ok", false) and navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1)
		await _frames(8)
		gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
		bridge = navigation.get_session_bridge()
		expected_move_limit = int(bridge.get_move_budget_state().get("move_limit", 0))
		_check("Retry restores the full 48-move budget", expected_move_limit == 48 and int(bridge.get_move_budget_state().get("moves_remaining", 0)) == expected_move_limit)
		if gameplay != null:
			gameplay.shot_controller.shot_fired.connect(func(_drink: Drink, _velocity: Vector2) -> void: shot_count += 1)
		await _fire_until_terminal()
		second_terminal = bridge.get_terminal_result()
		_check("retry run reaches the same natural move-limit loss", second_terminal.get("outcome", "") == "LOSE" and second_terminal.get("reason", "") == "MOVES_EXHAUSTED")
		map_pointer = await _send_button_pointer("ISLAND_MAP", false)
		_check("mouse Island Map action routes once to the map", map_pointer.get("ok", false) and navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0)
		captures.append(await _capture("island_map_after_action"))
	elif first_terminal.get("outcome", "") == "WIN":
		map_pointer = await _send_button_pointer("ISLAND_MAP", false)
		_check("WIN Island Map action routes once to the map", map_pointer.get("ok", false) and navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0)
		captures.append(await _capture("island_map_after_action"))
	var report := {"work_item": "BCM-M25-PERCENT400", "renderer": "Godot 4.7.2 GL Compatibility", "presentation_mode": presentation_mode, "target_strategy": target_strategy, "requested_viewport_height": requested_height, "level_id": 6, "move_limit": expected_move_limit, "shot_count_total": shot_count, "input_event_count": input_events, "first_terminal": first_terminal, "retry_terminal": second_terminal, "retry_pointer": retry_pointer, "island_map_pointer": map_pointer, "captures": captures, "failures": failures}
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/result_metadata.json" % out_dir), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	print("M25_MOVE_RUNTIME_RESULT %s failures=%d first=%s/%s retry=%s/%s shots=%d inputs=%d" % ["PASS" if failures.is_empty() else "FAIL", failures.size(), str(first_terminal.get("outcome", "NONE")), str(first_terminal.get("reason", "")), str(second_terminal.get("outcome", "NONE")), str(second_terminal.get("reason", "")), shot_count, input_events])
	if is_instance_valid(shell):
		shell.queue_free()
	await _frames(4)
	quit(0 if failures.is_empty() else 1)
