extends SceneTree

## R10 V10 focused regression for exact visual transform composition, finite
## rail ownership, real crowded physics contacts, rear tangency and merge
## containment.

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
    root.add_child(sub)
    var manager := GameManager.new()
    sub.add_child(manager)
    await process_frame
    await process_frame
    await process_frame

    _check("V05 left rail source coordinates are frozen", _points_equal(GameManager.TABLE_LEFT_EDGE_SOURCE_POINTS, V05_LEFT))
    _check("V05 right rail source coordinates are frozen", _points_equal(GameManager.TABLE_RIGHT_EDGE_SOURCE_POINTS, V05_RIGHT))
    _check("13 finite boundary segments remain exposed", manager.get_playable_boundary_edges().size() == 13)
    _check("all L01-L12 collider radii remain unchanged", _radii_unchanged())
    _check("production scalar V06-V08 boundary model stays retired", _scalar_model_retired())

    await _check_transform_equivalence(manager)
    await _check_side_crowd(manager, 1, manager.get_playable_boundary_edges()[1], "left")
    await _check_side_crowd(manager, 6, manager.get_playable_boundary_edges()[7], "right")
    await _check_rear_accumulation(manager)
    await _check_merge_stress(manager, manager.get_playable_boundary_edges()[1], "left")
    await _check_merge_stress(manager, manager.get_playable_boundary_edges()[7], "right")

    manager.queue_free()
    await process_frame
    sub.queue_free()
    await process_frame
    if failures.is_empty():
        print("R10_V10_VISUAL_HULL_CONTAINMENT_RESULT=PASS")
        quit(0)
    else:
        print("R10_V10_VISUAL_HULL_CONTAINMENT_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)


func _check_transform_equivalence(manager: GameManager) -> void:
    var all_match := true
    var non_unit_root := true
    for item in [[1, 450.0], [6, 800.0], [12, 1100.0]]:
        var level: int = item[0]
        var y_pos: float = item[1]
        var drink := Drink.create(level)
        manager.world.add_child(drink)
        drink.position = Vector2(360.0, y_pos)
        await process_frame
        var source := Drink.boundary_contact_hull_source_for_level(level)
        var composed := drink._visual_root.transform * drink._cocktail_sprite.transform
        non_unit_root = non_unit_root and absf(drink._visual_root.scale.x - 1.0) > 0.0001
        var actual := drink.get_boundary_contact_hull_local()
        if actual.size() != source.size():
            all_match = false
        else:
            for index in range(source.size()):
                if actual[index].distance_to(composed * source[index]) > 0.001:
                    all_match = false
        print("R10_V10_TRANSFORM level=L%02d y=%.1f root_scale=%.6f equivalent=%s" % [level, y_pos, drink._visual_root.scale.x, actual.size() == source.size()])
        drink.queue_free()
        await process_frame
    _check("Visual->Sprite hull transform equals composed node transforms", all_match and non_unit_root)


func _check_side_crowd(manager: GameManager, level: int, edge: Dictionary, side: String) -> void:
    var inward: Vector2 = edge["inward_normal"]
    var tangent: Vector2 = (edge["b"] - edge["a"]).normalized()
    var midpoint: Vector2 = (edge["a"] + edge["b"]) * 0.5
    var target := manager.spawn_drink(level, midpoint, false)
    var attacker_a := manager.spawn_drink(level, midpoint + inward * 180.0 + tangent * 28.0, false)
    var attacker_b := manager.spawn_drink(level, midpoint + inward * 260.0 - tangent * 28.0, false)
    var spawned := is_instance_valid(target) and is_instance_valid(attacker_a) and is_instance_valid(attacker_b)
    _check("%s crowded side drinks spawn" % side, spawned)
    if not spawned:
        return
    target.set_settled()
    attacker_a.start_sliding(-inward * 700.0)
    attacker_b.start_sliding(-inward * 700.0)
    for _i in range(180):
        await physics_frame
    var safe := true
    var edge_distance := INF
    for drink in [target, attacker_a, attacker_b]:
        if not is_instance_valid(drink):
            continue
        safe = safe and _hull_inside_all(manager, drink)
        edge_distance = minf(edge_distance, _min_distance(drink.global_transform, drink.get_boundary_contact_hull_local(), edge))
    print("R10_V10_SIDE_STRESS side=%s level=L%02d min_edge_distance=%.3f inside_all=%s" % [side, level, edge_distance, safe])
    _check("%s crowded glass bodies never escape accepted rails" % side, safe and edge_distance >= -1.0)
    for drink in [target, attacker_a, attacker_b]:
        if is_instance_valid(drink):
            drink.queue_free()
    await process_frame


func _check_rear_accumulation(manager: GameManager) -> void:
    var rear: Dictionary = manager.get_playable_boundary_edges()[12]
    var safe := true
    var max_gap := 0.0
    for fraction in [0.08, 0.50, 0.92]:
        var x_pos := lerpf(rear["a"].x, rear["b"].x, fraction)
        var drink := manager.spawn_drink(12, Vector2(x_pos, manager.rear_table_y + 260.0), false)
        if not is_instance_valid(drink):
            safe = false
            continue
        drink.start_sliding(Vector2(0.0, -700.0))
        for _i in range(180):
            await physics_frame
        var gap := _min_distance(drink.global_transform, drink.get_boundary_contact_hull_local(), rear)
        max_gap = maxf(max_gap, gap)
        safe = safe and _hull_inside_all(manager, drink) and gap >= -1.0 and gap <= 1.0
        print("R10_V10_REAR_STRESS fraction=%.2f center=%s body_rear_distance=%.3f" % [fraction, drink.position, gap])
        drink.queue_free()
        await process_frame
    _check("rear accumulation reaches the same rear rail without a body gap", safe and max_gap <= 1.0)


func _check_merge_stress(manager: GameManager, edge: Dictionary, side: String) -> void:
    var inward: Vector2 = edge["inward_normal"]
    var midpoint: Vector2 = (edge["a"] + edge["b"]) * 0.5 + inward * 64.0
    var first := manager.spawn_drink(1, midpoint, false)
    var second := manager.spawn_drink(1, midpoint, false)
    _check("%s merge stress inputs spawn" % side, is_instance_valid(first) and is_instance_valid(second))
    if not is_instance_valid(first) or not is_instance_valid(second):
        return
    manager.merge_queue.request_merge(first, second, 2)
    await process_frame
    await process_frame
    var result: Drink = null
    for child in manager.world.get_children():
        if child is Drink and child.level == 2 and not child.is_queued_for_deletion():
            result = child
            break
    var valid := is_instance_valid(result) and _hull_inside_all(manager, result)
    print("R10_V10_MERGE_STRESS side=%s valid=%s position=%s" % [side, valid, result.position if is_instance_valid(result) else Vector2.INF])
    _check("%s merge result remains inside the same authoritative solver" % side, valid)
    if is_instance_valid(result):
        result.queue_free()
    await process_frame


func _hull_inside_all(manager: GameManager, drink: Drink) -> bool:
    for edge in manager.get_playable_boundary_edges():
        if _min_distance(drink.global_transform, drink.get_boundary_contact_hull_local(), edge) < -1.0:
            return false
    return true


func _min_distance(transform: Transform2D, hull: PackedVector2Array, edge: Dictionary) -> float:
    var minimum := INF
    for point in hull:
        minimum = minf(minimum, edge["inward_normal"].dot((transform * point) - edge["a"]))
    return minimum


func _radii_unchanged() -> bool:
    for index in range(EXPECTED_RADII.size()):
        if not is_equal_approx(Drink.collider_radius_for_level(index + 1), EXPECTED_RADII[index]):
            return false
    return true


func _scalar_model_retired() -> bool:
    var drink_source := FileAccess.get_file_as_string("res://scripts/drink.gd")
    var manager_source := FileAccess.get_file_as_string("res://scripts/game_manager.gd")
    return drink_source.find("TABLE_EDGE_CONTACT_HALF_WIDTHS") < 0 and manager_source.find("get_horizontal_edge_contact_bounds_at_y") < 0 and manager_source.find("_max_side_wall_clearance") < 0


func _points_equal(actual: Array, expected: Array) -> bool:
    if actual.size() != expected.size():
        return false
    for index in range(actual.size()):
        if (actual[index] as Vector2).distance_to(expected[index]) > 0.001:
            return false
    return true


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R10_V10_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_V10_PROBE FAIL: %s" % label)
