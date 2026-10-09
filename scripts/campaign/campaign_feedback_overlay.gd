class_name CampaignFeedbackOverlay
extends Control

## One concise presentation surface for locked feedback, milestone/reward
## summaries, and terminal campaign results. It never owns progression.

signal action_requested(action: String)

var feedback_kind := ""
var visible_actions: Array[String] = []

var _title: Label
var _body: Label
var _actions: VBoxContainer
var _result_entrance_tween: Tween
var _action_buttons: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	visible = false
	add_to_group("presentation_effect_target")
	_ensure_shell()


func show_locked_island(reason: String, progress: String) -> void:
	_show("LOCKED ISLAND", "%s\n%s" % [reason, progress], ["DISMISS"], "LOCKED_ISLAND")


func show_locked_level(level_id: int, highest_unlocked: int) -> void:
	_show("LEVEL LOCKED", "Level %d is not open yet.\nComplete the campaign path through Level %d." % [level_id, highest_unlocked], ["DISMISS"], "LOCKED_LEVEL")


func show_result(result: Dictionary) -> void:
	var outcome := str(result.get("outcome", ""))
	if outcome == "WIN":
		modulate.a = 0.0
	var progression: Dictionary = result.get("progression", {}) if result.get("progression", {}) is Dictionary else {}
	var record: Dictionary = progression.get("record", {}) if progression.get("record", {}) is Dictionary else {}
	var stars := clampi(int(record.get("stars", result.get("stars", 0))), 0, 3)
	var score := maxi(0, int(record.get("best_score", result.get("score", 0))))
	var star_text := ""
	for index in range(3):
		star_text += "★" if index < stars else "☆"
	var reward_text := ""
	var cumulative: Variant = progression.get("cumulative_rewards", [])
	var economy: Variant = result.get("economy", {})
	if cumulative is Array and not cumulative.is_empty():
		reward_text = "\nMILESTONE REWARD EARNED"
	elif economy is Dictionary and not economy.get("grants", []).is_empty():
		reward_text = "\nREWARD ADDED"
	var level_text := "Level %d" % int(result.get("level_id", 0))
	var title := "LEVEL COMPLETE" if outcome == "WIN" else "LEVEL FAILED"
	var body := "%s\n%s\nSCORE %d   %s%s" % [level_text, "Normal order complete" if outcome == "WIN" else "Keep merging and try again", score, star_text, reward_text]
	var actions: Array[String] = []
	if outcome == "WIN":
		if bool(result.get("next_level_available", false)):
			actions.append("NEXT_LEVEL")
		actions.append("ISLAND_MAP")
	elif outcome == "LOSE":
		actions = ["RETRY", "ISLAND_MAP"]
	_show(title, body, actions, "RESULT_%s" % outcome)


func hide_feedback() -> void:
	if _result_entrance_tween != null and _result_entrance_tween.is_running():
		_result_entrance_tween.kill()
	modulate.a = 1.0
	visible = false
	feedback_kind = ""
	visible_actions.clear()


func get_feedback_kind() -> String:
	return feedback_kind


func get_visible_actions() -> Array[String]:
	return visible_actions.duplicate()


func get_title_text() -> String:
	return _title.text if _title != null else ""


func get_body_text() -> String:
	return _body.text if _body != null else ""


func get_result_presentation_targets() -> Array[CanvasItem]:
	_ensure_shell()
	var targets: Array[CanvasItem] = []
	for node in [get_node_or_null("FeedbackCard"), _title, _body]:
		if node is CanvasItem:
			var item := node as CanvasItem
			if not item.is_in_group("presentation_effect_target"):
				item.add_to_group("presentation_effect_target")
			targets.append(item)
	return targets


func get_result_presentation_target() -> CanvasItem:
	_ensure_shell()
	if _title != null and not _title.is_in_group("presentation_effect_target"):
		_title.add_to_group("presentation_effect_target")
	return _title


func get_reward_presentation_target() -> CanvasItem:
	_ensure_shell()
	if _body != null and not _body.is_in_group("presentation_effect_target"):
		_body.add_to_group("presentation_effect_target")
	return _body


func get_action_presentation_target(action: String) -> CanvasItem:
	var target: Variant = _action_buttons.get(action)
	if not is_instance_valid(target) or not target is CanvasItem:
		return null
	if not target.is_in_group("presentation_effect_target"):
		target.add_to_group("presentation_effect_target")
	return target as CanvasItem


func play_result_entrance(duration: float) -> void:
	if _result_entrance_tween != null and _result_entrance_tween.is_running():
		_result_entrance_tween.kill()
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.0)
	_result_entrance_tween = create_tween()
	_result_entrance_tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 1.0), clampf(duration, 0.0, 0.75))


func trigger_action(action: String) -> bool:
	if not visible or not visible_actions.has(action):
		return false
	action_requested.emit(action)
	return true


func _show(title: String, body: String, actions: Array[String], kind: String) -> void:
	_ensure_shell()
	if not is_instance_valid(_title) or not is_instance_valid(_body) or not is_instance_valid(_actions):
		return
	feedback_kind = kind
	visible_actions = actions.duplicate()
	_title.text = title
	_body.text = body
	for child in _actions.get_children():
		_actions.remove_child(child)
		child.queue_free()
	_action_buttons.clear()
	for action in visible_actions:
		var button := Button.new()
		button.text = _action_label(action)
		button.custom_minimum_size = Vector2(0.0, 68.0)
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_color_override("font_color", Color("#fff0c6"))
		button.add_theme_stylebox_override("normal", _style(Color("#12354d"), Color("#73e0d1")))
		button.add_theme_stylebox_override("hover", _style(Color("#185875"), Color("#ffd166")))
		button.pressed.connect(func() -> void: trigger_action(action))
		_actions.add_child(button)
		if action in ["NEXT_LEVEL", "RETRY"]:
			button.add_to_group("presentation_effect_target")
			_action_buttons[action] = button
	visible = true


func _ensure_shell() -> void:
	_title = get_node_or_null("FeedbackTitle") as Label
	_body = get_node_or_null("FeedbackBody") as Label
	_actions = get_node_or_null("FeedbackActions") as VBoxContainer
	if _title != null and _body != null and _actions != null:
		return
	_build_shell()
	_title = get_node_or_null("FeedbackTitle") as Label
	_body = get_node_or_null("FeedbackBody") as Label
	_actions = get_node_or_null("FeedbackActions") as VBoxContainer


func _build_shell() -> void:
	if get_node_or_null("FeedbackShade") == null:
		var shade := ColorRect.new()
		shade.name = "FeedbackShade"
		shade.color = Color(0.02, 0.025, 0.04, 0.84)
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shade.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(shade)

	if get_node_or_null("FeedbackCard") == null:
		var card := PanelContainer.new()
		card.name = "FeedbackCard"
		card.position = Vector2(54.0, 300.0)
		card.size = Vector2(612.0, 650.0)
		card.add_theme_stylebox_override("panel", _style(Color("#103d52"), Color("#f7d47b")))
		add_child(card)

	if get_node_or_null("FeedbackTitle") == null:
		var title_label := Label.new()
		title_label.name = "FeedbackTitle"
		title_label.position = Vector2(86.0, 368.0)
		title_label.size = Vector2(548.0, 76.0)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 38)
		title_label.add_theme_color_override("font_color", Color("#fff0c6"))
		add_child(title_label)

	if get_node_or_null("FeedbackBody") == null:
		var body_label := Label.new()
		body_label.name = "FeedbackBody"
		body_label.position = Vector2(90.0, 478.0)
		body_label.size = Vector2(540.0, 230.0)
		body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body_label.add_theme_font_size_override("font_size", 23)
		body_label.add_theme_color_override("font_color", Color("#d7ebe4"))
		add_child(body_label)

	if get_node_or_null("FeedbackActions") == null:
		var actions := VBoxContainer.new()
		actions.name = "FeedbackActions"
		actions.position = Vector2(140.0, 750.0)
		actions.size = Vector2(440.0, 168.0)
		actions.add_theme_constant_override("separation", 14)
		add_child(actions)


func _action_label(action: String) -> String:
	match action:
		"NEXT_LEVEL":
			return "NEXT LEVEL"
		"ISLAND_MAP":
			return "ISLAND MAP"
		"RETRY":
			return "RETRY"
		"DISMISS":
			return "CONTINUE"
	return action


func _style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	style.shadow_size = 8
	return style
