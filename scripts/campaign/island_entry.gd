class_name IslandEntry
extends Button

## A visible island body is also its mouse/touch target. Its center, rendered
## dimensions, and label offset all come from the island's single layout record.

signal island_pressed(island_id: String)

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"

var island_id := ""
var island_state := STATE_LOCKED
var island_definition: Dictionary = {}
var locked_reason := ""
var progress_text := ""

var _island_art: TextureRect
var _name_panel: Panel
var _number_badge: Panel
var _number_label: Label
var _name_label: Label
var _state_label: Label
var _selection_ring: Panel
var _layout_scale := 1.0
var _base_size := Vector2(180.0, 180.0)
var _base_label_offset := Vector2(0.0, 72.0)
var _base_label_size := Vector2(150.0, 40.0)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	flat = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_add_transparent_button_styles()
	pressed.connect(_on_pressed)
	_build_content()
	_refresh_visuals()


func configure(definition: Dictionary, state: String, reason: String, progress: String) -> void:
	island_definition = definition.duplicate(true)
	island_id = str(island_definition.get("id", ""))
	island_state = state
	locked_reason = reason
	progress_text = progress
	_read_layout()
	if is_node_ready():
		apply_layout(_layout_scale)
		_refresh_visuals()


func apply_layout(scale_factor: float = 1.0) -> void:
	_layout_scale = scale_factor
	size = _base_size * scale_factor
	custom_minimum_size = size
	if _selection_ring != null:
		var ring_margin := (25.0 if island_state == STATE_CURRENT else 12.0) * scale_factor
		_selection_ring.position = Vector2(-ring_margin, -ring_margin)
		_selection_ring.size = size + Vector2.ONE * ring_margin * 2.0
	if _island_art != null:
		_island_art.position = Vector2.ZERO
		_island_art.size = size
	if _name_panel != null:
		var label_size := _base_label_size * scale_factor
		var label_center := size * 0.5 + _base_label_offset * scale_factor
		_name_panel.position = label_center - label_size * 0.5
		_name_panel.size = label_size
		_number_badge.position = Vector2(8.0, (label_size.y - 22.0 * scale_factor) * 0.5)
		_number_badge.size = Vector2.ONE * 22.0 * scale_factor
		_number_label.position = _number_badge.position
		_number_label.size = _number_badge.size
		_name_label.position = Vector2(30.0, 1.0) * scale_factor
		_name_label.size = Vector2(label_size.x - 34.0 * scale_factor, label_size.y * 0.55)
		_state_label.position = Vector2(30.0, 19.0) * scale_factor
		_state_label.size = Vector2(_name_label.size.x, label_size.y * 0.34)


func set_entry_state(state: String, reason: String, progress: String) -> void:
	island_state = state
	locked_reason = reason
	progress_text = progress
	_refresh_visuals()


func is_selectable() -> bool:
	return island_state != STATE_LOCKED and not island_id.is_empty()


func get_art_global_rect() -> Rect2:
	return _island_art.get_global_rect() if _island_art != null else get_global_rect()


func get_label_global_rect() -> Rect2:
	return _name_panel.get_global_rect() if _name_panel != null else Rect2()


func _read_layout() -> void:
	var presentation: Dictionary = island_definition.get("world_map_layout", {})
	var raw_size: Array = presentation.get("render_size", [180.0, 180.0])
	var raw_offset: Array = presentation.get("label_offset", [0.0, 72.0])
	var raw_label_size: Array = presentation.get("label_size", [150.0, 40.0])
	if raw_size.size() == 2:
		_base_size = Vector2(float(raw_size[0]), float(raw_size[1]))
	if raw_offset.size() == 2:
		_base_label_offset = Vector2(float(raw_offset[0]), float(raw_offset[1]))
	if raw_label_size.size() == 2:
		_base_label_size = Vector2(float(raw_label_size[0]), float(raw_label_size[1]))


func _build_content() -> void:
	_selection_ring = Panel.new()
	_selection_ring.name = "SelectionRing"
	_selection_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_selection_ring)

	_island_art = TextureRect.new()
	_island_art.name = "IslandArt"
	_island_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_island_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_island_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_island_art)

	_name_panel = Panel.new()
	_name_panel.name = "IslandNamePanel"
	_name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_panel)
	_number_badge = Panel.new()
	_number_badge.name = "IslandNumberBadge"
	_number_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_panel.add_child(_number_badge)
	_number_label = Label.new()
	_number_label.name = "IslandNumber"
	_number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_number_label.add_theme_font_size_override("font_size", 9)
	_number_label.add_theme_color_override("font_color", Color("#173a42"))
	_number_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_panel.add_child(_number_label)

	_name_label = Label.new()
	_name_label.name = "IslandName"
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color("#fff2d3"))
	_name_label.add_theme_color_override("font_shadow_color", Color("#092c38"))
	_name_label.add_theme_constant_override("shadow_offset_x", 1)
	_name_label.add_theme_constant_override("shadow_offset_y", 1)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_panel.add_child(_name_label)

	_state_label = Label.new()
	_state_label.name = "IslandState"
	_state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_state_label.add_theme_font_size_override("font_size", 8)
	_state_label.add_theme_color_override("font_color", Color("#c8e8e4"))
	_state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_panel.add_child(_state_label)


func _refresh_visuals() -> void:
	if _name_label == null or island_id.is_empty():
		return
	var display_name := str(island_definition.get("display_name", island_id)).to_upper()
	var asset_path := str(island_definition.get("map_asset", ""))
	if asset_path.is_empty():
		asset_path = "res://assets/ui_assets/campaign/world_map/%s.png" % island_id
	_island_art.texture = load(asset_path)
	_island_art.visible = true
	_name_label.text = display_name.replace(" (TBD)", "")
	_state_label.text = "START HERE" if island_state == STATE_CURRENT else island_state
	_number_label.text = "%02d" % int(island_definition.get("order_index", 0))
	_name_label.add_theme_font_size_override("font_size", 12 if display_name.length() < 14 else 9)
	var locked := island_state == STATE_LOCKED
	_island_art.modulate = Color(0.78, 0.86, 0.88) if locked else Color.WHITE
	_selection_ring.visible = island_state == STATE_CURRENT or island_state == STATE_OPEN
	_selection_ring.add_theme_stylebox_override("panel", _ring_style(island_state))
	_name_panel.add_theme_stylebox_override("panel", _label_style(island_state))
	_number_badge.add_theme_stylebox_override("panel", _badge_style(island_state))
	tooltip_text = "%s — %s" % [display_name, island_state]
	disabled = false


func _ring_style(state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.76, 0.28, 0.06) if state == STATE_CURRENT else Color(0.36, 0.86, 0.78, 0.035)
	style.border_color = Color(1.0, 0.83, 0.43, 0.45) if state == STATE_CURRENT else Color(0.55, 0.9, 0.86, 0.28)
	style.set_border_width_all(3 if state == STATE_CURRENT else 2)
	style.set_corner_radius_all(120)
	style.shadow_color = Color(0.03, 0.18, 0.24, 0.22)
	style.shadow_size = 5
	return style


func _label_style(state: String) -> StyleBoxFlat:
	var current := state == STATE_CURRENT or state == STATE_OPEN
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1f525b") if current else Color("#0d3446")
	style.border_color = Color("#ffda7c") if current else Color("#b1d3cb")
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.shadow_color = Color(0.0, 0.08, 0.13, 0.62)
	style.shadow_size = 4
	return style


func _badge_style(state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#f4c152") if state == STATE_CURRENT or state == STATE_OPEN else Color("#68a7ac")
	style.border_color = Color("#fff6d3")
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	return style


func _add_transparent_button_styles() -> void:
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color(0, 0, 0, 0)
	button_mask = MOUSE_BUTTON_MASK_LEFT
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(style_name, empty)


func _on_pressed() -> void:
	island_pressed.emit(island_id)
