extends SceneTree

## V10 before/after runtime diagnostic. The pre-fix run was captured against
## V09 before remediation; the committed form is the post-fix assertion.

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const SIDE_ESCAPE_TOLERANCE := -1.0
const REAR_GAP_TOLERANCE := 1.0

var failures: Array[String] = []
var observed_side_escape := false
var observed_rear_gap := false


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

    await _run_side_crowd(manager, "left", 1)
    await _run_side_crowd(manager, "right", 6)
    await _run_rear_accumulation(manager)

    print("R10_V10_POST_SIDE_ESCAPE=%s" % observed_side_escape)
    print("R10_V10_POST_REAR_GAP=%s" % observed_rear_gap)
    if not observed_side_escape and not observed_rear_gap:
        print("R10_V10_POST_REPRODUCTION_RESULT=PASS_NO_V09_FAILURE")
        quit(0)
    else:
        print("R10_V10_POST_REPRODUCTION_RESULT=FAIL_REMAINING_BOUNDARY_DEFECT")
        quit(1)


func _run_side_crowd(manager: GameManager, side: String, level: int) -> void:
    var edges := manager.get_playable_boundary_edges()
    var edge: Dictionary = edges[1] if side == "left" else edges[7]
    var inward: Vector2 = edge["inward_normal"]
    var tangent: Vector2 = (edge["b"] - edge["a"]).normalized()
    var midpoint: Vector2 = (edge["a"] + edge["b"]) * 0.5

    var target := manager.spawn_drink(level, midpoint, false)
    var attacker_a := manager.spawn_drink(level, midpoint + inward * 180.0 + tangent * 28.0, false)
    var attacker_b := manager.spawn_drink(level, midpoint + inward * 260.0 - tangent * 28.0, false)
    if not is_instance_valid(target) or not is_instance_valid(attacker_a) or not is_instance_valid(attacker_b):
        failures.append("%s crowd spawn" % side)
        return

    target.set_settled()
    attacker_a.start_sliding(-inward * 700.0)
    attacker_b.start_sliding(-inward * 700.0)
    for _i in range(180):
        await physics_frame

    for drink in [target, attacker_a, attacker_b]:
        if not is_instance_valid(drink):
            continue
        var distance := _min_body_hull_distance(drink, edge)
        print("R10_V10_POST_SIDE side=%s level=L%02d center=%s glass_body_edge_distance=%.3f" % [side, level, drink.position, distance])
        if distance < SIDE_ESCAPE_TOLERANCE:
            observed_side_escape = true
        drink.queue_free()
    await process_frame


func _run_rear_accumulation(manager: GameManager) -> void:
    var rear: Dictionary = manager.get_playable_boundary_edges()[12]
    for fraction in [0.08, 0.20, 0.50, 0.80, 0.92]:
        var x_pos := lerpf(rear["a"].x, rear["b"].x, fraction)
        var drink := manager.spawn_drink(12, Vector2(x_pos, manager.rear_table_y + 260.0), false)
        if not is_instance_valid(drink):
            continue
        drink.start_sliding(Vector2(0.0, -700.0))
        for _i in range(180):
            await physics_frame
        if not is_instance_valid(drink):
            continue
        var body_distance := _min_body_hull_distance(drink, rear)
        print("R10_V10_POST_REAR fraction=%.2f level=L%02d center=%s glass_body_rear_distance=%.3f" % [fraction, drink.level, drink.position, body_distance])
        if body_distance > REAR_GAP_TOLERANCE:
            observed_rear_gap = true
        drink.queue_free()
        await process_frame


func _rendered_hull_local(drink: Drink) -> PackedVector2Array:
    # Owner-visible failure measurement intentionally uses the full rendered
    # alpha footprint, including garnish. Production contact hulls still use
    # glass/container body only; this exposes visible art escaping that body
    # hull containment can otherwise hide.
    var texture := drink._cocktail_sprite.texture as Texture2D
    var image := texture.get_image()
    var used := image.get_used_rect()
    var texture_center := Vector2(texture.get_width(), texture.get_height()) * 0.5
    var source_hull := PackedVector2Array([
        Vector2(used.position.x, used.position.y) - texture_center,
        Vector2(used.end.x, used.position.y) - texture_center,
        Vector2(used.end.x, used.end.y) - texture_center,
        Vector2(used.position.x, used.end.y) - texture_center,
    ])
    var composed := Transform2D.IDENTITY
    if drink._visual_root != null:
        composed = drink._visual_root.transform
    if drink._cocktail_sprite != null:
        composed = composed * drink._cocktail_sprite.transform
    var result := PackedVector2Array()
    for point in source_hull:
        result.append(composed * point)
    return result


func _min_rendered_hull_distance(drink: Drink, edge: Dictionary) -> float:
    var minimum := INF
    for point in _rendered_hull_local(drink):
        var world_point: Vector2 = drink.global_transform * point
        minimum = minf(minimum, edge["inward_normal"].dot(world_point - edge["a"]))
    return minimum


func _min_body_hull_distance(drink: Drink, edge: Dictionary) -> float:
    var minimum := INF
    for point in drink.get_boundary_contact_hull_local():
        var world_point: Vector2 = drink.global_transform * point
        minimum = minf(minimum, edge["inward_normal"].dot(world_point - edge["a"]))
    return minimum
