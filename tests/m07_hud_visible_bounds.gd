extends Node2D

## Evidence-only overlay. It derives alpha bounds from imported texture pixels
## and text bounds from the active Godot font metrics; it is not production UI.

var manager: GameManager
var layout: Dictionary
var title := ""

func _ready() -> void:
    z_index = 45
    queue_redraw()

func _draw() -> void:
    if manager == null:
        return
    var hud := manager.get_node_or_null("UI/HUD") as Control
    if hud == null:
        return
    var visible_color := Color(1.0, 0.25, 0.85, 0.95)
    var box_color := Color(0.2, 1.0, 0.4, 0.95)
    var best := hud.get_node_or_null("BestScorePanel") as Control
    var score := hud.get_node_or_null("ScorePanel") as Control
    var to_go := hud.get_node_or_null("ToGoOrdersPanel") as Control
    var next := hud.get_node_or_null("NextPanel") as Control
    var strip := hud.get_node_or_null("ProgressionStrip") as Control
    _draw_label_bounds(best, manager._best_value, visible_color)
    _draw_label_bounds(score, manager._score_value, visible_color)
    _draw_sprite_bounds(to_go, manager._to_go_target_sprite, visible_color)
    _draw_label_bounds(to_go, manager._to_go_level_label, visible_color)
    _draw_label_bounds(to_go, manager._to_go_reward_label, visible_color)
    _draw_sprite_bounds(next, manager._next_sprite, visible_color)
    if strip != null:
        for icon in manager._progression_icons:
            _draw_sprite_bounds(strip, icon, visible_color)
    _draw_dataset_boxes(hud, best, score, to_go, next, strip, box_color)
    draw_string(ThemeDB.fallback_font, Vector2(12.0, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 17, Color.WHITE)

func _draw_dataset_boxes(hud: Control, best: Control, score: Control, to_go: Control, next: Control, strip: Control, color: Color) -> void:
    _draw_panel_box(best, "BestScorePanel", "value", hud, color)
    _draw_panel_box(score, "ScorePanel", "value", hud, color)
    _draw_panel_box(to_go, "ToGoOrdersPanel", "target", hud, color)
    _draw_panel_box(to_go, "ToGoOrdersPanel", "level", hud, color)
    _draw_panel_box(to_go, "ToGoOrdersPanel", "reward", hud, color)
    _draw_panel_box(next, "NextPanel", "inset", hud, color)
    if strip == null:
        return
    var progression: Dictionary = layout.get("panels", {}).get("ProgressionStrip", {})
    var cells: Array = progression.get("cells", [])
    for cell_data in cells:
        var cell_rect := _relative_cell_rect(strip, cell_data)
        _rect(Rect2(strip.position + cell_rect.position, cell_rect.size), color)

func _draw_panel_box(panel: Control, panel_name: String, key: String, hud: Control, color: Color) -> void:
    if panel == null:
        return
    var panel_data: Dictionary = layout.get("panels", {}).get(panel_name, {})
    var values: Array = panel_data.get(key, [])
    if values.size() != 4:
        return
    var rect := Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
    _rect(Rect2(panel.position + rect.position, rect.size), color)

func _draw_label_bounds(panel: Control, label: Label, color: Color) -> void:
    var rect := _label_visible_rect(label)
    if panel != null:
        rect.position += panel.position
    _rect(rect, color)

func _draw_sprite_bounds(panel: Control, sprite: Sprite2D, color: Color) -> void:
    var rect := _sprite_visible_rect(sprite)
    if panel != null:
        rect.position += panel.position
    _rect(rect, color)

func _label_visible_rect(label: Label) -> Rect2:
    if label == null:
        return Rect2()
    var font := label.get_theme_font("font")
    var size := label.get_theme_font_size("font_size")
    var measured := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size)
    var origin := label.position + Vector2((label.size.x - measured.x) * 0.5, (label.size.y - measured.y) * 0.5)
    var shadow_x := float(label.get_theme_constant("shadow_offset_x"))
    var shadow_y := float(label.get_theme_constant("shadow_offset_y"))
    var left := minf(origin.x, origin.x + shadow_x)
    var top := minf(origin.y, origin.y + shadow_y)
    var right := maxf(origin.x + measured.x, origin.x + measured.x + shadow_x)
    var bottom := maxf(origin.y + measured.y, origin.y + measured.y + shadow_y)
    return Rect2(left, top, right - left, bottom - top)

func _sprite_visible_rect(sprite: Sprite2D) -> Rect2:
    if sprite == null or sprite.texture == null:
        return Rect2()
    var image := sprite.texture.get_image()
    var used := image.get_used_rect()
    var texture_size := Vector2(sprite.texture.get_width(), sprite.texture.get_height())
    var scale := sprite.scale
    var position := sprite.position + (Vector2(used.position) - texture_size * 0.5) * scale
    return Rect2(position, Vector2(used.size) * scale)

func _relative_cell_rect(strip: Control, cell_data: Array) -> Rect2:
    var width_ratio := float(cell_data[2])
    var x_ratio := float(cell_data[2] - width_ratio)
    # cell_data stores the right edge in slot 2 and slot width in slot 4.
    x_ratio = float(cell_data[2]) - float(cell_data[4])
    var y_ratio := float(cell_data[3])
    var cell_width := strip.size.x * float(cell_data[4])
    var cell_height := strip.size.y * float(cell_data[5])
    return Rect2(strip.size.x * x_ratio, strip.size.y * y_ratio, cell_width, cell_height)

func _rect(rect: Rect2, color: Color) -> void:
    draw_rect(rect, color, false, 2.0)
