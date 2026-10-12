class_name GameplayTutorial
extends CanvasLayer

signal tutorial_completed

const STORAGE_PATH := "user://gameplay_tutorial_state.json"
const PROMPTS := [
	"LAUNCH: drag from the held cocktail and release on the board.",
	"MERGE: match two equal cocktails to create the next level.",
	"TO-GO: deliver the requested cocktail to complete the order.",
	"VIP IS OPTIONAL: it adds a bonus objective and never blocks a normal win.",
	"MOVES AND STARS: committed launches count as moves; stars use the move budget.",
	"RETRY: on Results, choose Retry to replay this same level.",
]

var current_step := 0
var completed := false
var reduced_motion := false
var high_contrast := false
var storage_path := STORAGE_PATH
var _panel: PanelContainer
var _highlight: ReferenceRect
var _label: Label
var _advance_button: Button
var _skip_button: Button


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
	if is_instance_valid(_highlight):
		_highlight.border_color = Color.WHITE if high_contrast else Color("#ffd166")
		_highlight.border_width = 5.0 if high_contrast else 3.0


func skip() -> void:
	_finish()


func _set_step(step: int) -> void:
	current_step = clampi(step, 0, PROMPTS.size() - 1)
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
	_label.text = "STEP %d / %d\n%s" % [current_step + 1, PROMPTS.size(), PROMPTS[current_step]]
	_advance_button.visible = current_step in [3, 4]
	_advance_button.text = "CONTINUE"
	_skip_button.text = "SKIP TUTORIAL"
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
	_panel.anchor_top = 0.66
	_panel.anchor_bottom = 0.99
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_panel)
	var column := VBoxContainer.new()
	_panel.add_child(column)
	_label = Label.new()
	_label.name = "TutorialStepText"
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_label)
	var actions := HBoxContainer.new()
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
		current_step = clampi(int(parsed.get("current_step", 0)), 0, PROMPTS.size() - 1)
		completed = bool(parsed.get("completed", false))


func _save_state() -> void:
	var file := FileAccess.open(storage_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"schema_version": 1, "current_step": current_step, "completed": completed}))
