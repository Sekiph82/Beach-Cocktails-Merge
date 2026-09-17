extends SceneTree

## R09 independent rear-boundary validation.
## The expected Y comes from a read-only pixel measurement of the canonical
## background, not from production geometry or helper output.

const MEASUREMENT_PATH := "res://docs/evidence/r09/independent_rear_table_measurement.json"
const CAPTURE_DIR := "res://docs/evidence/r09"
const BACKGROUND_PATH := "res://assets/environment/game_board_background.png"
const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)}
]
const LEVELS := [1, 6, 12]
const RUNTIME_PIXEL_TOLERANCE := 3.0

var failures: Array[String] = []
var measurement: Dictionary = {}


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    measurement = _load_measurement()
    _check("independent rear measurement loads", not measurement.is_empty())
    var expected_source_y := float(measurement.get("actual_visible_rear_table_source_y", -1.0))
    _check("independent rear measurement has positive source Y", expected_source_y > 0.0)
    var background := load(BACKGROUND_PATH) as Texture2D
    _check("owner-approved background loads", background != null and background.get_width() == 1024 and background.get_height() == 1536)

    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("production main scene loads", packed != null)
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

        var expected_rear_y := GameManager.source_to_viewport(Vector2(0.0, expected_source_y), manager.get_board_size()).y
        var detected_rear_y := _detect_runtime_rear_y(viewport.get_texture().get_image(), manager.get_board_size(), expected_rear_y)
        _check("%s runtime wood boundary independently matches measured Y" % case.name, detected_rear_y >= 0.0 and absf(detected_rear_y - expected_rear_y) <= RUNTIME_PIXEL_TOLERANCE)
        _check("%s TopRail uses measured common rear boundary" % case.name, absf(manager.table_top_y - expected_rear_y) <= 0.01 and absf(manager.rear_table_y - expected_rear_y) <= 0.01)
        print("R09_REAR_BOUNDARY label=%s independent_source_y=%.1f expected_runtime_y=%.3f detected_runtime_y=%.3f production_top_y=%.3f production_rear_y=%.3f" % [case.name, expected_source_y, expected_rear_y, detected_rear_y, manager.table_top_y, manager.rear_table_y])

        for level in LEVELS:
            var radius := Drink.collider_radius_for_level(level)
            var target_y := expected_rear_y + radius
            var bounds := manager.get_horizontal_bounds_at_y(target_y, radius)
            var xs := [bounds.x, (bounds.x + bounds.y) * 0.5, bounds.y]
            for x_pos in xs:
                var drink := manager.spawn_drink(level, Vector2(x_pos, target_y), false)
                var contact_y := drink.position.y - GameManager.TABLE_SOLVER_EPSILON
                var visible_body_top_y := contact_y - radius
                var error := visible_body_top_y - expected_rear_y
                _check("%s L%02d rear body tangent at x=%.1f" % [case.name, level, x_pos], absf(error) <= 0.01)
                print("R09_REAR_TANGENCY label=%s level=L%02d x=%.3f radius=%.3f rear_target_center_y=%.3f visible_body_top_y=%.3f independent_rear_y=%.3f error=%.3f" % [case.name, level, x_pos, radius, target_y, visible_body_top_y, expected_rear_y, error])
        await process_frame
        await _save_capture(viewport, case.name)
        for child in manager.world.get_children():
            if child is Drink:
                (child as Drink).queue_free()
        await process_frame
        await _save_contact_capture(viewport, manager, case.name, expected_rear_y)
        manager.queue_free()
        await process_frame
        if viewport != root:
            viewport.queue_free()
            await process_frame
    _finish()


func _detect_runtime_rear_y(image: Image, viewport_size: Vector2, expected_y: float) -> float:
    var scale := GameManager.background_scale_for_viewport(viewport_size)
    var offset := GameManager.background_offset_for_viewport(viewport_size)
    var sample_xs: Array[int] = []
    for source_x in range(288, 801, 32):
        var screen_x := clampi(int(round(offset.x + float(source_x) * scale)), 0, image.get_width() - 1)
        sample_xs.append(screen_x)
    for y in range(maxi(0, int(floor(expected_y)) - 6), mini(image.get_height(), int(ceil(expected_y)) + 7)):
        var woodish := 0
        for x in sample_xs:
            var color := image.get_pixel(x, y)
            if color.r > color.g * 1.20 and color.g > color.b * 1.15 and color.b < 0.62:
                woodish += 1
        if float(woodish) / float(sample_xs.size()) >= 0.75:
            return float(y)
    return -1.0


func _save_capture(viewport: Viewport, label: String) -> void:
    var image := viewport.get_texture().get_image()
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    var error := image.save_png(path)
    _check("%s capture saved" % path, error == OK and FileAccess.file_exists(path))
    print("R09_REAR_CAPTURE label=%s dimensions=%dx%d error=%s path=%s" % [label, image.get_width(), image.get_height(), error, path])


func _save_contact_capture(viewport: Viewport, manager: GameManager, label: String, rear_y: float) -> void:
    var contact_specs := [
        {"level": 1, "x": "left"},
        {"level": 6, "x": "center"},
        {"level": 12, "x": "right"}
    ]
    for spec in contact_specs:
        var level: int = spec.level
        var radius := Drink.collider_radius_for_level(level)
        var target_y := rear_y + radius
        var bounds := manager.get_horizontal_bounds_at_y(target_y, radius)
        var x_pos := bounds.x if spec.x == "left" else bounds.y if spec.x == "right" else (bounds.x + bounds.y) * 0.5
        manager.spawn_drink(level, Vector2(x_pos, target_y), false)
    await process_frame
    await process_frame
    var image := viewport.get_texture().get_image()
    var path := "%s/%s_rear_contacts.png" % [CAPTURE_DIR, label]
    var error := image.save_png(path)
    _check("%s contact capture saved" % path, error == OK and FileAccess.file_exists(path))
    print("R09_REAR_CONTACT_CAPTURE label=%s dimensions=%dx%d error=%s path=%s" % [label, image.get_width(), image.get_height(), error, path])


func _load_measurement() -> Dictionary:
    var file := FileAccess.open(MEASUREMENT_PATH, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R09_REAR PASS: %s" % label)
    else:
        failures.append(label)
        print("R09_REAR FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R09_REAR_BOUNDARY_REGRESSION_RESULT=PASS")
        quit(0)
    else:
        print("R09_REAR_BOUNDARY_REGRESSION_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
