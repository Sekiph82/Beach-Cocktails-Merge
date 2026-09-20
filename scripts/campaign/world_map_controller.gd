class_name WorldMapController
extends Control

## Reusable, data-driven World Map controller.
##
## This layer only presents LevelDatabase/CampaignManager state. Unlock rules,
## completion, and progress are intentionally delegated to CampaignManager.

signal island_selected(island_id: String)
signal island_map_requested(island_id: String)
signal locked_island_feedback(island_id: String, reason: String, progress: String)
signal return_requested

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"

const CARD_SCENE := preload("res://scenes/campaign/IslandEntry.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var level_database
var campaign_manager
var selected_island_id := ""
var last_locked_feedback: Dictionary = {}
var _ordered_ids: Array[String] = []

var _island_list: VBoxContainer
var _entries: Dictionary = {}
var _status_label: Label
var _selection_label: Label
var _scroll: ScrollContainer


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_shell()
    if level_database == null or campaign_manager == null:
        _configure_default_campaign()
    _bind_campaign_signals()
    refresh()


func configure_campaign(database, manager) -> bool:
    if database == null or manager == null or not database.is_loaded():
        return false
    level_database = database
    campaign_manager = manager
    _bind_campaign_signals()
    refresh()
    return true


func refresh() -> void:
    if _island_list == null or level_database == null or campaign_manager == null:
        return
    for child in _island_list.get_children():
        _island_list.remove_child(child)
        child.free()
    _entries.clear()
    _ordered_ids.clear()
    var definitions: Array[Dictionary] = []
    for island_id in level_database.get_island_ids():
        var definition: Dictionary = level_database.get_island(island_id)
        definitions.append(definition)
    definitions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return int(a.get("order_index", 0)) < int(b.get("order_index", 0))
    )

    for definition in definitions:
        var island_id := str(definition.get("id", ""))
        var feedback: Dictionary = campaign_manager.get_island_unlock_feedback(island_id)
        var state := _state_for(island_id, bool(feedback.get("unlocked", false)))
        var entry = CARD_SCENE.instantiate()
        _island_list.add_child(entry)
        entry.call("configure", definition, state, str(feedback.get("reason", "")), str(feedback.get("progress", "")))
        entry.connect("island_pressed", Callable(self, "_on_island_pressed"))
        _entries[island_id] = entry
        _ordered_ids.append(island_id)

    if selected_island_id.is_empty():
        selected_island_id = campaign_manager.current_island_id
    _update_summary()


func get_entry_count() -> int:
    return _entries.size()


func get_entry_ids() -> Array[String]:
    return _ordered_ids.duplicate()


func get_entry_state(island_id: String) -> String:
    var entry = _entries.get(island_id)
    return str(entry.get("island_state")) if entry != null else ""


func is_entry_selectable(island_id: String) -> bool:
    var entry = _entries.get(island_id)
    return entry != null and bool(entry.call("is_selectable"))


func get_locked_feedback() -> Dictionary:
    return last_locked_feedback.duplicate(true)


func select_island(island_id: String) -> bool:
    if campaign_manager == null:
        return false
    var feedback: Dictionary = campaign_manager.get_island_unlock_feedback(island_id)
    if not bool(feedback.get("unlocked", false)):
        last_locked_feedback = {
            "island_id": island_id,
            "reason": str(feedback.get("reason", "Island locked")),
            "progress": str(feedback.get("progress", "Progress required")),
        }
        _show_locked_feedback(last_locked_feedback)
        locked_island_feedback.emit(island_id, last_locked_feedback["reason"], last_locked_feedback["progress"])
        return false
    if not campaign_manager.select_island(island_id):
        return false
    selected_island_id = island_id
    island_selected.emit(island_id)
    # M13 owns IslandMapScene. This signal is the navigation boundary; this
    # controller never launches gameplay directly.
    island_map_requested.emit(island_id)
    refresh()
    _show_selection_feedback(island_id)
    return true


func get_layout_report(reference_size: Vector2 = Vector2(720, 1280)) -> Dictionary:
    var report := {
        "reference_size": reference_size,
        "entry_count": _entries.size(),
        "horizontal_clipping": false,
        "overlap": false,
        "navigation_overlap": false,
        "entries_fit_width": true,
    }
    if _entries.is_empty():
        return report
    var previous_bottom := -INF
    for island_id in get_entry_ids():
        var entry: Control = _entries[island_id] as Control
        var rect := entry.get_global_rect()
        if rect.position.x < 0.0 or rect.end.x > reference_size.x:
            report["horizontal_clipping"] = true
            report["entries_fit_width"] = false
        if rect.position.y < previous_bottom:
            report["overlap"] = true
        previous_bottom = rect.end.y
    if _selection_label != null and not _entries.is_empty():
        var last_entry: Control = _entries[get_entry_ids().back()] as Control
        if last_entry.get_global_rect().intersects(_selection_label.get_global_rect()):
            report["navigation_overlap"] = true
    return report


func _build_shell() -> void:
    var background := ColorRect.new()
    background.name = "Background"
    background.color = Color("#071b2c")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)

    var outer := MarginContainer.new()
    outer.name = "OuterMargin"
    outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    outer.add_theme_constant_override("margin_left", 34)
    outer.add_theme_constant_override("margin_top", 34)
    outer.add_theme_constant_override("margin_right", 34)
    outer.add_theme_constant_override("margin_bottom", 28)
    add_child(outer)

    var column := VBoxContainer.new()
    column.name = "Column"
    column.add_theme_constant_override("separation", 18)
    outer.add_child(column)

    var header := HBoxContainer.new()
    header.name = "Header"
    header.custom_minimum_size = Vector2(0, 112)
    header.add_theme_constant_override("separation", 18)
    column.add_child(header)

    var back := Button.new()
    back.name = "BackButton"
    back.text = "‹"
    back.custom_minimum_size = Vector2(64, 64)
    back.add_theme_font_size_override("font_size", 42)
    back.tooltip_text = "Return"
    back.pressed.connect(func() -> void: return_requested.emit())
    header.add_child(back)

    var title_column := VBoxContainer.new()
    title_column.name = "TitleColumn"
    title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_column.add_theme_constant_override("separation", 2)
    header.add_child(title_column)

    var eyebrow := Label.new()
    eyebrow.text = "CAMPAIGN  •  ISLAND SELECT"
    eyebrow.add_theme_font_size_override("font_size", 14)
    eyebrow.modulate = Color("#57d6c0")
    title_column.add_child(eyebrow)

    var title := Label.new()
    title.text = "World Map"
    title.add_theme_font_size_override("font_size", 40)
    title.modulate = Color("#fff4d5")
    title_column.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Choose an island to continue your beach-bar story"
    subtitle.add_theme_font_size_override("font_size", 15)
    subtitle.modulate = Color("#a9bed0")
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title_column.add_child(subtitle)

    var status_panel := PanelContainer.new()
    status_panel.name = "StatusPanel"
    status_panel.custom_minimum_size = Vector2(0, 70)
    var status_margin := MarginContainer.new()
    status_margin.add_theme_constant_override("margin_left", 18)
    status_margin.add_theme_constant_override("margin_top", 12)
    status_margin.add_theme_constant_override("margin_right", 18)
    status_margin.add_theme_constant_override("margin_bottom", 12)
    status_panel.add_child(status_margin)
    _status_label = Label.new()
    _status_label.add_theme_font_size_override("font_size", 16)
    _status_label.modulate = Color("#ffe9ad")
    _status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_margin.add_child(_status_label)
    column.add_child(status_panel)

    _scroll = ScrollContainer.new()
    _scroll.name = "IslandScroll"
    _scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    column.add_child(_scroll)

    _island_list = VBoxContainer.new()
    _island_list.name = "IslandList"
    _island_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _island_list.add_theme_constant_override("separation", 16)
    _scroll.add_child(_island_list)

    _selection_label = Label.new()
    _selection_label.name = "SelectionBoundary"
    _selection_label.text = "Select an open island to view its future Island Map"
    _selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _selection_label.add_theme_font_size_override("font_size", 15)
    _selection_label.modulate = Color("#a9bed0")
    _selection_label.custom_minimum_size = Vector2(0, 42)
    column.add_child(_selection_label)


func _configure_default_campaign() -> void:
    level_database = DATABASE_SCRIPT.new()
    if not level_database.load_canonical():
        return
    campaign_manager = CAMPAIGN_SCRIPT.new()
    campaign_manager.configure(level_database, SAVE_SCRIPT.new().create_default_state())
    _bind_campaign_signals()


func _bind_campaign_signals() -> void:
    if campaign_manager != null and not campaign_manager.progression_changed.is_connected(_on_progression_changed):
        campaign_manager.progression_changed.connect(_on_progression_changed)


func _on_progression_changed(_island_id: String, _level_id: int) -> void:
    refresh()


func _state_for(island_id: String, unlocked: bool) -> String:
    if campaign_manager.is_island_complete(island_id):
        return STATE_COMPLETE
    if campaign_manager.current_island_id == island_id:
        return STATE_CURRENT
    return STATE_OPEN if unlocked else STATE_LOCKED


func _on_island_pressed(island_id: String) -> void:
    select_island(island_id)


func _show_locked_feedback(feedback: Dictionary) -> void:
    _status_label.modulate = Color("#ffb4a2")
    _status_label.text = "%s\n%s" % [feedback["reason"], feedback["progress"]]
    _selection_label.text = "Locked island • complete the required campaign progress to continue"


func _show_selection_feedback(island_id: String) -> void:
    _status_label.modulate = Color("#ffe9ad")
    _status_label.text = "Selected %s • Island Map navigation boundary ready" % str(level_database.get_island(island_id).get("display_name", island_id))
    _selection_label.text = "Island selected • M13 Island Map will receive this island id"


func _update_summary() -> void:
    if selected_island_id.is_empty() or not _entries.has(selected_island_id):
        _status_label.text = "Sunny Cove is open • Tiki Island unlocks through campaign completion"
        return
    var selected_definition: Dictionary = level_database.get_island(selected_island_id)
    var selected_entry = _entries[selected_island_id]
    _status_label.modulate = Color("#ffe9ad")
    var display_state := "CURRENT • OPEN" if str(selected_entry.get("island_state")) == STATE_CURRENT else str(selected_entry.get("island_state"))
    _status_label.text = "%s  •  %s\n%s" % [selected_definition.get("display_name", selected_island_id), display_state, str(selected_entry.get("progress_text"))]
