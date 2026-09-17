extends SceneTree

## Deterministic M07-R05 probe. It validates the post-M06-R05 score-stack
## adaptation while checking that M07-R04 HUD consumers remain untouched.

const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]
const CAPTURE_DIR := "res://docs/evidence/m07_r05"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("M07-R05 main scene loads", packed != null)
    if packed == null:
        _finish()
        return
    var manager: GameManager = packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    await process_frame
    await _check_case(manager, "canonical_720x1280")
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
        await _check_case(responsive_manager, case.name)
        responsive_manager.queue_free()
        viewport.queue_free()
        await process_frame
    _finish()


func _check_case(manager: GameManager, label: String) -> void:
    var hud := manager.get_node_or_null("UI/HUD") as Control
    var logo := hud.get_node_or_null("Logo") as Control if hud != null else null
    var best := hud.get_node_or_null("BestScorePanel") as Control if hud != null else null
    var score := hud.get_node_or_null("ScorePanel") as Control if hud != null else null
    var to_go := hud.get_node_or_null("ToGoOrdersPanel") as Control if hud != null else null
    var next := hud.get_node_or_null("NextPanel") as Control if hud != null else null
    _check("%s HUD stack nodes exist" % label, hud != null and logo != null and best != null and score != null and to_go != null and next != null)
    if hud == null or logo == null or best == null or score == null or to_go == null or next == null:
        return

    var stack_up := best.position.y < 145.0 and score.position.y < 265.0
    var no_overlap := not _intersects(logo, best) and not _intersects(best, score) and not _intersects(score, to_go) and not _intersects(score, next) and not _intersects(best, to_go) and not _intersects(best, next)
    var open_table := score.position.y + score.size.y < manager.table_top_y - 4.0
    _check("%s BEST/SCORE moved upward" % label, stack_up)
    _check("%s logo -> BEST -> SCORE stack is fully visible and non-overlapping" % label, no_overlap and logo.position.y >= 0.0 and best.position.y >= 0.0 and score.position.y >= 0.0 and score.position.y + score.size.y <= hud.size.y)
    _check("%s upper tabletop remains open below HUD" % label, open_table)

    manager.best_score = 0
    manager.score = 0
    manager._refresh_hud()
    var score_rule := manager._best_value.get_theme_font_size("font_size") == GameManager.BEST_SCORE_FIXED_FONT_SIZE and manager._score_value.get_theme_font_size("font_size") == GameManager.SCORE_FIXED_FONT_SIZE and manager._best_value.text == "0" and manager._score_value.text == "0"
    manager.best_score = 9999999
    manager.score = 9999999
    manager._refresh_hud()
    score_rule = score_rule and manager._best_value.text == "9999999" and manager._score_value.text == "9999999"
    _check("%s preserves fixed seven-digit score behavior" % label, score_rule)

    var target_text_free := manager.get_node_or_null("UI/HUD/ToGoOrdersPanel/ToGoLevelLabel") == null and manager.get_node_or_null("UI/HUD/ToGoOrdersPanel/Label") == null
    var reward_digits := manager._to_go_reward_label.text == "1000" and not manager._to_go_reward_label.text.begins_with("+")
    var to_go_artwork := to_go.get_node_or_null("Artwork") as Sprite2D
    var to_go_top := _sprite_visible_top(to_go, to_go_artwork)
    var no_runtime_rope := hud.get_node_or_null("ToGoRopeLeft") == null and hud.get_node_or_null("ToGoRopeRight") == null
    _check("%s preserves target+reward-only To-Go and unchanged asset at viewport top" % label, target_text_free and reward_digits and to_go_artwork != null and no_runtime_rope and absf(to_go_top) <= 0.5)

    manager.set_next_level(12)
    var next_ok := manager._next_sprite.texture == Drink.texture_for_level(12)
    var progression_ok := manager._progression_icons.size() == 12 and hud.get_node_or_null("ProgressionIconL13") == null
    _check("%s preserves true NEXT and baked 2x6 progression" % label, next_ok and progression_ok)
    var geometry_ok := absf(manager.get_horizontal_bounds_at_y(manager.table_bottom_y * 0.75, 42.0).x - (manager.get_table_rail_bounds_at_y(manager.table_bottom_y * 0.75).x + 42.0 + GameManager.TABLE_SOLVER_EPSILON)) < 0.01
    _check("%s M06-R05 full tabletop bounds remain HUD-independent" % label, geometry_ok and manager.get_node_or_null("guide_line") == null)
    print("M07_R05_STATE label=%s viewport=%s logo=%s best=%s score=%s to_go=%s next=%s table_top_y=%.3f" % [label, manager.get_board_size(), logo.position, best.position, score.position, to_go.position, next.position, manager.table_top_y])
    await _save_capture(manager.get_viewport(), label)


func _save_capture(viewport: Viewport, label: String) -> void:
    var image := viewport.get_texture().get_image()
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    var err := image.save_png(path)
    _check("clean M07-R05 capture saved for %s" % label, err == OK and FileAccess.file_exists(path))
    print("M07_R05_CAPTURE label=%s path=%s dimensions=%dx%d error=%s" % [label, path, image.get_width(), image.get_height(), err])


func _intersects(a: Control, b: Control) -> bool:
    return Rect2(a.position, a.size).intersects(Rect2(b.position, b.size))


func _sprite_visible_top(panel: Control, sprite: Sprite2D) -> float:
    if panel == null or sprite == null or sprite.texture == null:
        return INF
    var used := sprite.texture.get_image().get_used_rect()
    var texture_size := Vector2(sprite.texture.get_width(), sprite.texture.get_height())
    return panel.position.y + sprite.position.y + (float(used.position.y) - texture_size.y * 0.5) * sprite.scale.y


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M07_R05_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M07_R05_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M07_R05_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M07_R05_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
