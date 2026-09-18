extends SceneTree

## R10-V06 focused 2D experiment:
## - collider radius remains the drink-to-drink footprint;
## - visible-body edge footprint drives side limits and merge correction;
## - CAST_SHAPE CCD is enabled on representative moving drinks;
## - V05 envelope coordinates and exact rear target remain frozen.

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const SAMPLE_Y := 620.0
const REAR_TOLERANCE := 0.01
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
    print("R10_V06_V05_ENVELOPE rear_source_y=%.1f left_points=%d right_points=%d" % [GameManager.ACTUAL_REAR_TABLE_SOURCE_Y, GameManager.TABLE_LEFT_EDGE_SOURCE_POINTS.size(), GameManager.TABLE_RIGHT_EDGE_SOURCE_POINTS.size()])

    for level in range(1, 13):
        var radius := Drink.collider_radius_for_level(level)
        var footprint := manager.get_table_edge_contact_half_width(level, SAMPLE_Y)
        var body_derived := float(Drink.VISIBLE_BODY_WIDTH_PX[level - 1]) * Drink.visual_scale_for_level(level) * 0.5 * Drink.visual_body_depth_scale_for_y(SAMPLE_Y)
        _check("L%02d exposes separate visible-body edge footprint" % level, footprint > 0.0 and absf(footprint - body_derived) <= 0.01)
        _check("L%02d drink collider radius remains unchanged" % level, is_equal_approx(radius, Drink.COLLIDER_RADII[level - 1]))
        _check("L%02d edge footprint is distinct from collider at sample depth" % level, footprint < radius - 0.01)
        _check("L%02d uses exact rear target" % level, absf(manager.get_rear_target_center_y(radius) - manager.rear_table_y) <= REAR_TOLERANCE)
        if level == 1 or level == 6 or level == 12:
            var representative := Drink.create(level)
            _check("L%02d representative uses CAST_SHAPE CCD" % level, representative.continuous_cd == RigidBody2D.CCD_MODE_CAST_SHAPE)
            print("R10_V06_BODY level=L%02d collider_radius=%.3f edge_contact_half_width=%.3f sample_y=%.3f ccd=%d rear_target_y=%.3f" % [level, radius, footprint, SAMPLE_Y, representative.continuous_cd, manager.get_rear_target_center_y(radius)])
            representative.queue_free()

    await _check_side_contacts(manager)
    await _check_wall_merge(manager, "left")
    await _check_wall_merge(manager, "right")
    await _check_center_merge_noop(manager)

    manager.queue_free()
    await process_frame
    sub.queue_free()
    await process_frame
    if failures.is_empty():
        print("R10_V06_EDGE_FOOTPRINT_RESULT=PASS")
        quit(0)
        return
    print("R10_V06_EDGE_FOOTPRINT_RESULT=FAIL failures=%s" % ", ".join(failures))
    quit(1)


func _check_side_contacts(manager: GameManager) -> void:
    for level in [1, 6, 12]:
        var radius := Drink.collider_radius_for_level(level)
        var edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, level)
        var collider_bounds := manager.get_horizontal_bounds_at_y(SAMPLE_Y, radius)
        _check("L%02d side limits use edge footprint instead of collider radius" % level, edge_bounds.x < collider_bounds.x and edge_bounds.y > collider_bounds.y)
        for side in ["left", "right"]:
            var x_pos := edge_bounds.x if side == "left" else edge_bounds.y
            var drink := manager.spawn_drink(level, Vector2(x_pos, SAMPLE_Y), false)
            var spawned_ok := is_instance_valid(drink) and absf(drink.position.x - x_pos) <= 0.01
            _check("L%02d %s edge contact spawns at footprint limit" % [level, side], spawned_ok)
            print("R10_V06_EDGE_CONTACT level=L%02d side=%s footprint=%.3f collider_radius=%.3f edge_limit=%.3f collider_limit=%.3f spawned_x=%.3f" % [level, side, manager.get_table_edge_contact_half_width(level, SAMPLE_Y), radius, x_pos, collider_bounds.x if side == "left" else collider_bounds.y, drink.position.x if is_instance_valid(drink) else INF])
            if is_instance_valid(drink):
                drink.start_sliding(Vector2(-80.0 if side == "left" else 80.0, -10.0))
                for _i in range(4):
                    await physics_frame
                var settled_edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(drink.position.y, level)
                var settled_on_edge := drink.position.x >= settled_edge_bounds.x - 0.01 and drink.position.x <= settled_edge_bounds.y + 0.01
                _check("L%02d %s moving contact remains inside edge-footprint limit" % [level, side], settled_on_edge)
                print("R10_V06_MOVING_EDGE level=L%02d side=%s final_x=%.3f edge_range=(%.3f,%.3f) inside=%s" % [level, side, drink.position.x, settled_edge_bounds.x, settled_edge_bounds.y, settled_on_edge])
                drink.queue_free()
        await process_frame


func _check_wall_merge(manager: GameManager, side: String) -> void:
    var y_pos := SAMPLE_Y
    var input_bounds := manager.get_horizontal_edge_contact_bounds_at_y(y_pos, 1)
    var input_x := input_bounds.x if side == "left" else input_bounds.y
    var first := manager.spawn_drink(1, Vector2(input_x, y_pos), false)
    var second := manager.spawn_drink(1, Vector2(input_x, y_pos), false)
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
    _check("%s-wall merge uses edge-footprint valid range" % side, contained and corrected)
    print("R10_V06_WALL_MERGE side=%s raw_merge_x=%.3f edge_contact_half_width=%.3f valid_range=(%.3f,%.3f) corrected_x=%.3f contained=%s corrected=%s" % [side, raw_merge_x, manager.get_table_edge_contact_half_width(result.level, result.position.y), valid.x, valid.y, result.position.x, contained, corrected])
    result.queue_free()
    await process_frame


func _check_center_merge_noop(manager: GameManager) -> void:
    var y_pos := SAMPLE_Y
    var edge_bounds := manager.get_horizontal_edge_contact_bounds_at_y(y_pos, 1)
    var raw_merge_x := (edge_bounds.x + edge_bounds.y) * 0.5
    var first := manager.spawn_drink(1, Vector2(raw_merge_x, y_pos), false)
    var second := manager.spawn_drink(1, Vector2(raw_merge_x, y_pos), false)
    _check("center no-op merge inputs spawn", is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return
    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame
    var result := _find_level(manager, 2)
    _check("center no-op merge creates L02" , is_instance_valid(result))
    if not is_instance_valid(result):
        return
    _check("center merge clamp is a no-op for valid raw X", absf(result.position.x - raw_merge_x) <= 0.01)
    print("R10_V06_CENTER_NOOP raw_merge_x=%.3f corrected_x=%.3f delta=%.3f" % [raw_merge_x, result.position.x, result.position.x - raw_merge_x])
    result.queue_free()
    await process_frame


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


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R10_V06_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_V06_PROBE FAIL: %s" % label)
