extends SceneTree

## Deterministic M07-R06 owner-layout probe. It measures rendered value bounds,
## checks the revised panel composition and validates held glass-body X/Y.

const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const CAPTURE_DIR := "res://docs/evidence/m07_r06"
const VALUE_BOX := Rect2(45.0, 55.0, 116.0, 52.0)
const TO_GO_TARGET_BOX := Rect2(30.0, 78.0, 150.0, 100.0)
const TO_GO_REWARD_BOX := Rect2(35.0, 185.0, 140.0, 35.0)
const NEXT_SAFE_BOX := Rect2(28.0, 62.0, 90.0, 100.0)

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("M07-R06 main scene loads", packed != null)
    if packed == null:
        _finish()
        return
    for case in CASES:
        var viewport: Viewport = root
        var manager: GameManager
        if case.name == "canonical_720x1280":
            manager = packed.instantiate() as GameManager
            root.add_child(manager)
        else:
            var sub := SubViewport.new()
            sub.size = case.size
            sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
            sub.transparent_bg = false
            root.add_child(sub)
            viewport = sub
            manager = GameManager.new()
            sub.add_child(manager)
        await process_frame
        await process_frame
        await process_frame
        _prepare(manager)
        _check_layout(manager, case.name)
        await _check_held_body_alignment(manager, case.name)
        await _save_capture(viewport, case.name)
        manager.queue_free()
        await process_frame
        if viewport != root:
            viewport.queue_free()
            await process_frame
    _finish()


func _prepare(manager: GameManager) -> void:
    manager.score = 12650
    manager.best_score = 24380
    manager._target_level = 6
    manager._refresh_merge_target_visual()
    manager.set_next_level(2)
    manager._refresh_hud()


func _check_layout(manager: GameManager, label: String) -> void:
    var hud := manager.get_node_or_null("UI/HUD") as Control
    var logo := hud.get_node_or_null("Logo") as Control if hud != null else null
    var best := hud.get_node_or_null("BestScorePanel") as Control if hud != null else null
    var score := hud.get_node_or_null("ScorePanel") as Control if hud != null else null
    var to_go := hud.get_node_or_null("ToGoOrdersPanel") as Control if hud != null else null
    var next := hud.get_node_or_null("NextPanel") as Control if hud != null else null
    _check("%s HUD panels exist" % label, hud != null and logo != null and best != null and score != null and to_go != null and next != null)
    if hud == null or best == null or score == null or to_go == null or next == null:
        return

    var score_right := score.position.x > hud.size.x * 0.65
    var score_below_next := score.position.y >= next.position.y + next.size.y
    var separated := not _intersects(score, next) and not _intersects(score, to_go) and not _intersects(best, to_go)
    _check("%s BEST remains left and SCORE is right below NEXT" % label, best.position.x < hud.size.x * 0.5 and score_right and score_below_next and separated)
    _check("%s score panel remains above tabletop and on-screen" % label, score.position.y + score.size.y < manager.table_top_y - 4.0 and _on_screen(score, hud.size))

    var score_values_ok := true
    for value in [0, 321, 24380, 999999, 9999999]:
        manager.score = value
        manager.best_score = value
        manager._refresh_hud()
        var best_bounds := _label_visible_rect(manager._best_value)
        var score_bounds := _label_visible_rect(manager._score_value)
        var best_center_delta := best_bounds.get_center().distance_to(VALUE_BOX.get_center())
        var score_center_delta := score_bounds.get_center().distance_to(VALUE_BOX.get_center())
        score_values_ok = score_values_ok and manager._best_value.text == "%d" % value and manager._score_value.text == "%d" % value and manager._best_value.get_theme_font_size("font_size") == GameManager.BEST_SCORE_FIXED_FONT_SIZE and manager._score_value.get_theme_font_size("font_size") == GameManager.SCORE_FIXED_FONT_SIZE and _inside(best_bounds, VALUE_BOX, 4.0) and _inside(score_bounds, VALUE_BOX, 4.0) and best_center_delta <= 1.5 and score_center_delta <= 1.5
        print("M07_R06_SCORE label=%s value=%d best_bounds=%s score_bounds=%s best_center_delta=%.3f score_center_delta=%.3f" % [label, value, _rect_string(best_bounds), _rect_string(score_bounds), best_center_delta, score_center_delta])
    _check("%s fixed-size score glyphs center inside both recessed windows" % label, score_values_ok and manager._score_display_text(10000000) == "9999999")

    manager.score = 12650
    manager.best_score = 24380
    manager._refresh_hud()
    for level in range(6, 13):
        manager._target_level = level
        manager._refresh_merge_target_visual()
        var target_bounds := _sprite_visible_rect(manager._to_go_target_sprite)
        var reward_bounds := _label_visible_rect(manager._to_go_reward_label)
        var reward_ok := manager._to_go_reward_label.text == "%d" % Drink.order_reward(level) and not manager._to_go_reward_label.text.begins_with("+") and _inside(target_bounds, TO_GO_TARGET_BOX, 4.0) and _inside(reward_bounds, TO_GO_REWARD_BOX, 4.0) and not target_bounds.intersects(reward_bounds)
        _check("%s To-Go L%d target+reward fit inside cream board" % [label, level], reward_ok)
        print("M07_R06_TO_GO label=%s level=L%d target=%s reward=%s reward_bounds=%s" % [label, level, _rect_string(target_bounds), manager._to_go_reward_label.text, _rect_string(reward_bounds)])
    _check("%s To-Go ropes remain attached to viewport top" % label, manager._to_go_rope_left != null and manager._to_go_rope_right != null and is_equal_approx(manager._to_go_rope_left.points[0].y, 0.0) and is_equal_approx(manager._to_go_rope_right.points[0].y, 0.0) and manager._to_go_rope_left.z_index < 0 and manager._to_go_rope_right.z_index < 0)

    var next_ok := true
    for level in range(1, 13):
        manager.set_next_level(level)
        var bounds := _sprite_visible_rect(manager._next_sprite)
        next_ok = next_ok and manager._next_sprite.texture == Drink.texture_for_level(level) and _inside(bounds, NEXT_SAFE_BOX, 4.0)
    _check("%s NEXT L01-L12 remains contained" % label, next_ok)
    var progression_ok := manager._progression_icons.size() == 12 and hud.get_node_or_null("ProgressionIconL13") == null
    for child in manager._progression_strip.get_children():
        progression_ok = progression_ok and not (child is Panel)
    _check("%s baked 2x6 progression remains frame-free" % label, progression_ok)
    _check("%s M06 danger/launch coordinates and no guide line remain" % label, is_equal_approx(manager.death_line_y, GameManager.source_to_viewport(Vector2(0.0, 1080.0), manager.get_board_size()).y) and is_equal_approx(manager.launch_y, GameManager.source_to_viewport(Vector2(0.0, 1136.0), manager.get_board_size()).y) and manager.get_node_or_null("guide_line") == null)


func _check_held_body_alignment(manager: GameManager, label: String) -> void:
    var x_error := 0.0
    var y_error := 0.0
    var halo_x := manager.get_board_size().x * 0.5
    var target_y := manager.launch_y + Drink.HELD_BODY_BASELINE_OFFSET_PX
    for level in range(1, 13):
        var drink := manager.spawn_drink(level, Vector2(halo_x, manager.launch_y), true)
        await process_frame
        var sprite := drink.get_node("Visual/CocktailSprite") as Sprite2D
        var visual := drink.get_node("Visual") as Node2D
        var center_x: float = drink.position.x + visual.scale.x * (sprite.position.x + Drink.VISIBLE_BODY_CENTER_OFFSET_PX[level - 1].x * sprite.scale.x)
        var body_bottom: float = drink.position.y + visual.scale.y * (sprite.position.y + float(Drink.HELD_BODY_FOOT_SOURCE_PX[level - 1]) * sprite.scale.x)
        x_error = maxf(x_error, absf(center_x - halo_x))
        y_error = maxf(y_error, absf(body_bottom - target_y))
        print("M07_R06_HELD label=%s level=L%d body_center_x=%.3f halo_x=%.3f x_delta=%.3f body_bottom_y=%.3f target_y=%.3f y_delta=%.3f" % [label, level, center_x, halo_x, center_x - halo_x, body_bottom, target_y, body_bottom - target_y])
        drink.queue_free()
    _check("%s held glass bodies center on halo X and share launch baseline Y" % label, x_error <= 0.5 and y_error <= 0.5)
    print("M07_R06_HELD_SUMMARY label=%s max_x_delta=%.3f max_y_delta=%.3f" % [label, x_error, y_error])


func _save_capture(viewport: Viewport, label: String) -> void:
    var image := viewport.get_texture().get_image()
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    var error := image.save_png(path)
    _check("%s screenshot saved" % label, error == OK and FileAccess.file_exists(path))
    print("M07_R06_CAPTURE label=%s dimensions=%dx%d path=%s error=%s" % [label, image.get_width(), image.get_height(), path, error])


func _label_visible_rect(label: Label) -> Rect2:
    var font := label.get_theme_font("font")
    var measured := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label.get_theme_font_size("font_size"))
    var shadow := Vector2(float(label.get_theme_constant("shadow_offset_x")), float(label.get_theme_constant("shadow_offset_y")))
    var left := minf(label.position.x, label.position.x + shadow.x)
    var top := minf(label.position.y, label.position.y + shadow.y)
    var right := maxf(label.position.x + measured.x, label.position.x + measured.x + shadow.x)
    var bottom := maxf(label.position.y + measured.y, label.position.y + measured.y + shadow.y)
    return Rect2(left, top, right - left, bottom - top)


func _sprite_visible_rect(sprite: Sprite2D) -> Rect2:
    var used := sprite.texture.get_image().get_used_rect()
    var texture_size := Vector2(sprite.texture.get_width(), sprite.texture.get_height())
    return Rect2(sprite.position + (Vector2(used.position) - texture_size * 0.5) * sprite.scale, Vector2(used.size) * sprite.scale)


func _inside(actual: Rect2, expected: Rect2, tolerance: float) -> bool:
    return actual.position.x >= expected.position.x - tolerance and actual.position.y >= expected.position.y - tolerance and actual.end.x <= expected.end.x + tolerance and actual.end.y <= expected.end.y + tolerance


func _intersects(a: Control, b: Control) -> bool:
    return Rect2(a.position, a.size).intersects(Rect2(b.position, b.size))


func _on_screen(node: Control, viewport_size: Vector2) -> bool:
    return node.position.x >= -0.01 and node.position.y >= -0.01 and node.position.x + node.size.x <= viewport_size.x + 0.01 and node.position.y + node.size.y <= viewport_size.y + 0.01


func _rect_string(rect: Rect2) -> String:
    return "[%.2f,%.2f,%.2f,%.2f]" % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M07_R06_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M07_R06_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M07_R06_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M07_R06_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
