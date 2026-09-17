extends SceneTree

## Deterministic focused M07-R04 probe. It verifies fixed score typography,
## target/reward-only To-Go content, ceiling ropes, NEXT containment and held
## visible-body foot alignment without changing gameplay state or PNG bytes.

const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const CAPTURE_DIR := "res://docs/evidence/m07_r04"
const LAYOUT_PATH := "res://docs/evidence/m07/independent_inner_content_layout_v02.json"
const BEST_VALUE_BOX := Rect2(45.0, 55.0, 116.0, 52.0)
const SCORE_VALUE_BOX := Rect2(45.0, 55.0, 116.0, 52.0)
const TO_GO_TARGET_BOX := Rect2(30.0, 78.0, 150.0, 100.0)
const TO_GO_REWARD_BOX := Rect2(35.0, 215.0, 140.0, 35.0)
const NEXT_SAFE_BOX := Rect2(28.0, 62.0, 90.0, 100.0)

var failures: Array[String] = []
var layout: Dictionary = {}


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    layout = _load_json(LAYOUT_PATH)
    _check("M07-R04 independent layout dataset loads", not layout.is_empty())
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("M07-R04 main scene loads", packed != null)
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
        _check_fixed_scores(manager, case.name)
        _check_to_go(manager, case.name)
        _check_ropes(manager, case.name)
        _check_next_all_levels(manager, case.name)
        await _check_held_body_anchor(manager, case.name)
        _check("%s preserves M06 danger/launch coordinates" % case.name, is_equal_approx(manager.death_line_y, GameManager.source_to_viewport(Vector2(0.0, 1080.0), manager.get_board_size()).y) and is_equal_approx(manager.launch_y, GameManager.source_to_viewport(Vector2(0.0, 1136.0), manager.get_board_size()).y))
        await _save_capture(viewport, manager, case.name)
        manager.queue_free()
        await process_frame
        if viewport != root:
            viewport.queue_free()
            await process_frame
    _finish()


func _prepare(manager: GameManager) -> void:
    manager.score = 24380
    manager.best_score = 24380
    manager._target_level = 6
    manager._refresh_merge_target_visual()
    manager.set_next_level(2)
    manager._refresh_hud()


func _check_fixed_scores(manager: GameManager, label: String) -> void:
    var values := [0, 321, 24380, 999999, 9999999]
    var best_sizes: Array[int] = []
    var score_sizes: Array[int] = []
    var fit_ok := true
    for value in values:
        manager.score = value
        manager.best_score = value
        manager._refresh_hud()
        best_sizes.append(manager._best_value.get_theme_font_size("font_size"))
        score_sizes.append(manager._score_value.get_theme_font_size("font_size"))
        fit_ok = fit_ok and manager._best_value.text == "%d" % value and manager._score_value.text == "%d" % value and _inside(_label_rect(manager._best_value), BEST_VALUE_BOX, 4.0) and _inside(_label_rect(manager._score_value), SCORE_VALUE_BOX, 4.0)
        print("M07_R04_FIXED_SCORE label=%s value=%d best_bounds=%s score_bounds=%s best_font=%d score_font=%d" % [label, value, _rect_string(_label_rect(manager._best_value)), _rect_string(_label_rect(manager._score_value)), best_sizes.back(), score_sizes.back()])
    var fixed_ok := _all_same(best_sizes) and _all_same(score_sizes) and best_sizes[0] == GameManager.BEST_SCORE_FIXED_FONT_SIZE and score_sizes[0] == GameManager.SCORE_FIXED_FONT_SIZE
    _check("%s fixed score font fits 0/321/24380/999999/9999999" % label, fit_ok and fixed_ok)
    _check("%s score display enforces seven-digit maximum" % label, GameManager.SCORE_DISPLAY_MAX_DIGITS == 7 and manager._score_display_text(10000000) == "9999999")


func _check_to_go(manager: GameManager, label: String) -> void:
    var ok := manager.get_node_or_null("UI/HUD/ToGoOrdersPanel") != null and manager.get_node_or_null("UI/HUD/ToGoOrdersPanel/ToGoRopeLeft") == null
    var panel := manager._to_go_panel
    var no_level_name_node := manager.get_node_or_null("UI/HUD/ToGoOrdersPanel/Label") == null and manager.get_node_or_null("UI/HUD/ToGoOrdersPanel/ToGoLevelLabel") == null
    for level in range(6, 13):
        manager._target_level = level
        manager._refresh_merge_target_visual()
        var target_bounds := _sprite_visible_rect(manager._to_go_target_sprite)
        var reward_bounds := _label_rect(manager._to_go_reward_label)
        var reward_text := "%d" % Drink.order_reward(level)
        var fits := manager._to_go_reward_label.text == reward_text and not manager._to_go_reward_label.text.begins_with("+") and _inside(target_bounds, TO_GO_TARGET_BOX, 4.0) and _inside(reward_bounds, TO_GO_REWARD_BOX, 4.0) and not target_bounds.intersects(reward_bounds)
        ok = ok and fits
        print("M07_R04_TO_GO label=%s target=L%d reward=%s target_bounds=%s reward_bounds=%s fits=%s" % [label, level, manager._to_go_reward_label.text, _rect_string(target_bounds), _rect_string(reward_bounds), fits])
    _check("%s To-Go contains target and digits-only reward for L06-L12" % label, ok and no_level_name_node and panel != null)


func _check_ropes(manager: GameManager, label: String) -> void:
    var left := manager._to_go_rope_left
    var right := manager._to_go_rope_right
    var panel := manager._to_go_panel
    var expected_left := panel.position.x + panel.size.x * 0.226
    var expected_right := panel.position.x + panel.size.x * 0.778
    var ok := left != null and right != null and left.points.size() == 2 and right.points.size() == 2 and is_equal_approx(left.points[0].y, 0.0) and is_equal_approx(right.points[0].y, 0.0) and is_equal_approx(left.points[1].y, panel.position.y + 1.0) and is_equal_approx(right.points[1].y, panel.position.y + 1.0) and is_equal_approx(left.points[0].x, expected_left) and is_equal_approx(right.points[0].x, expected_right) and left.z_index < 0 and right.z_index < 0
    _check("%s To-Go ropes attach viewport top to baked anchors" % label, ok)
    print("M07_R04_ROPES label=%s left_x=%.3f right_x=%.3f top_y=%.3f baked_join_y=(%.3f,%.3f)" % [label, left.points[0].x if left != null else -1.0, right.points[0].x if right != null else -1.0, left.points[0].y if left != null else -1.0, left.points[1].y if left != null else -1.0, right.points[1].y if right != null else -1.0])


func _check_next_all_levels(manager: GameManager, label: String) -> void:
    var ok := manager._next_panel != null and _count_named(manager.get_node("UI/HUD"), "NextPanel") == 1
    for level in range(1, 13):
        manager.set_next_level(level)
        var bounds := _sprite_visible_rect(manager._next_sprite)
        var fits := manager._next_sprite.texture == Drink.texture_for_level(level) and _inside(bounds, NEXT_SAFE_BOX, 4.0)
        ok = ok and fits
        print("M07_R04_NEXT label=%s level=L%d bounds=%s fits=%s" % [label, level, _rect_string(bounds), fits])
    _check("%s NEXT L01-L12 alpha bounds fit measured cream window" % label, ok)


func _check_held_body_anchor(manager: GameManager, label: String) -> void:
    var baselines: Array[float] = []
    for level in range(1, 13):
        var drink := manager.spawn_drink(level, Vector2(manager.get_board_size().x * 0.5, manager.launch_y), true)
        await process_frame
        var sprite := drink.get_node("Visual/CocktailSprite") as Sprite2D
        var visual := drink.get_node("Visual") as Node2D
        var baseline: float = float(drink.position.y + visual.scale.y * (sprite.position.y + float(Drink.HELD_BODY_FOOT_SOURCE_PX[level - 1]) * sprite.scale.x))
        baselines.append(baseline)
        print("M07_R04_HELD label=%s level=L%d pos_y=%.3f root_scale=%.4f sprite_scale=%.5f baseline=%.3f offset=%.3f" % [label, level, drink.position.y, visual.scale.y, sprite.scale.x, baseline, sprite.position.y - Drink.visual_offset_for_level(level).y])
        drink.queue_free()
    var min_baseline: float = baselines.min()
    var max_baseline: float = baselines.max()
    _check("%s held L01-L12 body bottoms share launch baseline" % label, max_baseline - min_baseline <= 2.0 and absf(min_baseline - (manager.launch_y + Drink.HELD_BODY_BASELINE_OFFSET_PX)) <= 2.0)
    print("M07_R04_HELD_SUMMARY label=%s baseline_min=%.3f baseline_max=%.3f spread=%.3f target=%.3f" % [label, min_baseline, max_baseline, max_baseline - min_baseline, manager.launch_y + Drink.HELD_BODY_BASELINE_OFFSET_PX])


func _save_capture(viewport: Viewport, manager: GameManager, label: String) -> void:
    var image := viewport.get_texture().get_image()
    var clean_path := "%s/%s.png" % [CAPTURE_DIR, label]
    image.save_png(clean_path)
    var overlay := Node2D.new()
    overlay.set_script(load("res://tests/m07_hud_visible_bounds.gd"))
    overlay.set("manager", manager)
    overlay.set("layout", layout)
    overlay.set("title", "M07-R04 visible content and rope evidence — %s" % label)
    manager.add_child(overlay)
    await process_frame
    await process_frame
    var overlay_image := viewport.get_texture().get_image()
    overlay_image.save_png("%s/%s_visible_bounds.png" % [CAPTURE_DIR, label])
    overlay.queue_free()
    await process_frame
    print("M07_R04_CAPTURE label=%s clean=%s visible_bounds=%s dimensions=%dx%d" % [label, clean_path, "%s/%s_visible_bounds.png" % [CAPTURE_DIR, label], image.get_width(), image.get_height()])


func _label_rect(label: Label) -> Rect2:
    var font := label.get_theme_font("font")
    var measured := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label.get_theme_font_size("font_size"))
    var origin := label.position + Vector2((label.size.x - measured.x) * 0.5, (label.size.y - measured.y) * 0.5)
    return Rect2(origin + Vector2(minf(0.0, label.get_theme_constant("shadow_offset_x")), minf(0.0, label.get_theme_constant("shadow_offset_y"))), measured + Vector2(absf(label.get_theme_constant("shadow_offset_x")), absf(label.get_theme_constant("shadow_offset_y"))))


func _sprite_visible_rect(sprite: Sprite2D) -> Rect2:
    var image := sprite.texture.get_image()
    var used := image.get_used_rect()
    var texture_size := Vector2(sprite.texture.get_width(), sprite.texture.get_height())
    return Rect2(sprite.position + (Vector2(used.position) - texture_size * 0.5) * sprite.scale, Vector2(used.size) * sprite.scale)


func _inside(actual: Rect2, expected: Rect2, tolerance: float) -> bool:
    return actual.position.x >= expected.position.x - tolerance and actual.position.y >= expected.position.y - tolerance and actual.end.x <= expected.end.x + tolerance and actual.end.y <= expected.end.y + tolerance


func _all_same(values: Array[int]) -> bool:
    if values.is_empty():
        return false
    for value in values:
        if value != values[0]:
            return false
    return true


func _count_named(parent: Node, node_name: String) -> int:
    var count := 0
    for child in parent.get_children():
        if child.name == node_name:
            count += 1
    return count


func _rect_string(rect: Rect2) -> String:
    return "[%.2f,%.2f,%.2f,%.2f]" % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]


func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var value = JSON.parse_string(file.get_as_text())
    return value if value is Dictionary else {}


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M07_R04_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M07_R04_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M07_R04_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M07_R04_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
