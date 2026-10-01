class_name ApplicationShell
extends Control

## The single application-level shell. It owns the menu and exactly one
## CampaignNavigationController instance; campaign state remains inside the
## existing navigation/campaign authorities.

signal campaign_requested
signal settings_requested
signal main_menu_entered
signal onboarding_shown
signal onboarding_dismissed

const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const ONBOARDING_SCHEMA_VERSION := 1
const DEFAULT_ONBOARDING_STORAGE_PATH := "user://onboarding_state.json"

var campaign_navigation: CampaignNavigationController
var current_view := "MAIN_MENU"
var onboarding_storage_path := DEFAULT_ONBOARDING_STORAGE_PATH
var onboarding_state: Dictionary = {}

var _menu_layer: Control
var _onboarding_layer: Control
var _onboarding_title: Label
var _onboarding_body: Label
var _onboarding_counter: Label
var _onboarding_next_button: Button
var _onboarding_page := 0
var _menu_play_button: Button
var _menu_settings_button: Button
var _status_label: Label


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_menu()
    _build_onboarding()
    campaign_navigation = NAVIGATION_SCENE.instantiate() as CampaignNavigationController
    campaign_navigation.name = "CampaignNavigation"
    campaign_navigation.main_menu_requested.connect(_on_navigation_main_menu_requested)
    add_child(campaign_navigation)
    campaign_navigation.visible = false
    onboarding_state = _read_onboarding_state()
    if not bool(onboarding_state.get("completed", false)):
        show_onboarding()
    else:
        show_main_menu()


func get_campaign_navigation() -> CampaignNavigationController:
    return campaign_navigation


func get_current_view() -> String:
    return current_view


func is_main_menu_visible() -> bool:
    return current_view == "MAIN_MENU" and _menu_layer != null and _menu_layer.visible


func is_onboarding_visible() -> bool:
    return current_view == "ONBOARDING" and _onboarding_layer != null and _onboarding_layer.visible


func get_onboarding_page_count() -> int:
    return 5


func get_onboarding_state() -> Dictionary:
    return onboarding_state.duplicate(true)


func show_onboarding() -> bool:
    if _onboarding_layer == null:
        return false
    _onboarding_page = 0
    _menu_layer.visible = false
    _onboarding_layer.visible = true
    current_view = "ONBOARDING"
    _refresh_onboarding_page()
    onboarding_shown.emit()
    return true


func next_onboarding_page() -> bool:
    if not is_onboarding_visible():
        return false
    if _onboarding_page >= get_onboarding_page_count() - 1:
        complete_onboarding()
    else:
        _onboarding_page += 1
        _refresh_onboarding_page()
    return true


func skip_onboarding() -> bool:
    if not is_onboarding_visible():
        return false
    _save_onboarding_state(true)
    _onboarding_layer.visible = false
    _menu_layer.visible = true
    current_view = "MAIN_MENU"
    onboarding_dismissed.emit()
    return true


func complete_onboarding() -> bool:
    return skip_onboarding()


func reset_onboarding_state() -> bool:
    ## This resets only the shell's separate onboarding file. It cannot alter
    ## campaign progression and is intentionally useful for explicit QA runs.
    _save_onboarding_state(false)
    return show_onboarding()


func show_main_menu() -> bool:
    if campaign_navigation == null:
        return false
    campaign_navigation.show_world_map()
    campaign_navigation.visible = false
    _menu_layer.visible = true
    current_view = "MAIN_MENU"
    main_menu_entered.emit()
    return true


func press_play_continue() -> bool:
    if campaign_navigation == null or is_onboarding_visible():
        return false
    if not campaign_navigation.show_world_map():
        return false
    _menu_layer.visible = false
    campaign_navigation.visible = true
    current_view = "CAMPAIGN"
    campaign_requested.emit()
    return true


func request_settings() -> void:
    settings_requested.emit()


func get_menu_controls() -> Dictionary:
    return {
        "play": _menu_play_button,
        "settings": _menu_settings_button,
    }


func _on_navigation_main_menu_requested() -> void:
    show_main_menu()


func _build_menu() -> void:
    _menu_layer = Control.new()
    _menu_layer.name = "MainMenu"
    _menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _menu_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(_menu_layer)

    var background := ColorRect.new()
    background.name = "MainMenuBackground"
    background.color = Color("#08283c")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _menu_layer.add_child(background)

    var wash := ColorRect.new()
    wash.name = "MainMenuAccent"
    wash.color = Color(0.10, 0.62, 0.57, 0.18)
    wash.set_anchors_preset(Control.PRESET_TOP_WIDE)
    wash.offset_bottom = 430.0
    wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _menu_layer.add_child(wash)

    var title := Label.new()
    title.name = "Title"
    title.text = "BEACH COCKTAILS"
    title.position = Vector2(42.0, 238.0)
    title.size = Vector2(636.0, 74.0)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 42)
    title.add_theme_color_override("font_color", Color("#fff0c6"))
    _menu_layer.add_child(title)

    var subtitle := Label.new()
    subtitle.name = "Subtitle"
    subtitle.text = "MERGE • MASTER • DISCOVER"
    subtitle.position = Vector2(42.0, 318.0)
    subtitle.size = Vector2(636.0, 32.0)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 17)
    subtitle.add_theme_color_override("font_color", Color("#73e0d1"))
    _menu_layer.add_child(subtitle)

    var card := PanelContainer.new()
    card.name = "MenuCard"
    card.position = Vector2(70.0, 470.0)
    card.size = Vector2(580.0, 430.0)
    card.add_theme_stylebox_override("panel", _panel_style(Color("#103d52"), Color("#4bb3a8"), 0.96))
    _menu_layer.add_child(card)

    var card_margin := MarginContainer.new()
    card_margin.add_theme_constant_override("margin_left", 44)
    card_margin.add_theme_constant_override("margin_top", 44)
    card_margin.add_theme_constant_override("margin_right", 44)
    card_margin.add_theme_constant_override("margin_bottom", 44)
    card.add_child(card_margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 22)
    card_margin.add_child(column)

    var eyebrow := Label.new()
    eyebrow.text = "YOUR CAMPAIGN AWAITS"
    eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    eyebrow.add_theme_font_size_override("font_size", 17)
    eyebrow.add_theme_color_override("font_color", Color("#f7d47b"))
    column.add_child(eyebrow)

    _menu_play_button = _make_menu_button("PLAY / CONTINUE", Color("#0e665f"), Color("#ffd166"))
    _menu_play_button.name = "PlayContinueButton"
    _menu_play_button.pressed.connect(press_play_continue)
    column.add_child(_menu_play_button)

    _menu_settings_button = _make_menu_button("SETTINGS", Color("#12354d"), Color("#73e0d1"))
    _menu_settings_button.name = "SettingsButton"
    _menu_settings_button.pressed.connect(request_settings)
    column.add_child(_menu_settings_button)

    _status_label = Label.new()
    _status_label.name = "Status"
    _status_label.text = "Progress is kept safe across menu and campaign transitions."
    _status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _status_label.add_theme_font_size_override("font_size", 15)
    _status_label.add_theme_color_override("font_color", Color("#d7ebe4"))
    column.add_child(_status_label)


func _build_onboarding() -> void:
    _onboarding_layer = Control.new()
    _onboarding_layer.name = "FirstRunOnboarding"
    _onboarding_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _onboarding_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    _onboarding_layer.visible = false
    add_child(_onboarding_layer)

    var background := ColorRect.new()
    background.name = "OnboardingBackground"
    background.color = Color("#08283c")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _onboarding_layer.add_child(background)

    var accent := ColorRect.new()
    accent.name = "OnboardingAccent"
    accent.color = Color(0.95, 0.62, 0.25, 0.18)
    accent.set_anchors_preset(Control.PRESET_TOP_WIDE)
    accent.offset_bottom = 410.0
    accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _onboarding_layer.add_child(accent)

    var eyebrow := Label.new()
    eyebrow.text = "WELCOME TO THE CAMPAIGN"
    eyebrow.position = Vector2(40.0, 142.0)
    eyebrow.size = Vector2(640.0, 30.0)
    eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    eyebrow.add_theme_font_size_override("font_size", 18)
    eyebrow.add_theme_color_override("font_color", Color("#73e0d1"))
    _onboarding_layer.add_child(eyebrow)

    _onboarding_title = Label.new()
    _onboarding_title.name = "OnboardingTitle"
    _onboarding_title.position = Vector2(42.0, 226.0)
    _onboarding_title.size = Vector2(636.0, 72.0)
    _onboarding_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _onboarding_title.add_theme_font_size_override("font_size", 34)
    _onboarding_title.add_theme_color_override("font_color", Color("#fff0c6"))
    _onboarding_layer.add_child(_onboarding_title)

    var card := PanelContainer.new()
    card.name = "OnboardingCard"
    card.position = Vector2(58.0, 380.0)
    card.size = Vector2(604.0, 430.0)
    card.add_theme_stylebox_override("panel", _panel_style(Color("#103d52"), Color("#f7d47b"), 0.97))
    _onboarding_layer.add_child(card)

    _onboarding_body = Label.new()
    _onboarding_body.name = "OnboardingBody"
    _onboarding_body.position = Vector2(92.0, 438.0)
    _onboarding_body.size = Vector2(536.0, 276.0)
    _onboarding_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _onboarding_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _onboarding_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _onboarding_body.add_theme_font_size_override("font_size", 23)
    _onboarding_body.add_theme_color_override("font_color", Color("#d7ebe4"))
    _onboarding_layer.add_child(_onboarding_body)

    _onboarding_counter = Label.new()
    _onboarding_counter.name = "OnboardingCounter"
    _onboarding_counter.position = Vector2(42.0, 850.0)
    _onboarding_counter.size = Vector2(636.0, 34.0)
    _onboarding_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _onboarding_counter.add_theme_font_size_override("font_size", 16)
    _onboarding_counter.add_theme_color_override("font_color", Color("#f7d47b"))
    _onboarding_layer.add_child(_onboarding_counter)

    _onboarding_next_button = _make_menu_button("NEXT", Color("#0e665f"), Color("#ffd166"))
    _onboarding_next_button.name = "OnboardingNextButton"
    _onboarding_next_button.position = Vector2(180.0, 950.0)
    _onboarding_next_button.size = Vector2(360.0, 78.0)
    _onboarding_next_button.pressed.connect(next_onboarding_page)
    _onboarding_layer.add_child(_onboarding_next_button)

    var skip := Button.new()
    skip.name = "SkipOnboardingButton"
    skip.text = "SKIP INTRO"
    skip.position = Vector2(240.0, 1055.0)
    skip.size = Vector2(240.0, 52.0)
    skip.add_theme_font_size_override("font_size", 16)
    skip.add_theme_color_override("font_color", Color("#d7ebe4"))
    skip.flat = true
    skip.pressed.connect(skip_onboarding)
    _onboarding_layer.add_child(skip)


func _refresh_onboarding_page() -> void:
    var pages := [
        {"title": "CHOOSE YOUR ISLAND", "body": "World Map shows your campaign route. Choose an island that is unlocked and set your destination."},
        {"title": "CHOOSE A LEVEL", "body": "Island Map lays out the level path. Open levels are ready to play; locked levels unlock through campaign progress."},
        {"title": "COMPLETE THE ORDER", "body": "Normal To-Go orders are timed. Merge drinks and deliver every listed order before the clock reaches zero."},
        {"title": "VIP IS OPTIONAL", "body": "VIP orders are bonus mastery. Normal completion never requires VIP, and skipping it cannot block your progress."},
        {"title": "EARN, REPLAY, MASTER", "body": "Wins record stars, best score, and rewards. Replay levels to improve mastery while the campaign keeps your progress safe."},
    ]
    var page: Dictionary = pages[_onboarding_page]
    _onboarding_title.text = str(page["title"])
    _onboarding_body.text = str(page["body"])
    _onboarding_counter.text = "STEP %d / %d" % [_onboarding_page + 1, pages.size()]
    _onboarding_next_button.text = "FINISH" if _onboarding_page == pages.size() - 1 else "NEXT"


func _read_onboarding_state() -> Dictionary:
    if not FileAccess.file_exists(onboarding_storage_path):
        return {"schema_version": ONBOARDING_SCHEMA_VERSION, "completed": false}
    var file := FileAccess.open(onboarding_storage_path, FileAccess.READ)
    if file == null:
        return {"schema_version": ONBOARDING_SCHEMA_VERSION, "completed": false}
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary or int(parsed.get("schema_version", -1)) != ONBOARDING_SCHEMA_VERSION or not parsed.has("completed"):
        return {"schema_version": ONBOARDING_SCHEMA_VERSION, "completed": false}
    return {"schema_version": ONBOARDING_SCHEMA_VERSION, "completed": bool(parsed["completed"])}


func _save_onboarding_state(completed: bool) -> bool:
    onboarding_state = {"schema_version": ONBOARDING_SCHEMA_VERSION, "completed": completed}
    var file := FileAccess.open(onboarding_storage_path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(onboarding_state))
    return true


func _make_menu_button(label_text: String, background: Color, border: Color) -> Button:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(0.0, 82.0)
    button.add_theme_font_size_override("font_size", 26)
    var normal := _panel_style(background, border, 0.98)
    var hover := normal.duplicate()
    hover.bg_color = background.lightened(0.12)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_color_override("font_color", Color("#fff0c6"))
    return button


func _panel_style(background: Color, border: Color, alpha: float) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(background.r, background.g, background.b, alpha)
    style.border_color = border
    style.set_border_width_all(2)
    style.set_corner_radius_all(18)
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
    style.shadow_size = 8
    return style
