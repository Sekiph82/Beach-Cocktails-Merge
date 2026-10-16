extends Control

## Development-only manual qualification shell around the production campaign
## router and gameplay scene. The scene is launched explicitly by the R18 tool.

const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const MAX_TIMELINE_EVENTS := 5000
const R17_REFERENCES := [
	"coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R17_INDEPENDENT_AUDIT_V01.md",
	"coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R17/attempts/20261015T224520552Z_946ec7624187436592abf3ef080e526c/attempt_summary.json",
	"coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R17/attempts/20261015T224520552Z_946ec7624187436592abf3ef080e526c/trial_f197967dd884403280bd2dc89fdd4a3c/case_record.json",
	"coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R17/attempts/20261015T224520552Z_946ec7624187436592abf3ef080e526c/trial_f197967dd884403280bd2dc89fdd4a3c/progress_trace.json",
	"coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R17/attempts/20261015T224520552Z_946ec7624187436592abf3ef080e526c/r16_error_triage.json",
	"coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/base_tiki_island_l30_MERGE_AWARE_V01.watchdog.json",
]

var _navigation: CampaignNavigationController
var _database
var _island_ids: Array[String] = []
var _dock: PanelContainer
var _compact_button: Button
var _island_option: OptionButton
var _level_spin: SpinBox
var _seed_line: LineEdit
var _selection_label: Label
var _metrics_label: Label
var _status_label: Label
var _timeline_label: Label
var _pause_button: Button
var _shots: Array[Dictionary] = []
var _timeline: Array[Dictionary] = []
var _action_origins: Dictionary = {}
var _hooked_drinks: Dictionary = {}
var _attempt_id := ""
var _attempt_island_id := ""
var _attempt_level_id := 0
var _selected_seed := 34116110
var _status := "UNTESTED"
var _last_result: Dictionary = {}
var _active_gameplay: GameManager
var _step_waiting := false
var _isolation_error := ""
var _event_limit_reported := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	if not _studio_environment_enabled():
		_isolation_error = "Launch with tools/BCM-M34-R18-Level-Qualification-Studio.ps1."
	elif not _profile_isolated():
		_isolation_error = "user:// is not inside the isolated R18 profile."
	if not _isolation_error.is_empty():
		_status = "UNTESTED"
		_status_label.text = "STUDIO BLOCKED · " + _isolation_error
		_disable_game_controls()
		return
	Engine.set_meta("bcm_m34_r18_studio_enabled", true)
	_navigation = NAVIGATION_SCENE.instantiate() as CampaignNavigationController
	_navigation.name = "QualificationCampaignNavigation"
	_navigation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_navigation.mouse_filter = Control.MOUSE_FILTER_PASS
	_navigation.gameplay_session_started.connect(_on_gameplay_session_started)
	_navigation.gameplay_session_finished.connect(_on_gameplay_session_finished)
	add_child(_navigation)
	_database = _navigation.level_database
	if _database == null or not _database.is_loaded() or not _navigation.get_content_load_error().is_empty():
		_isolation_error = "Canonical campaign data failed to load: %s" % _navigation.get_content_load_error()
		_status_label.text = "STUDIO BLOCKED · " + _isolation_error
		_disable_game_controls()
		return
	# This debug session starts from canonical content and in-memory progression.
	# Detaching economy from the session bridge prevents energy/reward mutations.
	_navigation.economy = null
	_navigation.campaign_manager.set_economy(null)
	_navigation.get_session_bridge().configure(_database, _navigation.campaign_manager, null)
	if _navigation._persistence_enabled:
		_isolation_error = "Campaign persistence was unexpectedly enabled."
		_status_label.text = "STUDIO BLOCKED · " + _isolation_error
		_disable_game_controls()
		return
	_island_ids = _database.get_island_ids()
	_island_ids.sort_custom(func(a: String, b: String) -> bool:
		return int(_database.get_island(a).get("order_index", 0)) < int(_database.get_island(b).get("order_index", 0))
	)
	_populate_islands()
	debug_select_case("tiki_island", 10, 34116110)
	_refresh_metrics()
	set_process(true)


func _process(_delta: float) -> void:
	if is_instance_valid(_active_gameplay):
		_attach_live_drinks()
		_refresh_metrics()


func _build_ui() -> void:
	_dock = PanelContainer.new()
	_dock.name = "QualificationStudioDock"
	_dock.anchor_left = 0.015
	_dock.anchor_top = 0.015
	_dock.anchor_right = 0.985
	_dock.anchor_bottom = 0.405
	_dock.offset_left = 0.0
	_dock.offset_top = 0.0
	_dock.offset_right = 0.0
	_dock.offset_bottom = 0.0
	_dock.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dock)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	_dock.add_child(body)
	var title := Label.new()
	title.text = "LEVEL QUALIFICATION STUDIO · DEVELOPMENT ONLY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	body.add_child(title)
	var chooser := HBoxContainer.new()
	chooser.add_theme_constant_override("separation", 5)
	body.add_child(chooser)
	_island_option = OptionButton.new()
	_island_option.custom_minimum_size.x = 190
	_island_option.item_selected.connect(_on_selection_changed)
	chooser.add_child(_island_option)
	_level_spin = SpinBox.new()
	_level_spin.min_value = 1
	_level_spin.max_value = 100
	_level_spin.step = 1
	_level_spin.custom_minimum_size.x = 92
	_level_spin.value_changed.connect(_on_selection_changed)
	chooser.add_child(_level_spin)
	_seed_line = LineEdit.new()
	_seed_line.placeholder_text = "seed"
	_seed_line.text = str(_selected_seed)
	_seed_line.custom_minimum_size.x = 110
	chooser.add_child(_seed_line)
	_add_button(chooser, "TIKI L10 · R17", func(): debug_select_case("tiki_island", 10, 34116110))
	_add_button(chooser, "TIKI L30 · R16", func(): debug_select_case("tiki_island", 30, 34116130))
	_selection_label = _make_label(16, 40)
	body.add_child(_selection_label)
	_metrics_label = _make_label(13, 64)
	body.add_child(_metrics_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 4)
	body.add_child(actions)
	_add_button(actions, "START / RESET SEED", debug_start_selected)
	_pause_button = _add_button(actions, "PAUSE", debug_pause)
	_add_button(actions, "RESUME", debug_resume)
	_add_button(actions, "STEP 1 PHYSICS", debug_step_once)
	_add_button(actions, "BUDGET UNKNOWN", debug_mark_budget_unknown)
	_add_button(actions, "EXPORT JSON", func(): debug_export_attempt(false))
	_add_button(actions, "CAPTURE + EXPORT", func(): debug_export_attempt(true))
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	body.add_child(footer)
	_timeline_label = _make_label(12, 96)
	_timeline_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_timeline_label.clip_text = true
	footer.add_child(_timeline_label)
	var hide_button := _add_button(footer, "HIDE STUDIO", func():
		_dock.visible = false
		_compact_button.visible = true
	)
	hide_button.custom_minimum_size.x = 100
	_compact_button = Button.new()
	_compact_button.name = "ShowStudio"
	_compact_button.text = "STUDIO"
	_compact_button.position = Vector2(12, 84)
	_compact_button.custom_minimum_size = Vector2(110, 38)
	_compact_button.visible = false
	_compact_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_compact_button.pressed.connect(func():
		_dock.visible = true
		_compact_button.visible = false
	)
	add_child(_compact_button)
	_status_label = _make_label(14, 25)
	_status_label.position = Vector2(130, 88)
	_status_label.size = Vector2(570, 32)
	_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_status_label)


func _populate_islands() -> void:
	_island_option.clear()
	for island_id in _island_ids:
		var island: Dictionary = _database.get_island(island_id)
		_island_option.add_item(str(island.get("display_name", island_id)))
		_island_option.set_item_metadata(_island_option.item_count - 1, island_id)


func _add_button(parent: Node, text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size.y = 32
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _make_label(font_size: int, height: float) -> Label:
	var label := Label.new()
	label.custom_minimum_size.y = height
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _disable_game_controls() -> void:
	if is_instance_valid(_island_option):
		_island_option.disabled = true
	if is_instance_valid(_level_spin):
		_level_spin.editable = false
	if is_instance_valid(_seed_line):
		_seed_line.editable = false
	if is_instance_valid(_pause_button):
		_pause_button.disabled = true


func _studio_environment_enabled() -> bool:
	return OS.get_environment("BCM_M34_R18_STUDIO") == "1" and OS.get_environment("BCM_M33_OWNER_PLAYTEST") == "1"


func _profile_isolated() -> bool:
	var actual := ProjectSettings.globalize_path("user://").replace("\\", "/").to_lower().trim_suffix("/")
	var expected := OS.get_environment("BCM_M34_R18_PROFILE_ROOT").replace("\\", "/").to_lower().trim_suffix("/")
	var normal := OS.get_environment("BCM_M34_R18_NORMAL_USER_DATA").replace("\\", "/").to_lower().trim_suffix("/")
	if expected.is_empty() or normal.is_empty():
		return false
	return actual.begins_with(expected + "/") and actual != normal and not actual.begins_with(normal + "/")


func _on_selection_changed(_value: Variant = null) -> void:
	_refresh_selection()


func _selected_island_id() -> String:
	if _island_option == null or _island_option.item_count == 0:
		return ""
	return str(_island_option.get_item_metadata(_island_option.selected))


func _refresh_selection() -> void:
	if _database == null or _island_option.item_count == 0:
		return
	var island_id := _selected_island_id()
	var level_id := int(_level_spin.value)
	var island: Dictionary = _database.get_island(island_id)
	_level_spin.max_value = maxi(1, int(island.get("level_count", 100)))
	var level: Dictionary = _database.get_level(island_id, level_id)
	if level.is_empty():
		_selection_label.text = "Canonical definition unavailable for %s L%d." % [island_id, level_id]
		return
	var t := int(level.get("theoretical_shots_total", 0))
	var exact_cap := t * 4
	var stored_cap := int(level.get("move_limit", exact_cap))
	var orders: Array[String] = []
	for order in level.get("orders", []):
		orders.append("L%d × %d" % [int(order.get("cocktail_level", 0)), int(order.get("quantity", 0))])
	var vip: Variant = level.get("vip", null)
	var vip_text := "none"
	if vip is Dictionary and bool(vip.get("enabled", true)):
		vip_text = "optional L%d × %d" % [int(vip.get("cocktail_level", 0)), int(vip.get("quantity", 0))]
	var thresholds: Dictionary = level.get("score_star_thresholds", {})
	_selection_label.text = "%s · L%d · G%d  |  Normal: %s  |  VIP: %s  |  T=%d, exact 4T cap=%d%s  |  Stars score ≥ %s / %s / %s" % [str(island.get("display_name", island_id)), level_id, int(level.get("global_level_id", 0)), ", ".join(orders), vip_text, t, exact_cap, "" if stored_cap == exact_cap else " · CONTENT CAP MISMATCH stored=%d" % stored_cap, str(thresholds.get("one_star", 0)), str(thresholds.get("two_stars", 0)), str(thresholds.get("three_stars", 0))]
	_status_label.text = "OWNER VISUAL CHECK PENDING · select level, click START, then aim/drag on the uncovered board. Production ShotController and physics are used."


func debug_select_case(island_id: String, level_id: int, seed_value: int) -> bool:
	if _status == "IN_PROGRESS" or _database == null or _database.get_level(island_id, level_id).is_empty() or _navigation == null:
		return false
	for index in range(_island_option.item_count):
		if str(_island_option.get_item_metadata(index)) == island_id:
			_island_option.select(index)
			break
	_level_spin.value = level_id
	_seed_line.text = str(seed_value)
	_selected_seed = seed_value
	_refresh_selection()
	return true


func debug_start_selected() -> bool:
	if _navigation == null or not _isolation_error.is_empty() or not _profile_isolated():
		_status_label.text = "STUDIO BLOCKED · isolated profile verification failed."
		return false
	var island_id := _selected_island_id()
	var level_id := int(_level_spin.value)
	var seed_value := _seed_line.text.strip_edges().to_int()
	if seed_value == 0 or _database.get_level(island_id, level_id).is_empty():
		_status_label.text = "Select a canonical level and a non-zero integer seed."
		return false
	_selected_seed = seed_value
	if _navigation.get_current_view() == CampaignNavigationController.VIEW_GAMEPLAY:
		if _status == "IN_PROGRESS":
			_finish_attempt("BUDGET_UNKNOWN", "scenario_reset_by_owner")
		get_tree().paused = false
		_navigation.show_world_map()
	Engine.set_meta("bcm_m34_r18_seed", _selected_seed)
	Engine.set_meta("bcm_m34_r18_studio_seed", _selected_seed)
	if not _navigation.launch_owner_playtest_sample(island_id, level_id):
		_status_label.text = "Unable to start this canonical level in isolated debug mode."
		return false
	return true


func debug_pause() -> void:
	if is_instance_valid(_active_gameplay):
		get_tree().paused = true
		_pause_button.text = "PHYSICS PAUSED"


func debug_resume() -> void:
	if get_tree().paused:
		get_tree().paused = false
	if is_instance_valid(_pause_button):
		_pause_button.text = "PAUSE"


func debug_step_once() -> void:
	if _step_waiting or not get_tree().paused or not is_instance_valid(_active_gameplay):
		return
	_step_waiting = true
	var start_frame := Engine.get_physics_frames()
	get_tree().paused = false
	await get_tree().physics_frame
	await get_tree().process_frame
	get_tree().paused = true
	_step_waiting = false
	_record_event("PHYSICS_STEP", {"physics_frames_advanced": maxi(0, Engine.get_physics_frames() - start_frame)})


func debug_mark_budget_unknown() -> void:
	if _status == "IN_PROGRESS":
		_finish_attempt("BUDGET_UNKNOWN", "manual_observation_stopped")
	get_tree().paused = true


func debug_export_attempt(capture_screenshot: bool = false) -> Dictionary:
	if _attempt_id.is_empty():
		return {"ok": false, "reason": "NO_ATTEMPT"}
	var root := ProjectSettings.globalize_path("user://m34_r18/exports")
	var make_root := DirAccess.make_dir_recursive_absolute(root)
	if make_root != OK and make_root != ERR_ALREADY_EXISTS:
		return {"ok": false, "reason": "EXPORT_ROOT_CREATE_FAILED", "error": make_root}
	var package_id := _make_unique_id("EXPORT")
	var package_path := root.path_join(package_id)
	var make_package := DirAccess.make_dir_absolute(package_path)
	if make_package != OK:
		return {"ok": false, "reason": "EXPORT_COLLISION_OR_CREATE_FAILED", "error": make_package}
	var report_path := package_path.path_join("qualification_attempt.json")
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": "REPORT_CREATE_FAILED", "error": FileAccess.get_open_error()}
	file.store_string(JSON.stringify(_build_attempt_report(package_id), "\t"))
	file.flush()
	file.close()
	var report_hash := _sha256_bytes(FileAccess.get_file_as_bytes(report_path))
	var manifest_path := root.path_join("exports_manifest.jsonl")
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ_WRITE) if FileAccess.file_exists(manifest_path) else FileAccess.open(manifest_path, FileAccess.WRITE)
	if manifest_file == null:
		return {"ok": false, "reason": "APPEND_ONLY_MANIFEST_OPEN_FAILED", "error": FileAccess.get_open_error(), "report_path": report_path}
	if FileAccess.file_exists(manifest_path):
		manifest_file.seek_end()
	manifest_file.store_line(JSON.stringify({"attempt_id": _attempt_id, "export_id": package_id, "report_path": package_id.path_join("qualification_attempt.json"), "report_sha256": report_hash, "exported_at_unix": Time.get_unix_time_from_system()}))
	manifest_file.flush()
	manifest_file.close()
	var result := {"ok": true, "attempt_id": _attempt_id, "export_id": package_id, "report_path": report_path, "report_sha256": report_hash, "manifest_path": manifest_path}
	if capture_screenshot:
		if DisplayServer.get_name() == "headless":
			result["screenshot"] = "UNAVAILABLE_HEADLESS"
		else:
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var screenshot_path := package_path.path_join("studio_capture.png")
			var save_result := image.save_png(screenshot_path)
			result["screenshot"] = screenshot_path if save_result == OK else "SAVE_FAILED:%d" % save_result
	_status_label.text = "EXPORTED · %s" % report_path
	return result


func debug_get_snapshot() -> Dictionary:
	var island_id := _selected_island_id()
	var level_id := int(_level_spin.value) if _level_spin != null else 0
	var level: Dictionary = _database.get_level(island_id, level_id) if _database != null else {}
	var t := int(level.get("theoretical_shots_total", 0))
	return {
		"island_id": island_id,
		"level_id": level_id,
		"global_level_id": int(level.get("global_level_id", 0)),
		"normal_theoretical_shots_T": t,
		"normal_4t_cap": t * 4,
		"stored_move_limit": int(level.get("move_limit", t * 4)),
		"star_thresholds": (level.get("score_star_thresholds", {}) as Dictionary).duplicate(true),
		"status": _status,
		"attempt_id": _attempt_id,
		"seed": _selected_seed,
		"shots": _shots.duplicate(true),
		"timeline": _timeline.duplicate(true),
	}


func _on_gameplay_session_started(configuration: Dictionary) -> void:
	_active_gameplay = _navigation.get_node_or_null("CampaignGameplay") as GameManager
	if not is_instance_valid(_active_gameplay):
		return
	_attempt_id = _make_unique_id("ATTEMPT")
	_attempt_island_id = str(configuration.get("island_id", ""))
	_attempt_level_id = int(configuration.get("level_id", 0))
	_status = "IN_PROGRESS"
	_refresh_selectors()
	_last_result.clear()
	_shots.clear()
	_timeline.clear()
	_action_origins.clear()
	_hooked_drinks.clear()
	_event_limit_reported = false
	_record_event("SESSION_STARTED", {
		"island_id": str(configuration.get("island_id", "")),
		"level_id": int(configuration.get("level_id", 0)),
		"seed": _selected_seed,
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
		"time_scale": Engine.time_scale,
		"actual_production_scene": "res://scenes/main.tscn",
	})
	_active_gameplay.shot_controller.shot_fired.connect(_on_shot_fired)
	_active_gameplay.qualification_drink_spawned.connect(_on_drink_spawned)
	_active_gameplay.qualification_delivery_diagnostic.connect(_on_delivery_diagnostic)
	_active_gameplay.merge_queue.qualification_merge_completed.connect(_on_merge_completed)
	_attach_live_drinks()
	_status_label.text = "IN_PROGRESS · %s L%d · seed %d · use drag/click on the uncovered board" % [str(configuration.get("island_id", "")), int(configuration.get("level_id", 0)), _selected_seed]


func _on_gameplay_session_finished(result: Dictionary) -> void:
	_last_result = result.duplicate(true)
	var outcome := str(result.get("outcome", "UNKNOWN"))
	if outcome == "WIN":
		_finish_attempt("OBSERVED_WIN", "production_terminal_win", int(result.get("stars", 0)))
	elif outcome == "LOSE":
		_finish_attempt("OBSERVED_LOSS", str(result.get("reason", "production_terminal_loss")))
	else:
		_finish_attempt("BUDGET_UNKNOWN", "unrecognized_terminal_outcome:%s" % outcome)
	get_tree().paused = true


func _on_shot_fired(drink: Drink, velocity: Vector2) -> void:
	if not is_instance_valid(drink) or _status != "IN_PROGRESS":
		return
	var action_id := "SHOT-%03d" % (_shots.size() + 1)
	var instance_id := drink.get_instance_id()
	_action_origins[instance_id] = [action_id]
	var bridge = _navigation.get_session_bridge()
	var move_state: Dictionary = bridge.get_move_budget_state()
	var row := {
		"action_id": action_id,
		"drink_instance_id": instance_id,
		"spawn_level": drink.level,
		"shot_speed_px_s": velocity.length(),
		"start_physics_frame": Engine.get_physics_frames(),
		"move_number": int(move_state.get("moves_used", 0)),
		"normal_objective_delta_by_level": {},
		"vip_objective_delta": 0,
		"shared_objective_events": [],
		"seed": _selected_seed,
	}
	_shots.append(row)
	_record_event("SHOT_FIRED", {"action_id": action_id, "drink_instance_id": instance_id, "level": drink.level, "position": _vector_json(drink.global_position), "velocity": _vector_json(velocity)})
	_hook_drink(drink)


func _on_drink_spawned(instance_id: int, level: int, held: bool) -> void:
	if not _action_origins.has(instance_id):
		_action_origins[instance_id] = ["HELD_NEXT" if held else "UNATTRIBUTED_SPAWN"]
	_record_event("DRINK_SPAWNED", {"drink_instance_id": instance_id, "level": level, "held": held})
	if is_instance_valid(_active_gameplay):
		var drink = instance_from_id(instance_id)
		if drink is Drink:
			_hook_drink(drink)


func _on_delivery_diagnostic(instance_id: int, objective_kind: String, level: int, accepted: int) -> void:
	var origins: Array = _action_origins.get(instance_id, ["UNATTRIBUTED_ORIGIN"]).duplicate()
	var source_actions: Array[String] = []
	for origin in origins:
		if str(origin).begins_with("SHOT-") and not source_actions.has(str(origin)):
			source_actions.append(str(origin))
	if source_actions.size() == 1:
		var shot_index := int(source_actions[0].trim_prefix("SHOT-")) - 1
		if shot_index >= 0 and shot_index < _shots.size():
			if objective_kind == "NORMAL":
				var deltas: Dictionary = _shots[shot_index]["normal_objective_delta_by_level"]
				deltas[str(level)] = int(deltas.get(str(level), 0)) + accepted
			else:
				_shots[shot_index]["vip_objective_delta"] = int(_shots[shot_index]["vip_objective_delta"]) + accepted
	else:
		for shot_id in source_actions:
			var shot_index := int(shot_id.trim_prefix("SHOT-")) - 1
			if shot_index >= 0 and shot_index < _shots.size():
				(_shots[shot_index]["shared_objective_events"] as Array).append({"kind": objective_kind, "level": level, "accepted": accepted, "source_action_ids": source_actions.duplicate()})
	_record_event("OBJECTIVE_DELIVERY", {"source_drink_instance_id": instance_id, "source_action_ids": source_actions, "other_origins": origins, "objective_kind": objective_kind, "level": level, "accepted": accepted})
	_refresh_timeline()


func _on_merge_completed(first_id: int, second_id: int, result_id: int, new_level: int) -> void:
	var origins: Array = []
	for instance_id in [first_id, second_id]:
		for origin in _action_origins.get(instance_id, ["UNATTRIBUTED_ORIGIN"]):
			if not origins.has(origin):
				origins.append(origin)
	_action_origins[result_id] = origins
	_record_event("MERGE_COMPLETED", {"first_instance_id": first_id, "second_instance_id": second_id, "result_instance_id": result_id, "new_level": new_level, "source_action_ids": origins.filter(func(item: Variant) -> bool: return str(item).begins_with("SHOT-"))})
	var drink = instance_from_id(result_id)
	if drink is Drink:
		_hook_drink(drink)


func _attach_live_drinks() -> void:
	if not is_instance_valid(_active_gameplay) or not is_instance_valid(_active_gameplay.world):
		return
	for child in _active_gameplay.world.get_children():
		if child is Drink:
			var instance_id := child.get_instance_id()
			if not _action_origins.has(instance_id):
				_action_origins[instance_id] = ["INITIAL_STOCK"]
			_hook_drink(child)


func _hook_drink(drink: Drink) -> void:
	var instance_id := drink.get_instance_id()
	if _hooked_drinks.has(instance_id):
		return
	_hooked_drinks[instance_id] = true
	if not drink.table_contact.is_connected(_on_drink_contact.bind(instance_id)):
		drink.table_contact.connect(_on_drink_contact.bind(instance_id))
	if not drink.resolved.is_connected(_on_drink_resolved):
		drink.resolved.connect(_on_drink_resolved)
	if not drink.merged.is_connected(_on_drink_merge_requested):
		drink.merged.connect(_on_drink_merge_requested)


func _on_drink_contact(contact: Dictionary, instance_id: int) -> void:
	_record_event("COLLISION_CONTACT", {"drink_instance_id": instance_id, "source_action_ids": _shot_origins(instance_id), "contact_type": str(contact.get("contact_type", "unknown")), "contact_level": int(contact.get("contact_level", 0)), "position": _vector_json(contact.get("position", Vector2.ZERO))})


func _on_drink_resolved(drink: Drink) -> void:
	if is_instance_valid(drink):
		_record_event("DRINK_SETTLED", {"drink_instance_id": drink.get_instance_id(), "level": drink.level, "source_action_ids": _shot_origins(drink.get_instance_id()), "physics_frame": Engine.get_physics_frames()})


func _on_drink_merge_requested(first: Drink, second: Drink, new_level: int) -> void:
	if is_instance_valid(first) and is_instance_valid(second):
		_record_event("MERGE_REQUESTED", {"first_instance_id": first.get_instance_id(), "second_instance_id": second.get_instance_id(), "new_level": new_level, "source_action_ids": _unique_origins(first.get_instance_id(), second.get_instance_id())})


func _shot_origins(instance_id: int) -> Array[String]:
	var result: Array[String] = []
	for origin in _action_origins.get(instance_id, []):
		if str(origin).begins_with("SHOT-"):
			result.append(str(origin))
	return result


func _unique_origins(first_id: int, second_id: int) -> Array[String]:
	var result: Array[String] = []
	for instance_id in [first_id, second_id]:
		for origin in _shot_origins(instance_id):
			if not result.has(origin):
				result.append(origin)
	return result


func _finish_attempt(final_status: String, reason: String, stars: int = 0) -> void:
	if _attempt_id.is_empty() or _status != "IN_PROGRESS":
		return
	_status = final_status
	_record_event("ATTEMPT_FINISHED", {"status": final_status, "reason": reason, "stars": stars})
	_status_label.text = "%s · %s · %s L%d · seed %d" % [final_status, reason, _selected_island_id(), int(_level_spin.value), _selected_seed]
	_refresh_metrics()
	_refresh_selectors()


func _refresh_selectors() -> void:
	var locked := _status == "IN_PROGRESS"
	if is_instance_valid(_island_option):
		_island_option.disabled = locked or not _isolation_error.is_empty()
	if is_instance_valid(_level_spin):
		_level_spin.editable = not locked and _isolation_error.is_empty()
	if is_instance_valid(_seed_line):
		_seed_line.editable = not locked and _isolation_error.is_empty()


func _record_event(kind: String, payload: Dictionary) -> void:
	if _timeline.size() >= MAX_TIMELINE_EVENTS:
		if not _event_limit_reported:
			_event_limit_reported = true
			_timeline.append({"kind": "TIMELINE_TRUNCATED", "monotonic_usec": Time.get_ticks_usec()})
			_refresh_timeline()
		return
	_timeline.append({"sequence": _timeline.size() + 1, "kind": kind, "monotonic_usec": Time.get_ticks_usec(), "physics_frame": Engine.get_physics_frames(), "payload": payload.duplicate(true)})
	_refresh_timeline()


func _refresh_timeline() -> void:
	if _timeline_label == null:
		return
	var lines: Array[String] = []
	var start := maxi(0, _timeline.size() - 5)
	for index in range(start, _timeline.size()):
		var event: Dictionary = _timeline[index]
		var payload: Dictionary = event.get("payload", {})
		lines.append("%04d f%-6d %-21s %s" % [int(event.get("sequence", index + 1)), int(event.get("physics_frame", 0)), str(event.get("kind", "")), JSON.stringify(payload)])
	_timeline_label.text = "Attempt %s · events %d · %s\n%s" % [_attempt_id if not _attempt_id.is_empty() else "not started", _timeline.size(), _status, "\n".join(lines)]


func _refresh_metrics() -> void:
	if _metrics_label == null:
		return
	if not is_instance_valid(_active_gameplay):
		_metrics_label.text = "FPS %d · physics %d Hz · time scale %.2f · board — · shots %d · status %s" % [Engine.get_frames_per_second(), Engine.physics_ticks_per_second, Engine.time_scale, _shots.size(), _status]
		return
	var bridge = _navigation.get_session_bridge()
	var objective_state: Dictionary = bridge.get_objective_state()
	var move_state: Dictionary = bridge.get_move_budget_state()
	var world_children: Array = _active_gameplay.world.get_children()
	var drink_count := 0
	for child in world_children:
		if child is Drink and not child.is_queued_for_deletion():
			drink_count += 1
	var next_level := int(_active_gameplay.shot_controller.get("_next_level")) if is_instance_valid(_active_gameplay.shot_controller) else 0
	var paused := "PAUSED" if get_tree().paused else "RUNNING"
	var progress: Array[String] = []
	var remaining: Dictionary = objective_state.get("normal_remaining", {})
	for level in remaining.keys():
		var total := int(objective_state.get("normal_totals", {}).get(level, 0))
		progress.append("L%s %d/%d" % [str(level), total - int(remaining[level]), total])
	var vip: Dictionary = bridge.get_vip_state()
	var vip_text := "VIP off" if not bool(vip.get("enabled", false)) else "VIP %d/%d" % [int(vip.get("delivered", 0)), int(vip.get("required", 0))]
	var shot_summary := "No action yet"
	if not _shots.is_empty():
		var last_shot: Dictionary = _shots.back()
		var normal_delta: Dictionary = last_shot.get("normal_objective_delta_by_level", {})
		shot_summary = "%s L%d · normal Δ%s · VIP Δ%d%s" % [str(last_shot.get("action_id", "")), int(last_shot.get("spawn_level", 0)), JSON.stringify(normal_delta), int(last_shot.get("vip_objective_delta", 0)), " · shared objective event" if not last_shot.get("shared_objective_events", []).is_empty() else ""]
	var physics_event := "No collision/merge event yet"
	for index in range(_timeline.size() - 1, -1, -1):
		var event_kind := str(_timeline[index].get("kind", ""))
		if event_kind in ["COLLISION_CONTACT", "MERGE_REQUESTED", "MERGE_COMPLETED"]:
			physics_event = event_kind + " · " + JSON.stringify(_timeline[index].get("payload", {}))
			break
	_metrics_label.text = "FPS %d · %d Hz · time %.2f · %s · next L%d · board %d · shots %d/%d · normal %s · %s\nAction: %s\nLast contact/merge: %s" % [Engine.get_frames_per_second(), Engine.physics_ticks_per_second, Engine.time_scale, paused, next_level, drink_count, int(move_state.get("moves_used", 0)), int(move_state.get("move_limit", 0)), ", ".join(progress), vip_text, shot_summary, physics_event]
	if _pause_button != null:
		_pause_button.text = "RESUME PHYSICS" if get_tree().paused else "PAUSE"


func _build_attempt_report(export_id: String) -> Dictionary:
	var island_id := _attempt_island_id if not _attempt_id.is_empty() else _selected_island_id()
	var level_id := _attempt_level_id if not _attempt_id.is_empty() else int(_level_spin.value)
	var level: Dictionary = _database.get_level(island_id, level_id)
	var t := int(level.get("theoretical_shots_total", 0))
	return {
		"schema_version": 1,
		"work_item": "BCM-M34-R18",
		"attempt_id": _attempt_id,
		"export_id": export_id,
		"status": _status,
		"island_id": island_id,
		"level_id": level_id,
		"global_level_id": int(level.get("global_level_id", 0)),
		"seed": _selected_seed,
		"first_action_id": str(_shots[0].get("action_id", "")) if not _shots.is_empty() else "",
		"normal_theoretical_shots_T": t,
		"normal_4t_legal_move_cap": t * 4,
		"score_star_thresholds": level.get("score_star_thresholds", {}).duplicate(true),
		"normal_orders": level.get("orders", []).duplicate(true),
		"vip_optional": level.get("vip", null),
		"actual_scene": "res://scenes/main.tscn",
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
		"time_scale": Engine.time_scale,
		"r17_immutable_evidence_refs": R17_REFERENCES.duplicate(),
		"result": _last_result.duplicate(true),
		"shots": _shots.duplicate(true),
		"timeline": _timeline.duplicate(true),
	}


func _make_unique_id(prefix: String) -> String:
	var crypto := Crypto.new()
	var nonce := crypto.generate_random_bytes(16).hex_encode()
	var stamp := Time.get_datetime_string_from_system(true, true).replace(":", "").replace("-", "").replace("T", "T").replace("Z", "Z")
	return "%s_%s_%d_%s" % [prefix, stamp, Time.get_ticks_usec(), nonce]


func _vector_json(value: Variant) -> Array[float]:
	var vector: Vector2 = value if value is Vector2 else Vector2.ZERO
	return [vector.x, vector.y]


func _sha256_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()
