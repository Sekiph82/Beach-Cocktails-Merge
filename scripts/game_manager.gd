class_name GameManager
extends Node2D

## Root game coordinator.
## Physics stays genuinely 2D, while the board geometry and drink artwork use
## a mild perspective treatment to create a more attractive 2.5D camera angle.

static var instance: GameManager

const BACKGROUND_PATH := "res://assets/environment/game_board_background.png"
const BACKGROUND_SOURCE_SIZE := Vector2(1024.0, 1536.0)

# Manual design-space landmarks from the owner-approved 1024x1536 background.
# Points follow the inside edge of the wooden rails, not the image canvas.
const TABLE_FAR_LEFT_SOURCE := Vector2(292.0, 464.0)
const TABLE_FAR_RIGHT_SOURCE := Vector2(732.0, 464.0)
const TABLE_NEAR_LEFT_SOURCE := Vector2(104.0, 1208.0)
const TABLE_NEAR_RIGHT_SOURCE := Vector2(920.0, 1208.0)
const DANGER_SOURCE_Y := 1048.0
const LAUNCH_SOURCE_Y := 1144.0

@export var table_top_y := 0.0
@export var table_bottom_y := 0.0
@export var table_top_inset := 0.0
@export var table_bottom_inset := 0.0
@export var wall_thickness := 24.0
@export var death_line_y := 0.0
@export var launch_y := 0.0
@export var death_tolerance := 1.0

var score := 0
var best_score := 0
var chain := 0
var chain_timer := 0.0
const COMBO_WINDOW := 1.5
const MAX_COMBO := 6
var game_over := false

var world: Node2D
var merge_queue: MergeQueue
var shot_controller: ShotController

var _line_timer := 0.0
var _score_label: Label
var _best_label: Label
var _next_label: Label
var _chain_label: Label
var _game_over_layer: Control
var _final_score_label: Label
var _background: Sprite2D
var _background_scale := 1.0
var _background_offset := Vector2.ZERO

# Active merge objective shown above the table.
var _target_level := 6
var _target_root: Node2D
var _target_body: Polygon2D
var _target_rim: Polygon2D
var _target_level_label: Label
var _target_caption: Label
var _target_transition := false
var _target_drink: Drink


func _ready() -> void:
    instance = self
    randomize()

    if not Drink.load_data():
        push_error("Drink verisi yuklenemedi. Oyun baslatilamiyor.")
        return

    _configure_board_layout()
    _build_background()

    world = Node2D.new()
    world.name = "World"
    add_child(world)

    merge_queue = MergeQueue.new()
    merge_queue.name = "MergeQueue"
    add_child(merge_queue)

    _build_walls()
    _build_ui()
    _build_merge_target()
    _choose_next_target(true)
    _load_best_score()
    _refresh_hud()

    shot_controller = ShotController.new()
    shot_controller.name = "ShotController"
    shot_controller.setup(self)
    add_child(shot_controller)

    queue_redraw()


func _exit_tree() -> void:
    if instance == self:
        instance = null


func get_board_size() -> Vector2:
    return get_viewport_rect().size


static func background_scale_for_viewport(viewport_size: Vector2) -> float:
    return maxf(viewport_size.x / BACKGROUND_SOURCE_SIZE.x, viewport_size.y / BACKGROUND_SOURCE_SIZE.y)


static func background_offset_for_viewport(viewport_size: Vector2) -> Vector2:
    var scale := background_scale_for_viewport(viewport_size)
    return (viewport_size - BACKGROUND_SOURCE_SIZE * scale) * 0.5


static func source_to_viewport(source_point: Vector2, viewport_size: Vector2) -> Vector2:
    return background_offset_for_viewport(viewport_size) + source_point * background_scale_for_viewport(viewport_size)


func _configure_board_layout() -> void:
    var size := get_board_size()
    _background_scale = background_scale_for_viewport(size)
    _background_offset = background_offset_for_viewport(size)

    var far_left := source_to_viewport(TABLE_FAR_LEFT_SOURCE, size)
    var far_right := source_to_viewport(TABLE_FAR_RIGHT_SOURCE, size)
    var near_left := source_to_viewport(TABLE_NEAR_LEFT_SOURCE, size)
    var near_right := source_to_viewport(TABLE_NEAR_RIGHT_SOURCE, size)
    table_top_y = far_left.y
    table_bottom_y = near_left.y
    table_top_inset = far_left.x
    table_bottom_inset = size.x - near_right.x
    death_line_y = source_to_viewport(Vector2(0.0, DANGER_SOURCE_Y), size).y
    launch_y = source_to_viewport(Vector2(0.0, LAUNCH_SOURCE_Y), size).y


func _build_background() -> void:
    _background = Sprite2D.new()
    _background.name = "GameBoardBackground"
    _background.texture = load(BACKGROUND_PATH) as Texture2D
    _background.position = get_board_size() * 0.5
    _background.scale = Vector2.ONE * _background_scale
    _background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _background.z_index = -100
    add_child(_background)


func get_table_rail_bounds_at_y(y_pos: float) -> Vector2:
    var size := get_board_size()
    var t := inverse_lerp(table_top_y, table_bottom_y, clampf(y_pos, table_top_y, table_bottom_y))
    var left := lerpf(table_top_inset, source_to_viewport(TABLE_NEAR_LEFT_SOURCE, size).x, t)
    var right := lerpf(size.x - table_top_inset, source_to_viewport(TABLE_NEAR_RIGHT_SOURCE, size).x, t)
    return Vector2(left, right)


func get_horizontal_bounds_at_y(y_pos: float, radius: float = 0.0) -> Vector2:
    var clearance := wall_thickness * 0.5 + radius + 3.0
    var rails := get_table_rail_bounds_at_y(y_pos)
    return Vector2(rails.x + clearance, rails.y - clearance)


func clamp_position_to_board(pos: Vector2, radius: float) -> Vector2:
    pos.y = clampf(pos.y, table_top_y + radius + wall_thickness * 0.5, table_bottom_y - radius - wall_thickness * 0.5)
    var bounds := get_horizontal_bounds_at_y(pos.y, radius)
    pos.x = clampf(pos.x, bounds.x, bounds.y)
    return pos


func get_launch_position(x_pos: float, radius: float = 20.0) -> Vector2:
    var bounds := get_horizontal_bounds_at_y(launch_y, radius)
    return Vector2(clampf(x_pos, bounds.x, bounds.y), launch_y)


func spawn_drink(p_level: int, pos: Vector2, held: bool = false) -> Drink:
    if world == null or game_over:
        return null

    var drink := Drink.create(p_level)
    if drink == null:
        return null

    pos = clamp_position_to_board(pos, drink.radius)
    drink.position = pos
    drink.merged.connect(merge_queue.request_merge)
    world.add_child(drink)

    if held:
        drink.set_held()
    else:
        drink.set_settled()

    return drink


func set_next_level(p_level: int) -> void:
    if _next_label == null:
        return
    _next_label.text = "NEXT  L%d  %s" % [p_level, Drink.level_name(p_level)]


func _add_score(points: int) -> void:
    if points <= 0:
        return
    score += points
    if score > best_score:
        best_score = score


func on_merged(new_level: int, merged_drink: Drink) -> void:
    if game_over or new_level < 1 or new_level > Drink.drinks_data.size():
        return
    if not is_instance_valid(merged_drink):
        return

    # Combo is time-based. Every merge refreshes the 1.5 s window. The bonus
    # grows by +25% of the base merge score per combo step and caps at x6.
    chain = mini(chain + 1, MAX_COMBO)
    chain_timer = COMBO_WINDOW

    var base := Drink.merge_score(new_level)
    var combo_bonus := int(round(float(base) * 0.25 * float(chain - 1)))
    var gained := base + combo_bonus
    _add_score(gained)

    _refresh_hud()
    _juice_effect(merged_drink.position)

    print("MERGE L%d +%d  COMBO x%d +%d  (toplam: %d)" % [new_level, base, chain, combo_bonus, score])

    # If the newly-created drink matches the active To-Go Order, deliver it.
    # Merge points/combo were already paid above; collection adds only the
    # separate To-Go Orders reward.
    if not _target_transition and new_level == _target_level:
        _collect_merge_target(merged_drink)


func _process(delta: float) -> void:
    if game_over:
        return

    if chain > 0:
        chain_timer -= delta
        if chain_timer <= 0.0:
            chain = 0
            chain_timer = 0.0
            _refresh_hud()

    _update_death_line(delta)


func _update_death_line(delta: float) -> void:
    var danger := false

    for child in world.get_children():
        if child is Drink:
            var drink := child as Drink
            if drink.is_settled() and not drink.is_queued_for_deletion():
                if drink.position.y + drink.radius > death_line_y:
                    danger = true
                    break

    _line_timer = _line_timer + delta if danger else 0.0

    if _line_timer >= death_tolerance:
        _game_over()


func try_chain_merge(source: Drink) -> void:
    if game_over or not is_instance_valid(source) or source.is_queued_for_deletion():
        return
    if not source.is_settled() or source.level >= Drink.max_level():
        return

    var best: Drink = null
    var best_distance := INF

    for child in world.get_children():
        if not (child is Drink) or child == source:
            continue

        var other := child as Drink
        if not other.is_settled() or other.level != source.level or other.is_queued_for_deletion():
            continue

        var distance := source.position.distance_to(other.position)
        var touching_distance := source.radius + other.radius + 4.0
        if distance <= touching_distance and distance < best_distance:
            best = other
            best_distance = distance

    if best != null:
        merge_queue.request_merge(source, best, source.level + 1)


func _game_over() -> void:
    if game_over:
        return

    game_over = true
    merge_queue.clear()
    shot_controller.stop_shooting()

    for child in world.get_children():
        if child is Drink:
            var drink := child as Drink
            drink.freeze = true

    # best_score is updated live by _add_score(), so compare-and-save here
    # would miss every new record. Persist the current best at the terminal
    # state; restart then reloads the same record from user://.
    _save_best_score()

    _refresh_hud()
    _final_score_label.text = "SKOR  %d\nREKOR  %d" % [score, best_score]
    _game_over_layer.visible = true

    print("OYUN BITTI - Skor: %d" % score)


func _restart_game() -> void:
    get_tree().reload_current_scene()


func _load_best_score() -> void:
    var cfg := ConfigFile.new()
    var err := cfg.load("user://save.cfg")
    if err == OK:
        best_score = int(cfg.get_value("records", "best", 0))
    else:
        best_score = 0


func _save_best_score() -> void:
    var cfg := ConfigFile.new()
    cfg.load("user://save.cfg")
    cfg.set_value("records", "best", best_score)
    var err := cfg.save("user://save.cfg")
    if err != OK:
        push_warning("Rekor kaydedilemedi. Hata kodu: %d" % err)


func _refresh_hud() -> void:
    if _score_label != null:
        _score_label.text = "SKOR  %d" % score
    if _best_label != null:
        _best_label.text = "REKOR  %d" % best_score
    if _chain_label != null:
        _chain_label.visible = chain > 1
        _chain_label.text = "COMBO x%d" % chain


func _build_walls() -> void:
    var size := get_board_size()

    var top_left := source_to_viewport(TABLE_FAR_LEFT_SOURCE, size)
    var top_right := source_to_viewport(TABLE_FAR_RIGHT_SOURCE, size)
    var bottom_left := source_to_viewport(TABLE_NEAR_LEFT_SOURCE, size)
    var bottom_right := source_to_viewport(TABLE_NEAR_RIGHT_SOURCE, size)

    # Angled rails match the trapezoid table. A collision therefore changes
    # direction using the actual contact normal rather than an artificial rule.
    _add_wall_segment(top_left, bottom_left, wall_thickness, "LeftRail", 0.0)
    _add_wall_segment(top_right, bottom_right, wall_thickness, "RightRail", 0.0)
    _add_wall_segment(top_left, top_right, wall_thickness, "TopRail", 0.0)
    _add_wall_segment(bottom_left, bottom_right, wall_thickness, "BottomRail", 0.0)


func _add_wall_segment(a: Vector2, b: Vector2, thickness: float, wall_name: String, bounce: float) -> void:
    var wall := StaticBody2D.new()
    wall.name = wall_name
    wall.position = (a + b) * 0.5
    wall.rotation = (b - a).angle()
    wall.collision_layer = 1
    wall.collision_mask = 1

    var collision := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(a.distance_to(b) + thickness, thickness)
    collision.shape = rect
    wall.add_child(collision)

    var mat := PhysicsMaterial.new()
    mat.friction = 0.10
    mat.bounce = bounce
    wall.physics_material_override = mat

    world.add_child(wall)


func _build_ui() -> void:
    var board_size := get_board_size()
    var canvas := CanvasLayer.new()
    canvas.name = "UI"
    add_child(canvas)

    var hud := Control.new()
    hud.name = "HUD"
    hud.position = Vector2.ZERO
    hud.size = board_size
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(hud)

    _score_label = _make_label(Vector2(28, 24), Vector2(300, 54), 30, HORIZONTAL_ALIGNMENT_LEFT)
    hud.add_child(_score_label)

    _best_label = _make_label(Vector2(board_size.x - 328, 24), Vector2(300, 54), 24, HORIZONTAL_ALIGNMENT_RIGHT)
    hud.add_child(_best_label)

    _next_label = _make_label(Vector2(28, 82), Vector2(board_size.x - 56, 46), 22, HORIZONTAL_ALIGNMENT_CENTER)
    hud.add_child(_next_label)

    _chain_label = _make_label(Vector2(28, 202), Vector2(board_size.x - 56, 44), 25, HORIZONTAL_ALIGNMENT_CENTER)
    _chain_label.add_theme_color_override("font_color", Color(1.0, 0.83, 0.28, 1.0))
    _chain_label.visible = false
    hud.add_child(_chain_label)

    var hint := _make_label(Vector2(30, board_size.y - 62), Vector2(board_size.x - 60, 34), 17, HORIZONTAL_ALIGNMENT_CENTER)
    hint.text = "Surukle: X konumu   •   Birak: masada kaydir"
    hint.add_theme_color_override("font_color", Color(0.78, 0.82, 0.9, 0.82))
    hud.add_child(hint)

    _game_over_layer = Control.new()
    _game_over_layer.name = "GameOver"
    _game_over_layer.position = Vector2.ZERO
    _game_over_layer.size = board_size
    _game_over_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    _game_over_layer.visible = false
    canvas.add_child(_game_over_layer)

    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.025, 0.04, 0.86)
    shade.position = Vector2.ZERO
    shade.size = board_size
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    _game_over_layer.add_child(shade)

    var title := _make_label(Vector2(70, 360), Vector2(board_size.x - 140, 90), 52, HORIZONTAL_ALIGNMENT_CENTER)
    title.text = "OYUN BITTI"
    title.add_theme_color_override("font_color", Color(1.0, 0.45, 0.42, 1.0))
    _game_over_layer.add_child(title)

    _final_score_label = _make_label(Vector2(70, 465), Vector2(board_size.x - 140, 120), 30, HORIZONTAL_ALIGNMENT_CENTER)
    _game_over_layer.add_child(_final_score_label)

    var restart := Button.new()
    restart.text = "TEKRAR OYNA"
    restart.position = Vector2(170, 620)
    restart.size = Vector2(board_size.x - 340, 82)
    restart.add_theme_font_size_override("font_size", 27)
    restart.pressed.connect(_restart_game)
    _game_over_layer.add_child(restart)


func _build_merge_target() -> void:
    var size := get_board_size()

    _target_caption = Label.new()
    _target_caption.text = "TO-GO ORDERS"
    _target_caption.position = Vector2(size.x * 0.5 - 120.0, 116.0)
    _target_caption.size = Vector2(240.0, 28.0)
    _target_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _target_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _target_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _target_caption.add_theme_font_size_override("font_size", 16)
    _target_caption.add_theme_color_override("font_color", Color(1.0, 0.84, 0.45, 0.95))
    add_child(_target_caption)

    _target_root = Node2D.new()
    _target_root.name = "MergeTarget"
    _target_root.position = Vector2(size.x * 0.5, 166.0)
    _target_root.z_index = 4000
    add_child(_target_root)

    _target_rim = Polygon2D.new()
    _target_rim.polygon = Drink._circle_points(44.0, 48)
    _target_rim.color = Color(1.0, 0.82, 0.35, 0.95)
    _target_root.add_child(_target_rim)

    _target_body = Polygon2D.new()
    _target_body.polygon = Drink._circle_points(37.0, 48)
    _target_root.add_child(_target_body)

    _target_level_label = Label.new()
    _target_level_label.position = Vector2(-58.0, -20.0)
    _target_level_label.size = Vector2(116.0, 40.0)
    _target_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _target_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _target_level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _target_level_label.add_theme_font_size_override("font_size", 23)
    _target_level_label.add_theme_color_override("font_color", Color.WHITE)
    _target_level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
    _target_level_label.add_theme_constant_override("shadow_offset_x", 1)
    _target_level_label.add_theme_constant_override("shadow_offset_y", 1)
    _target_root.add_child(_target_level_label)


func _choose_next_target(initial: bool = false) -> void:
    # To-Go objectives now start at L6. The first objective is explicitly
    # L6; after it is completed, objectives rotate through L6-L12 while
    # avoiding an immediate repeat.
    var max_level := Drink.max_level()
    var target_min := mini(6, max_level)
    var target_max := mini(12, max_level)

    if target_max < 1:
        _target_level = 1
    elif target_min >= target_max:
        _target_level = target_max
    elif initial:
        _target_level = target_min
    else:
        var previous := _target_level
        _target_level = randi_range(target_min, target_max)
        if _target_level == previous:
            _target_level += 1
            if _target_level > target_max:
                _target_level = target_min

    _refresh_merge_target_visual()

    # Every new order first checks the table inventory. If a matching L6-L12
    # drink was produced earlier, one existing drink is delivered immediately.
    # Only one drink fulfils one order.
    call_deferred("_try_collect_stocked_target")


func _try_collect_stocked_target() -> void:
    if game_over or _target_transition or world == null:
        return

    var candidate: Drink = null
    var best_distance := INF

    for child in world.get_children():
        if not (child is Drink):
            continue
        var drink := child as Drink
        if drink.level != _target_level or drink.is_queued_for_deletion():
            continue
        if drink.motion_state == Drink.MotionState.HELD:
            continue
        if drink.motion_state == Drink.MotionState.MERGING or drink.motion_state == Drink.MotionState.TARGET_CAPTURE:
            continue

        var distance := drink.position.distance_to(_target_root.position)
        if distance < best_distance:
            candidate = drink
            best_distance = distance

    if candidate != null:
        _collect_merge_target(candidate)


func _refresh_merge_target_visual() -> void:
    if _target_root == null:
        return

    _target_root.visible = true
    _target_root.scale = Vector2.ONE
    _target_root.modulate = Color.WHITE
    _target_caption.visible = true
    _target_caption.modulate = Color.WHITE

    var hue := float(_target_level - 1) / maxf(float(Drink.max_level()), 1.0) * 0.82
    _target_body.color = Color.from_hsv(hue, 0.72, 0.95)
    _target_level_label.text = "L%d" % _target_level
    _target_caption.text = "TO-GO ORDERS  •  %s  •  +%d" % [Drink.level_name(_target_level), Drink.order_reward(_target_level)]

    var pulse := create_tween()
    pulse.tween_property(_target_root, "scale", Vector2(1.12, 1.12), 0.12)
    pulse.tween_property(_target_root, "scale", Vector2.ONE, 0.18)


func _collect_merge_target(drink: Drink) -> void:
    if game_over or _target_transition:
        return
    if not is_instance_valid(drink) or drink.is_queued_for_deletion():
        return
    if drink.level != _target_level:
        return

    _target_transition = true
    _target_drink = drink
    drink.begin_target_capture()

    # The target drink physically leaves the table and flies into the objective.
    var tween := create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(drink, "position", _target_root.position, 0.34)
    tween.tween_property(drink, "scale", Vector2(0.42, 0.42), 0.34)
    tween.tween_property(drink, "modulate:a", 0.0, 0.34)
    tween.tween_property(_target_root, "scale", Vector2(1.35, 1.35), 0.34)
    tween.tween_property(_target_root, "modulate:a", 0.0, 0.34)
    tween.tween_property(_target_caption, "modulate:a", 0.0, 0.28)
    tween.finished.connect(_finish_target_collection, CONNECT_ONE_SHOT)


func _finish_target_collection() -> void:
    var drink := _target_drink
    _target_drink = null
    if is_instance_valid(drink):
        drink.queue_free()

    _target_root.visible = false
    _target_caption.visible = false

    # A delivered stock drink never receives merge/combo points a second time.
    # Only the currently requested To-Go reward is paid here.
    var order_bonus := Drink.order_reward(_target_level)
    _add_score(order_bonus)
    _refresh_hud()
    print("TO-GO ORDER L%d +%d  (toplam: %d)" % [_target_level, order_bonus, score])

    _target_transition = false
    _choose_next_target(false)


func _make_label(pos: Vector2, size: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
    var label := Label.new()
    label.position = pos
    label.size = size
    label.horizontal_alignment = alignment
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0, 1.0))
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    return label


func _juice_effect(pos: Vector2) -> void:
    var flash := Polygon2D.new()
    flash.position = pos
    flash.polygon = Drink._circle_points(28.0, 20)
    flash.color = Color(1.0, 0.92, 0.45, 0.8)
    world.add_child(flash)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(flash, "scale", Vector2(2.4, 1.8), 0.22)
    tween.tween_property(flash, "modulate:a", 0.0, 0.22)
    tween.chain().tween_callback(flash.queue_free)


func _draw() -> void:
    # The approved PNG supplies the table artwork. Keep only the existing
    # procedural danger boundary as a gameplay/debug aid until M07 owns the
    # final danger-line asset composition.
    var danger_bounds := get_table_rail_bounds_at_y(death_line_y)
    draw_line(
        Vector2(danger_bounds.x + wall_thickness, death_line_y),
        Vector2(danger_bounds.y - wall_thickness, death_line_y),
        Color(1.0, 0.30, 0.30, 0.82),
        4.0
    )
