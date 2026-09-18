extends SceneTree

## R10-V05 focused proof for the owner-defined three-sided playable envelope.
## The probe uses the production rail helper and exercises both wall-side merge
## results after the larger collider has been created.

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const OWNER_REAR_SOURCE_Y := 478.0
const OWNER_REAR_TOLERANCE := 0.01

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

    var expected_rear_y := GameManager.source_to_viewport(Vector2(0.0, OWNER_REAR_SOURCE_Y), VIEWPORT_SIZE).y
    _check("owner rear source measurement is production rear target", absf(manager.rear_table_y - expected_rear_y) <= OWNER_REAR_TOLERANCE and absf(manager.table_top_y - expected_rear_y) <= OWNER_REAR_TOLERANCE)
    var rear_rails := manager.get_table_rail_bounds_at_y(manager.rear_table_y)
    _check("three-sided rear rail is inset and perspective-shaped", rear_rails.x > 0.0 and rear_rails.y < VIEWPORT_SIZE.x and rear_rails.y > rear_rails.x)
    print("R10_V05_ENVELOPE rear_table_y=%.3f rear_rails=(%.3f,%.3f) bottom_y=%.3f" % [manager.rear_table_y, rear_rails.x, rear_rails.y, manager.table_bottom_y])

    for level in [1, 6, 12]:
        var radius := Drink.collider_radius_for_level(level)
        _check("L%02d uses exact common rear target" % level, absf(manager.get_rear_target_center_y(radius) - manager.rear_table_y) <= OWNER_REAR_TOLERANCE)
        print("R10_V05_REAR level=L%02d radius=%.3f rear_target_y=%.3f" % [level, radius, manager.get_rear_target_center_y(radius)])

    await _check_wall_merge(manager, "left")
    await _check_wall_merge(manager, "right")

    manager.queue_free()
    await process_frame
    sub.queue_free()
    await process_frame
    if failures.is_empty():
        print("R10_V05_THREE_SIDED_ENVELOPE_RESULT=PASS")
        quit(0)
        return
    print("R10_V05_THREE_SIDED_ENVELOPE_RESULT=FAIL failures=%s" % ", ".join(failures))
    quit(1)


func _check_wall_merge(manager: GameManager, side: String) -> void:
    var y_pos := lerpf(manager.rear_table_y, manager.table_bottom_y, 0.22)
    var small_radius := Drink.collider_radius_for_level(1)
    var input_bounds := manager.get_horizontal_edge_contact_bounds_at_y(y_pos, 1)
    var input_x := input_bounds.x if side == "left" else input_bounds.y
    var first := manager.spawn_drink(1, Vector2(input_x, y_pos), false)
    var second := manager.spawn_drink(1, Vector2(input_x, y_pos), false)
    _check("%s-wall merge inputs spawn" % side, is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return

    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame

    var result: Drink = null
    for child in manager.world.get_children():
        if child is Drink and child.level == 2 and child.motion_state != Drink.MotionState.HELD:
            result = child as Drink
            break
    _check("%s-wall merge creates larger result" % side, is_instance_valid(result))
    if not is_instance_valid(result):
        return

    var result_bounds := manager.get_horizontal_edge_contact_bounds_at_y(result.position.y, result.level)
    var expected_x := result_bounds.x if side == "left" else result_bounds.y
    var contained := result.position.x >= result_bounds.x - 0.01 and result.position.x <= result_bounds.y + 0.01
    var tangent := absf(result.position.x - expected_x) <= 0.01
    _check("%s-wall larger result stays inside current rail" % side, contained)
    _check("%s-wall larger result is tangent without solver gap" % side, tangent)
    print("R10_V05_WALL_MERGE side=%s input_x=%.3f result_x=%.3f result_radius=%.3f valid_bounds=(%.3f,%.3f) expected_tangent_x=%.3f contained=%s tangent=%s" % [side, input_x, result.position.x, result.radius, result_bounds.x, result_bounds.y, expected_x, contained, tangent])
    result.queue_free()
    await process_frame


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R10_V05_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_V05_PROBE FAIL: %s" % label)
