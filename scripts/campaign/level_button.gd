class_name LevelButton
extends Button

## Reusable presentation-only level node for IslandMapScene.
## CampaignManager remains the authority for unlock, completion, and stars.

signal level_selected(level_id: int)

const STATE_LOCKED := "LOCKED"
const STATE_OPEN := "OPEN"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"

var island_id := ""
var level_id := 0
var level_state := STATE_LOCKED
var earned_stars := 0
var milestone := false


func _ready() -> void:
	custom_minimum_size = Vector2(116.0, 112.0)
	size = custom_minimum_size
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)


func configure(
		configured_island_id: String,
		configured_level_id: int,
		configured_state: String,
		configured_stars: int,
		configured_milestone: bool
	) -> void:
	island_id = configured_island_id
	level_id = configured_level_id
	level_state = configured_state
	earned_stars = clampi(configured_stars, 0, 3)
	milestone = configured_milestone
	disabled = level_state == STATE_LOCKED
	tooltip_text = "Level %d%s" % [level_id, " milestone" if milestone else ""]
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


func is_milestone() -> bool:
	return milestone


func _on_pressed() -> void:
	try_select()


func _display_text() -> String:
	var stars := ""
	for index in range(3):
		stars += "★" if index < earned_stars else "☆"
	var marker := "  ◆" if milestone else ""
	return "L%d%s\n%s\n%s" % [level_id, marker, stars, level_state]


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
