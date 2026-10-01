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


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 100
    visible = false
    _build_shell()


func show_locked_island(reason: String, progress: String) -> void:
    _show("LOCKED ISLAND", "%s\n%s" % [reason, progress], ["DISMISS"], "LOCKED_ISLAND")


func show_locked_level(level_id: int, highest_unlocked: int) -> void:
    _show("LEVEL LOCKED", "Level %d is not open yet.\nComplete the campaign path through Level %d." % [level_id, highest_unlocked], ["DISMISS"], "LOCKED_LEVEL")


func show_result(result: Dictionary) -> void:
    var outcome := str(result.get("outcome", ""))
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


func trigger_action(action: String) -> bool:
    if not visible or not visible_actions.has(action):
        return false
    action_requested.emit(action)
    return true


func _show(title: String, body: String, actions: Array[String], kind: String) -> void:
    feedback_kind = kind
    visible_actions = actions.duplicate()
    _title.text = title
    _body.text = body
    for child in _actions.get_children():
        child.queue_free()
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
    visible = true


func _build_shell() -> void:
    var shade := ColorRect.new()
    shade.name = "FeedbackShade"
    shade.color = Color(0.02, 0.025, 0.04, 0.84)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(shade)

    var card := PanelContainer.new()
    card.name = "FeedbackCard"
    card.position = Vector2(54.0, 300.0)
    card.size = Vector2(612.0, 650.0)
    card.add_theme_stylebox_override("panel", _style(Color("#103d52"), Color("#f7d47b")))
    add_child(card)

    _title = Label.new()
    _title.name = "FeedbackTitle"
    _title.position = Vector2(86.0, 368.0)
    _title.size = Vector2(548.0, 76.0)
    _title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title.add_theme_font_size_override("font_size", 38)
    _title.add_theme_color_override("font_color", Color("#fff0c6"))
    add_child(_title)

    _body = Label.new()
    _body.name = "FeedbackBody"
    _body.position = Vector2(90.0, 478.0)
    _body.size = Vector2(540.0, 230.0)
    _body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _body.add_theme_font_size_override("font_size", 23)
    _body.add_theme_color_override("font_color", Color("#d7ebe4"))
    add_child(_body)

    _actions = VBoxContainer.new()
    _actions.name = "FeedbackActions"
    _actions.position = Vector2(140.0, 750.0)
    _actions.size = Vector2(440.0, 168.0)
    _actions.add_theme_constant_override("separation", 14)
    add_child(_actions)


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
