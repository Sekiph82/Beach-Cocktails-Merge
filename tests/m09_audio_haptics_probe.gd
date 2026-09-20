extends SceneTree

## Focused M09 probe for the owner-directed order sequence and safe feedback
## hooks. It does not replace the active gameplay/R11 regression suite.

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/evidence/m09"))
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("main scene loads", packed != null)
    if packed == null:
        _finish()
        return

    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    current_scene = manager
    await process_frame
    await process_frame
    await process_frame
    manager.shot_controller.stop_shooting()
    await process_frame

    _check("feedback service is attached", manager.feedback_service != null)
    _check("first live To-Go target is L5", manager._target_level == 5)
    _save_capture("startup_l5_720x1280.png")

    var expected_rewards := [0, 0, 0, 0, 0, 1000, 1800, 3000, 5000, 8000, 12000, 18000]
    var reward_table_ok := true
    for level in range(1, 13):
        reward_table_ok = reward_table_ok and Drink.order_reward(level) == expected_rewards[level - 1]
    _check("existing reward table remains unchanged including L5=0", reward_table_ok)

    var l5_delta := await _deliver_current_order(manager, 5)
    _check("first order completes as L5 with unchanged zero reward", l5_delta == 0 and manager._target_level == 6)
    var l6_delta := await _deliver_current_order(manager, 6)
    _check("second order completes as L6 with existing reward", l6_delta == 1000 and manager._target_level == 7)
    var l7_delta := await _deliver_current_order(manager, 7)
    _check("third order completes as L7 with existing reward", l7_delta == 1800)
    _check("fourth target resumes normal L6-L12 selection", manager._target_level >= 6 and manager._target_level <= 12 and manager._target_level != 7)
    _check("order-complete feedback fires once per completed order", manager.feedback_service.event_count("order_complete") == 3)

    await _cleanup_world(manager)
    var merge_a := manager.spawn_drink(1, Vector2(300.0, 600.0), false)
    var merge_b := manager.spawn_drink(1, Vector2(328.0, 600.0), false)
    merge_a.start_sliding(Vector2(40.0, -520.0))
    manager.merge_queue.request_merge(merge_a, merge_b, 2)
    manager.merge_queue.request_merge(merge_a, merge_b, 2)
    await process_frame
    await _physics_steps(3)
    _check("merge feedback hook fires at most once per merge", manager.feedback_service.event_count("merge") == 1)
    _check("audio hook remains safe without audio assets", manager.feedback_service.audio_play_count == 0 and manager.feedback_service.event_count("merge") == 1)

    var haptic_before: int = manager.feedback_service.haptic_call_count
    manager.feedback_service.set_haptics_supported_for_testing(true)
    manager.feedback_service.set_haptics_enabled(false)
    manager.feedback_service.emit_ui_tap()
    _check("disabling haptics prevents haptic calls", manager.feedback_service.haptic_call_count == haptic_before)
    manager.feedback_service.set_haptics_enabled(true)
    manager.feedback_service.set_haptics_supported_for_testing(false)
    manager.feedback_service.emit_ui_tap()
    _check("unsupported haptics path is a safe no-op", manager.feedback_service.haptic_call_count == haptic_before)

    await _wait_seconds(0.45)
    _check("M08 merge feedback cleanup remains intact", _count_named(manager.world, "MergeFeedback") == 0)
    _check("M08 delivery trail cleanup remains intact", _count_named(manager.world, "ToGoDeliveryTrail") == 0)

    manager.queue_free()
    await process_frame
    _finish()


func _deliver_current_order(manager: GameManager, level: int) -> int:
    _check("live target is expected L%d" % level, manager._target_level == level)
    var drink := manager.spawn_drink(level, Vector2(manager.get_board_size().x * 0.5, manager.launch_y - 150.0), false)
    drink.set_settled()
    var score_before := manager.score
    manager._collect_merge_target(drink)
    if level == 5:
        await _wait_seconds(0.10)
        _save_capture("l5_delivery_in_progress_720x1280.png")
    await _wait_seconds(0.52)
    _check("L%d delivery returns to idle" % level, not manager._target_transition and manager._target_drink == null)
    return manager.score - score_before


func _cleanup_world(manager: GameManager) -> void:
    var held := manager.shot_controller._current_drink
    for child in manager.world.get_children():
        if child is Drink and child != held:
            child.queue_free()
    manager.merge_queue.clear()
    await process_frame
    await _physics_steps(2)


func _physics_steps(count: int) -> void:
    for _index in range(count):
        await physics_frame


func _wait_seconds(seconds: float) -> void:
    await create_timer(seconds).timeout
    await process_frame


func _count_named(parent: Node, node_name: String) -> int:
    if parent == null:
        return 0
    var count := 0
    for child in parent.get_children():
        if child.name == node_name:
            count += 1
    return count


func _save_capture(name: String) -> void:
    if DisplayServer.get_name() == "headless":
        print("M09_CAPTURE name=%s unavailable=headless_renderer" % name)
        return
    var texture := root.get_texture()
    if texture == null:
        print("M09_CAPTURE name=%s unavailable=renderer_has_no_viewport_texture" % name)
        return
    var image := texture.get_image()
    if image == null:
        print("M09_CAPTURE name=%s unavailable=renderer_has_no_image" % name)
        return
    var path := "res://docs/evidence/m09/%s" % name
    var error := image.save_png(path)
    print("M09_CAPTURE name=%s dimensions=%dx%d error=%s" % [name, image.get_width(), image.get_height(), error])


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M09_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        push_error("M09_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M09_AUDIO_HAPTICS_RESULT=PASS")
        quit(0)
        return
    print("M09_AUDIO_HAPTICS_RESULT=FAIL failures=%s" % [failures])
    quit(1)
