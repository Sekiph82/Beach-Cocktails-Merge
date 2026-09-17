extends SceneTree

## Deterministic M06-R05 full-tabletop boundary probe. It measures the
## production perspective rails, verifies radius-only center bounds, and saves
## clean/overlay captures with both-side L01/L06/L12 contact cases.

const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const DEPTHS := [
    {"name": "far", "t": 0.14},
    {"name": "middle", "t": 0.50},
    {"name": "near", "t": 0.84},
]
const LEVELS := [1, 6, 12]
const CAPTURE_DIR := "res://docs/evidence/m06_r05"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("M06-R05 main scene loads", packed != null)
    if packed == null:
        _finish()
        return

    var manager: GameManager = packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    await process_frame
    await _check_case(manager, "canonical_720x1280")
    manager.queue_free()
    await process_frame

    for case in CASES:
        if case.name == "canonical_720x1280":
            continue
        var viewport := SubViewport.new()
        viewport.size = case.size
        viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
        viewport.transparent_bg = false
        root.add_child(viewport)
        var responsive_manager := GameManager.new()
        viewport.add_child(responsive_manager)
        await process_frame
        await process_frame
        await process_frame
        await _check_case(responsive_manager, case.name)
        responsive_manager.queue_free()
        viewport.queue_free()
        await process_frame

    _finish()


func _check_case(manager: GameManager, label: String) -> void:
    var viewport_size := manager.get_board_size()
    _check("%s viewport is one required portrait case" % label, (label == "canonical_720x1280" and viewport_size == Vector2(720, 1280)) or (label == "taller_720x1440" and viewport_size == Vector2(720, 1440)) or (label == "shorter_wider_800x1280" and viewport_size == Vector2(800, 1280)))
    _check("%s accepted danger/launch Y remain unchanged" % label, is_equal_approx(manager.death_line_y, GameManager.source_to_viewport(Vector2(0.0, 1080.0), viewport_size).y) and is_equal_approx(manager.launch_y, GameManager.source_to_viewport(Vector2(0.0, 1136.0), viewport_size).y))
    _check("%s HUD is not consulted by horizontal bounds" % label, _bounds_source_has_no_hud_dependency())

    var records: Array[Dictionary] = []
    var case_ok := true
    for depth in DEPTHS:
        var y_pos: float = lerpf(manager.table_top_y, manager.table_bottom_y, float(depth.t))
        var rails := manager.get_table_rail_bounds_at_y(y_pos)
        var previous_width := rails.y - rails.x
        for level in LEVELS:
            var radius: float = Drink.collider_radius_for_level(level)
            var safe := manager.get_horizontal_bounds_at_y(y_pos, radius)
            var left_body_edge := safe.x - radius
            var right_body_edge := safe.y + radius
            var left_ok := is_equal_approx(left_body_edge, rails.x + GameManager.TABLE_SOLVER_EPSILON) and left_body_edge >= rails.x - 0.01
            var right_ok := is_equal_approx(right_body_edge, rails.y - GameManager.TABLE_SOLVER_EPSILON) and right_body_edge <= rails.y + 0.01
            var no_escape := safe.x - radius >= rails.x - 0.01 and safe.y + radius <= rails.y + 0.01
            case_ok = case_ok and left_ok and right_ok and no_escape
            records.append({"level": level, "depth": depth.name, "y": y_pos, "left": safe.x, "right": safe.y, "radius": radius, "left_body": left_body_edge, "right_body": right_body_edge})
            print("M06_R05_CONTACT label=%s depth=%s level=L%d rails=(%.3f,%.3f) radius=%.3f left_center=%.3f right_center=%.3f left_body=%.3f right_body=%.3f left_ok=%s right_ok=%s" % [label, depth.name, level, rails.x, rails.y, radius, safe.x, safe.y, left_body_edge, right_body_edge, left_ok, right_ok])
        case_ok = case_ok and previous_width > 0.0
    _check("%s L01/L06/L12 reach both visible tabletop edges at far/middle/near depths" % label, case_ok)
    _check("%s wide bounds use radius plus only epsilon" % label, absf(manager.get_horizontal_bounds_at_y(manager.table_bottom_y * 0.75, 42.0).x - (manager.get_table_rail_bounds_at_y(manager.table_bottom_y * 0.75).x + 42.0 + GameManager.TABLE_SOLVER_EPSILON)) < 0.01)
    _check("%s static wall inward-face model is outward-offset" % label, _wall_source_has_outward_offset())
    _check("%s no guide_line is present" % label, manager.get_node_or_null("guide_line") == null and not FileAccess.file_exists("res://assets/ui/guide_line.png"))

    var viewport := manager.get_viewport()
    await _save_capture(viewport, manager, label, records)
    print("M06_R05_CASE_SUMMARY label=%s viewport=%s table_top_y=%.3f table_bottom_y=%.3f danger_y=%.3f launch_y=%.3f" % [label, viewport_size, manager.table_top_y, manager.table_bottom_y, manager.death_line_y, manager.launch_y])


func _save_capture(viewport: Viewport, manager: GameManager, label: String, records: Array[Dictionary]) -> void:
    var image := viewport.get_texture().get_image()
    var clean_path := "%s/%s.png" % [CAPTURE_DIR, label]
    var clean_err := image.save_png(clean_path)
    _check("clean full-tabletop capture saved for %s" % label, clean_err == OK and FileAccess.file_exists(clean_path))
    var overlay := Node2D.new()
    overlay.set_script(load("res://tests/m06_r05_geometry_overlay.gd"))
    overlay.set("manager", manager)
    overlay.set("label", label)
    overlay.set("records", records)
    manager.add_child(overlay)
    await process_frame
    await process_frame
    var overlay_image := viewport.get_texture().get_image()
    var overlay_path := "%s/%s_geometry_overlay.png" % [CAPTURE_DIR, label]
    var overlay_err := overlay_image.save_png(overlay_path)
    _check("geometry overlay capture saved for %s" % label, overlay_err == OK and FileAccess.file_exists(overlay_path))
    overlay.queue_free()
    await process_frame
    print("M06_R05_CAPTURE label=%s clean=%s overlay=%s dimensions=%dx%d clean_error=%s overlay_error=%s" % [label, clean_path, overlay_path, image.get_width(), image.get_height(), clean_err, overlay_err])


func _bounds_source_has_no_hud_dependency() -> bool:
    var file := FileAccess.open("res://scripts/game_manager.gd", FileAccess.READ)
    if file == null:
        return false
    var source := file.get_as_text()
    var start := source.find("func get_horizontal_bounds_at_y")
    var end := source.find("func clamp_position_to_board", start)
    if start < 0 or end < start:
        return false
    var function_source := source.substr(start, end - start)
    return not ("_hud" in function_source or "_best_panel" in function_source or "_score_panel" in function_source or "ToGoOrdersPanel" in function_source)


func _wall_source_has_outward_offset() -> bool:
    var file := FileAccess.open("res://scripts/game_manager.gd", FileAccess.READ)
    if file == null:
        return false
    var source := file.get_as_text()
    return "var outward := Vector2(-direction.y, direction.x).normalized()" in source and "var outward := Vector2(direction.y, -direction.x).normalized()" in source and "a + outward" in source and "b + outward" in source


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M06_R05_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M06_R05_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M06_R05_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M06_R05_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
