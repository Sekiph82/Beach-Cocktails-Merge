extends SceneTree

## Focused M08 visual-polish probe. It exercises existing delivery/economy
## entry points while asserting exactly-once state transitions and cleanup.

const EVIDENCE_DIR := "res://docs/evidence/m08"
const DELIVERY_DURATION := 0.34

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
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

    _check("runtime manager and To-Go target are ready", manager != null and manager.world != null and manager._target_root != null)
    _check_merge_feedback_cleanup(manager)
    await process_frame
    _save_capture("merge_feedback_720x1280.png")
    await _wait_seconds(0.34)
    _check("merge feedback self-cleans", _count_named(manager.world, "MergeFeedback") == 0)

    var merge_a := manager.spawn_drink(2, Vector2(280.0, 600.0), false)
    var merge_b := manager.spawn_drink(2, Vector2(320.0, 600.0), false)
    var raw_merge_position := (merge_a.position * merge_a.mass + merge_b.position * merge_b.mass) / (merge_a.mass + merge_b.mass)
    merge_a.start_sliding(Vector2(40.0, -520.0))
    manager.merge_queue.request_merge(merge_a, merge_b, 3)
    await process_frame
    var merge_result: Drink = null
    for child in manager.world.get_children():
        if child is Drink and child.level == 3 and child != manager.shot_controller._current_drink and not child.is_queued_for_deletion():
            merge_result = child
            break
    var merge_result_position := merge_result.position if merge_result != null else Vector2.ZERO
    _check("merge feedback preserves merge level and raw position", merge_result != null and absf(merge_result_position.x - raw_merge_position.x) < 8.0 and merge_result_position.y <= raw_merge_position.y + 4.0)
    _check("merge feedback preserves inherited momentum", merge_result != null and merge_result.linear_velocity.y <= 0.0 and merge_result.linear_velocity.length() > merge_result.settle_speed)
    for child in manager.world.get_children():
        if child is Drink and child != manager.shot_controller._current_drink:
            child.queue_free()
    manager.merge_queue.clear()
    await process_frame

    manager._target_level = 6
    manager._target_transition = false
    manager._target_drink = null
    manager.score = 0
    manager.chain = 0
    manager._refresh_merge_target_visual()
    var delivery_drink := manager.spawn_drink(6, Vector2(manager.get_board_size().x * 0.5, manager.launch_y - 140.0), false)
    delivery_drink.set_settled()
    var score_before := manager.score
    var reward := Drink.order_reward(6)
    manager._collect_merge_target(delivery_drink)
    _check("matching To-Go drink enters target capture once", manager._target_transition and manager._target_drink == delivery_drink and delivery_drink.motion_state == Drink.MotionState.TARGET_CAPTURE)
    _check("delivery trail is created", _count_named(manager.world, "ToGoDeliveryTrail") == 1)
    await _wait_seconds(0.10)
    _save_capture("delivery_in_progress_720x1280.png")
    await _wait_seconds(DELIVERY_DURATION + 0.10)
    _check("matching drink is removed exactly once", not is_instance_valid(delivery_drink))
    _check("To-Go reward is added exactly once", manager.score - score_before == reward)
    _check("target transition returns to idle and chooses next target", not manager._target_transition and manager._target_drink == null and manager._target_level >= 6 and manager._target_level <= 12)
    _check("stored delivery does not add merge/combo score", manager.chain == 0)
    _check("completion feedback is created", _count_named(manager._to_go_panel, "OrderCompleteFlash") == 1)
    print("M08_STATE completion panels best_visible=%s score_visible=%s hud_visible=%s best_modulate=%s score_modulate=%s" % [manager._best_panel.visible, manager._score_panel.visible, manager._hud.visible, manager._best_panel.modulate, manager._score_panel.modulate])
    _save_capture("order_completion_feedback_720x1280.png")
    await _wait_seconds(0.40)
    _check("delivery trail self-cleans", _count_named(manager.world, "ToGoDeliveryTrail") == 0)
    _check("completion feedback self-cleans", _count_named(manager._to_go_panel, "OrderCompleteFlash") == 0)

    manager._target_level = 6
    manager._target_transition = false
    manager.score = 0
    manager.chain = 0
    manager._refresh_merge_target_visual()
    var duplicate_drink := manager.spawn_drink(6, Vector2(manager.get_board_size().x * 0.5, manager.launch_y - 120.0), false)
    duplicate_drink.set_settled()
    var duplicate_before := manager.score
    manager._collect_merge_target(duplicate_drink)
    manager._collect_merge_target(duplicate_drink)
    await _wait_seconds(DELIVERY_DURATION + 0.12)
    _check("duplicate collection request pays one reward", manager.score - duplicate_before == reward)

    manager.queue_free()
    await process_frame
    _finish()


func _check_merge_feedback_cleanup(manager: GameManager) -> void:
    manager._juice_effect(Vector2(manager.get_board_size().x * 0.5, manager.launch_y - 180.0))
    _check("merge feedback node is created", _count_named(manager.world, "MergeFeedback") == 1)


func _save_capture(name: String) -> void:
    var texture := root.get_texture()
    if texture == null:
        failures.append("capture texture available %s" % name)
        push_error("M08_PROBE FAIL: capture texture unavailable %s" % name)
        return
    var image := texture.get_image()
    var path := "%s/%s" % [EVIDENCE_DIR, name]
    var error := image.save_png(path)
    _check("capture saved %s" % name, error == OK and image.get_width() == 720 and image.get_height() == 1280)
    print("M08_CAPTURE path=%s dimensions=%dx%d error=%s" % [path, image.get_width(), image.get_height(), error])


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


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M08_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        push_error("M08_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M08_TO_GO_DELIVERY_RESULT=PASS")
        quit(0)
        return
    print("M08_TO_GO_DELIVERY_RESULT=FAIL failures=%s" % [failures])
    quit(1)
