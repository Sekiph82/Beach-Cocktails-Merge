class_name MergeQueue
extends Node

## Merge requests can originate from a physics contact callback.
## They are collected and flushed deferred, after the physics query is finished.

var _pending: Array[Dictionary] = []
var _flush_scheduled := false


func request_merge(a: Drink, b: Drink, new_level: int) -> void:
    if not is_instance_valid(a) or not is_instance_valid(b) or a == b:
        return

    for item in _pending:
        if item["a"] == a or item["b"] == a or item["a"] == b or item["b"] == b:
            return

    _pending.append({"a": a, "b": b, "level": new_level})

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
        _do_merge(item["a"], item["b"], int(item["level"]))


func _do_merge(a: Drink, b: Drink, new_level: int) -> void:
    if not is_instance_valid(a) or not is_instance_valid(b):
        return
    if a.is_queued_for_deletion() or b.is_queued_for_deletion():
        return
    if a.get_parent() == null or b.get_parent() == null:
        return

    # Defensive protection for the top level.
    if new_level < 1 or new_level > Drink.max_level():
        a.already_merged = false
        b.already_merged = false
        return

    var total_mass := maxf(a.mass + b.mass, 0.001)
    var pos := (a.position * a.mass + b.position * b.mass) / total_mass
    var vel := (a.linear_velocity * a.mass + b.linear_velocity * b.mass) / total_mass

    # Stop further contacts immediately, then remove both old bodies.
    a.collision_layer = 0
    a.collision_mask = 0
    b.collision_layer = 0
    b.collision_mask = 0
    a.freeze = true
    b.freeze = true
    a.queue_free()
    b.queue_free()

    if GameManager.instance == null or GameManager.instance.game_over:
        return

    var new_drink := GameManager.instance.spawn_drink(new_level, pos, false)
    if new_drink == null:
        return

    new_drink.linear_velocity = vel * 0.5
    new_drink.angular_velocity = randf_range(-3.0, 3.0)
    GameManager.instance.on_merged(new_level, pos)
