class_name WorldMapController
extends Control

## Runtime composition for the owner-approved World Map. CampaignManager remains
## the authority for unlock state and island selection; this controller owns only
## presentation and emits the existing navigation boundary.

signal island_selected(island_id: String)
signal island_map_requested(island_id: String)
signal locked_island_feedback(island_id: String, reason: String, progress: String)
signal return_requested

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"
const CANONICAL_SIZE := Vector2(720.0, 1280.0)

const MAP_BACKGROUND := preload("res://assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png")
const CLOUDS_BACK := preload("res://assets/ui_assets/campaign/world_map/world_clouds_back.png")
const CLOUDS_FRONT := preload("res://assets/ui_assets/campaign/world_map/world_clouds_front.png")
const ROUTE_LINE := preload("res://assets/ui_assets/campaign/world_map/route_line.png")
const TITLE_PANEL := preload("res://assets/ui_assets/campaign/world_map/world_map_title_panel.png")
const COMPASS := preload("res://assets/ui_assets/campaign/world_map/world_map_compass.png")
const BOAT := preload("res://assets/ui_assets/campaign/world_map/world_map_boat.png")
const CARD_SCENE := preload("res://scenes/campaign/IslandEntry.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const FEEDBACK_SCENE := preload("res://scripts/campaign/campaign_feedback_overlay.gd")
const FEEDBACK_SERVICE_SCRIPT := preload("res://scripts/feedback_service.gd")
const PRESENTATION_BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")

var level_database
var campaign_manager
var selected_island_id := ""
var last_locked_feedback: Dictionary = {}
var _ordered_ids: Array[String] = []
var _definitions_by_id: Dictionary = {}
var _entries: Dictionary = {}
var _refresh_queued := false

var _map_canvas: Control
var _marker_layer: Control
var _route_layer: Control
var _feedback_overlay: CampaignFeedbackOverlay
var _feedback_service: FeedbackService
var _presentation_bridge: PresentationFeedbackBridge
var _pending_campaign_transition: Dictionary = {}


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


func set_presentation_mode(mode: String) -> bool:
	return _presentation_bridge != null and _presentation_bridge.set_presentation_mode(mode)


func present_campaign_transition(transition: Dictionary) -> bool:
	if transition.is_empty() or campaign_manager == null:
		return false
	_pending_campaign_transition = transition.duplicate(true)
	refresh()
	call_deferred("_flush_pending_campaign_transition")
	return true


func refresh() -> void:
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
		var island_art := entry.get_node_or_null("IslandArt") as CanvasItem
		if island_art != null and not island_art.is_in_group("presentation_effect_target"):
			island_art.add_to_group("presentation_effect_target")
		var island_name := entry.get_node_or_null("IslandNamePanel") as CanvasItem
		if island_name != null and not island_name.is_in_group("presentation_effect_target"):
			island_name.add_to_group("presentation_effect_target")
		entry.island_pressed.connect(_on_island_pressed)
		_entries[island_id] = entry
		_definitions_by_id[island_id] = definition
		_ordered_ids.append(island_id)

	if selected_island_id.is_empty():
		selected_island_id = campaign_manager.current_island_id
	_layout_map()
	call_deferred("_layout_map")
	call_deferred("_flush_pending_campaign_transition")


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


func get_entry(island_id: String) -> Control:
	return _entries.get(island_id) as Control


func get_locked_feedback() -> Dictionary:
	return last_locked_feedback.duplicate(true)


func get_feedback_overlay():
	return _feedback_overlay


func get_visual_marker_count() -> int:
	return _entries.size()


func get_map_node_count() -> int:
	return _marker_layer.get_child_count() if _marker_layer != null else 0


func get_marker_position(island_id: String) -> Vector2:
	var entry: Control = _entries.get(island_id) as Control
	return entry.position + entry.size * 0.5 if entry != null else Vector2(-1.0, -1.0)


func get_hotspot_center_report() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for island_id in _ordered_ids:
		var definition: Dictionary = _definitions_by_id.get(island_id, {})
		var entry: Control = _entries.get(island_id) as Control
		if entry == null:
			continue
		var center := entry.position + entry.size * 0.5
		result.append({
			"island_id": island_id,
			"map_position": definition.get("map_position", []),
			"map_canvas_center": center,
			"screen_center": _map_canvas.position + center,
			"source": "data/campaign/islands.json map_position",
		})
	return result


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
		locked_island_feedback.emit(island_id, last_locked_feedback["reason"], last_locked_feedback["progress"])
		if _feedback_overlay != null:
			_feedback_overlay.show_locked_island(last_locked_feedback["reason"], last_locked_feedback["progress"])
		return false
	if not campaign_manager.select_island(island_id):
		return false
	selected_island_id = island_id
	if _feedback_overlay != null:
		_feedback_overlay.hide_feedback()
	island_selected.emit(island_id)
	island_map_requested.emit(island_id)
	refresh()
	return true


func get_layout_report(reference_size: Vector2 = CANONICAL_SIZE) -> Dictionary:
	var report := {
		"reference_size": reference_size,
		"entry_count": _entries.size(),
		"visual_marker_count": _entries.size(),
		"horizontal_clipping": false,
		"vertical_clipping": false,
		"overlap": false,
		"header_overlap": false,
		"header_controls_fit": true,
		"status_overlap": false,
		"selection_boundary_overlap": false,
		"navigation_overlap": false,
		"entries_fit_width": true,
		"map_fills_viewport": _map_canvas != null,
		"duplicate_nodes": get_map_node_count() != _entries.size(),
		"islands": [],
	}
	if _map_canvas == null or _entries.is_empty():
		return report
	var viewport_rect := Rect2(Vector2.ZERO, reference_size)
	var header: Control = get_node("Header") as Control
	var header_rects: Array[Rect2] = [
		(header.get_node("BackButton") as Control).get_global_rect(),
		(header.get_node("TitlePanel") as Control).get_global_rect(),
		(header.get_node("Compass") as Control).get_global_rect(),
	]
	for control_rect in header_rects:
		if control_rect.position.x < 0.0 or control_rect.position.y < 0.0 or control_rect.end.x > reference_size.x or control_rect.end.y > reference_size.y:
			report["header_controls_fit"] = false
	var previous: Array[Rect2] = []
	var island_reports: Array[Dictionary] = []
	for island_id in _ordered_ids:
		var definition: Dictionary = _definitions_by_id.get(island_id, {})
		var entry: IslandEntry = _entries[island_id] as IslandEntry
		var hit_rect := entry.get_global_rect()
		if hit_rect.position.x < 0.0 or hit_rect.end.x > reference_size.x:
			report["horizontal_clipping"] = true
			report["entries_fit_width"] = false
		if hit_rect.position.y < 0.0 or hit_rect.end.y > reference_size.y:
			report["vertical_clipping"] = true
		for other in previous:
			if hit_rect.intersects(other):
				report["overlap"] = true
		previous.append(hit_rect)
		var art_rect := entry.get_art_global_rect()
		var label_rect := entry.get_label_global_rect()
		if label_rect.position.x < 0.0 or label_rect.end.x > reference_size.x:
			report["horizontal_clipping"] = true
		if label_rect.position.y < 0.0 or label_rect.end.y > reference_size.y:
			report["vertical_clipping"] = true
		for header_rect in header_rects:
			if hit_rect.intersects(header_rect) or label_rect.intersects(header_rect):
				report["header_overlap"] = true
		var center := art_rect.get_center()
		var expected_layout: Dictionary = definition.get("world_map_layout", {})
		var expected_position: Array = definition.get("map_position", [0.0, 0.0])
		var expected_center := Vector2(float(expected_position[0]) * CANONICAL_SIZE.x, float(expected_position[1]) * CANONICAL_SIZE.y)
		var expected_size: Array = expected_layout.get("render_size", [entry.size.x, entry.size.y])
		island_reports.append({
			"id": island_id,
			"source_png": str(definition.get("map_asset", "")),
			"expected_center": _vec_json(expected_center),
			"expected_size": _vec_json(Vector2(float(expected_size[0]), float(expected_size[1]))),
			"actual_center": _vec_json(center),
			"actual_size": _vec_json(art_rect.size),
			"hit_rect": _rect_json(hit_rect),
			"label_rect": _rect_json(label_rect),
			"route_anchor": _vec_json(center),
			"state": entry.island_state,
			"center_delta": _vec_json(center - expected_center),
			"size_delta": _vec_json(art_rect.size - Vector2(float(expected_size[0]), float(expected_size[1]))),
			"overlap": false,
			"clipped": hit_rect.position.x < 0.0 or hit_rect.position.y < 0.0 or hit_rect.end.x > reference_size.x or hit_rect.end.y > reference_size.y or label_rect.position.x < 0.0 or label_rect.position.y < 0.0 or label_rect.end.x > reference_size.x or label_rect.end.y > reference_size.y,
		})
	report["islands"] = island_reports
	report["navigation_overlap"] = bool(report["status_overlap"]) or bool(report["selection_boundary_overlap"])
	return report


func _build_shell() -> void:
	_feedback_service = FEEDBACK_SERVICE_SCRIPT.new() as FeedbackService
	_feedback_service.name = "WorldMapFeedbackService"
	add_child(_feedback_service)
	_presentation_bridge = PRESENTATION_BRIDGE_SCRIPT.new() as PresentationFeedbackBridge
	_presentation_bridge.name = "WorldMapPresentationFeedbackBridge"
	add_child(_presentation_bridge)
	_presentation_bridge.configure(_feedback_service, get_tree().root)
	_presentation_bridge.set_presentation_mode("FULL")
	_presentation_bridge.set_production_dispatch_enabled(true)
	_presentation_bridge.set_visual_diagnostics_enabled(true)
	var background := TextureRect.new()
	background.name = "WorldMapBackground"
	background.texture = MAP_BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = -10
	add_child(background)

	_map_canvas = Control.new()
	_map_canvas.name = "MapCanvas"
	_map_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_map_canvas)

	_route_layer = Control.new()
	_route_layer.name = "RouteLayer"
	_route_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_route_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_route_layer.z_index = 1
	_map_canvas.add_child(_route_layer)

	var boat := TextureRect.new()
	boat.name = "MapBoat"
	boat.texture = BOAT
	boat.position = Vector2(282.5, 357.5)
	boat.size = Vector2(115.0, 65.0)
	boat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	boat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	boat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boat.z_index = 2
	_map_canvas.add_child(boat)
	boat.size = Vector2(115.0, 65.0)

	_marker_layer = Control.new()
	_marker_layer.name = "IslandMarkers"
	_marker_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_marker_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_marker_layer.z_index = 3
	_map_canvas.add_child(_marker_layer)

	_add_cloud(CLOUDS_BACK, Rect2(0.0, 8.0, 126.0, 146.0), Vector2(23.0, 316.0), Vector2(126.0, 146.0), "CloudsBack", 4, 0.74)
	_add_cloud(CLOUDS_FRONT, Rect2(205.0, 12.0, 115.0, 146.0), Vector2(640.5, 243.0), Vector2(115.0, 146.0), "CloudsFront", 5, 0.74)

	var header := Control.new()
	header.name = "Header"
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 160.0
	header.mouse_filter = Control.MOUSE_FILTER_PASS
	header.z_index = 8
	add_child(header)

	var back := Button.new()
	back.name = "BackButton"
	back.text = "‹"
	back.position = Vector2(20.0, 53.0)
	back.size = Vector2(68.0, 68.0)
	back.add_theme_font_size_override("font_size", 48)
	back.tooltip_text = "Return"
	back.pressed.connect(func() -> void: return_requested.emit())
	_apply_button_style(back, Color("#12354d"), Color("#f7d47b"))
	header.add_child(back)

	var title_panel := TextureRect.new()
	title_panel.name = "TitlePanel"
	title_panel.texture = TITLE_PANEL
	title_panel.position = Vector2(110.0, 30.0)
	title_panel.size = Vector2(500.0, 120.0)
	title_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(title_panel)
	_add_title_label(header, "WORLD MAP", Vector2(180.0, 48.0), Vector2(360.0, 28.0), 15, Color("#bff5e7"))
	_add_title_label(header, "ISLAND JOURNEY", Vector2(160.0, 72.0), Vector2(400.0, 42.0), 29, Color("#fff0c1"))
	_add_title_label(header, "FOLLOW THE TROPICAL ROUTE", Vector2(175.0, 113.0), Vector2(370.0, 22.0), 12, Color("#ddf9e8"))

	var compass := TextureRect.new()
	compass.name = "Compass"
	compass.texture = COMPASS
	compass.position = Vector2(618.0, 47.0)
	compass.size = Vector2(82.0, 82.0)
	compass.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	compass.stretch_mode = TextureRect.STRETCH_SCALE
	compass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(compass)
	compass.size = Vector2(82.0, 82.0)

	_build_route()
	_feedback_overlay = FEEDBACK_SCENE.new()
	_feedback_overlay.name = "CampaignFeedbackOverlay"
	_feedback_overlay.action_requested.connect(_on_feedback_action)
	add_child(_feedback_overlay)


func _add_title_label(parent: Control, value: String, label_position: Vector2, label_size: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("#082a38"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)


func _add_cloud(source: Texture2D, region: Rect2, center: Vector2, cloud_size: Vector2, node_name: String, order: int, opacity: float) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	var cloud := TextureRect.new()
	cloud.name = node_name
	cloud.texture = atlas
	cloud.position = center - cloud_size * 0.5
	cloud.size = cloud_size
	cloud.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cloud.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cloud.modulate = Color(1.0, 1.0, 1.0, opacity)
	cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloud.z_index = order
	var feather_shader := Shader.new()
	feather_shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 color = texture(TEXTURE, UV) * COLOR;
	float edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	color.a *= smoothstep(0.0, 0.22, edge);
	COLOR = color;
}
"""
	var feather_material := ShaderMaterial.new()
	feather_material.shader = feather_shader
	cloud.material = feather_material
	_map_canvas.add_child(cloud)
	cloud.position = center - cloud_size * 0.5
	cloud.size = cloud_size


func _build_route() -> void:
	for child in _route_layer.get_children():
		child.queue_free()
	if level_database == null:
		return
	var definitions: Array[Dictionary] = []
	for island_id in level_database.get_island_ids():
		definitions.append(level_database.get_island(island_id))
	definitions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order_index", 0)) < int(b.get("order_index", 0))
	)
	var previous_center := Vector2.ZERO
	var has_previous := false
	for definition in definitions:
		var center := _canonical_center(definition)
		if has_previous:
			var segment := TextureRect.new()
			segment.name = "Route_%02d_%s" % [int(definition.get("order_index", 0)), str(definition.get("id", ""))]
			segment.texture = ROUTE_LINE
			var delta := center - previous_center
			var length := delta.length()
			segment.size = Vector2(length + 40.0, 19.0)
			segment.position = (center + previous_center) * 0.5 - segment.size * 0.5
			segment.rotation = delta.angle()
			segment.pivot_offset = segment.size * 0.5
			segment.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			segment.stretch_mode = TextureRect.STRETCH_SCALE
			segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_route_layer.add_child(segment)
			segment.size = Vector2(length + 40.0, 19.0)
		previous_center = center
		has_previous = true


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


func _flush_pending_campaign_transition() -> void:
	if _pending_campaign_transition.is_empty() or campaign_manager == null or not is_instance_valid(_presentation_bridge):
		return
	if _entries.size() != _ordered_ids.size() or _entries.is_empty():
		return
	var token := str(_pending_campaign_transition.get("transition_token", ""))
	if token.is_empty():
		return
	var unlock_ids: Array = _pending_campaign_transition.get("newly_unlocked_islands", [])
	for island_id_value in unlock_ids:
		var island_id := str(island_id_value)
		if not campaign_manager.is_island_unlocked(island_id):
			continue
		var entry: Node = _entries.get(island_id)
		var target := entry.get_node_or_null("IslandArt") if is_instance_valid(entry) else null
		if is_instance_valid(target):
			_feedback_service.request_semantic("island_unlock", {
				"island_id": island_id,
				"new_transition": true,
				"presentation_target": target,
			}, "%s:island-unlock:%s" % [token, island_id], {"source": "campaign_world_map"})
	_pending_campaign_transition.clear()


func _on_feedback_action(action: String) -> void:
	if action == "DISMISS" and _feedback_overlay != null:
		_feedback_overlay.hide_feedback()


func _state_for(island_id: String, unlocked: bool) -> String:
	if campaign_manager.is_island_complete(island_id):
		return STATE_COMPLETE
	if campaign_manager.current_island_id == island_id:
		return STATE_CURRENT
	return STATE_OPEN if unlocked else STATE_LOCKED


func _on_island_pressed(island_id: String) -> void:
	select_island(island_id)


func _layout_map() -> void:
	if _map_canvas == null:
		return
	var viewport_size := _map_canvas.size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = CANONICAL_SIZE
	var scale_factor := minf(viewport_size.x / CANONICAL_SIZE.x, viewport_size.y / CANONICAL_SIZE.y)
	var letterbox := (viewport_size - CANONICAL_SIZE * scale_factor) * 0.5
	for island_id in _ordered_ids:
		var definition: Dictionary = _definitions_by_id.get(island_id, {})
		var entry: IslandEntry = _entries.get(island_id) as IslandEntry
		if entry == null:
			continue
		var center := _canonical_center(definition) * scale_factor + letterbox
		entry.apply_layout(scale_factor)
		entry.position = center - entry.size * 0.5
	_build_route()


func _canonical_center(definition: Dictionary) -> Vector2:
	var raw_position: Variant = definition.get("map_position", [])
	if raw_position is Array and raw_position.size() == 2:
		return Vector2(float(raw_position[0]) * CANONICAL_SIZE.x, float(raw_position[1]) * CANONICAL_SIZE.y)
	var order_index := int(definition.get("order_index", 1))
	return Vector2(110.0 + float((order_index - 1) % 4) * 155.0, 280.0 + float((order_index - 1) / 4) * 330.0)


func _panel_style(background: Color, border: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(background.r, background.g, background.b, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(34)
	style.shadow_color = Color(0, 0, 0, 0.32)
	style.shadow_size = 5
	return style


func _apply_button_style(button: Button, background: Color, border: Color) -> void:
	var style := _panel_style(background, border, 0.96)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = background.lightened(0.12)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)


func _vec_json(value: Vector2) -> Dictionary:
	return {"x": snappedf(value.x, 0.01), "y": snappedf(value.y, 0.01)}


func _rect_json(value: Rect2) -> Dictionary:
	return {"x": snappedf(value.position.x, 0.01), "y": snappedf(value.position.y, 0.01), "width": snappedf(value.size.x, 0.01), "height": snappedf(value.size.y, 0.01)}
