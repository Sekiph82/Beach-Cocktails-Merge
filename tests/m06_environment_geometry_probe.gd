extends SceneTree

## Deterministic, non-production M06 environment/table/responsive probe.
## It instantiates the production scene/classes and saves bounded render captures.

const BACKGROUND_PATH := "res://assets/environment/game_board_background.png"
const CAPTURE_DIR := "res://docs/evidence/m06"
const EXPECTED_LANDMARKS_PATH := "res://docs/evidence/m06/expected_landmarks.json"
const RENDER_LANDMARKS_PATH := "res://docs/evidence/m06/render_space_landmarks.json"
const OVERLAY_SCRIPT := "res://tests/m06_geometry_overlay.gd"
const VIEWPORT_CASES := [
    {"name": "canonical_720x1280", "size": Vector2(720, 1280)},
    {"name": "taller_720x1440", "size": Vector2(720, 1440)},
    {"name": "shorter_wider_800x1280", "size": Vector2(800, 1280)},
]

var failures: Array[String] = []
var expected_landmarks: Dictionary = {}
var render_landmarks: Dictionary = {}


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var expected_variant: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXPECTED_LANDMARKS_PATH))
    _check("independent expected landmark dataset loads", expected_variant is Dictionary)
    if expected_variant is Dictionary:
        expected_landmarks = expected_variant
    var render_variant: Variant = JSON.parse_string(FileAccess.get_file_as_string(RENDER_LANDMARKS_PATH))
    _check("independent screenshot-space landmark dataset loads", render_variant is Dictionary)
    if render_variant is Dictionary:
        render_landmarks = render_variant
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

    _check_reference_geometry(manager, "canonical_720x1280")
    var depth_cases := [
        {"level": 1, "t": 0.14},
        {"level": 6, "t": 0.50},
        {"level": 12, "t": 0.84},
    ]
    var collider_ok := true
    for item in depth_cases:
        var level: int = item.level
        var y_pos := lerpf(manager.table_top_y, manager.table_bottom_y, item.t)
        var radius := Drink.collider_radius_for_level(level)
        var expected_bounds := _expected_rail_bounds("canonical_720x1280", item.t)
        var margin := manager.wall_thickness * 0.5 + radius + 3.0
        var center_x := (expected_bounds.x + expected_bounds.y) * 0.5
        var drink := manager.spawn_drink(level, Vector2(center_x, y_pos), false)
        var inside := is_instance_valid(drink) and drink.position.x - radius >= expected_bounds.x + margin - 0.01 and drink.position.x + radius <= expected_bounds.y - margin + 0.01
        collider_ok = collider_ok and inside
        print("M06_COLLIDER level=L%d y=%.3f radius=%.3f independent_bounds=(%.3f,%.3f) inside=%s" % [level, y_pos, radius, expected_bounds.x + margin, expected_bounds.y - margin, inside])
    _check("L01/mid/L12 collider footprints remain inside perspective rails", collider_ok)

    var held := manager.shot_controller._current_drink if manager.shot_controller != null else null
    var launch_bounds := manager.get_horizontal_bounds_at_y(manager.launch_y, held.radius if is_instance_valid(held) else 20.0)
    var launch_ok := is_instance_valid(held) and is_equal_approx(held.position.y, manager.launch_y) and held.position.x >= launch_bounds.x and held.position.x <= launch_bounds.y
    _check("held launch cocktail starts on the lower visible table", launch_ok)
    print("M06_LAUNCH position=%s bounds=(%.3f,%.3f) danger_y=%.3f" % [held.position if is_instance_valid(held) else Vector2.INF, launch_bounds.x, launch_bounds.y, manager.death_line_y])

    _check("no guide_line asset or node was introduced", not FileAccess.file_exists("res://assets/ui/guide_line.png") and manager.get_node_or_null("guide_line") == null)
    _check("canonical source-to-viewport mapping preserves aspect without distortion", GameManager.background_scale_for_viewport(viewport_size) >= viewport_size.x / 1024.0 and GameManager.background_scale_for_viewport(viewport_size) >= viewport_size.y / 1536.0)

    await _save_capture_pair(root, manager, "canonical_720x1280")
    _check_render_space_geometry(manager, "canonical_720x1280")
    manager.queue_free()
    await process_frame

    for case in VIEWPORT_CASES:
        var case_size: Vector2 = case.size
        var scale := GameManager.background_scale_for_viewport(case_size)
        var offset := GameManager.background_offset_for_viewport(case_size)
        var responsive_manager := await _build_case_viewport(case_size)
        _check_reference_geometry(responsive_manager, case.name)
        print("M06_RESPONSIVE name=%s viewport=%s scale=%.6f offset=%s no_distortion=true" % [case.name, case_size, scale, offset])
        var responsive_viewport := responsive_manager.get_viewport()
        await _save_capture_pair(responsive_viewport, responsive_manager, case.name)
        _check_render_space_geometry(responsive_manager, case.name)
        responsive_manager.queue_free()
        responsive_viewport.queue_free()
        await process_frame

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


func _build_case_viewport(size: Vector2) -> GameManager:
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
    return manager


func _save_capture_pair(viewport: Viewport, manager: GameManager, label: String) -> void:
    await _save_viewport_capture(viewport, label)
    var overlay := Node2D.new()
    overlay.set_script(load(OVERLAY_SCRIPT))
    overlay.set("manager", manager)
    overlay.set("title", "M06 geometry overlay — %s" % label)
    manager.add_child(overlay)
    await process_frame
    await process_frame
    await _save_viewport_capture(viewport, "%s_runtime_overlay" % label.trim_suffix(".png"))
    overlay.queue_free()
    await process_frame


func _expected_case(label: String) -> Dictionary:
    return expected_landmarks.get("viewports", {}).get(label, {})


func _expected_rail_bounds(label: String, t: float) -> Vector2:
    var case_data := _expected_case(label)
    var rail_data: Dictionary = case_data.get("rail_bounds_at_depth", {})
    if not rail_data.has("far") or not rail_data.has("middle") or not rail_data.has("near"):
        return Vector2.ZERO
    var far: Array = rail_data["far"]
    var middle: Array = rail_data["middle"]
    var near: Array = rail_data["near"]
    var far_bounds := Vector2(far[0], far[1])
    var middle_bounds := Vector2(middle[0], middle[1])
    var near_bounds := Vector2(near[0], near[1])
    if t <= 0.5:
        return far_bounds.lerp(middle_bounds, t * 2.0)
    return middle_bounds.lerp(near_bounds, (t - 0.5) * 2.0)


func _check_reference_geometry(manager: GameManager, label: String) -> void:
    var expected := _expected_case(label)
    var viewport_size := manager.get_board_size()
    var expected_size: Array = expected.get("size", [])
    _check("%s independent viewport size" % label, expected_size.size() == 2 and is_equal_approx(viewport_size.x, expected_size[0]) and is_equal_approx(viewport_size.y, expected_size[1]))
    _check("%s independent table Y landmarks" % label, absf(manager.table_top_y - float(expected.get("table_top_y", -1.0))) <= 3.0 and absf(manager.table_bottom_y - float(expected.get("table_bottom_y", -1.0))) <= 3.0 and absf(manager.death_line_y - float(expected.get("danger_y", -1.0))) <= 3.0 and absf(manager.launch_y - float(expected.get("launch_y", -1.0))) <= 3.0)
    var depths := [0.0, 0.5, 1.0]
    var rails_ok := true
    var previous_width := INF
    for index in range(depths.size()):
        var t: float = depths[index]
        var actual := manager.get_table_rail_bounds_at_y(lerpf(manager.table_top_y, manager.table_bottom_y, t))
        var expected_bounds := _expected_rail_bounds(label, t)
        var width := actual.y - actual.x
        var monotonic_ok := width < previous_width if index == 0 else width > previous_width
        rails_ok = rails_ok and actual.x >= -0.01 and actual.y <= viewport_size.x + 0.01 and actual.distance_to(expected_bounds) <= 3.0 and monotonic_ok
        previous_width = width
        print("M06_REFERENCE_RAILS label=%s t=%.2f actual=(%.3f,%.3f) expected=(%.3f,%.3f)" % [label, t, actual.x, actual.y, expected_bounds.x, expected_bounds.y])
    _check("%s rails match independent far/mid/near reference" % label, rails_ok)
    _check("%s launch/danger occupy lower visible wood" % label, manager.death_line_y > manager.table_top_y + 450.0 and manager.launch_y > manager.death_line_y and manager.launch_y < manager.table_bottom_y)


func _check_render_space_geometry(manager: GameManager, label: String) -> void:
    var case_data: Dictionary = render_landmarks.get("viewports", {}).get(label, {})
    var tolerance := float(render_landmarks.get("tolerance_px", 8.0))
    var actual_depths := [0.0, 0.5, 1.0]
    var names := ["far", "middle", "near"]
    var rails_ok := case_data.size() > 0
    for index in range(actual_depths.size()):
        var measured: Array = case_data.get("rails", {}).get(names[index], [])
        var measured_bounds := Vector2(measured[0], measured[1]) if measured.size() == 2 else Vector2.INF
        var y_pos := lerpf(manager.table_top_y, manager.table_bottom_y, actual_depths[index])
        var production_bounds := manager.get_table_rail_bounds_at_y(y_pos)
        var error := production_bounds.distance_to(measured_bounds)
        rails_ok = rails_ok and measured.size() == 2 and error <= tolerance and production_bounds.x >= 0.0 and production_bounds.y <= manager.get_board_size().x
        print("M06_RENDER_RAILS label=%s depth=%s measured=(%.2f,%.2f) production=(%.2f,%.2f) error=%.2f tolerance=%.2f" % [label, names[index], measured_bounds.x, measured_bounds.y, production_bounds.x, production_bounds.y, error, tolerance])
    _check("%s production rails match screenshot-space visible-wood landmarks" % label, rails_ok)


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
