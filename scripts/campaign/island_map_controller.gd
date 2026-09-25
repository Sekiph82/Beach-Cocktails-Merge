class_name IslandMapController
extends Control

## Generic, data-driven Island Map. It presents progression and emits bounded
## selection/navigation signals; it never launches gameplay.

signal level_selected(island_id: String, level_id: int)
signal return_requested
signal world_map_requested

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"
const MAP_WIDTH := 720.0
const NODE_HEIGHT := 126.0
const NODE_SIZE := Vector2(116.0, 112.0)
const DEFAULT_MILESTONES := [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

const LEVEL_BUTTON_SCENE := preload("res://scenes/campaign/LevelButton.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var island_id := ""
var level_database
var campaign_manager
var selected_level_id := 0
var _focus_level_id := 0
var _restoration_state: Dictionary = {}
var _refresh_queued := false
var _level_buttons: Dictionary = {}
var _milestone_levels: Array[int] = []

var _scroll: ScrollContainer
var _content: Control
var _path_line: Line2D
var _node_layer: Control
var _title_label: Label
var _summary_label: Label
var _focus_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_shell()
	if level_database == null or campaign_manager == null:
		_configure_default_campaign()
	if not island_id.is_empty():
		refresh()


func configure_island(
		configured_island_id: String,
		database,
		manager,
		restoration: Dictionary = {}
	) -> bool:
	if database == null or manager == null or not database.is_loaded():
		return false
	var definition: Dictionary = database.get_island(configured_island_id)
	if definition.is_empty():
		return false
	island_id = configured_island_id
	level_database = database
	campaign_manager = manager
	_restoration_state = restoration.duplicate(true)
	selected_level_id = int(_restoration_state.get("selected_level_id", 0))
	if selected_level_id <= 0 and campaign_manager.current_island_id == island_id:
		selected_level_id = int(campaign_manager.selected_level_id)
	if selected_level_id <= 0:
		selected_level_id = 1
	_focus_level_id = int(_restoration_state.get("scroll_focus_level_id", 0))
	if _focus_level_id <= 0:
		_focus_level_id = selected_level_id
	_refresh_milestones(definition)
	refresh()
	return true


func configure_campaign(database, manager, configured_island_id: String, restoration: Dictionary = {}) -> bool:
	return configure_island(configured_island_id, database, manager, restoration)


func refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh_deferred")


func select_level(level_id: int) -> bool:
	var button = _level_buttons.get(level_id)
	if button == null:
		return false
	return button.try_select()


func request_back_to_world_map() -> void:
	return_requested.emit()
	world_map_requested.emit()


func get_level_button_count() -> int:
	return _level_buttons.size()


func get_level_button(level_id: int):
	return _level_buttons.get(level_id)


func get_level_state(level_id: int) -> String:
	var button = _level_buttons.get(level_id)
	return str(button.get_state()) if button != null else ""


func get_level_stars(level_id: int) -> int:
	var button = _level_buttons.get(level_id)
	return int(button.get_stars()) if button != null else 0


func is_level_milestone(level_id: int) -> bool:
	return _milestone_levels.has(level_id)


func get_selected_level_id() -> int:
	return selected_level_id


func get_focus_level_id() -> int:
	return _focus_level_id


func get_scroll_focus_level_id() -> int:
	return _focus_level_id


func get_scroll_vertical() -> int:
	return _scroll.scroll_vertical if _scroll != null else 0


func get_restoration_state() -> Dictionary:
	return {
		"island_id": island_id,
		"selected_level_id": selected_level_id,
		"scroll_focus_level_id": _focus_level_id,
		"scroll_vertical": get_scroll_vertical(),
	}


func restore_state(restoration: Dictionary) -> bool:
	if str(restoration.get("island_id", island_id)) != island_id:
		return false
	_restoration_state = restoration.duplicate(true)
	var restored_selected := int(restoration.get("selected_level_id", 0))
	if restored_selected > 0 and campaign_manager != null and campaign_manager.is_level_unlocked(island_id, restored_selected):
		selected_level_id = restored_selected
	var restored_focus := int(restoration.get("scroll_focus_level_id", 0))
	if restored_focus > 0:
		_focus_level_id = restored_focus
	refresh()
	return true


func get_summary() -> Dictionary:
	var definition: Dictionary = level_database.get_island(island_id) if level_database != null else {}
	var progress: Dictionary = campaign_manager.get_island_progress(island_id) if campaign_manager != null else {"completed": 0, "total": int(definition.get("level_count", 0)), "island_complete": false}
	var completed := int(progress.get("completed", 0))
	var total := int(progress.get("total", definition.get("level_count", 0)))
	var stars := _earned_stars()
	var next_milestone := 0
	for milestone_level in _milestone_levels:
		if milestone_level > completed:
			next_milestone = milestone_level
			break
	return {
		"island_id": island_id,
		"display_name": str(definition.get("display_name", island_id)),
		"completed": completed,
		"total": total,
		"stars": stars,
		"next_milestone": next_milestone,
		"island_complete": bool(progress.get("island_complete", false)),
	}


func get_layout_report(reference_size: Vector2 = Vector2(720.0, 1280.0)) -> Dictionary:
	var report := {
		"reference_size": reference_size,
		"node_count": _level_buttons.size(),
		"reusable_scene_count": 1 if _level_buttons.size() > 0 else 0,
		"horizontal_clipping": false,
		"vertical_scrollable": false,
		"duplicate_nodes": _node_layer != null and _node_layer.get_child_count() != _level_buttons.size(),
		"content_width": MAP_WIDTH,
		"content_height": _content.size.y if _content != null else 0.0,
	}
	if _content == null:
		return report
	report["vertical_scrollable"] = _content.size.y > reference_size.y - 250.0
	for level_id in _level_buttons:
		var button: Control = _level_buttons[level_id]
		var rect := Rect2(button.position, button.size)
		if rect.position.x < 0.0 or rect.end.x > reference_size.x:
			report["horizontal_clipping"] = true
	return report


func _refresh_deferred() -> void:
	_refresh_queued = false
	if _content == null or level_database == null or campaign_manager == null or island_id.is_empty():
		return
	for child in _node_layer.get_children():
		_node_layer.remove_child(child)
		child.queue_free()
	_level_buttons.clear()
	_path_line.clear_points()

	var definition: Dictionary = level_database.get_island(island_id)
	var level_count := maxi(0, int(definition.get("level_count", 0)))
	_content.custom_minimum_size = Vector2(MAP_WIDTH, 164.0 + float(level_count) * NODE_HEIGHT)
	_content.size = _content.custom_minimum_size
	_node_layer.size = _content.size
	var points := PackedVector2Array()
	for level_id in range(1, level_count + 1):
		var button = LEVEL_BUTTON_SCENE.instantiate()
		var x := 92.0 if level_id % 2 == 1 else 512.0
		var y := 26.0 + float(level_id - 1) * NODE_HEIGHT
		button.position = Vector2(x, y)
		button.size = NODE_SIZE
		button.configure(island_id, level_id, _state_for(level_id), _stars_for(level_id), _milestone_levels.has(level_id))
		button.level_selected.connect(_on_level_button_selected)
		_node_layer.add_child(button)
		_level_buttons[level_id] = button
		points.append(Vector2(x + NODE_SIZE.x * 0.5, y + NODE_SIZE.y * 0.5))
	_path_line.points = points
	_update_summary()
	if _focus_level_id <= 0 or not _level_buttons.has(_focus_level_id):
		_focus_level_id = _entry_focus_level(level_count)
	call_deferred("_apply_focus")


func _state_for(level_id: int) -> String:
	if campaign_manager.is_level_completed(island_id, level_id):
		return STATE_COMPLETE
	if not campaign_manager.is_level_unlocked(island_id, level_id):
		return STATE_LOCKED
	if level_id == selected_level_id or level_id == int(campaign_manager.selected_level_id):
		return STATE_CURRENT
	return STATE_OPEN


func _entry_focus_level(level_count: int) -> int:
	for level_id in range(level_count, 0, -1):
		if campaign_manager.is_level_unlocked(island_id, level_id) and not campaign_manager.is_level_completed(island_id, level_id):
			return level_id
	return level_count if level_count > 0 else 0


func _on_level_button_selected(level_id: int) -> void:
	if campaign_manager == null or not campaign_manager.is_level_unlocked(island_id, level_id):
		return
	if not campaign_manager.select_level(island_id, level_id):
		return
	selected_level_id = level_id
	_focus_level_id = level_id
	level_selected.emit(island_id, level_id)
	_update_summary()
	refresh()
	call_deferred("_apply_focus")


func _apply_focus() -> void:
	if _scroll == null or _content == null or _focus_level_id <= 0:
		return
	var button = _level_buttons.get(_focus_level_id)
	if button == null:
		return
	var viewport_height := _scroll.size.y
	if viewport_height <= 0.0:
		viewport_height = 1030.0
	var target := int(button.position.y + button.size.y * 0.5 - viewport_height * 0.5)
	var max_scroll := maxi(0, int(_content.size.y - viewport_height))
	_scroll.scroll_vertical = clampi(target, 0, max_scroll)
	_focus_label.text = "FOCUS  •  Level %d" % _focus_level_id


func _update_summary() -> void:
	if _title_label == null:
		return
	var summary := get_summary()
	_title_label.text = str(summary.get("display_name", island_id)).to_upper()
	var milestone_text := "COMPLETE" if int(summary.get("next_milestone", 0)) == 0 else "Level %d" % int(summary["next_milestone"])
	var completion_text := "ISLAND COMPLETE" if bool(summary.get("island_complete", false)) else "IN PROGRESS"
	_summary_label.text = "%d / %d LEVELS   •   %d / %d STARS   •   NEXT MILESTONE: %s\n%s" % [int(summary["completed"]), int(summary["total"]), int(summary["stars"]), int(summary["total"]) * 3, milestone_text, completion_text]


func _earned_stars() -> int:
	if campaign_manager == null:
		return 0
	var state: Dictionary = campaign_manager.get_progression_state()
	var island_state: Dictionary = state.get("islands", {}).get(island_id, {})
	var completed: Dictionary = island_state.get("completed_levels", {})
	var stars := 0
	for record in completed.values():
		if record is Dictionary and bool(record.get("completed", false)):
			stars += clampi(int(record.get("stars", 0)), 0, 3)
	return stars


func _stars_for(level_id: int) -> int:
	if campaign_manager == null:
		return 0
	var state: Dictionary = campaign_manager.get_progression_state()
	var record: Dictionary = state.get("islands", {}).get(island_id, {}).get("completed_levels", {}).get(str(level_id), {})
	return clampi(int(record.get("stars", 0)), 0, 3)


func _refresh_milestones(definition: Dictionary) -> void:
	_milestone_levels.clear()
	var configured: Variant = definition.get("reward_track", {}).get("milestones", [])
	if configured is Array:
		for value in configured:
			var milestone_level := int(value)
			if milestone_level > 0 and not _milestone_levels.has(milestone_level):
				_milestone_levels.append(milestone_level)
	if _milestone_levels.is_empty():
		var total := int(definition.get("level_count", 0))
		for milestone_level in DEFAULT_MILESTONES:
			if milestone_level <= total:
				_milestone_levels.append(milestone_level)
	_milestone_levels.sort()


func _build_shell() -> void:
	var background := ColorRect.new()
	background.name = "IslandMapBackground"
	background.color = Color("#08283c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var header := PanelContainer.new()
	header.name = "IslandMapHeader"
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 166.0
	header.add_theme_stylebox_override("panel", _panel_style(Color("#103d52"), Color("#4bb3a8"), 0.98))
	header.z_index = 5
	add_child(header)

	var back := Button.new()
	back.name = "BackToWorldMap"
	back.text = "‹"
	back.position = Vector2(18.0, 24.0)
	back.size = Vector2(62.0, 62.0)
	back.add_theme_font_size_override("font_size", 40)
	back.add_theme_color_override("font_color", Color("#fff0c6"))
	back.add_theme_stylebox_override("normal", _panel_style(Color("#0b2b40"), Color("#f1bd64")))
	back.pressed.connect(request_back_to_world_map)
	header.add_child(back)

	_title_label = Label.new()
	_title_label.position = Vector2(92.0, 20.0)
	_title_label.size = Vector2(560.0, 42.0)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 28)
	_title_label.modulate = Color("#fff0c6")
	header.add_child(_title_label)

	var subtitle := Label.new()
	subtitle.text = "ISLAND MAP  •  SELECT A LEVEL TO VIEW ITS CAMPAIGN BOUNDARY"
	subtitle.position = Vector2(84.0, 58.0)
	subtitle.size = Vector2(574.0, 22.0)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.modulate = Color("#8ce0d0")
	header.add_child(subtitle)

	_summary_label = Label.new()
	_summary_label.position = Vector2(84.0, 88.0)
	_summary_label.size = Vector2(574.0, 60.0)
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_summary_label.add_theme_font_size_override("font_size", 14)
	_summary_label.modulate = Color("#d8f0df")
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(_summary_label)

	_scroll = ScrollContainer.new()
	_scroll.name = "LevelPathScroll"
	_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scroll.offset_top = 178.0
	_scroll.offset_bottom = -70.0
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	_scroll.z_index = 2
	add_child(_scroll)

	_content = Control.new()
	_content.name = "LevelPathContent"
	_content.custom_minimum_size = Vector2(MAP_WIDTH, 400.0)
	_content.size = _content.custom_minimum_size
	_scroll.add_child(_content)

	_path_line = Line2D.new()
	_path_line.name = "DeterministicLevelPath"
	_path_line.width = 8.0
	_path_line.default_color = Color("#d9a957")
	_path_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_path_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_path_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_path_line.z_index = 0
	_content.add_child(_path_line)

	_node_layer = Control.new()
	_node_layer.name = "LevelNodes"
	_node_layer.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_node_layer.size = _content.size
	_node_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_node_layer.z_index = 1
	_content.add_child(_node_layer)

	_focus_label = Label.new()
	_focus_label.name = "FocusStatus"
	_focus_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_focus_label.offset_left = 24.0
	_focus_label.offset_top = -54.0
	_focus_label.offset_right = -24.0
	_focus_label.offset_bottom = -20.0
	_focus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_focus_label.add_theme_font_size_override("font_size", 14)
	_focus_label.modulate = Color("#c3e8df")
	_focus_label.z_index = 5
	add_child(_focus_label)


func _configure_default_campaign() -> void:
	level_database = DATABASE_SCRIPT.new()
	if not level_database.load_canonical():
		return
	campaign_manager = CAMPAIGN_SCRIPT.new()
	if not campaign_manager.configure(level_database, SAVE_SCRIPT.new().create_default_state()):
		return
	island_id = campaign_manager.current_island_id
	selected_level_id = campaign_manager.selected_level_id
	_refresh_milestones(level_database.get_island(island_id))


func _panel_style(fill: Color, border: Color, alpha: float = 1.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	return style
