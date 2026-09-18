extends SceneTree

## R10-V09 focused regression for the directional visual-hull boundary solver.

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const V05_LEFT := [Vector2(199.0, 478.0), Vector2(149.0, 587.0), Vector2(124.0, 644.0), Vector2(85.0, 734.0), Vector2(60.0, 800.0), Vector2(20.0, 1000.0), Vector2(8.0, 1186.0)]
const V05_RIGHT := [Vector2(833.0, 478.0), Vector2(880.0, 587.0), Vector2(905.0, 644.0), Vector2(942.0, 734.0), Vector2(964.0, 800.0), Vector2(1002.0, 1000.0), Vector2(1016.0, 1186.0)]
const EXPECTED_RADII := [20.0, 23.0, 27.0, 31.0, 36.0, 42.0, 49.0, 56.0, 64.0, 72.0, 80.0, 90.0]

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

    _check("V05 source left rail coordinates remain unchanged", _points_equal(GameManager.TABLE_LEFT_EDGE_SOURCE_POINTS, V05_LEFT))
    _check("V05 source right rail coordinates remain unchanged", _points_equal(GameManager.TABLE_RIGHT_EDGE_SOURCE_POINTS, V05_RIGHT))
    _check("all 12 explicit visual hulls exist", Drink.BOUNDARY_CONTACT_HULL_SOURCE_PX.size() == 12)
    for level in range(1, 13):
        _check("L%02d visual hull has at least 4 points" % level, Drink.boundary_contact_hull_source_for_level(level).size() >= 4)
        _check("L%02d collider radius remains unchanged" % level, is_equal_approx(Drink.collider_radius_for_level(level), EXPECTED_RADII[level - 1]))

    var edges := manager.get_playable_boundary_edges()
    _check("six left, six right and one rear finite segments are exposed", edges.size() == 13)
    _check("rail segment normals are unit inward normals", _normals_are_inward(manager, edges))
    _check("table walls use non-drink layer/mask", _walls_are_non_drink(manager))
    _check("drink circle remains drink-only layer/mask", _drink_filter_is_drink_only())
    _check("production no longer uses scalar V08 table boundary", _production_scalar_model_is_retired())

    var left_edge: Dictionary = edges[1]
    var right_edge: Dictionary = edges[7]
    var rear_edge: Dictionary = edges[12]
    var asymmetric_hull := Drink.boundary_contact_hull_source_for_level(1)
    var left_support := _support_distance(asymmetric_hull, left_edge["inward_normal"])
    var right_support := _support_distance(asymmetric_hull, right_edge["inward_normal"])
    _check("asymmetric L01 support differs for left/right normals", absf(left_support - right_support) > 0.1)
    print("R10_V09_ASYMMETRIC_SUPPORT level=L01 left=%.3f right=%.3f delta=%.3f" % [left_support, right_support, absf(left_support - right_support)])

    await _check_side_approach(manager, 1, left_edge, "left")
    await _check_side_approach(manager, 6, right_edge, "right")
    await _check_rear_approach(manager, 1, rear_edge)
    _check_solver_velocity_projection(manager, 6, edges[3])
    _check_corner_projection(manager, 12, left_edge, rear_edge)
    await _check_merge_projection(manager, left_edge, "left")
    await _check_merge_projection(manager, right_edge, "right")
    await _check_center_merge_noop(manager)

    manager.queue_free()
    await process_frame
    sub.queue_free()
    await process_frame
    _finish()


func _check_side_approach(manager: GameManager, level: int, edge: Dictionary, side: String) -> void:
    var midpoint: Vector2 = (edge["a"] + edge["b"]) * 0.5
    var inward: Vector2 = edge["inward_normal"]
    var drink := manager.spawn_drink(level, midpoint + inward * 180.0, false)
    _check("L%02d %s approach spawns" % [level, side], is_instance_valid(drink))
    if not is_instance_valid(drink):
        return
    drink.start_sliding(-inward * 300.0)
    for _i in range(120):
        await physics_frame
    var hull := drink.get_boundary_contact_hull_local()
    var target_distance := _min_distance(drink.global_transform, hull, edge)
    _check("L%02d %s moving hull remains inside all rails" % [level, side], _hull_inside_all(manager, drink.global_transform, hull))
    _check("L%02d %s moving hull reaches target rail" % [level, side], target_distance >= -1.0 and target_distance <= 1.5)
    print("R10_V09_SIDE_CONTACT level=L%02d side=%s target_distance=%.3f center=(%.3f,%.3f)" % [level, side, target_distance, drink.position.x, drink.position.y])
    drink.queue_free()
    await process_frame


func _check_rear_approach(manager: GameManager, level: int, edge: Dictionary) -> void:
    var drink := manager.spawn_drink(level, Vector2(manager.get_board_size().x * 0.5, manager.rear_table_y + 120.0), false)
    _check("rear approach spawns", is_instance_valid(drink))
    if not is_instance_valid(drink):
        return
    drink.start_sliding(Vector2(0.0, -500.0))
    for _i in range(120):
        await physics_frame
    var hull := drink.get_boundary_contact_hull_local()
    var rear_distance := _min_distance(drink.global_transform, hull, edge)
    _check("rear hull remains inside all rails", _hull_inside_all(manager, drink.global_transform, hull))
    _check("rear contact is hull-to-line, not common center Y", rear_distance >= -1.0 and rear_distance <= 1.5 and absf(drink.position.y - manager.rear_table_y) > 0.1)
    print("R10_V09_REAR_CONTACT level=L%02d center_y=%.3f rear_table_y=%.3f rear_distance=%.3f" % [level, drink.position.y, manager.rear_table_y, rear_distance])
    drink.queue_free()
    await process_frame


func _check_solver_velocity_projection(manager: GameManager, level: int, edge: Dictionary) -> void:
    var temporary := Drink.create(level)
    var local_hull := temporary.get_boundary_contact_hull_local()
    var normal: Vector2 = edge["inward_normal"]
    var tangent: Vector2 = (edge["b"] - edge["a"]).normalized()
    var support := _support_distance(local_hull, normal)
    var origin: Vector2 = (edge["a"] + edge["b"]) * 0.5 + normal * (support - 5.0)
    var velocity: Vector2 = -normal * 100.0 + tangent * 80.0
    var result := manager.project_visual_hull_inside_table(Transform2D(0.0, origin), local_hull, velocity)
    var corrected_velocity: Vector2 = result["velocity"]
    _check("outward normal velocity is removed", corrected_velocity.dot(normal) >= -0.01)
    _check("tangential velocity is preserved", corrected_velocity.dot(tangent) > 40.0)
    print("R10_V09_VELOCITY normal_after=%.3f tangent_after=%.3f" % [corrected_velocity.dot(normal), corrected_velocity.dot(tangent)])
    temporary.free()


func _check_corner_projection(manager: GameManager, level: int, left_edge: Dictionary, rear_edge: Dictionary) -> void:
    var temporary := Drink.create(level)
    var left_normal: Vector2 = left_edge["inward_normal"]
    var rear_normal: Vector2 = rear_edge["inward_normal"]
    var corner_origin: Vector2 = left_edge["a"] - left_normal * 100.0 - rear_normal * 100.0
    var result := manager.project_visual_hull_inside_table(
        Transform2D(0.0, corner_origin),
        temporary.get_boundary_contact_hull_local(),
        Vector2(-120.0, -120.0)
    )
    var contacts: Array = result["contacts"]
    var corrected_transform: Transform2D = result["transform"]
    _check("corner projection uses multiple constraints", bool(result["corrected"]) and contacts.size() >= 2)
    _check("corner projection remains inside all rails", _hull_inside_all(manager, corrected_transform, temporary.get_boundary_contact_hull_local()))
    _check("corner projection includes rear or adjacent rail", contacts.has("RearRail") or contacts.has(String(rear_edge["name"])))
    print("R10_V09_CORNER contacts=%s corrected_origin=(%.3f,%.3f)" % [contacts, corrected_transform.origin.x, corrected_transform.origin.y])
    temporary.free()


func _check_merge_projection(manager: GameManager, edge: Dictionary, side: String) -> void:
    var midpoint: Vector2 = (edge["a"] + edge["b"]) * 0.5
    var inward: Vector2 = edge["inward_normal"]
    var first := manager.spawn_drink(1, midpoint + inward * 100.0, false)
    var second := manager.spawn_drink(1, midpoint + inward * 100.0, false)
    _check("%s hull merge inputs spawn" % side, is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return
    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame
    var result := _find_level(manager, 2)
    _check("%s hull merge creates L02" % side, is_instance_valid(result))
    if is_instance_valid(result):
        _check("%s hull merge uses same authoritative projection" % side, _hull_inside_all(manager, result.global_transform, result.get_boundary_contact_hull_local()))
        result.queue_free()
    await process_frame


func _check_center_merge_noop(manager: GameManager) -> void:
    var center := Vector2(manager.get_board_size().x * 0.5, (manager.rear_table_y + manager.table_bottom_y) * 0.5)
    var first := manager.spawn_drink(1, center, false)
    var second := manager.spawn_drink(1, center, false)
    _check("center merge inputs spawn", is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return
    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame
    var result := _find_level(manager, 2)
    _check("center merge creates L02", is_instance_valid(result))
    if is_instance_valid(result):
        _check("center merge remains unchanged", result.position.distance_to(center) <= 1.0)
        print("R10_V09_CENTER_MERGE raw=(%.3f,%.3f) corrected=(%.3f,%.3f)" % [center.x, center.y, result.position.x, result.position.y])
        result.queue_free()
    await process_frame


func _hull_inside_all(manager: GameManager, transform: Transform2D, hull: PackedVector2Array) -> bool:
    for edge in manager.get_playable_boundary_edges():
        if _min_distance(transform, hull, edge) < -1.0:
            return false
    return true


func _min_distance(transform: Transform2D, hull: PackedVector2Array, edge: Dictionary) -> float:
    var minimum: float = INF
    for point in hull:
        var world_point: Vector2 = transform * point
        minimum = minf(minimum, edge["inward_normal"].dot(world_point - edge["a"]))
    return minimum


func _support_distance(hull: PackedVector2Array, normal: Vector2) -> float:
    var minimum := INF
    for point in hull:
        minimum = minf(minimum, normal.dot(point))
    return -minimum


func _normals_are_inward(manager: GameManager, edges: Array[Dictionary]) -> bool:
    var interior := Vector2(manager.get_board_size().x * 0.5, (manager.rear_table_y + manager.table_bottom_y) * 0.5)
    for edge in edges:
        var normal: Vector2 = edge["inward_normal"]
        if absf(normal.length() - 1.0) > 0.001 or normal.dot(interior - edge["a"]) <= 0.0:
            return false
    return true


func _walls_are_non_drink(manager: GameManager) -> bool:
    var left := manager.world.get_node_or_null("LeftRail") as StaticBody2D
    var right := manager.world.get_node_or_null("RightRail") as StaticBody2D
    var top := manager.world.get_node_or_null("TopRail") as StaticBody2D
    return left != null and right != null and top != null and left.collision_layer == 2 and left.collision_mask == 2 and right.collision_layer == 2 and top.collision_layer == 2


func _drink_filter_is_drink_only() -> bool:
    var drink := Drink.create(1)
    var valid := drink.collision_layer == 1 and drink.collision_mask == 1
    drink.free()
    return valid


func _production_scalar_model_is_retired() -> bool:
    var drink_source := FileAccess.get_file_as_string("res://scripts/drink.gd")
    var manager_source := FileAccess.get_file_as_string("res://scripts/game_manager.gd")
    var merge_source := FileAccess.get_file_as_string("res://scripts/merge_queue.gd")
    return drink_source.find("TABLE_EDGE_CONTACT_HALF_WIDTHS") < 0 and manager_source.find("get_horizontal_edge_contact_bounds_at_y") < 0 and manager_source.find("_max_side_wall_clearance") < 0 and merge_source.find("get_horizontal_edge_contact_bounds_at_y") < 0


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
        print("R10_V09_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_V09_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R10_V09_VISUAL_HULL_CONTAINMENT_RESULT=PASS")
        quit(0)
    else:
        print("R10_V09_VISUAL_HULL_CONTAINMENT_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
