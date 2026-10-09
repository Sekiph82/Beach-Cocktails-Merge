extends SceneTree

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var mode := "FULL"
var expected_outcome := "WIN"
var output_dir := ""
var shell
var navigation
var gameplay: GameManager
var session_bridge
var shot_levels: Array[int] = []
var shot_score_deltas: Array[int] = []
var input_event_count := 0
var failure := ""
var selected_action_button_text := ""
var selected_action_button_rect := Rect2()
var terminal_events: Array[Dictionary] = []
var action_requested_count := 0
var action_requested_log: Array[String] = []
var selected_level_input := 0
var level_selection_geometry := {}
var pointer_geometry := {}
var pointer_input_mode := ""
var session_observations: Array[Dictionary] = []
const SHOT_INPUT_Y := 200.0


func _init() -> void:
	mode = OS.get_environment("BCM_R03_PRESENTATION_MODE").to_upper()
	if not ["FULL", "REDUCED"].has(mode):
		mode = "FULL"
	expected_outcome = OS.get_environment("BCM_R03_EXPECTED_OUTCOME").to_upper()
	if not ["WIN", "LOSE"].has(expected_outcome):
		expected_outcome = "WIN"
	output_dir = OS.get_environment("BCM_R03_CAPTURE_DIR").strip_edges()
	if not output_dir.begins_with("res://") or output_dir.contains(".."):
		output_dir = "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R03/genuine_gameplay/%s_%s" % [mode, expected_outcome]
	call_deferred("_run")


func _frame(count: int = 1) -> void:
	for _index in range(count):
		await process_frame


func _capture(name: String) -> Dictionary:
	var viewport := root.get_viewport()
	var image := viewport.get_texture().get_image()
	var path := "%s/%s.png" % [output_dir, name]
	var error := image.save_png(path) if image != null else ERR_CANT_CREATE
	return {"name": name, "path": path, "width": image.get_width() if image != null else 0, "height": image.get_height() if image != null else 0, "error": error, "captured_ticks_msec": Time.get_ticks_msec()}


func _send_mouse_drag(target_x: float) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(100.0, SHOT_INPUT_Y)
	Input.parse_input_event(press)
	input_event_count += 1
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = Vector2(target_x, SHOT_INPUT_Y)
	Input.parse_input_event(release)
	input_event_count += 1
	await process_frame


func _choose_lane(level: int) -> float:
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
	var desired := lanes[posmod(level - 1, lanes.size())]
	return clampf(desired, 35.0, gameplay.get_board_size().x - 35.0)


func _choose_loss_lane(level: int) -> float:
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


func _click_result_action(action: String) -> bool:
	var overlay = navigation.get_result_feedback_overlay()
	if overlay == null or not overlay.visible:
		return false
	var button: Button
	for child in overlay._actions.get_children():
		if child is Button and str(child.text).to_upper().replace(" ", "_") == action:
			button = child
			break
	if button == null:
		return false
	var center := button.get_global_rect().get_center()
	var vp := root.get_viewport()
	var rendered_size := vp.get_texture().get_size()
	var canvas_layer = overlay.get_parent()
	var canvas_xform := vp.get_canvas_transform()
	var event_center := center
	if pointer_input_mode == "RENDERED_PIXELS":
		event_center = Vector2(center.x * rendered_size.x / maxf(1.0, vp.size.x), center.y * rendered_size.y / maxf(1.0, vp.size.y))
	elif pointer_input_mode in ["WINDOW_SCALED_COORDS", "NATIVE_WAIT", "TOUCH_SCALED_COORDS"]:
		event_center = Vector2(center.x * vp.size.x / maxf(1.0, rendered_size.x), center.y * vp.size.y / maxf(1.0, rendered_size.y))
	pointer_geometry = {"button_global_rect": {"position": [button.get_global_rect().position.x, button.get_global_rect().position.y], "size": [button.get_global_rect().size.x, button.get_global_rect().size.y]}, "button_global_center": [center.x, center.y], "event_position": [event_center.x, event_center.y], "viewport_size": [vp.size.x, vp.size.y], "rendered_texture_size": [rendered_size.x, rendered_size.y], "viewport_window_size": [vp.get_window().size.x, vp.get_window().size.y], "scaled_event_factor": [vp.size.x / maxf(1.0, rendered_size.x), vp.size.y / maxf(1.0, rendered_size.y)], "canvas_transform": [canvas_xform.x.x, canvas_xform.y.y, canvas_xform.origin.x, canvas_xform.origin.y], "overlay_parent": str(canvas_layer.get_path()) if canvas_layer is Node else "NONE", "overlay_parent_visible": canvas_layer.visible if canvas_layer is CanvasItem else false, "clip_contents": button.clip_contents, "mouse_filter": button.mouse_filter, "focus_mode": button.focus_mode, "visible": button.is_visible_in_tree(), "rect_clipped": button.get_global_rect().intersection(vp.get_visible_rect()).has_area()}
	selected_action_button_text = button.text
	selected_action_button_rect = button.get_global_rect()
	if pointer_input_mode == "NATIVE_WAIT":
		await _frame(3600)
		return action_requested_count > 0
	if pointer_input_mode == "TOUCH_SCALED_COORDS":
		var touch_press := InputEventScreenTouch.new()
		touch_press.index = 0
		touch_press.pressed = true
		touch_press.position = event_center
		Input.parse_input_event(touch_press)
		await process_frame
		var touch_release := InputEventScreenTouch.new()
		touch_release.index = 0
		touch_release.pressed = false
		touch_release.position = event_center
		Input.parse_input_event(touch_release)
	else:
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		press.position = event_center
		Input.parse_input_event(press)
		await process_frame
		var release := InputEventMouseButton.new()
		release.button_index = MOUSE_BUTTON_LEFT
		release.pressed = false
		release.position = event_center
		Input.parse_input_event(release)
	await _frame(4)
	return true


func _cancel_bridges_under(node: Node) -> void:
	if node.has_method("cancel_presentation"):
		node.call("cancel_presentation")
	for child in node.get_children():
		_cancel_bridges_under(child)


func _shutdown() -> void:
	if is_instance_valid(shell):
		_cancel_bridges_under(shell)
	var spark := root.get_node_or_null("Spark")
	if is_instance_valid(spark) and spark.has_method("clear"):
		spark.call("clear")
	if is_instance_valid(shell):
		shell.queue_free()
		shell = null
	await _frame(3)
	await RenderingServer.frame_post_draw
	RenderingServer.force_sync()
	await RenderingServer.frame_post_draw
	await _frame(2)


func _run() -> void:
	var requested_viewport_height := int(OS.get_environment("BCM_R03_VIEWPORT_HEIGHT"))
	if requested_viewport_height == 1440:
		var root_window := root.get_window()
		root_window.content_scale_size = Vector2i(720, 1440)
		root_window.size = Vector2i(800, 1600)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m25_r01_onboarding_%s_%d.json" % [mode.to_lower(), Time.get_ticks_usec()]
	shell.settings_storage_path = "user://m25_r01_settings_%s_%d.json" % [mode.to_lower(), Time.get_ticks_usec()]
	root.add_child(shell)
	await _frame(5)
	shell.set_setting("reduced_motion", mode == "REDUCED")
	shell.skip_onboarding()
	await process_frame
	var requested_level := int(OS.get_environment("BCM_R03_START_LEVEL"))
	navigation = shell.get_campaign_navigation()
	if requested_level > 0 and navigation != null:
		var play_for_map: BaseButton = shell.get_menu_controls().get("play")
		if play_for_map == null:
			failure = "production Home PLAY control missing before level selection"
		else:
			play_for_map.pressed.emit()
			await _frame(6)
			navigation = shell.get_campaign_navigation()
		if failure.is_empty() and not navigation.show_world_map():
			failure = "production World Map did not clear the frontier gameplay session"
		if failure.is_empty() and not navigation.show_island_map("sunny_cove"):
			failure = "production Island Map did not open for previously unlocked level selection"
		elif failure.is_empty():
			await _frame(4)
			var island_map = navigation.get_island_map()
			level_selection_geometry = {"map_exists": island_map != null, "level_state": island_map.get_level_state(requested_level) if island_map != null else "NO_MAP", "setup_route": "IslandMapController.select_level"}
			var selected_ok: bool = island_map.select_level(requested_level) if island_map != null else false
			await _frame(6)
			var selected_config: Dictionary = navigation.get_session_bridge().get_session_configuration()
			selected_level_input = int(selected_config.get("level_id", 0))
			level_selection_geometry["nav_view_after_input"] = navigation.get_current_view()
			level_selection_geometry["gameplay_instance_count"] = navigation.get_gameplay_instance_count()
			level_selection_geometry["selected_session_config"] = selected_config.duplicate(true)
			level_selection_geometry["select_level_returned"] = selected_ok
			if not selected_ok or selected_level_input != requested_level:
				failure = "production IslandMapController did not select requested unlocked level"
	else:
		var play: BaseButton = shell.get_menu_controls().get("play")
		if play == null:
			failure = "production Home PLAY control missing"
		else:
			play.pressed.emit()
	await _frame(6)
	navigation = shell.get_campaign_navigation()
	gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	if gameplay == null:
		if failure.is_empty():
			failure = "production level input did not mount CampaignGameplay"
		session_bridge = null
	else:
		session_bridge = navigation.get_session_bridge()
		session_bridge.session_terminal.connect(func(result: Dictionary) -> void: terminal_events.append(result.duplicate(true)))
		gameplay.shot_controller.shot_fired.connect(func(drink: Drink, _velocity: Vector2) -> void: shot_levels.append(drink.level))
		if bool(gameplay.presentation_reduced_motion) != (mode == "REDUCED"):
			failure = "requested presentation mode did not reach production GameManager"
	var captures: Array[Dictionary] = []
	if gameplay != null:
		captures.append(_capture("before"))
		var max_shots := int(OS.get_environment("BCM_R03_MAX_SHOTS"))
		if max_shots <= 0: max_shots = 80
		for shot_index in range(max_shots):
			if session_bridge.is_terminal() or not terminal_events.is_empty():
				break
			if gameplay.game_over:
				for _terminal_frame in range(8):
					await process_frame
				if session_bridge.is_terminal():
					break
				continue
			var held: Drink = gameplay.shot_controller._current_drink
			if not is_instance_valid(held):
				await _frame(3)
				continue
			var score_before := gameplay.score
			var target_x := _choose_loss_lane(held.level) if expected_outcome == "LOSE" else _choose_lane(held.level)
			_send_mouse_drag(target_x)
			shot_score_deltas.append(gameplay.score - score_before)
			if expected_outcome == "LOSE":
				for settle_frame in range(240):
					if session_bridge.is_terminal() or not terminal_events.is_empty():
						break
					if not is_instance_valid(held) or held.is_queued_for_deletion() or held.is_settled():
						break
					await process_frame
				await _frame(3)
			else:
				var shot_delay_text := OS.get_environment("BCM_R03_SHOT_DELAY_FRAMES")
				if not shot_delay_text.is_empty() and int(shot_delay_text) > 0:
					await _frame(int(shot_delay_text))
				elif shot_index % 4 == 3:
					await _frame(24)
				else:
					await _frame(6)
			if session_bridge.is_terminal() or not terminal_events.is_empty():
				break
			var configuration: Dictionary = session_bridge.get_session_configuration()
			session_observations.append({"shot_index": shot_index + 1, "session_serial": int(configuration.get("session_serial", 0)), "level_id": int(configuration.get("level_id", 0)), "session_state": session_bridge.session_state, "terminal_event_count": terminal_events.size()})
		for _settle_frame in range(480):
			if session_bridge.is_terminal() or not terminal_events.is_empty():
				break
			await process_frame
		if session_bridge.is_terminal() or not terminal_events.is_empty():
			await _frame(2)
			captures.append(_capture("event"))
			await _frame(36)
			captures.append(_capture("settled"))
	var end_state: Dictionary = {}
	if gameplay != null:
		var settled_positions: Array[Dictionary] = []
		for child in gameplay.world.get_children():
			if child is Drink and not child.is_queued_for_deletion():
				var drink := child as Drink
				if drink.is_settled():
					settled_positions.append({"level": drink.level, "x": drink.position.x, "y": drink.position.y, "radius": drink.radius, "below_danger": drink.position.y + drink.radius > gameplay.death_line_y})
		end_state = {"score": gameplay.score, "game_over": gameplay.game_over, "death_line_y": gameplay.death_line_y, "death_tolerance": gameplay.death_tolerance, "line_timer": gameplay._line_timer, "settled_drinks": settled_positions}
		if terminal_events.is_empty() and not session_bridge.is_terminal():
			captures.append(_capture("after_attempts"))
	var terminal: Dictionary = terminal_events.back() if not terminal_events.is_empty() else (session_bridge.get_terminal_result() if session_bridge != null and session_bridge.has_method("get_terminal_result") else {})
	var overlay = navigation.get_result_feedback_overlay() if navigation != null else null
	if overlay != null:
		overlay.action_requested.connect(func(action: String) -> void:
			action_requested_count += 1
			action_requested_log.append(action))
	pointer_input_mode = OS.get_environment("BCM_R03_POINTER_MODE").to_upper()
	if pointer_input_mode.is_empty(): pointer_input_mode = "RECT_CENTER"
	var target_action_env := OS.get_environment("BCM_R03_ACTION").to_upper()
	var result_action := "RETRY" if expected_outcome == "LOSE" else "ISLAND_MAP"
	if ["RETRY", "ISLAND_MAP"].has(target_action_env): result_action = target_action_env
	var actions_before: Array[String] = overlay.get_visible_actions() if overlay != null else []
	var action_clicked := await _click_result_action(result_action) if terminal.size() > 0 else false
	var action_route_ok := false
	if action_clicked and navigation != null:
		if result_action == "RETRY":
			action_route_ok = navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1
		else:
			action_route_ok = navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0
		captures.append(_capture("after_action"))
	var report := {
		"work_item": "BCM-M25-R03",
		"route_type": "automated mouse InputEvents through ShotController._unhandled_input; production Drink physics/collisions/merge scoring and CampaignNavigation terminal route; no direct terminal/result injection",
		"human_operated": false,
		"renderer": "GL Compatibility",
		"viewport": [root.get_viewport().size.x, root.get_viewport().size.y],
		"requested_viewport_height": requested_viewport_height,
		"presentation_mode": mode,
		"expected_outcome": expected_outcome,
		"requested_level_start": int(OS.get_environment("BCM_R03_START_LEVEL")),
		"selected_level_input": selected_level_input,
		"level_selection_geometry": level_selection_geometry,
		"shot_delay_frames": int(OS.get_environment("BCM_R03_SHOT_DELAY_FRAMES")) if not OS.get_environment("BCM_R03_SHOT_DELAY_FRAMES").is_empty() else 0,
		"actual_outcome": str(terminal.get("outcome", "NONE")),
		"level_id": int(terminal.get("level_id", 0)),
		"score": int(terminal.get("score", 0)),
		"stars": int(terminal.get("stars", 0)),
		"first_clear": bool(terminal.get("progression", {}).get("first_clear", false)) if terminal.get("progression", {}) is Dictionary else false,
		"terminal_result": terminal,
		"terminal_event_count": terminal_events.size(),
		"terminal_event_levels": terminal_events.map(func(event: Dictionary) -> int: return int(event.get("level_id", 0))),
		"session_observations": session_observations,
		"shot_count": shot_levels.size(),
		"shot_levels": shot_levels,
		"shot_score_deltas": shot_score_deltas,
		"input_event_count": input_event_count,
		"gameplay_game_over": gameplay.game_over if gameplay != null else false,
		"gameplay_score": gameplay.score if gameplay != null else 0,
		"result_title": overlay.get_title_text() if overlay != null else "",
		"result_body": overlay.get_body_text() if overlay != null else "",
		"actions_before_click": actions_before,
		"action_clicked": result_action if action_clicked else "NONE",
		"selected_action_button_text": selected_action_button_text,
		"selected_action_button_rect": {"position": [selected_action_button_rect.position.x, selected_action_button_rect.position.y], "size": [selected_action_button_rect.size.x, selected_action_button_rect.size.y]},
		"action_route_ok": action_route_ok,
		"action_requested_count": action_requested_count,
		"action_requested_log": action_requested_log,
		"pointer_geometry": pointer_geometry,
		"navigation_after_action": navigation.get_current_view() if navigation != null else "NONE",
		"captures": captures,
		"failure": failure,
		"end_state": end_state,
	}
	if action_clicked and (not action_route_ok or action_requested_count != 1):
		failure = "pointer action did not route exactly once"
	var output := FileAccess.open("%s/result_metadata.json" % output_dir, FileAccess.WRITE)
	if output != null:
		output.store_string(JSON.stringify(report, "\t") + "\n")
		output.close()
	print("M25_R03_REAL_INPUT_RESULT=%s outcome=%s mode=%s shots=%d input_events=%d score=%d stars=%d failure=%s" % ["PASS" if str(terminal.get("outcome", "")) == expected_outcome and failure.is_empty() else "PARTIAL", str(terminal.get("outcome", "NONE")), mode, shot_levels.size(), input_event_count, int(terminal.get("score", 0)), int(terminal.get("stars", 0)), failure])
	await _shutdown()
	quit(0 if failure.is_empty() else 1)
