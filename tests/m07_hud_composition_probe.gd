extends SceneTree

## Deterministic, non-production M07 HUD probe.
## It interrogates the production scene and saves actual rendered captures.

const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const CAPTURE_DIR := "res://docs/evidence/m07"
const ASSET_ROOT := "res://assets/ui/"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("main scene loads as PackedScene", packed != null)
    if packed == null:
        _finish()
        return

    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    await process_frame
    _prepare_live_state(manager)
    await process_frame

    _check_hud_contract(manager, "canonical")
    await _save_capture(root, "canonical_720x1280")

    manager.queue_free()
    await process_frame

    for case in CASES:
        if case.name == "canonical_720x1280":
            continue
        var viewport := SubViewport.new()
        viewport.size = case.size
        viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
        viewport.transparent_bg = false
        root.add_child(viewport)
        var responsive_manager := GameManager.new()
        viewport.add_child(responsive_manager)
        await process_frame
        await process_frame
        await process_frame
        _prepare_live_state(responsive_manager)
        await process_frame
        _check_hud_contract(responsive_manager, case.name)
        await _save_capture(viewport, case.name)
        responsive_manager.queue_free()
        viewport.queue_free()
        await process_frame

    _finish()


func _prepare_live_state(manager: GameManager) -> void:
    manager.score = 12650
    manager.best_score = 24380
    manager._target_level = 6
    manager._refresh_merge_target_visual()
    manager.set_next_level(2)
    manager._refresh_hud()

    # Varying, non-matching settled drinks make the production screenshots
    # representative without changing any gameplay rule or order state.
    var levels := [1, 2, 3, 4, 5]
    var positions := [
        Vector2(270.0, 600.0),
        Vector2(350.0, 680.0),
        Vector2(445.0, 610.0),
        Vector2(315.0, 790.0),
        Vector2(470.0, 790.0),
    ]
    for i in range(levels.size()):
        manager.spawn_drink(levels[i], positions[i], false)


func _check_hud_contract(manager: GameManager, label: String) -> void:
    var hud := manager.get_node_or_null("UI/HUD") as Control
    _check("%s has one HUD root" % label, hud != null)
    if hud == null:
        return

    var logo := hud.get_node_or_null("Logo") as Control
    var best := hud.get_node_or_null("BestScorePanel") as Control
    var score := hud.get_node_or_null("ScorePanel") as Control
    var to_go := hud.get_node_or_null("ToGoOrdersPanel") as Control
    var next := hud.get_node_or_null("NextPanel") as Control
    var strip := hud.get_node_or_null("ProgressionStrip") as Control
    print("M07_PANEL_SIZES label=%s logo=%s best=%s score=%s to_go=%s next=%s strip=%s" % [label, logo.size if logo != null else Vector2.INF, best.size if best != null else Vector2.INF, score.size if score != null else Vector2.INF, to_go.size if to_go != null else Vector2.INF, next.size if next != null else Vector2.INF, strip.size if strip != null else Vector2.INF])
    _check("%s canonical logo/panels exist" % label, _asset(logo, "logo_beach_cocktails_merge.png") and _asset(best, "panel_best_score.png") and _asset(score, "panel_score.png") and _asset(to_go, "panel_to_go_orders.png") and _asset(next, "panel_next.png") and _asset(strip, "progression_strip.png"))
    _check("%s score panels share normalized display size" % label, best != null and score != null and best.size.distance_to(score.size) < 0.01)
    _check("%s top-left logo then Best Score then Score hierarchy" % label, logo != null and best != null and score != null and logo.position.x < best.position.x + 1.0 and logo.position.y < best.position.y and best.position.y < score.position.y)
    _check("%s upper-center To-Go panel and upper-right Next panel do not overlap" % label, to_go != null and next != null and to_go.position.x + to_go.size.x <= next.position.x + 2.0)

    _check("%s live score values are dynamic" % label, manager._best_value != null and manager._score_value != null and manager._best_value.text == "24380" and manager._score_value.text == "12650")
    _check("%s exactly one active To-Go panel/target/reward" % label, _count_named(hud, "ToGoOrdersPanel") == 1 and manager._to_go_target_sprite != null and manager._to_go_target_sprite.texture == Drink.texture_for_level(6) and manager._to_go_level_label.text.begins_with("L6") and manager._to_go_reward_label.text == "+1000")
    _check("%s exactly one Next panel shows true next texture" % label, _count_named(hud, "NextPanel") == 1 and manager._next_sprite != null and manager._next_sprite.texture == Drink.texture_for_level(2))

    var progression_ok := manager._progression_icons.size() == 12
    for i in range(12):
        var icon := manager._progression_icons[i] if i < manager._progression_icons.size() else null
        progression_ok = progression_ok and icon != null and icon.texture == Drink.texture_for_level(i + 1) and icon.name == "ProgressionIconL%02d" % (i + 1)
    _check("%s progression is exactly L01-L12 with no L13" % label, progression_ok and hud.get_node_or_null("ProgressionIconL13") == null)

    var held := manager.shot_controller._current_drink if manager.shot_controller != null else null
    _check("%s held cocktail is above canonical launch zone" % label, is_instance_valid(held) and manager._launch_zone.texture.resource_path == "res://assets/ui/launch_zone.png" and manager._launch_zone.visible and manager._launch_zone.position.distance_to(held.position) < 0.01 and manager._launch_zone.z_index < held.z_index)
    _check("%s canonical danger PNG tracks accepted M06 threshold" % label, manager._danger_line.texture.resource_path == "res://assets/ui/danger_line.png" and is_equal_approx(manager._danger_line.position.y, manager.death_line_y))
    _check("%s no guide-line or permanent prototype hint" % label, manager.get_node_or_null("guide_line") == null and not _source_contains("Surukle: X konumu") and manager._chain_label == null)
    _check("%s no legacy duplicate labels" % label, hud.get_node_or_null("ScoreLabel") == null and hud.get_node_or_null("BestLabel") == null and hud.get_node_or_null("NextLabel") == null and hud.get_node_or_null("TargetCaption") == null)

    # Verify dynamic consumers change through production APIs, then restore the
    # representative state used by the capture.
    manager.score = 777
    manager.best_score = 888
    manager._refresh_hud()
    manager.set_next_level(3)
    manager._target_level = 7
    manager._refresh_merge_target_visual()
    var dynamic_ok := manager._score_value.text == "777" and manager._best_value.text == "888" and manager._next_sprite.texture == Drink.texture_for_level(3) and manager._to_go_target_sprite.texture == Drink.texture_for_level(7) and manager._to_go_reward_label.text == "+1800"
    _check("%s live score/To-Go/Next state updates without duplicate mapping" % label, dynamic_ok)
    manager.score = 12650
    manager.best_score = 24380
    manager._target_level = 6
    manager._refresh_merge_target_visual()
    manager.set_next_level(2)
    manager._refresh_hud()

    # Rapid launches must keep the held drink and the true next texture paired.
    for _i in range(3):
        manager.shot_controller._launch()
    var current := manager.shot_controller._current_drink
    _check("%s rapid launch keeps current held sprite and Next synchronized" % label, is_instance_valid(current) and current.motion_state == Drink.MotionState.HELD and manager._next_sprite.texture == Drink.texture_for_level(manager.shot_controller._next_level))
    print("M07_HUD_STATE label=%s score=%d best=%d target=L%d reward=%d next=L%d progression_slots=%d death_y=%.3f launch_y=%.3f" % [label, manager.score, manager.best_score, manager._target_level, Drink.order_reward(manager._target_level), manager.shot_controller._next_level, manager._progression_icons.size(), manager.death_line_y, manager.launch_y])


func _asset(node: Control, filename: String) -> bool:
    var artwork := node.get_node_or_null("Artwork") as Sprite2D if node != null else null
    return artwork != null and artwork.texture != null and artwork.texture.resource_path == ASSET_ROOT + filename


func _count_named(parent: Node, node_name: String) -> int:
    var count := 0
    for child in parent.get_children():
        if child.name == node_name:
            count += 1
    return count


func _source_contains(value: String) -> bool:
    var file := FileAccess.open("res://scripts/game_manager.gd", FileAccess.READ)
    return file != null and value in file.get_as_text()


func _save_capture(viewport: Viewport, label: String) -> void:
    var texture := viewport.get_texture()
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    if texture == null:
        _check("render capture saved for %s" % label, false)
        print("M07_CAPTURE name=%s unavailable=no_render_texture path=%s" % [label, path])
        return
    var image := texture.get_image()
    var err := image.save_png(path)
    print("M07_CAPTURE name=%s dimensions=%dx%d path=%s error=%s" % [label, image.get_width(), image.get_height(), path, err])
    _check("render capture saved for %s" % label, err == OK and FileAccess.file_exists(path))


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M07_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M07_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M07_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M07_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
