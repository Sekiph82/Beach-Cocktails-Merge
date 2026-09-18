extends SceneTree

## R10-V07 focused regression for the independent PNG-derived edge dataset.
## The expected values are loaded from retained measurement evidence rather
## than imported from production constants or collider helpers.

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const SAMPLE_Y := 620.0
const REAR_TOLERANCE := 0.01
const MEASUREMENT_PATH := "res://docs/evidence/r10/v07_independent_edge_contact_measurements.json"
const V05_LEFT := [Vector2(199.0, 478.0), Vector2(149.0, 587.0), Vector2(124.0, 644.0), Vector2(85.0, 734.0), Vector2(60.0, 800.0), Vector2(20.0, 1000.0), Vector2(8.0, 1186.0)]
const V05_RIGHT := [Vector2(833.0, 478.0), Vector2(880.0, 587.0), Vector2(905.0, 644.0), Vector2(942.0, 734.0), Vector2(964.0, 800.0), Vector2(1002.0, 1000.0), Vector2(1016.0, 1186.0)]

var failures: Array[String] = []
var evidence: Dictionary = {}


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    evidence = _load_evidence()
    var records: Array = evidence.get("levels", [])
    _check("independent V07 measurement evidence loads", records.size() == 12)
    if records.size() != 12:
        _finish()
        return

    var sub := SubViewport.new()
    sub.size = VIEWPORT_SIZE
    sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    sub.transparent_bg = false
    root.add_child(sub)
    var manager := GameManager.new()
    sub.add_child(manager)
    await process_frame
    await process_frame
    await process_frame

    _check("V05 rear source coordinate remains frozen", is_equal_approx(GameManager.ACTUAL_REAR_TABLE_SOURCE_Y, 478.0))
    _check("V05 left envelope coordinates remain frozen", _points_equal(GameManager.TABLE_LEFT_EDGE_SOURCE_POINTS, V05_LEFT))
    _check("V05 right envelope coordinates remain frozen", _points_equal(GameManager.TABLE_RIGHT_EDGE_SOURCE_POINTS, V05_RIGHT))

    var expected_values: Array[float] = []
    for record in records:
        expected_values.append(float(record.get("runtime_edge_contact_half_width", -1.0)))
    _check("production exposes exactly 12 independent edge values", Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS.size() == 12)
    _check("production values match retained PNG measurement evidence", _arrays_equal(Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS, expected_values))

    for level in range(1, 13):
        var record: Dictionary = records[level - 1]
        var radius := Drink.collider_radius_for_level(level)
        var footprint := manager.get_table_edge_contact_half_width(level, SAMPLE_Y)
        var source_width := float(record.get("source_contact_width_px", 0.0))
        var source_dimensions: Array = record.get("dimensions", [])
        var texture := load(String(record.get("texture", ""))) as Texture2D
        var actual_dimensions_ok := texture != null and source_dimensions.size() == 2 and texture.get_width() == int(source_dimensions[0]) and texture.get_height() == int(source_dimensions[1])
        _check("L%02d source texture dimensions match evidence" % level, actual_dimensions_ok)
        var measured_source_width := _measure_contact_width(texture, record)
        var independent_measurement_ok := source_width > 0.0 and absf(measured_source_width - source_width) <= 2.0 and record.has("excluded") and not String(record.get("excluded", "")).is_empty()
        print("R10_V07_SOURCE_MEASURE level=L%02d expected=%.1f measured=%.1f" % [level, source_width, measured_source_width])
        _check("L%02d PNG contact-band measurement matches retained evidence" % level, independent_measurement_ok)
        _check("L%02d collider radius remains unchanged" % level, is_equal_approx(radius, float(record.get("collider_radius", -1.0))))
        _check("L%02d independent edge footprint is materially narrower" % level, footprint < radius - 4.0)
        _check("L%02d rear target is exact" % level, absf(manager.get_rear_target_center_y(radius) - manager.rear_table_y) <= REAR_TOLERANCE)
        if level == 1 or level == 6 or level == 12:
            var representative := Drink.create(level)
            _check("L%02d preserves CAST_SHAPE CCD" % level, representative.continuous_cd == RigidBody2D.CCD_MODE_CAST_SHAPE)
            print("R10_V07_BODY level=L%02d measured_source_contact_width_px=%.1f edge_contact_half_width=%.1f collider_radius=%.1f reduction=%.1f ccd=%d" % [level, measured_source_width, footprint, radius, radius - footprint, representative.continuous_cd])
            representative.queue_free()

    await _check_side_contacts(manager)
    await _check_wall_merge(manager, "left")
    await _check_wall_merge(manager, "right")
    await _check_center_merge_noop(manager)

    manager.queue_free()
    await process_frame
    sub.queue_free()
    await process_frame
    _finish()


func _check_side_contacts(manager: GameManager) -> void:
    for level in [1, 6, 12]:
        var radius := Drink.collider_radius_for_level(level)
        var edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, level)
        var collider_bounds := manager.get_horizontal_bounds_at_y(SAMPLE_Y, radius)
        _check("L%02d side limits use independent footprint" % level, edge_bounds.x < collider_bounds.x and edge_bounds.y > collider_bounds.y)
        for side in ["left", "right"]:
            var x_pos := edge_bounds.x if side == "left" else edge_bounds.y
            var drink := manager.spawn_drink(level, Vector2(x_pos, SAMPLE_Y), false)
            _check("L%02d %s edge contact spawns at independent limit" % [level, side], is_instance_valid(drink) and absf(drink.position.x - x_pos) <= 0.01)
            if is_instance_valid(drink):
                drink.start_sliding(Vector2(-80.0 if side == "left" else 80.0, -10.0))
                for _i in range(4):
                    await physics_frame
                var settled_bounds := manager.get_horizontal_edge_contact_bounds_at_y(drink.position.y, level)
                var inside := drink.position.x >= settled_bounds.x - 0.01 and drink.position.x <= settled_bounds.y + 0.01
                _check("L%02d %s moving contact stays inside independent limit" % [level, side], inside)
                print("R10_V07_EDGE_CONTACT level=L%02d side=%s edge_half_width=%.1f collider_radius=%.1f final_x=%.3f range=(%.3f,%.3f) inside=%s" % [level, side, manager.get_table_edge_contact_half_width(level, SAMPLE_Y), radius, drink.position.x, settled_bounds.x, settled_bounds.y, inside])
                drink.queue_free()
        await process_frame


func _check_wall_merge(manager: GameManager, side: String) -> void:
    var edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, 1)
    var input_x := edge_bounds.x if side == "left" else edge_bounds.y
    var first := manager.spawn_drink(1, Vector2(input_x, SAMPLE_Y), false)
    var second := manager.spawn_drink(1, Vector2(input_x, SAMPLE_Y), false)
    _check("%s-wall merge inputs spawn" % side, is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return
    var raw_merge_x := (first.position.x + second.position.x) * 0.5
    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame
    var result := _find_level(manager, 2)
    _check("%s-wall merge creates L02" % side, is_instance_valid(result))
    if not is_instance_valid(result):
        return
    var valid := manager.get_horizontal_edge_contact_bounds_at_y(result.position.y, result.level)
    var expected := valid.x if side == "left" else valid.y
    var contained := result.position.x >= valid.x - 0.01 and result.position.x <= valid.y + 0.01
    var corrected := absf(result.position.x - expected) <= 0.01
    _check("%s-wall merge uses independent edge range" % side, contained and corrected)
    print("R10_V07_WALL_MERGE side=%s raw_merge_x=%.3f edge_half_width=%.1f valid_range=(%.3f,%.3f) corrected_x=%.3f contained=%s corrected=%s" % [side, raw_merge_x, manager.get_table_edge_contact_half_width(result.level, result.position.y), valid.x, valid.y, result.position.x, contained, corrected])
    result.queue_free()
    await process_frame


func _check_center_merge_noop(manager: GameManager) -> void:
    var edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, 1)
    var raw_merge_x := (edge_bounds.x + edge_bounds.y) * 0.5
    var first := manager.spawn_drink(1, Vector2(raw_merge_x, SAMPLE_Y), false)
    var second := manager.spawn_drink(1, Vector2(raw_merge_x, SAMPLE_Y), false)
    _check("center no-op merge inputs spawn", is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return
    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame
    var result := _find_level(manager, 2)
    _check("center no-op merge creates L02", is_instance_valid(result))
    if not is_instance_valid(result):
        return
    _check("center merge clamp remains a no-op", absf(result.position.x - raw_merge_x) <= 0.01)
    print("R10_V07_CENTER_NOOP raw_merge_x=%.3f corrected_x=%.3f delta=%.3f" % [raw_merge_x, result.position.x, result.position.x - raw_merge_x])
    result.queue_free()
    await process_frame


func _load_evidence() -> Dictionary:
    var file := FileAccess.open(MEASUREMENT_PATH, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}


func _measure_contact_width(texture: Texture2D, record: Dictionary) -> float:
    if texture == null:
        return 0.0
    var image := texture.get_image()
    if image == null:
        return 0.0
    var bbox: Array = record.get("body_bbox_px", [])
    if bbox.size() != 4:
        return 0.0
    var x0 := maxi(0, int(bbox[0]))
    var y0 := maxi(0, int(bbox[1]))
    var x1 := mini(image.get_width() - 1, int(bbox[2]))
    var y1 := mini(image.get_height() - 1, int(bbox[3]))
    var fraction := clampf(float(record.get("body_band_fraction", 0.95)), 0.0, 1.0)
    var center_y := int(round(lerpf(float(y0), float(y1), fraction)))
    var widest := 0
    for y in range(maxi(y0, center_y - 3), mini(y1 + 1, center_y + 4)):
        var first := -1
        var last := -1
        for x in range(x0, x1 + 1):
            if image.get_pixel(x, y).a >= 32.0 / 255.0:
                if first < 0:
                    first = x
                last = x
        if first >= 0:
            widest = maxi(widest, last - first + 1)
    return float(widest)


func _find_level(manager: GameManager, level: int) -> Drink:
    for child in manager.world.get_children():
        if child is Drink and child.level == level and child.motion_state != Drink.MotionState.HELD and not child.is_queued_for_deletion():
            return child as Drink
    return null


func _points_equal(actual: Array, expected: Array) -> bool:
    if actual.size() != expected.size():
        return false
    for index in range(actual.size()):
        if (actual[index] as Vector2).distance_to(expected[index]) > 0.001:
            return false
    return true


func _arrays_equal(actual: Array, expected: Array) -> bool:
    if actual.size() != expected.size():
        return false
    for index in range(actual.size()):
        if absf(float(actual[index]) - float(expected[index])) > 0.001:
            return false
    return true


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R10_V07_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_V07_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R10_V07_INDEPENDENT_EDGE_DATASET_RESULT=PASS")
        quit(0)
    else:
        print("R10_V07_INDEPENDENT_EDGE_DATASET_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
