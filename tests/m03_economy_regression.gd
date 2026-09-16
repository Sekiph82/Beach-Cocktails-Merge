extends SceneTree

## Deterministic, non-production M03 economy/state regression probe.
## The caller redirects APPDATA so user://save.cfg is isolated.

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M03_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M03_PROBE FAIL: %s" % label)


func _frames(count: int = 1) -> void:
    for _i in range(count):
        await process_frame


func _cleanup(manager: GameManager) -> void:
    var held := manager.shot_controller._current_drink
    for child in manager.world.get_children():
        if child is Drink and child != held:
            child.queue_free()
    manager.merge_queue.clear()
    manager._target_transition = false
    await _frames(3)


func _count_level(manager: GameManager, level: int, include_held: bool = true) -> int:
    var count := 0
    for child in manager.world.get_children():
        if child is Drink and not child.is_queued_for_deletion() and child.level == level:
            if include_held or child != manager.shot_controller._current_drink:
                count += 1
    return count


func _run() -> void:
    print("M03_PROBE user_save_path=%s" % ProjectSettings.globalize_path("user://save.cfg"))
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("main scene loads as PackedScene", packed != null)
    if packed == null:
        _finish()
        return

    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    current_scene = manager
    await _frames(3)
    _check("runtime economy objects are ready", manager.world != null and manager.merge_queue != null and manager.shot_controller != null)

    var expected_scores := [0, 20, 50, 100, 200, 350, 600, 1000, 1600, 2500, 4000, 6500]
    var score_rows: Array[String] = []
    var score_table_ok := Drink.max_level() == 12
    var score_drinks: Array[Drink] = []
    manager._target_level = 1
    for level in range(2, 13):
        var score_drink := manager.spawn_drink(level, Vector2(80.0 + float(level) * 45.0, 500.0), false)
        score_drinks.append(score_drink)
        manager.score = 0
        manager.chain = 0
        manager.chain_timer = 0.0
        manager.on_merged(level, score_drink)
        var observed := manager.score
        score_rows.append("L%d expected=%d observed=%d" % [level, expected_scores[level - 1], observed])
        score_table_ok = score_table_ok and observed == expected_scores[level - 1]
    print("M03_SCORE_TABLE %s" % "; ".join(score_rows))
    _check("every resulting merge level L2-L12 pays the exact score once", score_table_ok)
    await _cleanup(manager)

    var combo_result := manager.spawn_drink(2, Vector2(360.0, 500.0), false)
    manager._target_level = 1
    manager.score = 0
    manager.chain = 0
    manager.chain_timer = 0.0
    var combo_observed: Array[int] = []
    for _step in range(7):
        var before := manager.score
        manager.on_merged(2, combo_result)
        combo_observed.append(manager.score - before)
    print("M03_COMBO observed_deltas=%s chain=%d timer=%s" % [combo_observed, manager.chain, manager.chain_timer])
    _check("combo x1 through x6+ uses 0/25/50/75/100/125 percent cap", combo_observed == [20, 25, 30, 35, 40, 45, 45] and manager.chain == 6)
    manager.chain_timer = 0.10
    manager._process(0.11)
    _check("combo expiration resets deterministically", manager.chain == 0 and is_equal_approx(manager.chain_timer, 0.0))
    var reset_before := manager.score
    manager.on_merged(2, combo_result)
    _check("post-window merge restarts at x1", manager.score - reset_before == 20 and manager.chain == 1)
    await _cleanup(manager)

    manager._choose_next_target(true)
    await _frames(2)
    _check("initial active To-Go target starts at L6", manager._target_level == 6)
    var previous_target := manager._target_level
    manager._choose_next_target(false)
    await _frames(2)
    _check("To-Go target stays in L6-L12 and avoids immediate repeat", manager._target_level >= 6 and manager._target_level <= 12 and manager._target_level != previous_target)

    manager._target_level = 8
    manager._refresh_merge_target_visual()
    manager.score = 0
    manager.chain = 0
    var immediate_match := manager.spawn_drink(8, Vector2(360.0, 700.0), false)
    manager.on_merged(8, immediate_match)
    await _frames(120)
    _check("newly created matching drink fulfills active order", not is_instance_valid(immediate_match) and manager.score == Drink.merge_score(8) + Drink.order_reward(8))
    await _cleanup(manager)

    manager._target_level = 9
    manager._refresh_merge_target_visual()
    manager.score = 0
    manager.chain = 0
    var stored_match := manager.spawn_drink(9, Vector2(220.0, 700.0), false)
    manager._try_collect_stocked_target()
    await _frames(120)
    var stored_score := manager.score
    manager._try_collect_stocked_target()
    await _frames(3)
    _check("stored matching drink receives only the current To-Go reward", not is_instance_valid(stored_match) and stored_score == Drink.order_reward(9) and manager.score == stored_score)
    await _cleanup(manager)

    manager._target_level = 10
    manager._refresh_merge_target_visual()
    manager.score = 0
    var stored_a := manager.spawn_drink(10, Vector2(200.0, 700.0), false)
    var stored_b := manager.spawn_drink(10, Vector2(500.0, 700.0), false)
    manager._try_collect_stocked_target()
    await _frames(120)
    _check("only one of multiple matching stored drinks is consumed", (not is_instance_valid(stored_a)) != (not is_instance_valid(stored_b)) and _count_level(manager, 10, false) == 1 and manager.score == Drink.order_reward(10))
    await _cleanup(manager)

    manager._target_level = 11
    manager._refresh_merge_target_visual()
    var stored_l12 := manager.spawn_drink(12, Vector2(360.0, 700.0), false)
    manager._try_collect_stocked_target()
    await _frames(3)
    var remains_when_not_ordered := is_instance_valid(stored_l12)
    manager._target_level = 12
    manager._refresh_merge_target_visual()
    manager.score = 0
    manager._try_collect_stocked_target()
    await _frames(120)
    _check("L12 remains stored when not ordered and fulfills a later L12 order", remains_when_not_ordered and not is_instance_valid(stored_l12) and manager.score == Drink.order_reward(12))
    await _cleanup(manager)

    manager._target_level = 1
    manager.score = 0
    var duplicate_a := manager.spawn_drink(1, Vector2(260.0, 600.0), false)
    var duplicate_b := manager.spawn_drink(1, Vector2(288.0, 600.0), false)
    manager.merge_queue.request_merge(duplicate_a, duplicate_b, 2)
    manager.merge_queue.request_merge(duplicate_a, duplicate_b, 2)
    await _frames(5)
    _check("duplicate merge request cannot double-pay", manager.score == Drink.merge_score(2) and _count_level(manager, 2, false) == 1 and manager.merge_queue._pending.is_empty())
    await _cleanup(manager)

    var save_path := "user://save.cfg"
    var save_absolute := ProjectSettings.globalize_path(save_path)
    if FileAccess.file_exists(save_absolute):
        DirAccess.remove_absolute(save_absolute)
    manager._load_best_score()
    _check("missing save loads safe best-score default", manager.best_score == 0)
    var corrupt := FileAccess.open(save_path, FileAccess.WRITE)
    corrupt.store_string("not a valid ConfigFile [[[")
    corrupt.close()
    manager.best_score = 999
    manager._load_best_score()
    _check("corrupt save loads safe best-score default without crash", manager.best_score == 0)

    var danger_drink := manager.spawn_drink(1, Vector2(360.0, 1050.0), false)
    manager._line_timer = 0.0
    manager._process(0.50)
    var before_tolerance := not manager.game_over
    manager._process(0.50)
    _check("danger line waits below one-second tolerance", before_tolerance)
    _check("danger line triggers deterministic Game Over at one second", manager.game_over and manager._line_timer >= manager.death_tolerance and danger_drink.freeze)

    manager = current_scene as GameManager
    manager._restart_game()
    await _frames(5)
    var restarted := current_scene as GameManager
    _check("restart clears session score/state and restores playable scene", restarted != null and not restarted.game_over and restarted.score == 0 and is_instance_valid(restarted.shot_controller._current_drink))

    restarted.score = 321
    restarted.best_score = 321
    var moving_at_gameover: Array[Drink] = []
    for index in range(3):
        var moving := restarted.spawn_drink(1 + index, Vector2(120.0 + float(index) * 240.0, 850.0), false)
        moving.start_sliding(Vector2(30.0 * float(index), -500.0))
        moving_at_gameover.append(moving)
    await _frames(2)
    restarted._game_over()
    await _frames(2)
    var all_frozen := true
    for moving in moving_at_gameover:
        all_frozen = all_frozen and is_instance_valid(moving) and moving.freeze
    _check("Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay", restarted.game_over and not restarted.shot_controller._can_shoot and restarted._game_over_layer.visible and restarted.merge_queue._pending.is_empty() and all_frozen)
    var persisted := ConfigFile.new()
    var persisted_error := persisted.load(save_path)
    _check("Game Over persists best score without corrupting save", persisted_error == OK and int(persisted.get_value("records", "best", 0)) == 321)
    restarted._restart_game()
    await _frames(5)
    var final_scene := current_scene as GameManager
    _check("restart after moving Game Over preserves best and clears session", final_scene != null and not final_scene.game_over and final_scene.score == 0 and final_scene.best_score == 321 and is_instance_valid(final_scene.shot_controller._current_drink))

    print("M03_REWARD_STATUS L6=%d L7=%d L8=%d L9=%d L10=%d L11=%d L12=%d" % [Drink.order_reward(6), Drink.order_reward(7), Drink.order_reward(8), Drink.order_reward(9), Drink.order_reward(10), Drink.order_reward(11), Drink.order_reward(12)])
    print("OWNER DECISION REQUIRED FOR FINAL L6/L7 REWARD VALUES")
    _finish()


func _finish() -> void:
    if failures.is_empty():
        print("M03_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M03_PROBE_RESULT=FAIL failures=%s" % [", ".join(failures)])
        quit(1)
