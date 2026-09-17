extends Node2D

## Evidence-only M06-R06 overlay. White marks the independently measured
## visible edge, cyan marks production, and gold marks rendered contact cases.

var manager: GameManager
var dataset: Dictionary = {}
var records: Array[Dictionary] = []
var title := ""


func _draw() -> void:
    if manager == null:
        return
    var size := manager.get_board_size()
    var source_samples: Array = dataset.get("samples_source_px", [])
    var independent_left := PackedVector2Array()
    var independent_right := PackedVector2Array()
    var production_left := PackedVector2Array()
    var production_right := PackedVector2Array()
    for sample in source_samples:
        var source_y := float(sample.get("y", 0.0))
        var y_pos := GameManager.source_to_viewport(Vector2(0.0, source_y), size).y
        var measured_left := clampf(GameManager.source_to_viewport(Vector2(float(sample.get("left", 0.0)), source_y), size).x, 0.0, size.x)
        var measured_right := clampf(GameManager.source_to_viewport(Vector2(float(sample.get("right", 0.0)), source_y), size).x, 0.0, size.x)
        var production := manager.get_table_rail_bounds_at_y(y_pos)
        independent_left.append(Vector2(measured_left, y_pos))
        independent_right.append(Vector2(measured_right, y_pos))
        production_left.append(Vector2(production.x, y_pos))
        production_right.append(Vector2(production.y, y_pos))

    draw_string(ThemeDB.fallback_font, Vector2(12.0, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(12.0, 52.0), "white=independent visible edge  cyan=production polyline  gold=rendered L01/L06/L12 contacts", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color.WHITE)
    draw_polyline(independent_left, Color(1.0, 0.96, 0.55, 0.95), 4.0, true)
    draw_polyline(independent_right, Color(1.0, 0.96, 0.55, 0.95), 4.0, true)
    draw_polyline(production_left, Color(0.20, 0.95, 1.0, 0.95), 3.0, true)
    draw_polyline(production_right, Color(0.20, 0.95, 1.0, 0.95), 3.0, true)
    for index in range(independent_left.size()):
        draw_circle(independent_left[index], 5.0, Color(1.0, 0.96, 0.55, 0.95))
        draw_circle(independent_right[index], 5.0, Color(1.0, 0.96, 0.55, 0.95))
    for record in records:
        var center := Vector2(float(record.get("x", 0.0)), float(record.get("y", 0.0)))
        var radius := float(record.get("radius", 0.0))
        var color := Color(1.0, 0.65, 0.12, 0.95)
        draw_arc(center, radius, 0.0, TAU, 40, color, 2.0, true)
        draw_string(ThemeDB.fallback_font, center + Vector2(-16.0, -radius - 6.0), str(record.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, color)
