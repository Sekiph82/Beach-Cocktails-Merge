class_name MergeQueue
extends Node
## KRITIK: Godot 4.7.2'de de (Jolt dahil) fizik callback'i icinde
## add_child / queue_free yapmak yasaktir. Tum birlesmeler frame sonunda
## _physics_process icinden islenir.

var _pending: Array = []

func request_merge(a: Drink, b: Drink, new_level: int) -> void:
    # Ayni nesne ikinci kez kuyruga eklenmesin
    for m in _pending:
        if m["a"] == a or m["b"] == a or m["a"] == b or m["b"] == b:
            return
    _pending.append({"a": a, "b": b, "level": new_level})

func _physics_process(_delta: float) -> void:
    while not _pending.is_empty():
        var m: Dictionary = _pending.pop_front()
        _do_merge(m["a"], m["b"], m["level"])

func _do_merge(a: Drink, b: Drink, new_level: int) -> void:
    if not is_instance_valid(a) or not is_instance_valid(b):
        return
    var world := a.get_parent()
    var pos := (a.position * a.mass + b.position * b.mass) / (a.mass + b.mass)
    var vel := (a.linear_velocity * a.mass + b.linear_velocity * b.mass) / (a.mass + b.mass)

    a.queue_free()
    b.queue_free()

    if new_level > 12:  # ust sinir - Efsanevi birlesmez
        return

    var new_drink := Drink.create(new_level)
    new_drink.position = pos
    world.add_child(new_drink)
    new_drink.linear_velocity = vel * 0.5    # geri tepme hissi
    new_drink.angular_velocity = randf_range(-3.0, 3.0)

    GameManager.instance.on_merged(new_level, pos)
