extends SceneTree

## Deterministic active M06 tabletop probe. It compares production geometry with a static
## independent five-sample visible-edge dataset and captures real contact nodes.

const DATASET_PATH := "res://docs/evidence/r10/v05_owner_envelope_measurement.json"
const CAPTURE_DIR := "res://docs/evidence/r10/v05_tabletop"
const OVERLAY_SCRIPT := "res://tests/m06_r06_geometry_overlay.gd"
const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const CONTACT_LEVELS := [1, 6, 12]
const CONTACT_SAMPLE_INDEXES := [0, 1, 2]

var failures: Array[String] = []
var dataset: Dictionary = {}


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    dataset = _load_dataset()
    _check("M06-R07 independent five-sample dataset loads", not dataset.is_empty())
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("M06-R07 main scene loads", packed != null)
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
        _check_case(manager, case.name)
        await _save_capture(viewport, manager, case.name, false)
        var records := _spawn_contact_cases(manager)
        await process_frame
        await process_frame
        await _save_capture(viewport, manager, case.name, true, records)
        manager.queue_free()
        await process_frame
        if viewport != root:
            viewport.queue_free()
            await process_frame
    _finish()


func _check_case(manager: GameManager, label: String) -> void:
    var case_data: Dictionary = dataset.get("viewports", {}).get(label, {})
    var expected_samples: Array = case_data.get("samples_viewport_px", [])
    var source_samples: Array = dataset.get("samples_source_px", [])
    _check("%s has five independent Y samples" % label, source_samples.size() >= 5 and expected_samples.size() >= 5)
    var tolerance := float(dataset.get("source_background", {}).get("tolerance_px", 3.0))
    var all_edges_ok := true
    for index in range(mini(source_samples.size(), expected_samples.size())):
        var sample: Dictionary = source_samples[index]
        var expected: Dictionary = expected_samples[index]
        var y_pos := GameManager.source_to_viewport(Vector2(0.0, float(sample.y)), manager.get_board_size()).y
        var actual := manager.get_table_rail_bounds_at_y(y_pos)
        var expected_bounds := Vector2(float(expected.left), float(expected.right))
        var delta := actual.distance_to(expected_bounds)
        all_edges_ok = all_edges_ok and delta <= tolerance and actual.x >= -0.01 and actual.y <= manager.get_board_size().x + 0.01
        print("M06_R07_EDGE label=%s sample=%s source_y=%.1f viewport_y=%.3f measured=(%.3f,%.3f) production=(%.3f,%.3f) delta=%.3f tolerance=%.1f" % [label, sample.name, float(sample.y), y_pos, expected_bounds.x, expected_bounds.y, actual.x, actual.y, delta, tolerance])
    _check("%s production follows independent visible edges at five depths" % label, all_edges_ok)
    _check("%s corrected geometry is piecewise and HUD-independent" % label, _source_has_polyline_model() and not _bounds_source_has_hud_dependency())
    _check("%s danger and launch Y remain accepted" % label, is_equal_approx(manager.death_line_y, GameManager.source_to_viewport(Vector2(0.0, 1080.0), manager.get_board_size()).y) and is_equal_approx(manager.launch_y, GameManager.source_to_viewport(Vector2(0.0, 1136.0), manager.get_board_size()).y))
    _check("%s no extra wall-width inset" % label, absf(manager.get_horizontal_bounds_at_y(manager.table_bottom_y * 0.75, 42.0).x - (manager.get_table_rail_bounds_at_y(manager.table_bottom_y * 0.75).x + 42.0 + GameManager.TABLE_SOLVER_EPSILON)) < 0.01)
    print("M06_R07_STATE label=%s viewport=%s table_top_y=%.3f table_bottom_y=%.3f danger_y=%.3f launch_y=%.3f" % [label, manager.get_board_size(), manager.table_top_y, manager.table_bottom_y, manager.death_line_y, manager.launch_y])


func _spawn_contact_cases(manager: GameManager) -> Array[Dictionary]:
    var records: Array[Dictionary] = []
    var source_samples: Array = dataset.get("samples_source_px", [])
    for index in range(CONTACT_LEVELS.size()):
        var level: int = CONTACT_LEVELS[index]
        var sample: Dictionary = source_samples[CONTACT_SAMPLE_INDEXES[index]]
        var requested_y := GameManager.source_to_viewport(Vector2(0.0, float(sample.y)), manager.get_board_size()).y
        var radius := Drink.collider_radius_for_level(level)
        # A physical body must keep its full radius below the top stop. The
        # far contact case therefore uses the first radius-safe Y at that
        # measured rear depth, while retaining the same visible side edge.
        var y_pos := maxf(requested_y, manager.table_top_y + radius + GameManager.TABLE_SOLVER_EPSILON)
        var bounds := manager.get_horizontal_edge_contact_bounds_at_y(y_pos, level)
        for side in ["left", "right"]:
            var x_pos := bounds.x if side == "left" else bounds.y
            var drink := manager.spawn_drink(level, Vector2(x_pos, y_pos), false)
            var actual := drink.position if is_instance_valid(drink) else Vector2.INF
            var record := {"label": "%s L%02d" % [side, level], "x": actual.x, "y": actual.y, "radius": radius}
            records.append(record)
            var expected_x := x_pos
            _check("rendered %s contact remains at visible edge" % record.label, is_instance_valid(drink) and absf(actual.x - expected_x) <= 0.01 and absf(actual.y - y_pos) <= 0.01)
            print("M06_R07_CONTACT label=%s source_y=%.1f center=(%.3f,%.3f) radius=%.3f body_edges=(%.3f,%.3f) rails=%s" % [record.label, float(sample.y), actual.x, actual.y, radius, actual.x - radius, actual.x + radius, manager.get_table_rail_bounds_at_y(y_pos)])
    return records


func _save_capture(viewport: Viewport, manager: GameManager, label: String, overlay: bool, records: Array[Dictionary] = []) -> void:
    var texture := viewport.get_texture()
    if texture == null:
        _check("capture texture exists for %s" % label, false)
        return
    if overlay:
        var node := Node2D.new()
        node.set_script(load(OVERLAY_SCRIPT))
        node.set("manager", manager)
        node.set("dataset", dataset)
        node.set("records", records)
        node.set("title", "M06-R07 independent inner tabletop edge — %s" % label)
        manager.add_child(node)
        await process_frame
        await process_frame
    var image := texture.get_image()
    if image == null:
        print("M06_R07_CAPTURE_SKIPPED label=%s reason=headless_renderer_no_image" % label)
        return
    var suffix := "_geometry_overlay" if overlay else ""
    var path := "%s/%s%s.png" % [CAPTURE_DIR, label, suffix]
    var error := image.save_png(path)
    _check("%s capture saved" % path, error == OK and FileAccess.file_exists(path))
    print("M06_R07_CAPTURE label=%s overlay=%s dimensions=%dx%d path=%s error=%s" % [label, overlay, image.get_width(), image.get_height(), path, error])


func _load_dataset() -> Dictionary:
    var file := FileAccess.open(DATASET_PATH, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}


func _source_has_polyline_model() -> bool:
    var file := FileAccess.open("res://scripts/game_manager.gd", FileAccess.READ)
    if file == null:
        return false
    var source := file.get_as_text()
    return "TABLE_LEFT_EDGE_SOURCE_POINTS" in source and "_piecewise_source_x" in source and "for index in range(left_points.size() - 1)" in source


func _bounds_source_has_hud_dependency() -> bool:
    var file := FileAccess.open("res://scripts/game_manager.gd", FileAccess.READ)
    if file == null:
        return true
    var source := file.get_as_text()
    var start := source.find("func get_horizontal_bounds_at_y")
    var end := source.find("func clamp_position_to_board", start)
    if start < 0 or end < 0:
        return true
    var body := source.substr(start, end - start)
    return "_hud" in body or "_best_panel" in body or "_score_panel" in body or "ToGoOrdersPanel" in body


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M06_R07_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M06_R07_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M06_R07_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M06_R07_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
