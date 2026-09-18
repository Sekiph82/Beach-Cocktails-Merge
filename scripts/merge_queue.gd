class_name MergeQueue
extends Node

## Merge requests can originate from a physics contact callback.
## Nodes are replaced outside the collision callback. The resulting drink keeps
## meaningful incoming momentum instead of freezing at the merge point.

var _pending: Array[Dictionary] = []
var _flush_scheduled := false


func request_merge(a: Drink, b: Drink, new_level: int) -> void:
    if not is_instance_valid(a) or not is_instance_valid(b) or a == b:
        return
    if a.is_queued_for_deletion() or b.is_queued_for_deletion():
        return
    if a.motion_state == Drink.MotionState.MERGING or b.motion_state == Drink.MotionState.MERGING:
        return
    if a.motion_state == Drink.MotionState.TARGET_CAPTURE or b.motion_state == Drink.MotionState.TARGET_CAPTURE:
        return

    for item in _pending:
        if item["a"] == a or item["b"] == a or item["a"] == b or item["b"] == b:
            return

    var va := a.get_merge_velocity()
    var vb := b.get_merge_velocity()
    var total_mass := maxf(a.mass + b.mass, 0.001)
    var merge_pos := (a.position * a.mass + b.position * b.mass) / total_mass
    var merge_velocity := (va * a.mass + vb * b.mass) / total_mass

    # A physical merge loses some energy, but not so much that a moving shot
    # suddenly dies at the merge point. Keep at least 62% of the fastest
    # meaningful incoming speed, in that incoming direction.
    var driver := va if va.length() >= vb.length() else vb
    var minimum_speed := driver.length() * 0.62
    merge_velocity *= 0.94

    if driver.length() > a.settle_speed and merge_velocity.length() < minimum_speed:
        merge_velocity = driver.normalized() * minimum_speed

    # Never send a merged glass back toward the player.
    if merge_velocity.y > 0.0:
        merge_velocity.y = 0.0

    a.begin_merge()
    b.begin_merge()

    _pending.append({
        "a": a,
        "b": b,
        "level": new_level,
        "position": merge_pos,
        "velocity": merge_velocity,
        "driver_speed": driver.length(),
    })

    if not _flush_scheduled:
        _flush_scheduled = true
        call_deferred("_flush_pending")


func clear() -> void:
    _pending.clear()
    _flush_scheduled = false


func _flush_pending() -> void:
    _flush_scheduled = false

    while not _pending.is_empty():
        var item: Dictionary = _pending.pop_front()
        _do_merge(
            item["a"],
            item["b"],
            int(item["level"]),
            item["position"],
            item["velocity"],
            float(item["driver_speed"])
        )


func _do_merge(a: Drink, b: Drink, new_level: int, merge_pos: Vector2, merge_velocity: Vector2, driver_speed: float) -> void:
    if not is_instance_valid(a) or not is_instance_valid(b):
        return
    if a.is_queued_for_deletion() or b.is_queued_for_deletion():
        return
    if a.get_parent() == null or b.get_parent() == null:
        return

    if new_level < 1 or new_level > Drink.max_level():
        a.set_settled()
        b.set_settled()
        return

    a.queue_free()
    b.queue_free()

    if GameManager.instance == null or GameManager.instance.game_over:
        return

    var new_drink := GameManager.instance.spawn_drink(new_level, merge_pos, false)
    if new_drink == null:
        return

    # Use the same directional visual-hull projection as normal physics. The
    # merge Y and inherited tangential momentum are preserved unless the new
    # hull genuinely penetrates an accepted rail.
    var projected := GameManager.instance.project_visual_hull_inside_table(
        Transform2D(0.0, new_drink.position),
        new_drink.get_boundary_contact_hull_local(),
        merge_velocity
    )
    new_drink.position = projected["transform"].origin
    merge_velocity = projected["velocity"]

    # If either input was genuinely moving, the merged result must keep moving.
    if driver_speed > new_drink.settle_speed:
        if merge_velocity.length() <= new_drink.settle_speed:
            merge_velocity = Vector2(0.0, -new_drink.settle_speed * 1.6)
        new_drink.start_sliding(merge_velocity)
    else:
        new_drink.set_settled()
        GameManager.instance.call_deferred("try_chain_merge", new_drink)

    GameManager.instance.on_merged(new_level, new_drink)
