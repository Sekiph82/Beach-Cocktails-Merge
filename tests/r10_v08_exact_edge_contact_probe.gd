extends SceneTree

## R10-V08 focused regression for the prescribed literal runtime edge dataset.
## This probe intentionally uses an independent literal expected array and does
## not load the historical V07 source-pixel measurement evidence.

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const SAMPLE_Y := 620.0
const REAR_TOLERANCE := 0.01
const EXPECTED_V08_EDGE_HALF_WIDTHS := [
    9.0, 10.5, 13.0, 10.0, 14.5, 16.0,
    18.0, 22.5, 22.0, 31.0, 32.0, 34.0
]
const EXPECTED_COLLIDER_RADII := [20.0, 23.0, 27.0, 31.0, 36.0, 42.0, 49.0, 56.0, 64.0, 72.0, 80.0, 90.0]
const V05_LEFT := [Vector2(199.0, 478.0), Vector2(149.0, 587.0), Vector2(124.0, 644.0), Vector2(85.0, 734.0), Vector2(60.0, 800.0), Vector2(20.0, 1000.0), Vector2(8.0, 1186.0)]
const V05_RIGHT := [Vector2(833.0, 478.0), Vector2(880.0, 587.0), Vector2(905.0, 644.0), Vector2(942.0, 734.0), Vector2(964.0, 800.0), Vector2(1002.0, 1000.0), Vector2(1016.0, 1186.0)]

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
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
    _check("production exposes exactly 12 V08 edge values", Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS.size() == EXPECTED_V08_EDGE_HALF_WIDTHS.size())
    _check("production values match literal V08 array", _arrays_equal(Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS, EXPECTED_V08_EDGE_HALF_WIDTHS))
    _check("V08 production helper has no forbidden derivation", _helper_is_literal_only())

    for level in range(1, 13):
        var radius := Drink.collider_radius_for_level(level)
        _check("L%02d collider radius remains unchanged" % level, is_equal_approx(radius, EXPECTED_COLLIDER_RADII[level - 1]))
        _check("L%02d rear target equals rear_table_y" % level, absf(manager.get_rear_target_center_y(radius) - manager.rear_table_y) <= REAR_TOLERANCE)

    for level in [1, 6, 12]:
        await _check_side_contacts(manager, level)

    await _check_wall_merge(manager, "left")
    await _check_wall_merge(manager, "right")
    await _check_center_merge_noop(manager)

    manager.queue_free()
    await process_frame
    sub.queue_free()
    await process_frame
    _finish()


func _check_side_contacts(manager: GameManager, level: int) -> void:
    var edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, level)
    var collider_bounds := manager.get_horizontal_bounds_at_y(SAMPLE_Y, Drink.collider_radius_for_level(level))
    var expected_width := float(EXPECTED_V08_EDGE_HALF_WIDTHS[level - 1])
    _check("L%02d edge helper returns V08 value" % level, is_equal_approx(manager.get_table_edge_contact_half_width(level, SAMPLE_Y), expected_width))
    _check("L%02d logical side range is wider than collider-radius range" % level, edge_bounds.x < collider_bounds.x and edge_bounds.y > collider_bounds.y)
    for side in ["left", "right"]:
        var x_pos := edge_bounds.x if side == "left" else edge_bounds.y
        var drink := manager.spawn_drink(level, Vector2(x_pos, SAMPLE_Y), false)
        var spawned := is_instance_valid(drink)
        _check("L%02d %s contact uses V08 limit" % [level, side], spawned and absf(drink.position.x - x_pos) <= 0.01)
        if spawned:
            drink.start_sliding(Vector2(-80.0 if side == "left" else 80.0, -10.0))
            for _i in range(4):
                await physics_frame
            var settled_bounds := manager.get_horizontal_edge_contact_bounds_at_y(drink.position.y, level)
            var inside := drink.position.x >= settled_bounds.x - 0.01 and drink.position.x <= settled_bounds.y + 0.01
            _check("L%02d %s moving contact remains inside V08 limit" % [level, side], inside)
            print("R10_V08_EDGE_CONTACT level=L%02d side=%s edge_half_width=%.1f collider_radius=%.1f final_x=%.3f range=(%.3f,%.3f) inside=%s" % [level, side, expected_width, Drink.collider_radius_for_level(level), drink.position.x, settled_bounds.x, settled_bounds.y, inside])
            drink.queue_free()
    await process_frame


func _check_wall_merge(manager: GameManager, side: String) -> void:
    var input_bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, 1)
    var input_x := input_bounds.x if side == "left" else input_bounds.y
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
    _check("%s-wall merge uses V08 L02=10.5 edge range" % side, is_equal_approx(manager.get_table_edge_contact_half_width(2, result.position.y), 10.5) and contained and corrected)
    print("R10_V08_WALL_MERGE side=%s raw_merge_x=%.3f edge_half_width=%.1f valid_range=(%.3f,%.3f) corrected_x=%.3f contained=%s corrected=%s" % [side, raw_merge_x, manager.get_table_edge_contact_half_width(result.level, result.position.y), valid.x, valid.y, result.position.x, contained, corrected])
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
    _check("center merge clamp is a no-op", absf(result.position.x - raw_merge_x) <= 0.01)
    print("R10_V08_CENTER_NOOP raw_merge_x=%.3f corrected_x=%.3f delta=%.3f" % [raw_merge_x, result.position.x, result.position.x - raw_merge_x])
    result.queue_free()
    await process_frame


func _helper_is_literal_only() -> bool:
    var source := FileAccess.get_file_as_string("res://scripts/drink.gd")
    var start := source.find("static func table_edge_contact_half_width_for_level")
    if start < 0:
        return false
    var end := source.find("\n\nstatic func", start + 1)
    if end < 0:
        end = source.length()
    var helper := source.substr(start, end - start)
    for forbidden in ["COLLIDER_RADII", "collider_radius", "visual_scale_for_level", "VISIBLE_BODY_WIDTH_PX", "texture", "source"]:
        if helper.find(forbidden) >= 0:
            return false
    return helper.find("return TABLE_EDGE_CONTACT_HALF_WIDTHS[p_level - 1]") >= 0


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
        print("R10_V08_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_V08_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R10_V08_EXACT_EDGE_CONTACT_RESULT=PASS")
        quit(0)
    else:
        print("R10_V08_EXACT_EDGE_CONTACT_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
