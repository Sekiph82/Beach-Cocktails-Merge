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
        _rect(Rect2(to_go.position + Vector2(30.0, 78.0) * to_go.size.x / 210.0, Vector2(150.0, 100.0) * to_go.size.x / 210.0), inner_color)
        _rect(Rect2(to_go.position + Vector2(25.0, 180.0) * to_go.size.x / 210.0, Vector2(160.0, 25.0) * to_go.size.x / 210.0), inner_color)
        _rect(Rect2(to_go.position + Vector2(35.0, 215.0) * to_go.size.x / 210.0, Vector2(140.0, 35.0) * to_go.size.x / 210.0), inner_color)
    if next != null:
        _rect(Rect2(next.position + Vector2(28.0, 62.0) * next.size.x / 145.0, Vector2(90.0, 100.0) * next.size.x / 145.0), inner_color)
    if strip != null:
        var source_scale := strip.size.x / 2170.0
        var x_ranges := [[499.0, 658.0], [701.0, 860.0], [902.0, 1060.0], [1102.0, 1261.0], [1303.0, 1462.0], [1506.0, 1666.0]]
        for row in range(2):
            for column in range(6):
                var x_range: Array = x_ranges[column]
                var y_pos := 187.0 if row == 0 else 380.0
                var height := 155.0 if row == 0 else 156.0
                _rect(Rect2(strip.position + Vector2(x_range[0], y_pos) * source_scale, Vector2(x_range[1] - x_range[0], height) * source_scale), inner_color)
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
