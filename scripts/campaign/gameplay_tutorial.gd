class_name GameplayTutorial
extends CanvasLayer

signal tutorial_completed

const STORAGE_PATH := "user://gameplay_tutorial_state.json"
const STEP_TITLES := ["LAUNCH", "MERGE", "DELIVER", "VIP BONUS", "MOVES & STARS", "PLAY AGAIN"]
const STEP_HINTS := [
	"Drag a drink onto the board.",
	"Bring two matching drinks together.",
	"Match the order shown above.",
	"VIP adds a bonus. Your normal goal stays open.",
	"Each launch uses a move. Save moves for stars.",
	"Choose Retry on Results to play again.",
]

var current_step := 0
var completed := false
var reduced_motion := false
var high_contrast := false
var storage_path := STORAGE_PATH
var _panel: PanelContainer
var _highlight: ReferenceRect
var _label: Label
var _step_label: Label
var _guide: TutorialVisualGuide
var _advance_button: Button
var _skip_button: Button


class TutorialVisualGuide extends Control:
	var step_index := 0
	var reduced_motion := false
	var _phase := 0.0

	func _process(delta: float) -> void:
		if not reduced_motion:
			_phase = fmod(_phase + delta * 2.2, TAU)
			queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var pulse := 0.5 + 0.5 * sin(_phase)
		draw_circle(center, minf(size.x, size.y) * (0.34 + pulse * 0.025), Color("#ffd166", 0.16))
		draw_circle(center, minf(size.x, size.y) * 0.29, Color("#0b3142"), true, -1.0, true)
		match step_index:
			0: _draw_launch(center)
			1: _draw_merge(center)
			2: _draw_delivery(center)
			3: _draw_vip(center)
			4: _draw_moves(center)
			_: _draw_retry(center)

	func _draw_launch(c: Vector2) -> void:
		_draw_cocktail(c + Vector2(-29, 20), Color("#ff795e"), 0.72)
		_draw_arrow(c + Vector2(-12, 3), c + Vector2(25, -23))
		_draw_hand(c + Vector2(27, 23), 0.72)

	func _draw_merge(c: Vector2) -> void:
		_draw_cocktail(c + Vector2(-28, 9), Color("#ff795e"), 0.63)
		_draw_cocktail(c + Vector2(27, 9), Color("#ff795e"), 0.63)
		draw_line(c + Vector2(-9, 10), c + Vector2(9, 10), Color("#ffd166"), 5.0, true)
		draw_colored_polygon(PackedVector2Array([c + Vector2(5, 1), c + Vector2(15, 10), c + Vector2(5, 19)]), Color("#ffd166"))
		_draw_cocktail(c + Vector2(0, -26), Color("#f7b844"), 0.64)

	func _draw_delivery(c: Vector2) -> void:
		_draw_cocktail(c + Vector2(-29, 10), Color("#ff795e"), 0.66)
		_draw_arrow(c + Vector2(-7, 2), c + Vector2(18, -14))
		draw_rect(Rect2(c + Vector2(15, -27), Vector2(25, 34)), Color("#ffd166"), false, 4.0, true)
		draw_line(c + Vector2(20, -17), c + Vector2(35, -17), Color("#ffd166"), 3.0, true)

	func _draw_vip(c: Vector2) -> void:
		var crown := PackedVector2Array([c + Vector2(-34, -9), c + Vector2(-26, 13), c + Vector2(25, 13), c + Vector2(34, -9), c + Vector2(18, -1), c + Vector2(0, -18), c + Vector2(-17, -1)])
		draw_colored_polygon(crown, Color("#ffd166"))
		draw_rect(Rect2(c + Vector2(-26, 16), Vector2(52, 8)), Color("#f7b844"), true)
		draw_arc(c, 37.0, 0.2, 2.9, 24, Color("#9be7c4"), 4.0, true)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-34, 5), c + Vector2(-43, 1), c + Vector2(-35, -5)]), Color("#9be7c4"))

	func _draw_moves(c: Vector2) -> void:
		for i in 3:
			var x := c.x - 30 + i * 30
			draw_circle(Vector2(x, c.y + 8), 10, Color("#7ad7c0"))
			draw_circle(Vector2(x, c.y + 8), 4, Color("#0b3142"))
		var star := PackedVector2Array()
		for i in 10:
			var angle := -PI / 2.0 + i * PI / 5.0
			var radius := 18.0 if i % 2 == 0 else 8.0
			star.append(c + Vector2(cos(angle), sin(angle)) * radius + Vector2(0, -24))
		draw_colored_polygon(star, Color("#ffd166"))

	func _draw_retry(c: Vector2) -> void:
		draw_arc(c, 30.0, -2.25, 1.05, 32, Color("#7ad7c0"), 7.0, true)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-31, -5), c + Vector2(-18, -8), c + Vector2(-27, 5)]), Color("#7ad7c0"))
		draw_colored_polygon(PackedVector2Array([c + Vector2(31, 5), c + Vector2(18, 8), c + Vector2(27, -5)]), Color("#7ad7c0"))
		draw_circle(c, 12, Color("#ff795e"))
		draw_colored_polygon(PackedVector2Array([c + Vector2(-4, -7), c + Vector2(7, 0), c + Vector2(-4, 7)]), Color.WHITE)

	func _draw_cocktail(c: Vector2, drink_color: Color, scale: float) -> void:
		var s := scale
		draw_colored_polygon(PackedVector2Array([c + Vector2(-13, -17) * s, c + Vector2(13, -17) * s, c + Vector2(8, 4) * s, c + Vector2(-8, 4) * s]), Color("#fff2d6"))
		draw_colored_polygon(PackedVector2Array([c + Vector2(-10, -7) * s, c + Vector2(10, -7) * s, c + Vector2(7, 2) * s, c + Vector2(-7, 2) * s]), drink_color)
		draw_line(c + Vector2(0, 4) * s, c + Vector2(0, 14) * s, Color("#fff2d6"), 2.0 * s, true)
		draw_line(c + Vector2(-8, 16) * s, c + Vector2(8, 16) * s, Color("#fff2d6"), 2.0 * s, true)
		draw_line(c + Vector2(3, -18) * s, c + Vector2(13, -28) * s, Color("#9be7c4"), 2.0 * s, true)

	func _draw_arrow(from: Vector2, to: Vector2) -> void:
		draw_line(from, to, Color("#ffd166"), 5.0, true)
		var direction := (to - from).normalized()
		var normal := Vector2(-direction.y, direction.x)
		draw_colored_polygon(PackedVector2Array([to, to - direction * 12.0 + normal * 7.0, to - direction * 12.0 - normal * 7.0]), Color("#ffd166"))

	func _draw_hand(c: Vector2, scale: float) -> void:
		var points := PackedVector2Array([
			c + Vector2(-12, 5) * scale, c + Vector2(-12, -10) * scale,
			c + Vector2(-8, -20) * scale, c + Vector2(-3, -18) * scale,
			c + Vector2(-2, -5) * scale, c + Vector2(3, -23) * scale,
			c + Vector2(8, -21) * scale, c + Vector2(7, -4) * scale,
			c + Vector2(14, -14) * scale, c + Vector2(19, -11) * scale,
			c + Vector2(15, 7) * scale, c + Vector2(3, 17) * scale,
			c + Vector2(-8, 14) * scale,
		])
		draw_colored_polygon(points, Color("#fff2d6"))
		draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4]]), Color("#0b3142"), 2.0, true)


func _ready() -> void:
	_load_state()
	_build_ui()
	visible = false


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
		style.set_corner_radius_all(16)
		_panel.add_theme_stylebox_override("panel", style)
		_label.add_theme_font_size_override("font_size", 28 if high_contrast else 24)
		_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color("#fff0c6"))
		_step_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color("#ffd166"))
	if is_instance_valid(_highlight):
		_highlight.border_color = Color.WHITE if high_contrast else Color("#ffd166")
		_highlight.border_width = 5.0 if high_contrast else 3.0
	if is_instance_valid(_guide):
		_guide.reduced_motion = reduced_motion


func skip() -> void:
	_finish()


func _set_step(step: int) -> void:
	current_step = clampi(step, 0, STEP_HINTS.size() - 1)
	_save_state()
	_refresh()


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
	_guide.step_index = current_step
	_guide.queue_redraw()
	_advance_button.visible = current_step in [3, 4]
	_advance_button.text = "CONTINUE"
	_skip_button.text = "SKIP"
	match current_step:
		0, 1:
			_highlight.anchor_left = 0.08
			_highlight.anchor_right = 0.92
			_highlight.anchor_top = 0.30
			_highlight.anchor_bottom = 0.64
		2, 3:
			_highlight.anchor_left = 0.34
			_highlight.anchor_right = 0.66
			_highlight.anchor_top = 0.0
			_highlight.anchor_bottom = 0.20
		4:
			_highlight.anchor_left = 0.32
			_highlight.anchor_right = 0.68
			_highlight.anchor_top = 0.18
			_highlight.anchor_bottom = 0.28
		5:
			_highlight.anchor_left = 0.20
			_highlight.anchor_right = 0.80
			_highlight.anchor_top = 0.45
			_highlight.anchor_bottom = 0.63


func _build_ui() -> void:
	var root := Control.new()
	root.name = "TutorialOverlay"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_highlight = ReferenceRect.new()
	_highlight.name = "TutorialActionHighlight"
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_highlight.editor_only = false
	root.add_child(_highlight)
	_panel = PanelContainer.new()
	_panel.name = "TutorialPrompt"
	_panel.anchor_left = 0.08
	_panel.anchor_right = 0.92
	_panel.anchor_top = 0.765
	_panel.anchor_bottom = 0.975
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_panel.add_child(row)
	_guide = TutorialVisualGuide.new()
	_guide.name = "TutorialVisualGuide"
	_guide.custom_minimum_size = Vector2(116, 116)
	_guide.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_guide)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 4)
	row.add_child(column)
	_step_label = Label.new()
	_step_label.name = "TutorialStepTitle"
	_step_label.add_theme_font_size_override("font_size", 18)
	_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	column.add_child(_step_label)
	_label = Label.new()
	_label.name = "TutorialStepText"
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_label.add_theme_font_size_override("font_size", 22)
	column.add_child(_label)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	column.add_child(actions)
	_advance_button = Button.new()
	_advance_button.name = "TutorialContinue"
	_advance_button.custom_minimum_size = Vector2(0, 52)
	_advance_button.pressed.connect(func() -> void: _set_step(current_step + 1))
	actions.add_child(_advance_button)
	_skip_button = Button.new()
	_skip_button.name = "TutorialSkip"
	_skip_button.text = "SKIP TUTORIAL"
	_skip_button.custom_minimum_size = Vector2(0, 52)
	_skip_button.pressed.connect(skip)
	actions.add_child(_skip_button)
	set_presentation_state({})


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
