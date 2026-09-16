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
const DANGER_SOURCE_Y := 1100.0
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
var _hud: Control
var _best_panel: Control
var _score_panel: Control
var _to_go_panel: Control
var _next_panel: Control
var _progression_strip: Control
var _best_value: Label
var _score_value: Label
var _to_go_target_sprite: Sprite2D
var _to_go_level_label: Label
var _to_go_reward_label: Label
var _next_sprite: Sprite2D
var _progression_icons: Array[Sprite2D] = []
var _chain_label: Label
var _game_over_layer: Control
var _final_score_label: Label
var _background: Sprite2D
var _background_scale := 1.0
var _background_offset := Vector2.ZERO
var _launch_zone: Sprite2D
var _danger_line: Sprite2D

# Active merge objective shown above the table.
var _target_level := 6
var _target_root: Node2D
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
    # At taller portrait ratios the source-cover transform can place the
    # source near rail outside the viewport. Keep the gameplay rail on the
    # visible wood/frame edge rather than allowing an off-screen collider.
    table_bottom_inset = clampf(maxf(size.x - near_right.x, 20.0), 20.0, size.x * 0.18)
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
    var left := lerpf(table_top_inset, table_bottom_inset, t)
    var right := lerpf(size.x - table_top_inset, size.x - table_bottom_inset, t)
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
    _refresh_next_visual(p_level)


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
        _update_launch_zone(false)
        return

    if chain > 0:
        chain_timer -= delta
        if chain_timer <= 0.0:
            chain = 0
            chain_timer = 0.0
            _refresh_hud()

    _update_death_line(delta)
    _update_launch_zone(true)


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
    if _score_value != null:
        _score_value.text = "%s" % score
    if _best_value != null:
        _best_value.text = "%s" % best_score
    if _chain_label != null:
        _chain_label.visible = chain > 1
        _chain_label.text = "COMBO x%d" % chain


func _build_walls() -> void:
    var size := get_board_size()

    var top_left := Vector2(table_top_inset, table_top_y)
    var top_right := Vector2(size.x - table_top_inset, table_top_y)
    var bottom_left := Vector2(table_bottom_inset, table_bottom_y)
    var bottom_right := Vector2(size.x - table_bottom_inset, table_bottom_y)

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
    var ui_scale := clampf(board_size.x / 720.0, 0.94, 1.10)
    var canvas := CanvasLayer.new()
    canvas.name = "UI"
    add_child(canvas)

    _hud = Control.new()
    _hud.name = "HUD"
    _hud.position = Vector2.ZERO
    _hud.size = board_size
    _hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(_hud)

    _best_panel = _make_panel("BestScorePanel", "res://assets/ui/panel_best_score.png", Rect2(16.0 * ui_scale, 164.0 * ui_scale, 230.0 * ui_scale, 130.0 * ui_scale))
    _hud.add_child(_best_panel)
    _best_value = _make_panel_value(_best_panel, "%s" % best_score, 28, 0.54)

    _score_panel = _make_panel("ScorePanel", "res://assets/ui/panel_score.png", Rect2(16.0 * ui_scale, 298.0 * ui_scale, 230.0 * ui_scale, 130.0 * ui_scale))
    _hud.add_child(_score_panel)
    _score_value = _make_panel_value(_score_panel, "%s" % score, 30, 0.54)

    var logo := _make_panel("Logo", "res://assets/ui/logo_beach_cocktails_merge.png", Rect2(12.0 * ui_scale, 6.0 * ui_scale, 220.0 * ui_scale, 148.0 * ui_scale))
    _hud.add_child(logo)

    var to_go_width := 310.0 * ui_scale
    var to_go_height := to_go_width * 1024.0 / 1536.0
    var to_go_rect := Rect2((board_size.x - to_go_width) * 0.5, 14.0 * ui_scale, to_go_width, to_go_height)
    _to_go_panel = _make_panel("ToGoOrdersPanel", "res://assets/ui/panel_to_go_orders.png", to_go_rect)
    _hud.add_child(_to_go_panel)

    _to_go_target_sprite = Sprite2D.new()
    _to_go_target_sprite.name = "TargetCocktail"
    _to_go_target_sprite.position = Vector2(to_go_rect.size.x * 0.5, to_go_rect.size.y * 0.61)
    _to_go_target_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _to_go_target_sprite.z_index = 2
    _to_go_panel.add_child(_to_go_target_sprite)

    _to_go_level_label = _make_panel_text(_to_go_panel, "", Rect2(to_go_rect.size.x * 0.20, to_go_rect.size.y * 0.60, to_go_rect.size.x * 0.60, 24.0 * ui_scale), 16, Color(0.34, 0.13, 0.05, 1.0))
    _to_go_reward_label = _make_panel_text(_to_go_panel, "", Rect2(to_go_rect.size.x * 0.23, to_go_rect.size.y * 0.80, to_go_rect.size.x * 0.54, 28.0 * ui_scale), 24, Color(0.30, 0.10, 0.03, 1.0))

    var next_size := 150.0 * ui_scale
    var next_rect := Rect2(board_size.x - next_size - 12.0 * ui_scale, 10.0 * ui_scale, next_size, next_size)
    _next_panel = _make_panel("NextPanel", "res://assets/ui/panel_next.png", next_rect)
    _hud.add_child(_next_panel)
    _next_sprite = Sprite2D.new()
    _next_sprite.name = "NextCocktail"
    _next_sprite.position = Vector2(next_size * 0.5, next_size * 0.64)
    _next_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _next_panel.add_child(_next_sprite)

    var strip_margin := 12.0 * ui_scale
    var strip_width := board_size.x - strip_margin * 2.0
    var strip_height := strip_width * 725.0 / 2170.0
    _progression_strip = _make_panel("ProgressionStrip", "res://assets/ui/progression_strip.png", Rect2(strip_margin, board_size.y - strip_height - 8.0 * ui_scale, strip_width, strip_height))
    _hud.add_child(_progression_strip)
    _build_progression_icons(_progression_strip)

    # World-space overlays stay independent from HUD layout but follow the
    # accepted M06 launch/death coordinates. They have no collision/input.
    _launch_zone = Sprite2D.new()
    _launch_zone.name = "LaunchZone"
    _launch_zone.texture = load("res://assets/ui/launch_zone.png") as Texture2D
    _launch_zone.position = Vector2(board_size.x * 0.5, launch_y)
    _launch_zone.scale = Vector2.ONE * clampf(112.0 / 1254.0, 0.07, 0.12)
    _launch_zone.z_index = 1
    _launch_zone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    add_child(_launch_zone)

    _danger_line = Sprite2D.new()
    _danger_line.name = "DangerLine"
    _danger_line.texture = load("res://assets/ui/danger_line.png") as Texture2D
    _danger_line.z_index = 1
    _danger_line.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    add_child(_danger_line)
    _layout_danger_line()

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


func _make_panel(panel_name: String, texture_path: String, rect: Rect2) -> Control:
    var panel := Control.new()
    panel.name = panel_name
    panel.position = rect.position
    panel.size = rect.size
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var artwork := Sprite2D.new()
    artwork.name = "Artwork"
    artwork.texture = load(texture_path) as Texture2D
    artwork.position = rect.size * 0.5
    if artwork.texture != null:
        artwork.scale = Vector2.ONE * minf(rect.size.x / float(artwork.texture.get_width()), rect.size.y / float(artwork.texture.get_height()))
    artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    panel.add_child(artwork)
    return panel


func _make_panel_value(panel: Control, value: String, font_size: int, y_ratio: float) -> Label:
    var label := _make_panel_text(panel, value, Rect2(panel.size.x * 0.23, panel.size.y * y_ratio - 18.0, panel.size.x * 0.54, 44.0), font_size, Color(1.0, 0.93, 0.76, 1.0))
    label.add_theme_color_override("font_shadow_color", Color(0.18, 0.06, 0.02, 0.8))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    return label


func _make_panel_text(panel: Control, text_value: String, rect: Rect2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = text_value
    label.position = rect.position
    label.size = rect.size
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    panel.add_child(label)
    return label


func _build_progression_icons(strip: Control) -> void:
    _progression_icons.clear()
    var slot_x_ratios := [0.112, 0.184, 0.255, 0.327, 0.399, 0.472, 0.543, 0.615, 0.687, 0.758, 0.830, 0.902]
    for i in range(12):
        var level := i + 1
        var icon := Sprite2D.new()
        icon.name = "ProgressionIconL%02d" % level
        icon.texture = Drink.texture_for_level(level)
        icon.position = Vector2(strip.size.x * slot_x_ratios[i], strip.size.y * 0.49)
        icon.scale = Vector2.ONE * _hud_icon_scale(level, 54.0)
        icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
        icon.z_index = 2
        strip.add_child(icon)
        _progression_icons.append(icon)


func _hud_icon_scale(level: int, max_dimension: float) -> float:
    var texture := Drink.texture_for_level(level)
    if texture == null:
        return 0.0
    var source_dimension := float(maxi(texture.get_width(), texture.get_height()))
    return minf(Drink.visual_scale_for_level(level), max_dimension / source_dimension)


func _refresh_next_visual(level: int) -> void:
    if _next_sprite == null:
        return
    _next_sprite.texture = Drink.texture_for_level(level)
    _next_sprite.scale = Vector2.ONE * _hud_icon_scale(level, 92.0)


func _layout_danger_line() -> void:
    if _danger_line == null:
        return
    var bounds := get_table_rail_bounds_at_y(death_line_y)
    var width := maxf(bounds.y - bounds.x - wall_thickness * 2.0, 120.0)
    var texture := _danger_line.texture
    _danger_line.position = Vector2((bounds.x + bounds.y) * 0.5, death_line_y)
    _danger_line.scale = Vector2.ONE * (width / float(texture.get_width()) if texture != null else 0.25)


func _update_launch_zone(visible: bool) -> void:
    if _launch_zone == null:
        return
    var held := shot_controller._current_drink if shot_controller != null else null
    _launch_zone.visible = visible and is_instance_valid(held)
    if _launch_zone.visible:
        _launch_zone.position = held.position


func _build_merge_target() -> void:
    _target_root = Node2D.new()
    _target_root.name = "ToGoTargetDestination"
    _target_root.position = _to_go_target_sprite.global_position
    _target_root.visible = false
    add_child(_target_root)


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
    if _to_go_panel == null or _to_go_target_sprite == null:
        return

    _to_go_panel.visible = true
    _to_go_panel.modulate = Color.WHITE
    _to_go_target_sprite.visible = true
    _to_go_target_sprite.modulate = Color.WHITE
    _to_go_target_sprite.texture = Drink.texture_for_level(_target_level)
    _to_go_target_sprite.scale = Vector2.ONE * _hud_icon_scale(_target_level, 104.0)
    _to_go_level_label.text = "L%d  %s" % [_target_level, Drink.level_name(_target_level)]
    _to_go_reward_label.text = "+%d" % Drink.order_reward(_target_level)
    if _target_root != null:
        _target_root.position = _to_go_target_sprite.global_position

    var pulse := create_tween()
    pulse.tween_property(_to_go_target_sprite, "modulate", Color(1.18, 1.18, 1.18, 1.0), 0.12)
    pulse.tween_property(_to_go_target_sprite, "modulate", Color.WHITE, 0.18)


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
    tween.tween_property(_to_go_target_sprite, "scale", _to_go_target_sprite.scale * 1.18, 0.34)
    tween.tween_property(_to_go_target_sprite, "modulate:a", 0.0, 0.34)
    tween.finished.connect(_finish_target_collection, CONNECT_ONE_SHOT)


func _finish_target_collection() -> void:
    var drink := _target_drink
    _target_drink = null
    if is_instance_valid(drink):
        drink.queue_free()

    _to_go_panel.visible = false

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
    # All table/HUD-facing artwork is supplied by canonical V7 assets.
    pass
