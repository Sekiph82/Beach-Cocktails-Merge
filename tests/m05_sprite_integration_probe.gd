extends SceneTree

## Deterministic, non-production M05 sprite/body integration regression probe.
## The production Drink class owns both the RigidBody2D and its Sprite2D.

var failures: Array[String] = []
const EVIDENCE_DIR := "res://docs/evidence/m05"
const EVIDENCE_CANVAS_SCRIPT := "res://tests/m05_evidence_canvas.gd"


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M05_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M05_PROBE FAIL: %s" % label)


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


func _drink_count(manager: GameManager, include_held: bool = true) -> int:
    var count := 0
    for child in manager.world.get_children():
        if child is Drink and not child.is_queued_for_deletion():
            if include_held or child != manager.shot_controller._current_drink:
                count += 1
    return count


func _sprite_for(drink: Drink) -> Sprite2D:
    return drink.get_node_or_null("Visual/CocktailSprite") as Sprite2D


func _body_radius_for(drink: Drink) -> float:
    for child in drink.get_children():
        if child is CollisionShape2D:
            var circle := child.shape as CircleShape2D
            return circle.radius if circle != null else 0.0
    return 0.0


func _run() -> void:
    print("M05_PROBE user_save_path=%s" % ProjectSettings.globalize_path("user://save.cfg"))
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
    _check("runtime world and shot controller are ready", manager.world != null and manager.shot_controller != null)

    var map_ok := Drink.texture_path_for_level(0).is_empty() and Drink.texture_path_for_level(13).is_empty() and Drink.texture_for_level(0) == null and Drink.texture_for_level(13) == null
    print("M05_TEXTURE_MAP L01=%s L12=%s invalid13=%s" % [Drink.texture_path_for_level(1), Drink.texture_path_for_level(12), Drink.texture_path_for_level(13)])
    _check("invalid levels fail safely without an L13 texture", map_ok)

    var table_rows: Array[String] = []
    var table_ok := true
    var radii_ok := true
    var previous_radius := 0.0
    for level in range(1, 13):
        var drink := manager.spawn_drink(level, Vector2(60.0 + float(level) * 50.0, 520.0), false)
        var sprite := _sprite_for(drink)
        var texture_ok := sprite != null and sprite.texture == Drink.texture_for_level(level) and sprite.texture.resource_path == Drink.texture_path_for_level(level)
        var presentation_ok := texture_ok and is_equal_approx(sprite.scale.x, Drink.visual_scale_for_level(level)) and is_equal_approx(sprite.position.x, Drink.visual_offset_for_level(level).x) and is_equal_approx(sprite.position.y, Drink.visual_offset_for_level(level).y)
        var radius := _body_radius_for(drink)
        var collider_ok := is_equal_approx(radius, Drink.collider_radius_for_level(level)) and radius > 0.0
        radii_ok = radii_ok and radius > previous_radius
        previous_radius = radius
        table_ok = table_ok and presentation_ok and collider_ok and drink.get_node_or_null("Visual") != null
        table_rows.append("L%d texture=%s scale=%.6f offset=%s collider_radius=%.1f" % [level, sprite.texture.resource_path if sprite != null and sprite.texture != null else "INVALID", Drink.visual_scale_for_level(level), Drink.visual_offset_for_level(level), radius])
    print("M05_PRESENTATION_TABLE %s" % "; ".join(table_rows))
    _check("all L01-L12 table drinks use the canonical Sprite2D mapping", table_ok and radii_ok)
    _check("all L01-L12 visual/body scales stay bounded for the portrait playfield", table_ok and _max_visual_extent(manager) <= 360.0)
    await _save_presentation_evidence()

    var held := manager.shot_controller._current_drink
    var held_sprite := _sprite_for(held)
    _check("held launch drink uses a canonical Sprite2D", is_instance_valid(held) and held_sprite != null and held_sprite.texture == Drink.texture_for_level(held.level) and held.motion_state == Drink.MotionState.HELD)
    await _cleanup(manager)

    var merge_a := manager.spawn_drink(2, Vector2(280.0, 600.0), false)
    var merge_b := manager.spawn_drink(2, Vector2(320.0, 600.0), false)
    var merge_position := (merge_a.position * merge_a.mass + merge_b.position * merge_b.mass) / (merge_a.mass + merge_b.mass)
    merge_a.start_sliding(Vector2(40.0, -520.0))
    manager.merge_queue.request_merge(merge_a, merge_b, 3)
    await process_frame
    var merge_result_position := Vector2.ZERO
    for child in manager.world.get_children():
        if child is Drink and child.level == 3 and child != manager.shot_controller._current_drink and not child.is_queued_for_deletion():
            merge_result_position = child.position
            break
    await _physics_steps(3)
    var merge_result: Drink = null
    for child in manager.world.get_children():
        if child is Drink and child.level == 3 and child != manager.shot_controller._current_drink and not child.is_queued_for_deletion():
            merge_result = child
            break
    var merge_sprite := _sprite_for(merge_result) if merge_result != null else null
    var plausible_contact_position := absf(merge_result_position.x - merge_position.x) < 8.0 and merge_result_position.y <= merge_position.y + 4.0 and merge_result_position.y > merge_position.y - 140.0
    var merge_visual_ok := merge_result != null and merge_sprite != null and merge_sprite.texture == Drink.texture_for_level(3) and is_equal_approx(_body_radius_for(merge_result), Drink.collider_radius_for_level(3)) and plausible_contact_position and merge_result.linear_velocity.y <= 0.0 and merge_result.linear_velocity.length() > merge_result.settle_speed
    print("M05_MERGE_RESULT level=%s position=%s expected_position=%s texture=%s radius=%s velocity=%s" % [merge_result.level if merge_result != null else "NONE", merge_result.position if merge_result != null else "NONE", merge_position, merge_sprite.texture.resource_path if merge_sprite != null and merge_sprite.texture != null else "NONE", _body_radius_for(merge_result) if merge_result != null else 0.0, merge_result.linear_velocity if merge_result != null else Vector2.ZERO])
    _check("merge creates the correct next-level sprite atomically", merge_visual_ok)
    _check("merge result preserves forward/lateral momentum without visual teleport", merge_visual_ok)
    await _cleanup(manager)

    var l12_a := manager.spawn_drink(12, Vector2(300.0, 620.0), false)
    var l12_b := manager.spawn_drink(12, Vector2(390.0, 620.0), false)
    manager.merge_queue.request_merge(l12_a, l12_b, 13)
    await process_frame
    await _physics_steps(2)
    _check("L12 has no L13 texture/path and stays capped", Drink.texture_path_for_level(13).is_empty() and _drink_count(manager, false) == 2 and _drink_count(manager, false) > 0)
    await _cleanup(manager)

    manager.shot_controller.stop_shooting()
    manager.shot_controller._can_shoot = true
    manager.shot_controller._spawn_next()
    await process_frame
    var rapid_ok := true
    var rapid_visuals := 0
    for launch_index in range(6):
        var current := manager.shot_controller._current_drink
        var current_sprite := _sprite_for(current)
        var pre_ok := is_instance_valid(current) and current.motion_state == Drink.MotionState.HELD and current_sprite != null and current_sprite.texture == Drink.texture_for_level(current.level)
        manager.shot_controller._move_current_to(100.0 + float(launch_index) * 90.0)
        manager.shot_controller._launch()
        var next := manager.shot_controller._current_drink
        var next_sprite := _sprite_for(next)
        var post_ok := is_instance_valid(next) and next.motion_state == Drink.MotionState.HELD and next_sprite != null and next_sprite.texture == Drink.texture_for_level(next.level)
        rapid_ok = rapid_ok and pre_ok and post_ok
        rapid_visuals += 1 if pre_ok and post_ok else 0
    await _physics_steps(3)
    print("M05_RAPID_VISUALS launches=6 verified_steps=%d current_level=%d" % [rapid_visuals, manager.shot_controller._current_drink.level])
    _check("rapid launches preserve coherent current/next Sprite2D visuals", rapid_ok and rapid_visuals == 6)
    await _cleanup(manager)

    manager._restart_game()
    await process_frame
    await _physics_steps(3)
    var restarted := current_scene as GameManager
    var restart_drink := restarted.shot_controller._current_drink
    _check("restart leaves one playable held Sprite2D and no orphan visuals", restarted != null and not restarted.game_over and _drink_count(restarted) == 1 and _sprite_for(restart_drink) != null)
    var moving := restarted.spawn_drink(4, Vector2(300.0, 850.0), false)
    moving.start_sliding(Vector2(80.0, -500.0))
    await _physics_steps(2)
    restarted._game_over()
    await process_frame
    var gameover_visuals_ok := true
    for child in restarted.world.get_children():
        if child is Drink:
            gameover_visuals_ok = gameover_visuals_ok and _sprite_for(child) != null and child.get_node_or_null("Visual") != null
    _check("Game Over preserves visual/body ownership without orphan nodes", restarted.game_over and gameover_visuals_ok)
    restarted._restart_game()
    await process_frame
    await _physics_steps(3)
    var final_scene := current_scene as GameManager
    _check("restart after Game Over restores one canonical held visual", final_scene != null and not final_scene.game_over and _drink_count(final_scene) == 1 and _sprite_for(final_scene.shot_controller._current_drink) != null)

    _finish()


func _max_visual_extent(manager: GameManager) -> float:
    var maximum := 0.0
    for child in manager.world.get_children():
        if child is Drink:
            var sprite := _sprite_for(child)
            if sprite != null and sprite.texture != null:
                maximum = maxf(maximum, float(maxi(sprite.texture.get_width(), sprite.texture.get_height())) * sprite.scale.x)
    return maximum


func _save_presentation_evidence() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
    var levels := range(1, 13)
    var grid_positions: Array[Vector2] = []
    for y in [180.0, 390.0, 600.0]:
        for x in [190.0, 590.0, 990.0, 1390.0]:
            grid_positions.append(Vector2(x, y))
    var clean := await _render_evidence(levels, grid_positions, false, "M05 L01-L12 clean presentation")
    var overlay := await _render_evidence(levels, grid_positions, true, "M05 L01-L12 collider / pivot overlay")
    var pairs := await _render_evidence([1, 2, 6, 7, 11, 12], [Vector2(100.0, 190.0), Vector2(143.0, 190.0), Vector2(430.0, 190.0), Vector2(521.0, 190.0), Vector2(780.0, 190.0), Vector2(950.0, 190.0)], true, "M05 touching pairs: small / mid / high")
    var continuity := await _render_evidence([2, 2, 3], [Vector2(270.0, 250.0), Vector2(345.0, 250.0), Vector2(850.0, 250.0)], false, "M05 merge continuity: L02 + L02 -> L03")
    var saves := [
        [clean, "%s/all_levels_clean.png" % EVIDENCE_DIR],
        [overlay, "%s/all_levels_collider_overlay.png" % EVIDENCE_DIR],
        [pairs, "%s/touching_pairs.png" % EVIDENCE_DIR],
        [continuity, "%s/merge_continuity.png" % EVIDENCE_DIR],
    ]
    var saved_ok := true
    for item in saves:
        var image: Image = item[0]
        var path: String = item[1]
        var error := image.save_png(path)
        saved_ok = saved_ok and error == OK and FileAccess.file_exists(path)
        print("M05_EVIDENCE_CAPTURE path=%s dimensions=%dx%d error=%s" % [path, image.get_width(), image.get_height(), error])
    _check("runtime collider/pivot/contact evidence captures saved", saved_ok)


func _render_evidence(levels: Array, positions: Array[Vector2], annotated: bool, title: String) -> Image:
    var viewport := SubViewport.new()
    viewport.size = Vector2i(1600, 760)
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport.transparent_bg = false
    root.add_child(viewport)
    var canvas := Node2D.new()
    canvas.set_script(load(EVIDENCE_CANVAS_SCRIPT))
    var evidence_drinks: Array[Drink] = []
    canvas.set("annotated", annotated)
    canvas.set("title", title)
    viewport.add_child(canvas)
    for index in range(levels.size()):
        var drink := Drink.create(int(levels[index]))
        drink.position = positions[index]
        drink.set_settled()
        viewport.add_child(drink)
        evidence_drinks.append(drink)
    canvas.set("drinks", evidence_drinks)
    await process_frame
    await process_frame
    var image := viewport.get_texture().get_image()
    viewport.queue_free()
    await process_frame
    return image


func _finish() -> void:
    if failures.is_empty():
        print("M05_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M05_PROBE_RESULT=FAIL failures=%s" % [", ".join(failures)])
        quit(1)
