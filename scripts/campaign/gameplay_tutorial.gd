class_name GameplayTutorial
extends CanvasLayer

signal tutorial_completed
signal step_changed(step: int)

const STORAGE_PATH := "user://gameplay_tutorial_state.json"
const STEP_TITLES := ["LAUNCH", "MERGE", "DELIVER", "VIP BONUS", "MOVES & STARS", "PLAY AGAIN"]
const STEP_HINTS := [
	"Drag the glass into the board.",
	"Guide two matching drinks together.",
	"Match the highlighted To-Go drink.",
	"VIP adds a bonus; To-Go wins.",
	"T = ideal shots. A win earns 3★ under 2T, 2★ under 3T, else 1★.",
	"Tap RETRY on Results to replay.",
]

const VIP_BADGE_PATH := "res://assets/ui_assets/screens/tutorial/tutorial_vip_badge.png"
const STAR_PATH := "res://assets/ui_assets/ui/rewards/star_large_filled.png"

var current_step := 0
var completed := false
var reduced_motion := false
var high_contrast := false
var storage_path := STORAGE_PATH
var _panel: PanelContainer
var _highlight: ReferenceRect
var _secondary_highlight: ReferenceRect
var _label: Label
var _step_label: Label
var _guide: TutorialVisualGuide
var _advance_button: Button
var _skip_button: Button


class TutorialVisualGuide extends Control:
	var step_index := 0
	var reduced_motion := false
	var drink_level := 1
	var vip_enabled := true
	var _phase := 0.0
	var _primary_icon: TextureRect
	var _secondary_icon: TextureRect
	var _badge_icon: TextureRect

	func _ready() -> void:
		_primary_icon = _create_icon("PrimaryCocktail")
		_secondary_icon = _create_icon("MatchingCocktail")
		_badge_icon = _create_icon("TutorialBadge")
		refresh_art()

	func _process(delta: float) -> void:
		if not reduced_motion:
			_phase = fmod(_phase + delta * 2.2, TAU)
			queue_redraw()

	func _draw() -> void:
		var pulse := 0.5 + 0.5 * sin(_phase)
		var radius := minf(size.x, size.y) * (0.44 + pulse * 0.025)
		draw_circle(size * 0.5, radius, Color("#ffd166", 0.14))
		match step_index:
			0:
				_draw_arrow(size * Vector2(0.43, 0.36), size * Vector2(0.82, 0.14))
			1:
				draw_line(size * Vector2(0.35, 0.48), size * Vector2(0.65, 0.48), Color("#ffd166"), 3.0, true)
				_draw_arrow(size * Vector2(0.55, 0.40), size * Vector2(0.77, 0.40))
			2:
				_draw_arrow(size * Vector2(0.48, 0.44), size * Vector2(0.83, 0.20))
			3:
				if vip_enabled:
					draw_arc(size * Vector2(0.36, 0.48), minf(size.x, size.y) * 0.31, 0.2, TAU - 0.2, 24, Color("#ffd166"), 2.0, true)
			4:
				for index in range(3):
					var x := size.x * (0.22 + index * 0.28)
					draw_circle(Vector2(x, size.y * 0.82), minf(size.x, size.y) * 0.07, Color("#73e0d1"))

	func refresh_art() -> void:
		if not is_instance_valid(_primary_icon):
			return
		_primary_icon.texture = Drink.texture_for_level(clampi(drink_level, 1, 12))
		_secondary_icon.texture = Drink.texture_for_level(clampi(drink_level, 1, 12))
		_badge_icon.texture = null
		_primary_icon.visible = true
		_secondary_icon.visible = false
		match step_index:
			0:
				_set_icon(_primary_icon, Rect2(size.x * 0.04, size.y * 0.38, size.x * 0.50, size.y * 0.58))
			1:
				_set_icon(_primary_icon, Rect2(size.x * 0.02, size.y * 0.30, size.x * 0.45, size.y * 0.62))
				_set_icon(_secondary_icon, Rect2(size.x * 0.53, size.y * 0.30, size.x * 0.45, size.y * 0.62))
				_secondary_icon.visible = true
			2:
				_set_icon(_primary_icon, Rect2(size.x * 0.04, size.y * 0.37, size.x * 0.48, size.y * 0.58))
			3:
				_badge_icon.texture = load(VIP_BADGE_PATH) as Texture2D
				_set_icon(_badge_icon, Rect2(size.x * 0.02, size.y * 0.16, size.x * 0.50, size.y * 0.54))
				_set_icon(_primary_icon, Rect2(size.x * 0.46, size.y * 0.40, size.x * 0.50, size.y * 0.56))
			4:
				_badge_icon.texture = load(STAR_PATH) as Texture2D
				_set_icon(_badge_icon, Rect2(size.x * 0.20, size.y * 0.05, size.x * 0.60, size.y * 0.67))
				_primary_icon.visible = false
			5:
				_set_icon(_primary_icon, Rect2(size.x * 0.23, size.y * 0.18, size.x * 0.54, size.y * 0.70))
		queue_redraw()

	func _create_icon(icon_name: String) -> TextureRect:
		var icon := TextureRect.new()
		icon.name = icon_name
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		add_child(icon)
		return icon

	func _set_icon(icon: TextureRect, rect: Rect2) -> void:
		icon.position = rect.position
		icon.size = rect.size
		icon.visible = icon.texture != null

	func _draw_arrow(from: Vector2, to: Vector2) -> void:
		var bend := from.lerp(to, 0.55) + Vector2(0.0, -5.0)
		draw_line(from, bend, Color("#fff0c6"), 3.0, true)
		draw_line(bend, to, Color("#fff0c6"), 3.0, true)
		var direction := (to - bend).normalized()
		var normal := Vector2(-direction.y, direction.x)
		draw_colored_polygon(PackedVector2Array([to, to - direction * 8.0 + normal * 5.0, to - direction * 8.0 - normal * 5.0]), Color("#ffd166"))


func _ready() -> void:
	_load_state()
	_build_ui()
	visible = false


func _process(_delta: float) -> void:
	if visible:
		_update_highlights()


func start() -> bool:
	if completed:
		return false
	visible = true
	_save_state()
	_refresh()
	return true


func restart() -> bool:
	completed = false
	current_step = 0
	return start()


func on_shot_launched() -> void:
	if visible and current_step == 0:
		_set_step(1)


func on_merge() -> void:
	if visible and current_step == 1:
		_set_step(2)


func on_delivery() -> void:
	if visible and current_step == 2:
		_set_step(3)


func on_retry() -> void:
	if visible and current_step == 5:
		_finish()


func set_presentation_state(state: Dictionary) -> void:
	reduced_motion = bool(state.get("reduced_motion", false))
	high_contrast = bool(state.get("high_contrast", false))
	if is_instance_valid(_panel):
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#061522") if high_contrast else Color("#103d52")
		style.border_color = Color.WHITE if high_contrast else Color("#ffd166")
		style.set_border_width_all(4 if high_contrast else 2)
		style.set_corner_radius_all(15)
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
		style.shadow_size = 7
		_panel.add_theme_stylebox_override("panel", style)
		_label.add_theme_font_size_override("font_size", 15 if high_contrast else 14)
		_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color("#fff0c6"))
		_step_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color("#ffd166"))
	if is_instance_valid(_highlight):
		_highlight.border_color = Color.WHITE if high_contrast else Color("#ffd166")
		_highlight.border_width = 5.0 if high_contrast else 3.0
		_secondary_highlight.border_color = _highlight.border_color
		_secondary_highlight.border_width = _highlight.border_width
	if is_instance_valid(_guide):
		_guide.reduced_motion = reduced_motion


func skip() -> void:
	_finish()


func _set_step(step: int) -> void:
	current_step = clampi(step, 0, STEP_HINTS.size() - 1)
	_save_state()
	_refresh()
	step_changed.emit(current_step)


func _finish() -> void:
	completed = true
	visible = false
	_save_state()
	tutorial_completed.emit()


func _refresh() -> void:
	if not is_instance_valid(_label):
		return
	_step_label.text = "STEP %d / %d  •  %s" % [current_step + 1, STEP_HINTS.size(), STEP_TITLES[current_step]]
	_label.text = STEP_HINTS[current_step]
	var manager := get_parent()
	if not manager is GameManager:
		manager = null
	var vip_sprite := manager.get("_vip_target_sprite") as Sprite2D if manager != null else null
	_guide.drink_level = int(manager.get("_target_level")) if manager != null else 1
	_guide.vip_enabled = is_instance_valid(vip_sprite) and vip_sprite.visible
	_guide.step_index = current_step
	_guide.refresh_art()
	_guide.queue_redraw()
	_advance_button.visible = current_step in [3, 4]
	_skip_button.visible = current_step < 5 or current_step == 5
	_advance_button.text = "NEXT"
	_advance_button.custom_minimum_size = Vector2(66, 31)
	_skip_button.text = "SKIP"
	_skip_button.custom_minimum_size = Vector2(60, 31)
	if current_step == 5:
		_panel.anchor_left = 0.5
		_panel.anchor_right = 0.5
		_panel.anchor_top = 0.0
		_panel.anchor_bottom = 0.0
		_panel.offset_left = -160.0
		_panel.offset_right = 160.0
		_panel.offset_top = 14.0
		_panel.offset_bottom = 108.0
		_guide.custom_minimum_size = Vector2(48, 48)
		_skip_button.custom_minimum_size = Vector2(54, 30)
	else:
		_panel.anchor_left = 1.0
		_panel.anchor_right = 1.0
		_panel.anchor_top = 1.0
		_panel.anchor_bottom = 1.0
		_panel.offset_left = -256.0
		_panel.offset_right = -8.0
		_panel.offset_top = -156.0
		_panel.offset_bottom = -8.0
		_guide.custom_minimum_size = Vector2(54, 54)
	_update_highlights()


func _build_ui() -> void:
	var root := Control.new()
	root.name = "TutorialOverlay"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_highlight = _make_highlight(root, "TutorialActionHighlight")
	_secondary_highlight = _make_highlight(root, "TutorialSecondaryHighlight")
	_panel = PanelContainer.new()
	_panel.name = "TutorialPrompt"
	_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 5)
	_panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	margin.add_child(row)
	_guide = TutorialVisualGuide.new()
	_guide.name = "TutorialVisualGuide"
	_guide.custom_minimum_size = Vector2(54, 54)
	_guide.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_guide)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 1)
	row.add_child(column)
	_step_label = Label.new()
	_step_label.name = "TutorialStepTitle"
	_step_label.add_theme_font_size_override("font_size", 11)
	_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_step_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(_step_label)
	_label = Label.new()
	_label.name = "TutorialStepText"
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_label.add_theme_font_size_override("font_size", 14)
	column.add_child(_label)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 4)
	column.add_child(actions)
	_advance_button = Button.new()
	_advance_button.name = "TutorialContinue"
	_advance_button.custom_minimum_size = Vector2(66, 31)
	_advance_button.add_theme_font_size_override("font_size", 11)
	_advance_button.pressed.connect(func() -> void: _set_step(current_step + 1))
	actions.add_child(_advance_button)
	_skip_button = Button.new()
	_skip_button.name = "TutorialSkip"
	_skip_button.text = "SKIP"
	_skip_button.custom_minimum_size = Vector2(60, 31)
	_skip_button.add_theme_font_size_override("font_size", 11)
	_skip_button.pressed.connect(skip)
	actions.add_child(_skip_button)
	set_presentation_state({})


func _make_highlight(parent: Control, highlight_name: String) -> ReferenceRect:
	var highlight := ReferenceRect.new()
	highlight.name = highlight_name
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight.editor_only = false
	highlight.border_color = Color("#ffd166")
	highlight.border_width = 3.0
	parent.add_child(highlight)
	return highlight


func _update_highlights() -> void:
	if not is_instance_valid(_highlight) or not is_instance_valid(_secondary_highlight):
		return
	var primary: CanvasItem
	var secondary: CanvasItem
	var manager := get_parent()
	if not manager is GameManager:
		manager = null
	match current_step:
		0:
			var shot_controller: Node = manager.get("shot_controller") as Node if manager != null else null
			primary = shot_controller.get("_current_drink") as CanvasItem if shot_controller != null else null
		1:
			var drinks := _matching_board_drinks(manager)
			if drinks.size() >= 2:
				primary = drinks[0]
				secondary = drinks[1]
		2:
			primary = manager.get("_to_go_target_sprite") as CanvasItem if manager != null else null
			secondary = _first_matching_board_drink(manager)
		3:
			primary = manager.get("_vip_target_sprite") as CanvasItem if manager != null else null
		4:
			primary = manager.get("_move_limit_label") as CanvasItem if manager != null else null
		5:
			var retry := get_tree().get_first_node_in_group("tutorial_retry_button")
			primary = retry as CanvasItem if retry is CanvasItem else null
	_apply_highlight(_highlight, primary, current_step in [0, 1, 2])
	_apply_highlight(_secondary_highlight, secondary, false)


func _apply_highlight(rect: ReferenceRect, item: CanvasItem, show_fallback: bool) -> void:
	if is_instance_valid(item):
		var transform := item.get_global_transform_with_canvas()
		var local_size := _canvas_item_size(item)
		var local_origin := Vector2.ZERO
		if item is Sprite2D:
			local_origin = (item as Sprite2D).offset - local_size * 0.5
		elif item is Node2D and not item is Control:
			local_origin = -local_size * 0.5
		var local_end := local_origin + local_size
		var corners := [transform * local_origin, transform * Vector2(local_end.x, local_origin.y), transform * local_end, transform * Vector2(local_origin.x, local_end.y)]
		var bounds := Rect2(corners[0], Vector2.ZERO)
		for point in corners:
			bounds = bounds.expand(point)
		bounds = bounds.grow(6.0)
		rect.position = bounds.position
		rect.size = bounds.size
		rect.visible = true
	elif show_fallback:
		var viewport_size := get_viewport().get_visible_rect().size
		rect.position = Vector2(viewport_size.x * 0.08, viewport_size.y * 0.30)
		rect.size = Vector2(viewport_size.x * 0.84, viewport_size.y * 0.40)
		rect.visible = true
	else:
		rect.visible = false


func _canvas_item_size(item: CanvasItem) -> Vector2:
	if item is Control:
		return (item as Control).size
	if item is Sprite2D and (item as Sprite2D).texture != null:
		var sprite := item as Sprite2D
		return sprite.texture.get_size()
	return Vector2(72, 72)


func _matching_board_drinks(manager: Node) -> Array[CanvasItem]:
	var found: Array[CanvasItem] = []
	if not manager is GameManager:
		return found
	var world := manager.get_node_or_null("World")
	if world == null:
		return found
	var drinks_by_level: Dictionary = {}
	for node in world.find_children("*", "Drink", true, false):
		if not node is CanvasItem or node.is_queued_for_deletion() or int(node.get("motion_state")) in [Drink.MotionState.HELD, Drink.MotionState.MERGING, Drink.MotionState.TARGET_CAPTURE]:
			continue
		var level := int(node.get("level"))
		var same_level_drinks: Array = drinks_by_level.get(level, [])
		same_level_drinks.append(node as CanvasItem)
		drinks_by_level[level] = same_level_drinks
		if same_level_drinks.size() >= 2:
			found = [same_level_drinks[0], same_level_drinks[1]]
			break
	return found


func _first_matching_board_drink(manager: Node) -> CanvasItem:
	if not manager is GameManager:
		return null
	var world := manager.get_node_or_null("World")
	if world == null:
		return null
	var target_level := int(manager.get("_target_level"))
	for node in world.find_children("*", "Drink", true, false):
		if node is CanvasItem and not node.is_queued_for_deletion() and int(node.get("level")) == target_level and int(node.get("motion_state")) not in [Drink.MotionState.HELD, Drink.MotionState.MERGING, Drink.MotionState.TARGET_CAPTURE]:
			return node as CanvasItem
	return null


func _load_state() -> void:
	if not FileAccess.file_exists(storage_path):
		return
	var file := FileAccess.open(storage_path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and int(parsed.get("schema_version", 0)) == 1:
		current_step = clampi(int(parsed.get("current_step", 0)), 0, STEP_HINTS.size() - 1)
		completed = bool(parsed.get("completed", false))


func _save_state() -> void:
	var file := FileAccess.open(storage_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"schema_version": 1, "current_step": current_step, "completed": completed}))
