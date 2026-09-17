extends Node2D

## Evidence-only overlay for M06-R05. It does not participate in production
## physics or input and shows the visible edge/wall-face model plus contacts.

var manager: GameManager
var label := ""
var records: Array[Dictionary] = []


func _draw() -> void:
    if manager == null:
        return
    var size := manager.get_board_size()
    var top := manager.get_table_rail_bounds_at_y(manager.table_top_y)
    var bottom := manager.get_table_rail_bounds_at_y(manager.table_bottom_y)
    var middle_y := lerpf(manager.table_top_y, manager.table_bottom_y, 0.5)
    var middle := manager.get_table_rail_bounds_at_y(middle_y)
    var edge_color := Color(0.20, 0.95, 1.0, 0.95)
    var wall_color := Color(0.30, 1.0, 0.55, 0.95)
    var contact_color := Color(1.0, 0.82, 0.18, 0.90)
    draw_string(ThemeDB.fallback_font, Vector2(16.0, 30.0), "M06-R05 full tabletop — %s" % label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(16.0, 56.0), "HUD ignored; cyan=visible edge, green=wall inward face, gold=body tangent", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)
    draw_line(Vector2(top.x, manager.table_top_y), Vector2(bottom.x, manager.table_bottom_y), edge_color, 4.0)
    draw_line(Vector2(top.y, manager.table_top_y), Vector2(bottom.y, manager.table_bottom_y), edge_color, 4.0)
    draw_line(Vector2(top.x, manager.table_top_y), Vector2(top.y, manager.table_top_y), edge_color, 4.0)
    draw_line(Vector2(bottom.x, manager.table_bottom_y), Vector2(bottom.y, manager.table_bottom_y), edge_color, 4.0)
    draw_line(Vector2(top.x, manager.table_top_y), Vector2(bottom.x, manager.table_bottom_y), wall_color, 2.0)
    draw_line(Vector2(top.y, manager.table_top_y), Vector2(bottom.y, manager.table_bottom_y), wall_color, 2.0)
    draw_line(Vector2(middle.x, middle_y), Vector2(middle.y, middle_y), Color(0.45, 1.0, 0.70, 0.75), 2.0)
    draw_line(Vector2(top.x, manager.death_line_y), Vector2(top.y, manager.death_line_y), Color(1.0, 0.25, 0.25, 0.95), 4.0)
    draw_circle(Vector2(size.x * 0.5, manager.launch_y), 15.0, Color(1.0, 0.82, 0.18, 0.8))
    for record in records:
        var y: float = record.y
        var radius: float = record.radius
        var left: float = record.left
        var right: float = record.right
        draw_circle(Vector2(left, y), radius, Color(1.0, 0.82, 0.18, 0.16))
        draw_arc(Vector2(left, y), radius, 0.0, TAU, 32, contact_color, 2.0)
        draw_circle(Vector2(right, y), radius, Color(1.0, 0.82, 0.18, 0.16))
        draw_arc(Vector2(right, y), radius, 0.0, TAU, 32, contact_color, 2.0)
        draw_string(ThemeDB.fallback_font, Vector2(left - 18.0, y - radius - 5.0), "L%d" % record.level, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, contact_color)
        draw_string(ThemeDB.fallback_font, Vector2(right - 18.0, y - radius - 5.0), "L%d" % record.level, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, contact_color)
