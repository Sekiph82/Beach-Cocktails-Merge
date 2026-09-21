class_name WorldMapController
extends Control

## Reusable, data-driven World Map controller.
##
## Island definitions, map coordinates, art, and unlock rules come from the
## campaign definition layer. CampaignManager remains the sole authority for
## OPEN/LOCKED/CURRENT/COMPLETE state and selection decisions.

signal island_selected(island_id: String)
signal island_map_requested(island_id: String)
signal locked_island_feedback(island_id: String, reason: String, progress: String)
signal return_requested

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"

const MAP_BACKGROUND := preload("res://assets/ui_assets/campaign/world_map/world_map_background.png")
const CLOUDS_FRONT := preload("res://assets/ui_assets/campaign/world_map/world_clouds_front.png")
const TITLE_PANEL := preload("res://assets/ui_assets/campaign/world_map/world_map_title_panel.png")
const COMPASS := preload("res://assets/ui_assets/campaign/world_map/world_map_compass.png")
const BOAT := preload("res://assets/ui_assets/campaign/world_map/world_map_boat.png")
const CARD_SCENE := preload("res://scenes/campaign/IslandEntry.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var level_database
var campaign_manager
var selected_island_id := ""
var last_locked_feedback: Dictionary = {}
var _ordered_ids: Array[String] = []
var _definitions_by_id: Dictionary = {}
var _entries: Dictionary = {}
var _refresh_queued := false

var _map_canvas: Control
var _route_line: Line2D
var _marker_layer: Control
var _status_label: Label
var _selection_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_shell()
	if level_database == null or campaign_manager == null:
		_configure_default_campaign()
	_bind_campaign_signals()
	refresh()


func configure_campaign(database, manager) -> bool:
	if database == null or manager == null or not database.is_loaded():
		return false
	level_database = database
	campaign_manager = manager
	_bind_campaign_signals()
	refresh()
	return true


func refresh() -> void:
	# Rebuilds are deferred so a marker cannot be freed while its pressed signal
	# is still dispatching. The old marker is detached and queue-freed only from
	# the deferred rebuild, never immediate-freed.
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh_deferred")


func _refresh_deferred() -> void:
	_refresh_queued = false
	if _marker_layer == null or level_database == null or campaign_manager == null:
		return
	for child in _marker_layer.get_children():
		_marker_layer.remove_child(child)
		child.queue_free()
	_entries.clear()
	_ordered_ids.clear()
	_definitions_by_id.clear()

	var definitions: Array[Dictionary] = []
	for island_id in level_database.get_island_ids():
		var definition: Dictionary = level_database.get_island(island_id)
		definitions.append(definition)
	definitions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order_index", 0)) < int(b.get("order_index", 0))
	)

	for definition in definitions:
		var island_id := str(definition.get("id", ""))
		if island_id.is_empty():
			continue
		var feedback: Dictionary = campaign_manager.get_island_unlock_feedback(island_id)
		var state := _state_for(island_id, bool(feedback.get("unlocked", false)))
		var entry = CARD_SCENE.instantiate()
		_marker_layer.add_child(entry)
		entry.configure(definition, state, str(feedback.get("reason", "")), str(feedback.get("progress", "")))
		entry.island_pressed.connect(_on_island_pressed)
		_entries[island_id] = entry
		_definitions_by_id[island_id] = definition
		_ordered_ids.append(island_id)

	if selected_island_id.is_empty():
		selected_island_id = campaign_manager.current_island_id
	_layout_map()
	_update_summary()
	call_deferred("_layout_map")


func get_entry_count() -> int:
	return _entries.size()


func get_entry_ids() -> Array[String]:
	return _ordered_ids.duplicate()


func get_entry_state(island_id: String) -> String:
	var entry = _entries.get(island_id)
	return str(entry.island_state) if entry != null else ""


func is_entry_selectable(island_id: String) -> bool:
	var entry = _entries.get(island_id)
	return entry != null and bool(entry.is_selectable())


func get_locked_feedback() -> Dictionary:
	return last_locked_feedback.duplicate(true)


func get_visual_marker_count() -> int:
	return _entries.size()


func get_map_node_count() -> int:
	return _marker_layer.get_child_count() if _marker_layer != null else 0


func get_marker_position(island_id: String) -> Vector2:
	var entry: Control = _entries.get(island_id) as Control
	return entry.position if entry != null else Vector2(-1.0, -1.0)


func select_island(island_id: String) -> bool:
	if campaign_manager == null:
		return false
	var feedback: Dictionary = campaign_manager.get_island_unlock_feedback(island_id)
	if not bool(feedback.get("unlocked", false)):
		last_locked_feedback = {
			"island_id": island_id,
			"reason": str(feedback.get("reason", "Island locked")),
			"progress": str(feedback.get("progress", "Progress required")),
		}
		_show_locked_feedback(last_locked_feedback)
		locked_island_feedback.emit(island_id, last_locked_feedback["reason"], last_locked_feedback["progress"])
		return false
	if not campaign_manager.select_island(island_id):
		return false
	selected_island_id = island_id
	island_selected.emit(island_id)
	# M13 owns IslandMapScene. This signal is the navigation boundary; this
	# controller never launches gameplay directly.
	island_map_requested.emit(island_id)
	refresh()
	_show_selection_feedback(island_id)
	return true


func get_layout_report(reference_size: Vector2 = Vector2(720, 1280)) -> Dictionary:
	var report := {
		"reference_size": reference_size,
		"entry_count": _entries.size(),
		"visual_marker_count": _entries.size(),
		"horizontal_clipping": false,
		"overlap": false,
		"navigation_overlap": false,
		"entries_fit_width": true,
		"map_fills_viewport": _map_canvas != null,
		"duplicate_nodes": get_map_node_count() != _entries.size(),
	}
	if _map_canvas == null or _entries.is_empty():
		return report
	var map_size := _map_canvas.size
	var previous: Array[Rect2] = []
	for island_id in get_entry_ids():
		var entry: Control = _entries[island_id] as Control
		var rect := Rect2(entry.position, entry.size)
		if rect.position.x < 0.0 or rect.end.x > map_size.x or rect.position.y < 0.0 or rect.end.y > map_size.y:
			report["horizontal_clipping"] = true
			report["entries_fit_width"] = false
		for other in previous:
			if rect.intersects(other):
				report["overlap"] = true
		previous.append(rect)
	if _selection_label != null and _selection_label.get_global_rect().intersects(_map_canvas.get_global_rect()):
		report["navigation_overlap"] = true
	return report


func _build_shell() -> void:
	var background := TextureRect.new()
	background.name = "WorldMapBackground"
	background.texture = MAP_BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var ocean_wash := ColorRect.new()
	ocean_wash.name = "OceanWash"
	ocean_wash.color = Color(0.02, 0.10, 0.18, 0.12)
	ocean_wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ocean_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ocean_wash)

	_map_canvas = Control.new()
	_map_canvas.name = "MapCanvas"
	_map_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_canvas.offset_top = 142.0
	_map_canvas.offset_bottom = -214.0
	_map_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_map_canvas)

	_route_line = Line2D.new()
	_route_line.name = "IslandRoute"
	_route_line.width = 6.0
	_route_line.default_color = Color("#ffd166")
	_route_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_route_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_route_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_route_line.antialiased = true
	_route_line.z_index = 1
	_map_canvas.add_child(_route_line)

	_marker_layer = Control.new()
	_marker_layer.name = "IslandMarkers"
	_marker_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_marker_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_marker_layer.z_index = 2
	_map_canvas.add_child(_marker_layer)

	var clouds := TextureRect.new()
	clouds.name = "CloudsFront"
	clouds.texture = CLOUDS_FRONT
	clouds.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clouds.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	clouds.stretch_mode = TextureRect.STRETCH_SCALE
	clouds.modulate = Color(1.0, 1.0, 1.0, 0.06)
	clouds.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clouds.z_index = 4
	add_child(clouds)

	var header := Control.new()
	header.name = "Header"
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 138.0
	header.mouse_filter = Control.MOUSE_FILTER_PASS
	header.z_index = 8
	add_child(header)

	var back := Button.new()
	back.name = "BackButton"
	back.text = "‹"
	back.position = Vector2(22.0, 28.0)
	back.size = Vector2(64.0, 64.0)
	back.add_theme_font_size_override("font_size", 42)
	back.tooltip_text = "Return"
	back.pressed.connect(func() -> void: return_requested.emit())
	_apply_button_style(back, Color("#12354d"), Color("#f7d47b"))
	header.add_child(back)

	var title_panel := TextureRect.new()
	title_panel.name = "TitlePanel"
	title_panel.texture = TITLE_PANEL
	title_panel.position = Vector2(138.0, 22.0)
	title_panel.size = Vector2(444.0, 86.0)
	title_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(title_panel)

	var eyebrow := Label.new()
	eyebrow.text = "CAMPAIGN NAVIGATION"
	eyebrow.position = Vector2(170.0, 32.0)
	eyebrow.size = Vector2(380.0, 22.0)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.modulate = Color("#73e0d1")
	eyebrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(eyebrow)

	var title := Label.new()
	title.text = "WORLD MAP"
	title.position = Vector2(170.0, 52.0)
	title.size = Vector2(380.0, 42.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.modulate = Color("#fff3cf")
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(title)

	var compass := TextureRect.new()
	compass.name = "Compass"
	compass.texture = COMPASS
	compass.position = Vector2(624.0, 28.0)
	compass.size = Vector2(70.0, 70.0)
	compass.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	compass.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	compass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(compass)

	var status_panel := PanelContainer.new()
	status_panel.name = "StatusPanel"
	status_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_panel.offset_left = 24.0
	status_panel.offset_top = -160.0
	status_panel.offset_right = -24.0
	status_panel.offset_bottom = -82.0
	status_panel.add_theme_stylebox_override("panel", _panel_style(Color("#08283c"), Color("#3f9b9b"), 0.92))
	status_panel.z_index = 9
	add_child(status_panel)

	var status_margin := MarginContainer.new()
	status_margin.add_theme_constant_override("margin_left", 18)
	status_margin.add_theme_constant_override("margin_top", 10)
	status_margin.add_theme_constant_override("margin_right", 18)
	status_margin.add_theme_constant_override("margin_bottom", 8)
	status_panel.add_child(status_margin)
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 16)
	_status_label.modulate = Color("#fff0c6")
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_margin.add_child(_status_label)

	_selection_label = Label.new()
	_selection_label.name = "SelectionBoundary"
	_selection_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_selection_label.offset_left = 26.0
	_selection_label.offset_top = -70.0
	_selection_label.offset_right = -26.0
	_selection_label.offset_bottom = -24.0
	_selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selection_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_selection_label.add_theme_font_size_override("font_size", 14)
	_selection_label.modulate = Color("#d7ebe4")
	_selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_selection_label.z_index = 9
	add_child(_selection_label)

	var boat := TextureRect.new()
	boat.name = "MapBoat"
	boat.texture = BOAT
	boat.position = Vector2(38.0, 1030.0)
	boat.size = Vector2(86.0, 62.0)
	boat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	boat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	boat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boat.z_index = 5
	add_child(boat)


func _configure_default_campaign() -> void:
	level_database = DATABASE_SCRIPT.new()
	if not level_database.load_canonical():
		return
	campaign_manager = CAMPAIGN_SCRIPT.new()
	campaign_manager.configure(level_database, SAVE_SCRIPT.new().create_default_state())
	_bind_campaign_signals()


func _bind_campaign_signals() -> void:
	if campaign_manager != null and not campaign_manager.progression_changed.is_connected(_on_progression_changed):
		campaign_manager.progression_changed.connect(_on_progression_changed)


func _on_progression_changed(_island_id: String, _level_id: int) -> void:
	refresh()


func _state_for(island_id: String, unlocked: bool) -> String:
	if campaign_manager.is_island_complete(island_id):
		return STATE_COMPLETE
	if campaign_manager.current_island_id == island_id:
		return STATE_CURRENT
	return STATE_OPEN if unlocked else STATE_LOCKED


func _on_island_pressed(island_id: String) -> void:
	select_island(island_id)


func _show_locked_feedback(feedback: Dictionary) -> void:
	_status_label.modulate = Color("#ffd0c4")
	_status_label.text = "%s\n%s" % [feedback["reason"], feedback["progress"]]
	_selection_label.text = "LOCKED DESTINATION  •  Complete the required campaign progress to continue"


func _show_selection_feedback(island_id: String) -> void:
	_status_label.modulate = Color("#fff0c6")
	var definition: Dictionary = _definitions_by_id.get(island_id, {})
	_status_label.text = "Selected %s  •  Island Map navigation boundary ready" % str(definition.get("display_name", island_id))
	_selection_label.text = "ISLAND SELECTED  •  M13 Island Map will receive this island id"


func _update_summary() -> void:
	if selected_island_id.is_empty() or not _entries.has(selected_island_id):
		_status_label.text = "Sunny Cove is open • follow the route to discover future islands"
		_selection_label.text = "Select an open island to continue • locked destinations show their campaign requirement"
		return
	var selected_definition: Dictionary = _definitions_by_id.get(selected_island_id, {})
	var selected_entry = _entries[selected_island_id]
	_status_label.modulate = Color("#fff0c6")
	var display_state := "CURRENT • OPEN" if str(selected_entry.island_state) == STATE_CURRENT else str(selected_entry.island_state)
	_status_label.text = "%s  •  %s\n%s" % [selected_definition.get("display_name", selected_island_id), display_state, str(campaign_manager.get_island_unlock_feedback(selected_island_id).get("progress", ""))]
	_selection_label.text = "Select an island destination • locked markers are not navigable"


func _layout_map() -> void:
	if _map_canvas == null:
		return
	var map_size := _map_canvas.size
	if map_size.x <= 0.0 or map_size.y <= 0.0:
		map_size = Vector2(720.0, 924.0)
	var route_points := PackedVector2Array()
	for island_id in _ordered_ids:
		var definition: Dictionary = _definitions_by_id.get(island_id, {})
		var entry: Control = _entries.get(island_id) as Control
		if entry == null:
			continue
		var normalized := _map_position(definition, int(definition.get("order_index", 1)))
		var center := Vector2(normalized.x * map_size.x, normalized.y * map_size.y)
		entry.position = center - entry.size * 0.5
		route_points.append(center)
	_route_line.points = route_points


func _map_position(definition: Dictionary, order_index: int) -> Vector2:
	var raw_position: Variant = definition.get("map_position", [])
	if raw_position is Array and raw_position.size() == 2:
		return Vector2(clampf(float(raw_position[0]), 0.10, 0.90), clampf(float(raw_position[1]), 0.10, 0.90))
	var fallback_x := 0.16 + float((order_index - 1) % 4) * 0.22
	var fallback_y := 0.18 + float((order_index - 1) / 4) * 0.28
	return Vector2(fallback_x, fallback_y)


func _panel_style(background: Color, border: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(background.r, background.g, background.b, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 8
	return style


func _apply_button_style(button: Button, background: Color, border: Color) -> void:
	var style := _panel_style(background, border, 0.94)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = background.lightened(0.12)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
