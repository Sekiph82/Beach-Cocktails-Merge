extends SceneTree

## Active M06-R08 probe. The rear boundary is independent evidence from the
## measured background dataset; each body half-extent comes from that drink's
## active CircleShape2D, never from garnish or transparent texture margins.

const DATASET_PATH := "res://docs/evidence/r09/independent_rear_table_measurement.json"
const CAPTURE_DIR := "res://docs/evidence/m06_r08"
const OVERLAY_SCRIPT := "res://tests/m06_r08_tangency_overlay.gd"
const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const REPRESENTATIVE_LEVELS := [1, 6, 12]
const TANGENCY_TOLERANCE := 0.01

var failures: Array[String] = []
var dataset: Dictionary = {}


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    dataset = _load_dataset()
    _check("M06-R08 independent rear dataset loads", not dataset.is_empty())
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("M06-R08 main scene loads", packed != null)
    if packed == null:
        _finish()
        return

    for case in CASES:
        var viewport: Viewport = root
        var manager: GameManager
        if case.name == "canonical_720x1280":
            manager = packed.instantiate() as GameManager
            root.add_child(manager)
        else:
            var sub := SubViewport.new()
            sub.size = case.size
            sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
            sub.transparent_bg = false
            root.add_child(sub)
            viewport = sub
            manager = GameManager.new()
            sub.add_child(manager)
        await process_frame
        await process_frame
        await process_frame
        var records := _check_all_levels(manager, case.name)
        await _save_capture(viewport, manager, case.name, records, false)
        await _save_capture(viewport, manager, case.name, records, true)
        manager.queue_free()
        await process_frame
        if viewport != root:
            viewport.queue_free()
            await process_frame
    _finish()


func _check_all_levels(manager: GameManager, label: String) -> Array[Dictionary]:
    var source_rear_y := float(dataset.get("actual_visible_rear_table_source_y", 457.0))
    var independent_rear_y := GameManager.source_to_viewport(Vector2(0.0, source_rear_y), manager.get_board_size()).y
    _check("%s uses one common rear_table_y" % label, absf(manager.rear_table_y - independent_rear_y) <= 0.01 and is_equal_approx(manager.rear_table_y, manager.table_top_y))
    print("M06_R08_REAR_STATE label=%s rear_table_y=%.3f source_y=%.1f" % [label, manager.rear_table_y, source_rear_y])

    var records: Array[Dictionary] = []
    var target_centers: Array[float] = []
    for level in range(1, 13):
        var probe := Drink.create(level)
        var shape: CollisionShape2D = null
        for child in probe.get_children():
            if child is CollisionShape2D:
                shape = child as CollisionShape2D
                break
        var circle := shape.shape as CircleShape2D if shape != null else null
        var body_half_extent_y := circle.radius if circle != null else -1.0
        var expected_center_y := independent_rear_y + body_half_extent_y
        var helper_center_y := manager.get_rear_target_center_y(body_half_extent_y)
        var visible_body_top_y := expected_center_y - body_half_extent_y
        var tangency_error := visible_body_top_y - independent_rear_y
        var drink := manager.spawn_drink(level, Vector2(manager.get_board_size().x * 0.5, expected_center_y), false)
        var runtime_contact_center_y := drink.position.y - GameManager.TABLE_SOLVER_EPSILON if is_instance_valid(drink) else INF
        var runtime_top_y := runtime_contact_center_y - body_half_extent_y
        var runtime_error := runtime_top_y - independent_rear_y
        var formula_ok := circle != null and absf(helper_center_y - expected_center_y) <= TANGENCY_TOLERANCE and absf(tangency_error) <= TANGENCY_TOLERANCE and absf(runtime_error) <= 0.01 and expected_center_y != independent_rear_y
        _check("%s L%02d common rear tangency formula" % [label, level], formula_ok)
        target_centers.append(expected_center_y)
        var record := {"level": level, "x": drink.position.x if is_instance_valid(drink) else INF, "y": runtime_contact_center_y, "half_extent_y": body_half_extent_y, "rear_table_y": independent_rear_y, "rear_target_center_y": expected_center_y, "visible_body_top_y": runtime_top_y, "tangency_error": runtime_error}
        records.append(record)
        print("M06_R08_TANGENCY label=%s level=L%02d rear_table_y=%.3f body_half_extent_y=%.3f rear_target_center_y=%.3f visible_body_top_y=%.3f tangency_error=%.3f" % [label, level, independent_rear_y, body_half_extent_y, expected_center_y, runtime_top_y, runtime_error])
        probe.queue_free()
    _check("%s level-derived rear targets are not one shared center Y" % label, target_centers.max() > target_centers.min())

    for side in ["left", "right"]:
        var level: int = 1 if side == "left" else 12
        var radius := Drink.collider_radius_for_level(level)
        var target_y := independent_rear_y + radius
        var bounds := manager.get_horizontal_bounds_at_y(target_y, radius)
        var x_pos := bounds.x if side == "left" else bounds.y
        var drink := manager.spawn_drink(level, Vector2(x_pos, target_y), false)
        var actual_contact_y := drink.position.y - GameManager.TABLE_SOLVER_EPSILON if is_instance_valid(drink) else INF
        var top_y := actual_contact_y - radius
        var ok := is_instance_valid(drink) and absf(top_y - independent_rear_y) <= 0.01
        _check("%s rear-%s representative body remains tangent" % [label, side], ok)
        print("M06_R08_CORNER label=%s side=%s level=L%02d center=(%.3f,%.3f) body_top_y=%.3f rear_table_y=%.3f tangency_error=%.3f" % [label, side, level, drink.position.x if is_instance_valid(drink) else INF, actual_contact_y, top_y, independent_rear_y, top_y - independent_rear_y])
        records.append({"level": level, "side": side, "x": drink.position.x if is_instance_valid(drink) else INF, "y": actual_contact_y, "half_extent_y": radius, "rear_table_y": independent_rear_y, "rear_target_center_y": target_y, "visible_body_top_y": top_y, "tangency_error": top_y - independent_rear_y})
    return records


func _save_capture(viewport: Viewport, manager: GameManager, label: String, records: Array[Dictionary], overlay: bool) -> void:
    var overlay_node: Node2D
    if overlay:
        overlay_node = Node2D.new()
        overlay_node.set_script(load(OVERLAY_SCRIPT))
        overlay_node.set("manager", manager)
        overlay_node.set("records", records)
        overlay_node.set("title", "M06-R08 common rear body tangency — %s" % label)
        manager.add_child(overlay_node)
        await process_frame
        await process_frame
    var image := viewport.get_texture().get_image()
    var suffix := "_tangency_overlay" if overlay else ""
    var path := "%s/%s%s.png" % [CAPTURE_DIR, label, suffix]
    var error := image.save_png(path)
    _check("%s capture saved" % path, error == OK and FileAccess.file_exists(path))
    print("M06_R08_CAPTURE label=%s overlay=%s dimensions=%dx%d path=%s error=%s" % [label, overlay, image.get_width(), image.get_height(), path, error])
    if overlay:
        overlay_node.queue_free()
        await process_frame


func _load_dataset() -> Dictionary:
    var file := FileAccess.open(DATASET_PATH, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M06_R08_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M06_R08_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M06_R08_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M06_R08_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
