class_name LevelButton
extends Button

## Reusable presentation-only level node for IslandMapScene.
## CampaignManager remains the authority for unlock, completion, and stars.

signal level_selected(level_id: int)

const STATE_LOCKED := "LOCKED"
const STATE_OPEN := "OPEN"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"
const NODE_TEXTURES := {
	STATE_LOCKED: "res://assets/ui_assets/campaign/island_map/level_node_locked.png",
	STATE_OPEN: "res://assets/ui_assets/campaign/island_map/level_node_unlocked.png",
	STATE_CURRENT: "res://assets/ui_assets/campaign/island_map/level_node_finale.png",
}
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
var _node_art: TextureRect
var _level_label: Label
var _stars_label: Label
var _score_label: Label
var _milestone_marker: TextureRect


func _ready() -> void:
	custom_minimum_size = Vector2(116.0, 112.0)
	size = custom_minimum_size
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	flat = true
	text = ""
	_build_node_art()
	_build_vip_marker()
	_update_labels()
	_node_art.texture = load(_texture_path_for_state()) as Texture2D
	_vip_marker.visible = vip_enabled
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
	_update_labels()
	if _node_art != null:
		_node_art.texture = load(_texture_path_for_state()) as Texture2D


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


func _build_node_art() -> void:
	_node_art = TextureRect.new()
	_node_art.name = "NodeArt"
	_node_art.position = Vector2(-14.0, -9.0)
	_node_art.size = Vector2(144.0, 81.0)
	_node_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_node_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_node_art.texture = load(_texture_path_for_state()) as Texture2D
	_node_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_node_art.z_index = 0
	add_child(_node_art)

	_level_label = _make_overlay_label("LevelNumber", Rect2(22.0, 22.0, 72.0, 28.0), 20, Color.WHITE)
	_stars_label = _make_overlay_label("EarnedStars", Rect2(8.0, 67.0, 100.0, 20.0), 16, Color("#ffd970"))
	_score_label = _make_overlay_label("BestScore", Rect2(5.0, 88.0, 106.0, 18.0), 11, Color("#fff3d2"))
	_milestone_marker = TextureRect.new()
	_milestone_marker.name = "MilestoneMarker"
	_milestone_marker.texture = load("res://assets/ui_assets/campaign/island_map/milestone_chest_marker.png") as Texture2D
	_milestone_marker.position = Vector2(98.0, -2.0)
	_milestone_marker.size = Vector2(18.0, 18.0)
	_milestone_marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_milestone_marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_milestone_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_milestone_marker.z_index = 3
	_milestone_marker.visible = false
	add_child(_milestone_marker)


func _make_overlay_label(label_name: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = label_name
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.05, 0.13, 0.16, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 2
	add_child(label)
	return label


func _texture_path_for_state() -> String:
	if level_state == STATE_COMPLETE:
		match earned_stars:
			0: return "res://assets/ui_assets/campaign/island_map/level_node_completed.png"
			1: return "res://assets/ui_assets/campaign/island_map/level_node_current.png"
			2: return "res://assets/ui_assets/campaign/island_map/level_node_two_star.png"
			_: return "res://assets/ui_assets/campaign/island_map/level_node_milestone.png"
	return str(NODE_TEXTURES.get(level_state, NODE_TEXTURES[STATE_LOCKED]))


func _update_labels() -> void:
	if _level_label == null:
		return
	_level_label.text = "L%d" % level_id
	var stars := ""
	for index in range(3):
		stars += "★" if index < earned_stars else "☆"
	_stars_label.text = stars
	_score_label.text = "BEST %d" % best_score if best_score > 0 else ("MILESTONE" if milestone else "")
	if _milestone_marker != null:
		_milestone_marker.visible = milestone


func get_skin_path() -> String:
	return _texture_path_for_state()
