extends SceneTree

## Deterministic, non-production M01 contract probe.
## Run with an isolated APPDATA so user://save.cfg cannot touch owner data.

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M01_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M01_PROBE FAIL: %s" % label)


func _physics_steps(count: int = 1) -> void:
    for _i in range(count):
        await physics_frame


func _run() -> void:
    print("M01_PROBE user_save_path=%s" % ProjectSettings.globalize_path("user://save.cfg"))

    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("main scene loads as PackedScene", packed != null)
    if packed == null:
        _finish()
        return

    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    current_scene = manager
    await process_frame
    await _physics_steps(2)

    _check("runtime world is created", manager.world != null)
    _check("runtime ShotController is created", manager.shot_controller != null)
    _check("runtime MergeQueue is created", manager.merge_queue != null)
    _check("initial held drink exists", is_instance_valid(manager.shot_controller._current_drink))
    if not is_instance_valid(manager.shot_controller._current_drink):
        _finish()
        return

    var first := manager.shot_controller._current_drink
    _check("initial drink is HELD", first.motion_state == Drink.MotionState.HELD)
    _check("held drink is frozen", first.freeze)
    _check("held drink has no collision layer/mask", first.collision_layer == 0 and first.collision_mask == 0)

    var mouse_down := InputEventMouseButton.new()
    mouse_down.button_index = MOUSE_BUTTON_LEFT
    mouse_down.pressed = true
    mouse_down.position = Vector2(260.0, first.position.y)
    manager.shot_controller._unhandled_input(mouse_down)
    var mouse_up := InputEventMouseButton.new()
    mouse_up.button_index = MOUSE_BUTTON_LEFT
    mouse_up.pressed = false
    mouse_up.position = Vector2(260.0, first.position.y)
    manager.shot_controller._unhandled_input(mouse_up)
    var launch_velocity_y := first.linear_velocity.y
    await process_frame
    _check("mouse release launches current drink", first.motion_state == Drink.MotionState.SLIDING)
    _check("launched drink uses 700 px/s initial velocity", is_equal_approx(launch_velocity_y, -700.0))
    _check("launched drink is collidable", first.collision_layer == 1 and first.collision_mask == 1)
    _check("next held drink appears immediately after mouse launch", is_instance_valid(manager.shot_controller._current_drink) and manager.shot_controller._current_drink != first)
    var second := manager.shot_controller._current_drink
    _check("next drink is HELD", is_instance_valid(second) and second.motion_state == Drink.MotionState.HELD)

    var touch_down := InputEventScreenTouch.new()
    touch_down.index = 7
    touch_down.pressed = true
    touch_down.position = Vector2(460.0, second.position.y)
    manager.shot_controller._unhandled_input(touch_down)
    var touch_up := InputEventScreenTouch.new()
    touch_up.index = 7
    touch_up.pressed = false
    touch_up.position = Vector2(460.0, second.position.y)
    manager.shot_controller._unhandled_input(touch_up)
    await process_frame
    _check("touch release launches current drink", second.motion_state == Drink.MotionState.SLIDING)
    _check("touch route provides another immediate held drink", is_instance_valid(manager.shot_controller._current_drink) and manager.shot_controller._current_drink.motion_state == Drink.MotionState.HELD)

    var moving_a := manager.spawn_drink(1, Vector2(210.0, 900.0), false)
    var moving_b := manager.spawn_drink(2, Vector2(480.0, 820.0), false)
    moving_a.start_sliding(Vector2(0.0, -700.0))
    moving_b.start_sliding(Vector2(90.0, -620.0))
    await _physics_steps(2)
    _check("multiple drinks can move simultaneously", moving_a.is_sliding() and moving_b.is_sliding())
    _check("sliding deceleration is 180 px/s^2", moving_a.linear_velocity.length() < 700.0 and moving_a.linear_velocity.length() > 690.0)
    _check("forward-only motion removes +Y rebound", moving_a.linear_velocity.y <= 0.0 and moving_b.linear_velocity.y <= 0.0)

    var settled := manager.spawn_drink(2, Vector2(120.0, 800.0), false)
    var impact_mover := manager.spawn_drink(1, Vector2(120.0, 930.0), false)
    impact_mover.start_sliding(Vector2(0.0, -700.0))
    await _physics_steps(16)
    _check("settled drink wakes and is physically movable on impact", settled.is_sliding() or settled.linear_velocity.length() > 0.0)

    var merge_a := manager.spawn_drink(1, Vector2(180.0, 600.0), false)
    var merge_b := manager.spawn_drink(1, Vector2(280.0, 600.0), false)
    merge_a.start_sliding(Vector2(40.0, -600.0))
    manager.merge_queue.request_merge(merge_a, merge_b, 2)
    await process_frame
    await _physics_steps(1)
    var merged_result: Drink = null
    for child in manager.world.get_children():
        if child is Drink and child.level == 2 and child.motion_state != Drink.MotionState.HELD and not child.is_queued_for_deletion():
            merged_result = child
            break
    _check("merge creates capped next level", merged_result != null)
    _check("merge result preserves forward/lateral momentum", merged_result != null and merged_result.is_sliding() and merged_result.linear_velocity.y <= 0.0 and merged_result.linear_velocity.length() > 30.0)
    _check("L12 is the cap and L13 is unavailable", Drink.max_level() == 12)

    manager.score = 123
    manager.best_score = 123
    manager._game_over()
    await process_frame
    await _physics_steps(1)
    var save_path := ProjectSettings.globalize_path("user://save.cfg")
    var persisted := ConfigFile.new()
    var load_err := persisted.load("user://save.cfg")
    _check("Game Over freezes the run and shows overlay", manager.game_over and manager._game_over_layer.visible and not manager.shot_controller._can_shoot)
    _check("best score is persisted through user://", load_err == OK and int(persisted.get_value("records", "best", 0)) == 123 and FileAccess.file_exists(save_path))
    manager._restart_game()
    await process_frame
    await _physics_steps(2)
    var restarted := current_scene as GameManager
    _check("restart reloads a playable scene", restarted != null and not restarted.game_over and is_instance_valid(restarted.shot_controller._current_drink))
    _check("best score survives restart", restarted != null and restarted.best_score == 123)

    _finish()


func _finish() -> void:
    if failures.is_empty():
        print("M01_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M01_PROBE_RESULT=FAIL failures=%s" % [", ".join(failures)])
        quit(1)
