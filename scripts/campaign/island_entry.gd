class_name IslandEntry
extends Button

## Reusable World Map island entry. It renders a supplied definition and state;
## unlock decisions remain owned by CampaignManager.

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

var _index_label: Label
var _name_label: Label
var _state_label: Label
var _detail_label: Label
var _action_label: Label
var _accent: ColorRect


func _ready() -> void:
    custom_minimum_size = Vector2(0.0, 164.0)
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
    var margin := MarginContainer.new()
    margin.name = "Margin"
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_bottom", 18)
    add_child(margin)

    var row := HBoxContainer.new()
    row.name = "Row"
    row.add_theme_constant_override("separation", 18)
    margin.add_child(row)

    var badge := PanelContainer.new()
    badge.name = "Badge"
    badge.custom_minimum_size = Vector2(112, 0)
    var badge_center := CenterContainer.new()
    badge.add_child(badge_center)
    _index_label = Label.new()
    _index_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _index_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _index_label.add_theme_font_size_override("font_size", 24)
    badge_center.add_child(_index_label)
    row.add_child(badge)

    var copy := VBoxContainer.new()
    copy.name = "Copy"
    copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    copy.add_theme_constant_override("separation", 4)
    row.add_child(copy)

    _name_label = Label.new()
    _name_label.add_theme_font_size_override("font_size", 28)
    _name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    copy.add_child(_name_label)

    _state_label = Label.new()
    _state_label.add_theme_font_size_override("font_size", 14)
    copy.add_child(_state_label)

    _detail_label = Label.new()
    _detail_label.add_theme_font_size_override("font_size", 15)
    _detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    copy.add_child(_detail_label)

    _accent = ColorRect.new()
    _accent.name = "Accent"
    _accent.custom_minimum_size = Vector2(5, 0)
    row.add_child(_accent)

    var action := CenterContainer.new()
    action.name = "Action"
    action.custom_minimum_size = Vector2(100, 0)
    _action_label = Label.new()
    _action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _action_label.add_theme_font_size_override("font_size", 14)
    action.add_child(_action_label)
    row.add_child(action)


func _refresh_visuals() -> void:
    if _name_label == null:
        return
    var display_name := str(island_definition.get("display_name", island_id))
    _name_label.text = display_name
    _index_label.text = "%02d" % int(island_definition.get("order_index", 0))
    _state_label.text = "CURRENT • OPEN" if island_state == STATE_CURRENT else island_state
    _detail_label.text = locked_reason if island_state == STATE_LOCKED else progress_text
    _action_label.text = "LOCKED" if island_state == STATE_LOCKED else "OPEN ISLAND"
    _action_label.modulate = Color("#9ba7b8") if island_state == STATE_LOCKED else Color("#ffe9ad")
    _state_label.modulate = _state_color()
    _accent.color = _state_color()
    # Locked entries remain input-safe and tappable so the controller can
    # surface the reason/progress feedback without allowing navigation.
    disabled = false
    _apply_style()


func _state_color() -> Color:
    match island_state:
        STATE_CURRENT:
            return Color("#ffd166")
        STATE_OPEN:
            return Color("#57d6c0")
        STATE_COMPLETE:
            return Color("#b99cff")
        _:
            return Color("#8591a3")


func _apply_style() -> void:
    var base := StyleBoxFlat.new()
    base.bg_color = Color("#17334a") if island_state != STATE_LOCKED else Color("#172333")
    base.border_color = _state_color().darkened(0.18)
    base.set_border_width_all(2)
    base.set_corner_radius_all(18)
    base.shadow_color = Color(0, 0, 0, 0.22)
    base.shadow_size = 8
    add_theme_stylebox_override("normal", base)

    var hover := base.duplicate()
    if is_selectable():
        hover.bg_color = Color("#21465d")
    add_theme_stylebox_override("hover", hover)
    add_theme_stylebox_override("pressed", hover)
    add_theme_stylebox_override("disabled", base)


func _on_pressed() -> void:
    island_pressed.emit(island_id)
