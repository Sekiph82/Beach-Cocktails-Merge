extends Node2D

var manager: GameManager
var title := ""

func _ready() -> void:
    z_index = 40
    queue_redraw()

func _draw() -> void:
    if manager == null:
        return
    var hud := manager.get_node_or_null("UI/HUD") as Control
    if hud == null:
        return
    var outer_color := Color(0.25, 0.95, 0.95, 0.95)
    var inner_color := Color(1.0, 0.85, 0.15, 0.95)
    _box(hud.get_node_or_null("Logo") as Control, outer_color)
    _box(hud.get_node_or_null("BestScorePanel") as Control, outer_color)
    _box(hud.get_node_or_null("ScorePanel") as Control, outer_color)
    var to_go := hud.get_node_or_null("ToGoOrdersPanel") as Control
    var next := hud.get_node_or_null("NextPanel") as Control
    var strip := hud.get_node_or_null("ProgressionStrip") as Control
    _box(to_go, outer_color)
    _box(next, outer_color)
    _box(strip, outer_color)
    if to_go != null:
        _rect(Rect2(to_go.position + Vector2(to_go.size.x * 0.29, to_go.size.y * 0.12), Vector2(to_go.size.x * 0.42, to_go.size.y * 0.52)), inner_color)
        _rect(Rect2(to_go.position + Vector2(to_go.size.x * 0.20, to_go.size.y * 0.58), Vector2(to_go.size.x * 0.60, to_go.size.y * 0.20)), inner_color)
        _rect(Rect2(to_go.position + Vector2(to_go.size.x * 0.24, to_go.size.y * 0.77), Vector2(to_go.size.x * 0.52, to_go.size.y * 0.19)), inner_color)
    if next != null:
        _rect(Rect2(next.position + Vector2(next.size.x * 0.16, next.size.y * 0.16), Vector2(next.size.x * 0.68, next.size.y * 0.70)), inner_color)
    if strip != null:
        var cell_width := strip.size.x / 6.0
        var cell_height := strip.size.y * 0.34
        for row in range(2):
            for column in range(6):
                _rect(Rect2(strip.position + Vector2(column * cell_width + 3.0, strip.size.y * (0.08 + row * 0.46)), Vector2(cell_width - 6.0, cell_height)), inner_color)
    var rail := Color(0.25, 0.95, 0.95, 0.9)
    draw_line(Vector2(0.0, manager.table_top_y), Vector2(manager.get_board_size().x, manager.table_top_y), rail, 2.0)
    draw_line(Vector2(0.0, manager.table_bottom_y), Vector2(manager.get_board_size().x, manager.table_bottom_y), rail, 2.0)
    draw_line(Vector2(0.0, manager.death_line_y), Vector2(manager.get_board_size().x, manager.death_line_y), Color(1.0, 0.2, 0.25, 0.95), 3.0)
    draw_circle(Vector2(manager.get_board_size().x * 0.5, manager.launch_y), 8.0, Color(1.0, 0.85, 0.15, 0.95))
    draw_string(ThemeDB.fallback_font, Vector2(12.0, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 17, Color.WHITE)

func _box(node: Control, color: Color) -> void:
    if node == null:
        return
    _rect(Rect2(node.position, node.size), color)

func _rect(rect: Rect2, color: Color) -> void:
    draw_rect(rect, color, false, 2.0)

