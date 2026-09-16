extends Node2D

var manager: GameManager
var title := ""


func _draw() -> void:
    if manager == null:
        return
    var size := manager.get_board_size()
    var top := manager.get_table_rail_bounds_at_y(manager.table_top_y)
    var middle_y := lerpf(manager.table_top_y, manager.table_bottom_y, 0.5)
    var middle := manager.get_table_rail_bounds_at_y(middle_y)
    var bottom := manager.get_table_rail_bounds_at_y(manager.table_bottom_y)
    var rail := Color(0.20, 0.95, 1.0, 0.85)
    var danger := Color(1.0, 0.30, 0.30, 0.95)
    var launch := Color(1.0, 0.84, 0.25, 0.95)
    draw_string(ThemeDB.fallback_font, Vector2(18.0, 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color.WHITE)
    draw_line(Vector2(top.x, manager.table_top_y), Vector2(bottom.x, manager.table_bottom_y), rail, 4.0)
    draw_line(Vector2(top.y, manager.table_top_y), Vector2(bottom.y, manager.table_bottom_y), rail, 4.0)
    draw_line(Vector2(top.x, manager.table_top_y), Vector2(top.y, manager.table_top_y), rail, 4.0)
    draw_line(Vector2(bottom.x, manager.table_bottom_y), Vector2(bottom.y, manager.table_bottom_y), rail, 4.0)
    draw_line(Vector2(middle.x, middle_y), Vector2(middle.y, middle_y), Color(0.35, 0.95, 0.70, 0.8), 3.0)
    draw_line(Vector2(top.x, manager.death_line_y), Vector2(top.y, manager.death_line_y), danger, 5.0)
    draw_circle(Vector2(size.x * 0.5, manager.launch_y), 16.0, launch)
    draw_string(ThemeDB.fallback_font, Vector2(top.x + 8.0, manager.table_top_y - 10.0), "TOP", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, rail)
    draw_string(ThemeDB.fallback_font, Vector2(middle.x + 8.0, middle_y - 10.0), "MID", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(0.35, 0.95, 0.70, 0.9))
    draw_string(ThemeDB.fallback_font, Vector2(bottom.x + 8.0, manager.table_bottom_y - 10.0), "BOTTOM", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, rail)
    draw_string(ThemeDB.fallback_font, Vector2(top.x + 8.0, manager.death_line_y - 10.0), "DANGER", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, danger)
    draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 + 20.0, manager.launch_y + 6.0), "LAUNCH", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, launch)
