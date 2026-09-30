class_name LevelButton
extends Button

## Reusable presentation-only level node for IslandMapScene.
## CampaignManager remains the authority for unlock, completion, and stars.

signal level_selected(level_id: int)

const STATE_LOCKED := "LOCKED"
const STATE_OPEN := "OPEN"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"
const VIP_MARKER_TEXTURE_PATH := "res://assets/ui_assets/ui/gameplay/vip_badge.png"
const VIP_MARKER_TEXTURE := preload(VIP_MARKER_TEXTURE_PATH)
const VIP_MARKER_SIZE := Vector2(36.0, 36.0)

var island_id := ""
var level_id := 0
var level_state := STATE_LOCKED
var earned_stars := 0
var best_score := 0
var milestone := false
var vip_enabled := false
var _vip_marker: TextureRect


func _ready() -> void:
	custom_minimum_size = Vector2(116.0, 112.0)
	size = custom_minimum_size
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_vip_marker()
	pressed.connect(_on_pressed)


func configure(
		configured_island_id: String,
	configured_level_id: int,
	configured_state: String,
	configured_stars: int,
	configured_milestone: bool,
	configured_vip: bool = false,
	configured_best_score: int = 0
	) -> void:
	island_id = configured_island_id
	level_id = configured_level_id
	level_state = configured_state
	earned_stars = clampi(configured_stars, 0, 3)
	best_score = maxi(0, configured_best_score)
	milestone = configured_milestone
	vip_enabled = configured_vip
	disabled = level_state == STATE_LOCKED
	if _vip_marker != null:
		_vip_marker.visible = vip_enabled
	tooltip_text = "Level %d%s\nBest score: %d" % [level_id, " milestone" if milestone else "", best_score]
	text = _display_text()
	_apply_style()


func try_select() -> bool:
	if level_state == STATE_LOCKED or disabled:
		return false
	level_selected.emit(level_id)
	return true


func is_selectable() -> bool:
	return level_state != STATE_LOCKED and not disabled


func get_state() -> String:
	return level_state


func get_stars() -> int:
	return earned_stars


func get_best_score() -> int:
	return best_score


func is_milestone() -> bool:
	return milestone


func is_vip() -> bool:
	return vip_enabled


func is_vip_marker_visible() -> bool:
	return _vip_marker != null and _vip_marker.visible


func _on_pressed() -> void:
	try_select()


func _build_vip_marker() -> void:
	_vip_marker = TextureRect.new()
	_vip_marker.name = "VipCrownMarker"
	_vip_marker.position = Vector2(118.0, 2.0)
	_vip_marker.custom_minimum_size = VIP_MARKER_SIZE
	_vip_marker.size = VIP_MARKER_SIZE
	_vip_marker.texture = VIP_MARKER_TEXTURE
	_vip_marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vip_marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_vip_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vip_marker.tooltip_text = "VIP opportunity"
	_vip_marker.z_index = 3
	_vip_marker.visible = vip_enabled
	add_child(_vip_marker)


func _display_text() -> String:
	var stars := ""
	for index in range(3):
		stars += "★" if index < earned_stars else "☆"
	var marker := "  ◆" if milestone else ""
	return "L%d%s\n%s\nBEST %d\n%s" % [level_id, marker, stars, best_score, level_state]


func _apply_style() -> void:
	var fill := Color("#173f54")
	var border := Color("#5cb8b0")
	var font := Color("#f9f1cf")
	if level_state == STATE_LOCKED:
		fill = Color("#233542")
		border = Color("#64717b")
		font = Color("#a4afb4")
	elif level_state == STATE_CURRENT:
		fill = Color("#725124")
		border = Color("#ffd166")
	elif level_state == STATE_COMPLETE:
		fill = Color("#245746")
		border = Color("#8be0a8")
	add_theme_font_size_override("font_size", 15)
	add_theme_color_override("font_color", font)
	add_theme_color_override("font_hover_color", font)
	add_theme_color_override("font_pressed_color", font)
	add_theme_color_override("font_disabled_color", font)
	add_theme_stylebox_override("normal", _style(fill, border))
	add_theme_stylebox_override("hover", _style(fill.lightened(0.10), border, 3.0))
	add_theme_stylebox_override("pressed", _style(fill.darkened(0.08), border, 4.0))
	add_theme_stylebox_override("disabled", _style(fill, border.darkened(0.15)))


func _style(fill: Color, border: Color, width: float = 2.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(int(width))
	style.set_corner_radius_all(18)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
