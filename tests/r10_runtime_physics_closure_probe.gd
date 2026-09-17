extends SceneTree

## R10 focused probe: normal rigid-body rear travel plus measured HUD bounds.
## This probe is never configured as the production main scene or autoload.

const CAPTURE_DIR := "res://docs/evidence/r10"
const CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720.0, 1280.0)},
    {"name": "taller_720x1440", "size": Vector2(720.0, 1440.0)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800.0, 1280.0)},
]
const MOTION_CASES := [
    {"label": "rear-center-L01", "level": 1, "vx": 0.0},
    {"label": "rear-center-L06", "level": 6, "vx": 0.0},
    {"label": "rear-center-L12", "level": 12, "vx": 0.0},
    {"label": "rear-left-L01", "level": 1, "vx": -70.0},
    {"label": "rear-right-L12", "level": 12, "vx": 70.0},
]

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("R10 production main scene loads", packed != null)
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
        _check_hud_alignment(manager, case.name)
        await _save_capture(viewport, case.name)

        if case.name == "canonical_720x1280":
            await _check_normal_rear_motion(manager)

        manager.queue_free()
        await process_frame
        if viewport != root:
            viewport.queue_free()
            await process_frame

    _finish()


func _check_hud_alignment(manager: GameManager, label: String) -> void:
    var score_rect := Rect2(manager._score_panel.position, manager._score_panel.size)
    var best_rect := Rect2(manager._best_panel.position, manager._best_panel.size)
    var logo_node := manager._hud.get_node("Logo") as Control
    var logo_rect := Rect2(logo_node.position, logo_node.size)
    var next_rect := Rect2(manager._next_panel.position, manager._next_panel.size)
    var score_bounds := manager._visible_artwork_bounds("res://assets/ui/panel_score.png", score_rect)
    var best_bounds := manager._visible_artwork_bounds("res://assets/ui/panel_best_score.png", best_rect)
    var logo_bounds := manager._visible_artwork_bounds("res://assets/ui/logo_beach_cocktails_merge.png", logo_rect)
    var next_bounds := manager._visible_artwork_bounds("res://assets/ui/panel_next.png", next_rect)
    var bottom_error := best_bounds.end.y - score_bounds.end.y
    var score_next_x_error := score_bounds.get_center().x - next_bounds.get_center().x
    var logo_best_x_error := logo_bounds.get_center().x - best_bounds.get_center().x
    _check("%s BEST/SCORE visible bottom alignment" % label, absf(bottom_error) <= 0.01)
    _check("%s SCORE/NEXT visible center-X alignment" % label, absf(score_next_x_error) <= 0.01)
    _check("%s logo/BEST visible center-X alignment" % label, absf(logo_best_x_error) <= 0.01)
    _check("%s logo is modestly larger than prior 190 px panel width" % label, logo_node.size.x > 190.0)
    _check("%s logo aspect ratio is preserved" % label, is_equal_approx(logo_node.size.x / logo_node.size.y, 1536.0 / 1024.0))
    _check("%s fixed score fonts remain 20 px" % label, manager._score_value.get_theme_font_size("font_size") == 20 and manager._best_value.get_theme_font_size("font_size") == 20)
    print("R10_HUD_BOUNDS label=%s best_bottom_y=%.4f score_bottom_y=%.4f bottom_error=%.4f score_center_x=%.4f next_center_x=%.4f score_next_x_error=%.4f logo_center_x=%.4f best_center_x=%.4f logo_best_x_error=%.4f logo_panel_width=%.4f" % [label, best_bounds.end.y, score_bounds.end.y, bottom_error, score_bounds.get_center().x, next_bounds.get_center().x, score_next_x_error, logo_bounds.get_center().x, best_bounds.get_center().x, logo_best_x_error, logo_node.size.x])


func _check_normal_rear_motion(manager: GameManager) -> void:
    var rear_y := manager.rear_table_y
    var rear_bounds := manager.get_table_rail_bounds_at_y(rear_y)
    print("R10_REAR_PHYSICAL_STATE rear_table_y=%.4f table_top_y=%.4f rear_bounds=(%.4f,%.4f)" % [rear_y, manager.table_top_y, rear_bounds.x, rear_bounds.y])
    _check("R10 TopRail begins from common measured rear span", absf(manager.get_node("World/TopRail").position.y + manager.wall_thickness * 0.5 + Drink.collider_radius_for_level(12) + GameManager.TOP_RAIL_CLEARANCE - rear_y) <= 0.01)

    for spec in MOTION_CASES:
        var level: int = spec.level
        var radius := Drink.collider_radius_for_level(level)
        var start_bounds := manager.get_horizontal_bounds_at_y(manager.table_bottom_y - radius - 2.0, radius)
        var start_x := (start_bounds.x + start_bounds.y) * 0.5
        if spec.label.contains("left"):
            start_x = start_bounds.x + 24.0
        elif spec.label.contains("right"):
            start_x = start_bounds.y - 24.0
        var drink := manager.spawn_drink(level, Vector2(start_x, manager.table_bottom_y - radius - 2.0), false)
        _check("%s spawned for normal motion" % spec.label, is_instance_valid(drink))
        if not is_instance_valid(drink):
            continue
        drink.start_sliding(Vector2(float(spec.vx), -700.0))
        for _i in range(150):
            await physics_frame
        var target_error := drink.position.y - rear_y
        var physically_settled := drink.motion_state == Drink.MotionState.SETTLED or drink.linear_velocity.length() <= drink.settle_speed * 1.35
        _check("%s reaches exact common rear target under normal physics" % spec.label, absf(target_error) <= 0.01 and physically_settled)
        print("R10_REAR_MOTION label=%s level=L%02d start_x=%.4f final=(%.4f,%.4f) rear_table_y=%.4f target_error=%.4f state=%s velocity=(%.4f,%.4f)" % [spec.label, level, start_x, drink.position.x, drink.position.y, rear_y, target_error, Drink.MotionState.keys()[drink.motion_state], drink.linear_velocity.x, drink.linear_velocity.y])
        drink.queue_free()
        await process_frame


func _save_capture(viewport: Viewport, label: String) -> void:
    var render_texture := viewport.get_texture()
    if render_texture == null:
        print("R10_CAPTURE label=%s unavailable=renderer_has_no_viewport_texture" % label)
        return
    var image := render_texture.get_image()
    if image == null:
        print("R10_CAPTURE label=%s unavailable=renderer_has_no_image" % label)
        return
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    var error := image.save_png(path)
    _check("%s runtime capture saved" % path, error == OK and FileAccess.file_exists(path))
    print("R10_CAPTURE label=%s dimensions=%dx%d path=%s error=%s" % [label, image.get_width(), image.get_height(), path, error])


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R10_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS")
        quit(0)
    else:
        print("R10_RUNTIME_PHYSICS_CLOSURE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
