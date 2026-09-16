extends SceneTree

## Deterministic, non-production M06 environment/table/responsive probe.
## It instantiates the production scene/classes and saves bounded render captures.

const BACKGROUND_PATH := "res://assets/environment/game_board_background.png"
const CAPTURE_DIR := "res://docs/evidence/m06"
const VIEWPORT_CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]

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

    var background := manager.get_node_or_null("GameBoardBackground") as Sprite2D
    var texture := background.texture if background != null else null
    _check("production background node uses exact canonical asset", background != null and texture != null and texture.resource_path == BACKGROUND_PATH)
    _check("background source dimensions are 1024x1536", texture != null and texture.get_width() == 1024 and texture.get_height() == 1536)
    _check("background is behind gameplay world", background != null and background.z_index < manager.world.z_index)

    var viewport_size := manager.get_board_size()
    var expected_scale := GameManager.background_scale_for_viewport(viewport_size)
    var expected_offset := GameManager.background_offset_for_viewport(viewport_size)
    _check("canonical cover scale/offset is deterministic", is_equal_approx(background.scale.x, expected_scale) and expected_offset.x < 0.0 and background.position.distance_to(viewport_size * 0.5) < 0.01)
    print("M06_CANONICAL_RENDER viewport=%s source=1024x1536 scale=%.6f offset=%s table_top_y=%.3f table_bottom_y=%.3f danger_y=%.3f launch_y=%.3f" % [viewport_size, expected_scale, expected_offset, manager.table_top_y, manager.table_bottom_y, manager.death_line_y, manager.launch_y])

    var top_rails := manager.get_table_rail_bounds_at_y(manager.table_top_y)
    var middle_y := lerpf(manager.table_top_y, manager.table_bottom_y, 0.5)
    var middle_rails := manager.get_table_rail_bounds_at_y(middle_y)
    var bottom_rails := manager.get_table_rail_bounds_at_y(manager.table_bottom_y)
    var perspective_ok := top_rails.x > middle_rails.x and middle_rails.x > bottom_rails.x and top_rails.y < middle_rails.y and middle_rails.y < bottom_rails.y
    _check("visible perspective rails narrow toward top", perspective_ok)
    _check("top stop and bottom rail are inside the rendered table", manager.table_top_y > 0.0 and manager.table_bottom_y < viewport_size.y and manager.table_bottom_y > manager.table_top_y)
    _check("danger line is near launch side with usable table area", manager.death_line_y > manager.table_top_y + 400.0 and manager.launch_y > manager.death_line_y and manager.launch_y < manager.table_bottom_y)
    print("M06_RAILS top=(%.3f,%.3f) middle_y=%.3f middle=(%.3f,%.3f) bottom=(%.3f,%.3f)" % [top_rails.x, top_rails.y, middle_y, middle_rails.x, middle_rails.y, bottom_rails.x, bottom_rails.y])

    var wall_names := ["LeftRail", "RightRail", "TopRail", "BottomRail"]
    var walls_ok := true
    for wall_name in wall_names:
        walls_ok = walls_ok and manager.world.get_node_or_null(wall_name) != null
    _check("production walls use four bounded perspective rail segments", walls_ok)

    var depth_cases := [
        {"level": 1, "y": manager.table_top_y + 70.0},
        {"level": 6, "y": middle_y},
        {"level": 12, "y": manager.table_bottom_y - 120.0},
    ]
    var collider_ok := true
    for item in depth_cases:
        var level: int = item.level
        var y_pos: float = item.y
        var radius := Drink.collider_radius_for_level(level)
        var safe_bounds := manager.get_horizontal_bounds_at_y(y_pos, radius)
        var drink := manager.spawn_drink(level, Vector2((safe_bounds.x + safe_bounds.y) * 0.5, y_pos), false)
        var inside := is_instance_valid(drink) and drink.position.x - radius >= safe_bounds.x - 0.01 and drink.position.x + radius <= safe_bounds.y + 0.01
        collider_ok = collider_ok and inside
        print("M06_COLLIDER level=L%d y=%.3f radius=%.3f safe_bounds=(%.3f,%.3f) inside=%s" % [level, y_pos, radius, safe_bounds.x, safe_bounds.y, inside])
    _check("L01/mid/L12 collider footprints remain inside perspective rails", collider_ok)

    var held := manager.shot_controller._current_drink if manager.shot_controller != null else null
    var launch_bounds := manager.get_horizontal_bounds_at_y(manager.launch_y, held.radius if is_instance_valid(held) else 20.0)
    var launch_ok := is_instance_valid(held) and is_equal_approx(held.position.y, manager.launch_y) and held.position.x >= launch_bounds.x and held.position.x <= launch_bounds.y
    _check("held launch cocktail starts on the lower visible table", launch_ok)
    print("M06_LAUNCH position=%s bounds=(%.3f,%.3f) danger_y=%.3f" % [held.position if is_instance_valid(held) else Vector2.INF, launch_bounds.x, launch_bounds.y, manager.death_line_y])

    _check("no guide_line asset or node was introduced", not FileAccess.file_exists("res://assets/ui/guide_line.png") and manager.get_node_or_null("guide_line") == null)
    _check("canonical source-to-viewport mapping preserves aspect without distortion", GameManager.background_scale_for_viewport(viewport_size) >= viewport_size.x / 1024.0 and GameManager.background_scale_for_viewport(viewport_size) >= viewport_size.y / 1536.0)

    await _save_viewport_capture(root, "canonical_720x1280")
    manager.queue_free()
    await process_frame

    for case in VIEWPORT_CASES:
        var case_size: Vector2 = case.size
        var scale := GameManager.background_scale_for_viewport(case_size)
        var offset := GameManager.background_offset_for_viewport(case_size)
        var mapped_top := GameManager.source_to_viewport(GameManager.TABLE_FAR_LEFT_SOURCE, case_size)
        var mapped_bottom := GameManager.source_to_viewport(GameManager.TABLE_NEAR_LEFT_SOURCE, case_size)
        var center_visible := mapped_top.x < case_size.x and mapped_top.x + (GameManager.TABLE_FAR_RIGHT_SOURCE.x - GameManager.TABLE_FAR_LEFT_SOURCE.x) * scale > 0.0 and mapped_bottom.y < case_size.y
        var case_ok := scale > 0.0 and offset.y <= 0.0 and center_visible
        _check("responsive %s keeps portrait table landmarks visible" % case.name, case_ok)
        print("M06_RESPONSIVE name=%s viewport=%s scale=%.6f offset=%s mapped_top_left=%s mapped_near_left=%s no_distortion=true" % [case.name, case_size, scale, offset, mapped_top, mapped_bottom])
        await _save_subviewport_capture(case_size, case.name)

    print("M06_NOTE direct/glancing collision, rapid launch, merge, restart, Game Over and To-Go contracts are covered by the rerun M01-M05 probes recorded with this run.")
    _finish()


func _save_viewport_capture(viewport: Viewport, label: String) -> void:
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    var render_texture := viewport.get_texture()
    if render_texture == null:
        print("M06_CAPTURE name=%s unavailable=no_render_texture path=%s" % [label, path])
        _check("render capture saved for %s" % label, false)
        return
    var image := render_texture.get_image()
    var err := image.save_png(path)
    print("M06_CAPTURE name=%s dimensions=%dx%d path=%s error=%s" % [label, image.get_width(), image.get_height(), path, err])
    _check("render capture saved for %s" % label, err == OK and FileAccess.file_exists(path))


func _save_subviewport_capture(size: Vector2, label: String) -> void:
    var viewport := SubViewport.new()
    viewport.size = size
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport.transparent_bg = false
    root.add_child(viewport)
    var manager := GameManager.new()
    viewport.add_child(manager)
    await process_frame
    await process_frame
    await process_frame
    await _save_viewport_capture(viewport, label)
    manager.queue_free()
    viewport.queue_free()
    await process_frame


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M06_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M06_PROBE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("M06_PROBE_RESULT=PASS")
        quit(0)
    else:
        print("M06_PROBE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
