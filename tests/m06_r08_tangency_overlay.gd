extends Node2D

var manager: GameManager
var records: Array[Dictionary] = []
var title := "M06-R08"


func _draw() -> void:
    if manager == null:
        return
    var rear_y := manager.rear_table_y
    draw_line(Vector2(0.0, rear_y), Vector2(manager.get_board_size().x, rear_y), Color(1.0, 0.25, 0.2, 0.95), 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(12.0, rear_y - 10.0), "COMMON REAR TABLE Y", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(1.0, 0.35, 0.25, 1.0))
    for record in records:
        if not [1, 6, 12].has(int(record.get("level", 0))):
            continue
        var center := Vector2(float(record.get("x", 0.0)), float(record.get("y", 0.0)))
        var radius := float(record.get("half_extent_y", 0.0))
        draw_arc(center, radius, 0.0, TAU, 48, Color(0.2, 1.0, 0.35, 0.85), 2.0, true)
        draw_line(Vector2(center.x - radius, rear_y), Vector2(center.x + radius, rear_y), Color(0.2, 1.0, 0.35, 0.75), 2.0)
        draw_string(ThemeDB.fallback_font, center + Vector2(-18.0, -radius - 8.0), "L%02d" % int(record.get("level", 0)), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.2, 1.0, 0.35, 1.0))
    draw_string(ThemeDB.fallback_font, Vector2(12.0, manager.get_board_size().y - 14.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)
