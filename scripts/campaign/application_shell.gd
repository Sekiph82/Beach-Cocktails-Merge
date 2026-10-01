class_name ApplicationShell
extends Control

## The single application-level shell. It owns the menu and exactly one
## CampaignNavigationController instance; campaign state remains inside the
## existing navigation/campaign authorities.

signal campaign_requested
signal settings_requested
signal main_menu_entered

const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")

var campaign_navigation: CampaignNavigationController
var current_view := "MAIN_MENU"

var _menu_layer: Control
var _menu_play_button: Button
var _menu_settings_button: Button
var _status_label: Label


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_menu()
    campaign_navigation = NAVIGATION_SCENE.instantiate() as CampaignNavigationController
    campaign_navigation.name = "CampaignNavigation"
    campaign_navigation.main_menu_requested.connect(_on_navigation_main_menu_requested)
    add_child(campaign_navigation)
    campaign_navigation.visible = false


func get_campaign_navigation() -> CampaignNavigationController:
    return campaign_navigation


func get_current_view() -> String:
    return current_view


func is_main_menu_visible() -> bool:
    return current_view == "MAIN_MENU" and _menu_layer != null and _menu_layer.visible


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
    if campaign_navigation == null:
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
