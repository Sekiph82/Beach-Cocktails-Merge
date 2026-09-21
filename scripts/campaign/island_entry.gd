class_name IslandEntry
extends Button

## Reusable spatial island marker. It renders a supplied campaign definition and
## state; unlock decisions remain owned by CampaignManager.

signal island_pressed(island_id: String)

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"

const MARKER_SIZE := Vector2(136.0, 164.0)
const ART_RECT := Rect2(10.0, 0.0, 116.0, 116.0)
const LOCKED_OVERLAY_PATH := "res://assets/ui_assets/campaign/world_map/island_locked_overlay.png"

var island_id := ""
var island_state := STATE_LOCKED
var island_definition: Dictionary = {}
var locked_reason := ""
var progress_text := ""

var _island_art: TextureRect
var _lock_overlay: TextureRect
var _name_label: Label
var _state_label: Label
var _selection_ring: Panel


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = MARKER_SIZE
	size = MARKER_SIZE
	flat = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)
	_build_content()
	_refresh_visuals()


func configure(definition: Dictionary, state: String, reason: String, progress: String) -> void:
	island_definition = definition.duplicate(true)
	island_id = str(island_definition.get("id", ""))
	island_state = state
	locked_reason = reason
	progress_text = progress
	if is_node_ready():
		_refresh_visuals()


func set_entry_state(state: String, reason: String, progress: String) -> void:
	island_state = state
	locked_reason = reason
	progress_text = progress
	_refresh_visuals()


func is_selectable() -> bool:
	return island_state != STATE_LOCKED and not island_id.is_empty()


func _build_content() -> void:
	_selection_ring = Panel.new()
	_selection_ring.name = "SelectionRing"
	_selection_ring.position = Vector2(2.0, 2.0)
	_selection_ring.size = Vector2(132.0, 132.0)
	_selection_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_selection_ring)

	_island_art = TextureRect.new()
	_island_art.name = "IslandArt"
	_island_art.position = ART_RECT.position
	_island_art.size = ART_RECT.size
	_island_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_island_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_island_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_island_art)

	_lock_overlay = TextureRect.new()
	_lock_overlay.name = "LockOverlay"
	_lock_overlay.position = Vector2(24.0, 34.0)
	_lock_overlay.size = Vector2(88.0, 52.0)
	_lock_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lock_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lock_overlay.texture = load(LOCKED_OVERLAY_PATH)
	_lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lock_overlay)

	_name_label = Label.new()
	_name_label.name = "IslandName"
	_name_label.position = Vector2(0.0, 113.0)
	_name_label.size = Vector2(MARKER_SIZE.x, 25.0)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_label)

	_state_label = Label.new()
	_state_label.name = "IslandState"
	_state_label.position = Vector2(0.0, 138.0)
	_state_label.size = Vector2(MARKER_SIZE.x, 22.0)
	_state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_state_label.add_theme_font_size_override("font_size", 11)
	_state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_state_label)


func _refresh_visuals() -> void:
	if _name_label == null or island_id.is_empty():
		return
	var display_name := str(island_definition.get("display_name", island_id))
	var asset_path := str(island_definition.get("map_asset", ""))
	if asset_path.is_empty():
		asset_path = "res://assets/ui_assets/campaign/world_map/%s.png" % island_id
	_island_art.texture = load(asset_path)
	_name_label.text = display_name
	_name_label.modulate = Color("#fff5d6") if island_state != STATE_LOCKED else Color("#c4d0d2")
	_state_label.text = "CURRENT • OPEN" if island_state == STATE_CURRENT else island_state
	_state_label.modulate = _state_color()
	_lock_overlay.visible = island_state == STATE_LOCKED
	_island_art.modulate = Color("#596f78") if island_state == STATE_LOCKED else Color.WHITE
	disabled = false
	_apply_style()
	queue_redraw()


func _state_color() -> Color:
	match island_state:
		STATE_CURRENT:
			return Color("#ffd166")
		STATE_OPEN:
			return Color("#68e0c7")
		STATE_COMPLETE:
			return Color("#c7a8ff")
		_:
			return Color("#8b9aa2")


func _apply_style() -> void:
	var clear := StyleBoxFlat.new()
	clear.bg_color = Color(0, 0, 0, 0)
	clear.set_border_width_all(0)
	add_theme_stylebox_override("normal", clear)
	add_theme_stylebox_override("pressed", clear)
	add_theme_stylebox_override("disabled", clear)
	add_theme_stylebox_override("hover", clear)
	var ring := StyleBoxFlat.new()
	ring.bg_color = Color(0, 0, 0, 0)
	ring.border_color = _state_color()
	ring.set_border_width_all(4 if island_state == STATE_CURRENT else 2)
	ring.set_corner_radius_all(66)
	ring.shadow_color = Color(0, 0, 0, 0.25)
	ring.shadow_size = 8
	_selection_ring.add_theme_stylebox_override("panel", ring)


func _draw() -> void:
	var center := Vector2(MARKER_SIZE.x * 0.5, 58.0)
	if island_state == STATE_CURRENT:
		draw_circle(center, 70.0, Color(1.0, 0.82, 0.34, 0.13))
		draw_arc(center, 70.0, 0.0, TAU, 64, Color(1.0, 0.84, 0.4, 0.72), 3.0, true)
	elif island_state == STATE_LOCKED:
		draw_circle(center, 61.0, Color(0.02, 0.10, 0.15, 0.24))
	else:
		draw_circle(center, 64.0, Color(0.1, 0.75, 0.72, 0.08))


func _on_pressed() -> void:
	island_pressed.emit(island_id)
