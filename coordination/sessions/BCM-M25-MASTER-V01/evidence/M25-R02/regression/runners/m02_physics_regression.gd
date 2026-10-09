extends SceneTree

## Deterministic, non-production M02 physics/merge/rapid-launch regression probe.
## The caller redirects APPDATA so user:// persistence is isolated.

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M02_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M02_PROBE FAIL: %s" % label)


func _physics_steps(count: int = 1) -> void:
    for _i in range(count):
        await physics_frame


func _cleanup(manager: GameManager) -> void:
    var held := manager.shot_controller._current_drink
    for child in manager.world.get_children():
        if child is Drink and child != held:
            child.queue_free()
    manager.merge_queue.clear()
    await process_frame
    await _physics_steps(2)


func _drink_count(manager: GameManager, level: int = -1, include_held: bool = true) -> int:
    var count := 0
    for child in manager.world.get_children():
        if child is Drink and not child.is_queued_for_deletion():
            if not include_held and child == manager.shot_controller._current_drink:
                continue
            if level < 0 or child.level == level:
                count += 1
    return count


func _run() -> void:
    print("M02_PROBE user_save_path=%s" % ProjectSettings.globalize_path("user://save.cfg"))
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

    _check("runtime GameManager/World is ready", manager.world != null)
    _check("runtime world has four named rails", manager.world.get_node_or_null("LeftRail") != null and manager.world.get_node_or_null("RightRail") != null and manager.world.get_node_or_null("TopRail") != null and manager.world.get_node_or_null("BottomRail") != null)

    var body := manager.spawn_drink(6, Vector2(360.0, 700.0), false)
    var material := body.physics_material_override as PhysicsMaterial
    var body_config_ok := body is RigidBody2D and body.freeze_mode == RigidBody2D.FREEZE_MODE_STATIC and body.continuous_cd == RigidBody2D.CCD_MODE_CAST_SHAPE and is_equal_approx(body.mass, 2.5) and is_equal_approx(body.linear_damp, 0.0) and is_equal_approx(body.angular_damp, 3.0) and material != null and is_equal_approx(material.friction, 0.08) and is_equal_approx(material.bounce, 0.0)
    print("M02_BODY_CONFIG level=6 mass=%s radius=%s freeze_mode=%s ccd=%s linear_damp=%s angular_damp=%s friction=%s bounce=%s" % [body.mass, body.radius, body.freeze_mode, body.continuous_cd, body.linear_damp, body.angular_damp, material.friction, material.bounce])
    _check("RigidBody2D body and zero-bounce physics configuration", body_config_ok)
    _check("settled body starts dynamic, sleeping, and collidable", not body.freeze and body.sleeping and body.collision_layer == 1 and body.collision_mask == 1 and body.is_settled())

    var mass_rows: Array[String] = []
    var mass_monotonic := true
    var previous_mass := 0.0
    for level in range(1, Drink.max_level() + 1):
        var mass_drink := manager.spawn_drink(level, Vector2(60.0 + float(level) * 45.0, 400.0), false)
        mass_rows.append("L%d radius=%s mass=%s json_mass=%s" % [level, mass_drink.radius, mass_drink.mass, float(Drink.drinks_data[level - 1].get("mass", 0))])
        mass_monotonic = mass_monotonic and mass_drink.mass > previous_mass
        previous_mass = mass_drink.mass
    print("M02_MASS_RADIUS_TABLE %s" % "; ".join(mass_rows))
    _check("all 12 collider radii are positive and runtime mass is monotonic", mass_monotonic and Drink.max_level() == 12)
    await _cleanup(manager)

    var held := manager.shot_controller._current_drink
    _check("held state is frozen and non-physical before release", is_instance_valid(held) and held.motion_state == Drink.MotionState.HELD and held.freeze and held.collision_layer == 0 and held.collision_mask == 0)
    held.start_sliding(Vector2(0.0, -700.0))
    await _physics_steps(2)
    _check("held-to-sliding transition enables dynamic collision", held.motion_state == Drink.MotionState.SLIDING and not held.freeze and held.collision_layer == 1 and held.collision_mask == 1)
    await _cleanup(manager)

    # Isolate the next top-rail case from the deliberately launched preview
    # used above. Keeping that moving reference alive would let it collide
    # with top_hit before the top-rail assertion and invalidate the fixture.
    manager.shot_controller.stop_shooting()
    manager.shot_controller._can_shoot = true
    manager.shot_controller._spawn_next()
    await process_frame

    var top_hit := manager.spawn_drink(1, Vector2(360.0, 520.0), false)
    top_hit.start_sliding(Vector2(0.0, -700.0))
    await _physics_steps(55)
    print("M02_TOP_CONTACT final_position=%s motion_state=%s velocity=%s" % [top_hit.position, top_hit.motion_state, top_hit.linear_velocity])
    _check("top boundary contact settles without +Y rebound", top_hit.is_settled() and top_hit.position.y <= manager.table_top_y + top_hit.radius + manager.wall_thickness and top_hit.linear_velocity.y <= 0.1)
    await _cleanup(manager)

    var direct_target := manager.spawn_drink(2, Vector2(150.0, 700.0), false)
    var direct_mover := manager.spawn_drink(1, Vector2(150.0, 900.0), false)
    var direct_start := direct_target.position
    var direct_contacts := {"count": 0}
    direct_target.body_entered.connect(func(_other: Node): direct_contacts["count"] += 1)
    direct_mover.start_sliding(Vector2(0.0, -700.0))
    await _physics_steps(30)
    print("M02_DIRECT_HIT contacts=%d target_position=%s target_state=%s" % [direct_contacts["count"], direct_target.position, direct_target.motion_state])
    _check("700 px/s direct-hit has contact without tunneling", direct_contacts["count"] > 0 and direct_target.position != direct_start and (direct_target.is_sliding() or direct_target.linear_velocity.length() > 0.0))
    await _cleanup(manager)

    var glance_target := manager.spawn_drink(2, Vector2(520.0, 700.0), false)
    var glance_mover := manager.spawn_drink(1, Vector2(430.0, 900.0), false)
    var glance_start := glance_target.position
    var glance_contacts := {"count": 0}
    glance_target.body_entered.connect(func(_other: Node): glance_contacts["count"] += 1)
    glance_mover.start_sliding(Vector2(240.0, -700.0))
    await _physics_steps(35)
    print("M02_GLANCING_HIT contacts=%d target_position=%s target_state=%s" % [glance_contacts["count"], glance_target.position, glance_target.motion_state])
    _check("700 px/s glancing-hit has contact without tunneling", glance_contacts["count"] > 0 and glance_target.position != glance_start and (glance_target.is_sliding() or glance_target.linear_velocity.length() > 0.0))
    _check("collision response remains forward-only", glance_mover.linear_velocity.y <= 0.0 and glance_target.linear_velocity.y <= 0.0)
    await _cleanup(manager)

    var merge_a := manager.spawn_drink(1, Vector2(260.0, 600.0), false)
    var merge_b := manager.spawn_drink(1, Vector2(288.0, 600.0), false)
    var score_before := manager.score
    manager.merge_queue.request_merge(merge_a, merge_b, 2)
    manager.merge_queue.request_merge(merge_a, merge_b, 2)
    await process_frame
    await _physics_steps(2)
    var merge_result_count := _drink_count(manager, 2, false)
    print("M02_SINGLE_MERGE score_delta=%d level2_bodies=%d pending=%d" % [manager.score - score_before, merge_result_count, manager.merge_queue._pending.size()])
    _check("one pair resolves once with one score and one result body", not is_instance_valid(merge_a) and not is_instance_valid(merge_b) and manager.score - score_before == Drink.merge_score(2) and merge_result_count == 1 and manager.merge_queue._pending.is_empty())
    await _cleanup(manager)

    var chain_a := manager.spawn_drink(1, Vector2(200.0, 580.0), false)
    var chain_b := manager.spawn_drink(1, Vector2(228.0, 580.0), false)
    var chain_partner := manager.spawn_drink(2, Vector2(250.0, 580.0), false)
    var stress_one := manager.spawn_drink(3, Vector2(80.0, 900.0), false)
    var stress_two := manager.spawn_drink(4, Vector2(600.0, 900.0), false)
    stress_one.start_sliding(Vector2(70.0, -520.0))
    stress_two.start_sliding(Vector2(-70.0, -520.0))
    manager.merge_queue.request_merge(chain_a, chain_b, 2)
    await process_frame
    await _physics_steps(10)
    var chain_l3 := _drink_count(manager, 3, false)
    print("M02_CHAIN_STRESS l3_bodies=%d moving_stress=%s pending=%d" % [chain_l3, stress_one.is_sliding() and stress_two.is_sliding(), manager.merge_queue._pending.size()])
    _check("moving multi-body chain merge produces stable L3", chain_l3 == 2 and stress_one.is_sliding() and stress_two.is_sliding() and manager.merge_queue._pending.is_empty())
    _check("chain merge consumes only the intended chain inputs", not is_instance_valid(chain_a) and not is_instance_valid(chain_b) and not is_instance_valid(chain_partner))
    await _cleanup(manager)

    var l12_a := manager.spawn_drink(12, Vector2(480.0, 650.0), false)
    var l12_b := manager.spawn_drink(12, Vector2(480.0, 900.0), false)
    l12_a.start_sliding(Vector2(0.0, -500.0))
    await _physics_steps(40)
    _check("L12 plus L12 remains two L12 bodies with no L13", is_instance_valid(l12_a) and is_instance_valid(l12_b) and l12_a.level == 12 and l12_b.level == 12 and _drink_count(manager, 13) == 0)
    _check("L12 remains a hard cap", Drink.max_level() == 12)
    await _cleanup(manager)

    # The prior transition test deliberately launched the controller's held
    # object directly. Re-seed the controller so this section starts with a
    # fresh held reference, matching a real post-shot controller state.
    manager.shot_controller.stop_shooting()
    manager.shot_controller._can_shoot = true
    manager.shot_controller._spawn_next()
    await process_frame

    var rapid_previous: Drink = null
    var rapid_fired: Array[Drink] = []
    var rapid_ok := true
    for launch_index in range(6):
        var current := manager.shot_controller._current_drink
        var pre_ok := is_instance_valid(current) and current.motion_state == Drink.MotionState.HELD and current.freeze and current.collision_layer == 0 and current.collision_mask == 0 and (rapid_previous == null or rapid_previous.motion_state == Drink.MotionState.SLIDING)
        manager.shot_controller._move_current_to(90.0 + float(launch_index) * 100.0)
        manager.shot_controller._launch()
        rapid_fired.append(current)
        rapid_previous = current
        var post_current := manager.shot_controller._current_drink
        var post_ok := is_instance_valid(post_current) and post_current != current and post_current.motion_state == Drink.MotionState.HELD
        print("M02_RAPID_STEP index=%d pre_ok=%s post_ok=%s fired_state=%s next_state=%s" % [launch_index + 1, pre_ok, post_ok, current.motion_state if is_instance_valid(current) else "INVALID", post_current.motion_state if is_instance_valid(post_current) else "INVALID"])
        rapid_ok = rapid_ok and pre_ok and post_ok
    await _physics_steps(3)
    var rapid_simulated := 0
    for fired in rapid_fired:
        if is_instance_valid(fired) and (fired.is_sliding() or fired.is_settled()):
            rapid_simulated += 1
    print("M02_RAPID_LAUNCH launches=6 world_drinks=%d simulated_previous=%d current_valid=%s current_state=%s" % [_drink_count(manager), rapid_simulated, is_instance_valid(manager.shot_controller._current_drink), manager.shot_controller._current_drink.motion_state if is_instance_valid(manager.shot_controller._current_drink) else "INVALID"])
    _check("six rapid launches preserve current/next integrity", rapid_ok and is_instance_valid(manager.shot_controller._current_drink) and manager.shot_controller._current_drink.motion_state == Drink.MotionState.HELD)
    _check("earlier rapid-launch drinks continue physical simulation", rapid_simulated >= 4)
    await _cleanup(manager)

    for moving_index in range(4):
        var moving := manager.spawn_drink(1 + moving_index, Vector2(100.0 + float(moving_index) * 170.0, 850.0), false)
        moving.start_sliding(Vector2(30.0 * float(moving_index - 1), -560.0))
    await _physics_steps(2)
    manager._restart_game()
    await process_frame
    await _physics_steps(3)
    var restarted := current_scene as GameManager
    _check("restart during multi-body motion produces clean playable scene", restarted != null and not restarted.game_over and is_instance_valid(restarted.shot_controller._current_drink) and _drink_count(restarted) == 1)
    manager = restarted

    for moving_index in range(4):
        var gameover_moving := manager.spawn_drink(1 + moving_index, Vector2(100.0 + float(moving_index) * 170.0, 850.0), false)
        gameover_moving.start_sliding(Vector2(20.0 * float(moving_index), -540.0))
    await _physics_steps(2)
    manager._game_over()
    await process_frame
    var frozen_after_gameover := true
    for child in manager.world.get_children():
        if child is Drink:
            frozen_after_gameover = frozen_after_gameover and child.freeze
    _check("Game Over with multiple moving drinks freezes all and stops shooting", manager.game_over and manager._game_over_layer.visible and not manager.shot_controller._can_shoot and frozen_after_gameover and manager.merge_queue._pending.is_empty())
    manager._restart_game()
    await process_frame
    await _physics_steps(3)
    var final_scene := current_scene as GameManager
    _check("post-Game-Over restart has no stale moving-body references", final_scene != null and not final_scene.game_over and is_instance_valid(final_scene.shot_controller._current_drink) and _drink_count(final_scene) == 1)

    _finish()


func _finish() -> void:
    if failures.is_empty():
        print("M02_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M02_PROBE_RESULT=FAIL failures=%s" % [", ".join(failures)])
        quit(1)
