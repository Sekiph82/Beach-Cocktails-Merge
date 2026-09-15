class_name GameManager
extends Node2D

## Root game coordinator for the playable prototype.

static var instance: GameManager

@export var death_line_y := 200.0
@export var death_tolerance := 1.0

var score := 0
var best_score := 0
var chain := 0
var chain_timer := 0.0
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


func _ready() -> void:
    instance = self
    randomize()

    if not Drink.load_data():
        push_error("Drink verisi yuklenemedi. Oyun baslatilamiyor.")
        return

    world = Node2D.new()
    world.name = "World"
    add_child(world)

    merge_queue = MergeQueue.new()
    merge_queue.name = "MergeQueue"
    add_child(merge_queue)

    _build_walls()
    _build_ui()
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


func spawn_drink(p_level: int, pos: Vector2, held: bool = false) -> Drink:
    if world == null or game_over:
        return null

    var drink := Drink.create(p_level)
    if drink == null:
        return null

    drink.position = pos
    drink.freeze = held
    drink.merged.connect(merge_queue.request_merge)
    world.add_child(drink)
    return drink


func set_next_level(p_level: int) -> void:
    if _next_label == null:
        return
    _next_label.text = "NEXT  L%d  %s" % [p_level, Drink.level_name(p_level)]


func on_merged(new_level: int, pos: Vector2) -> void:
    if game_over or new_level < 1 or new_level > Drink.drinks_data.size():
        return

    chain += 1
    chain_timer = 0.8

    var base := int(Drink.drinks_data[new_level - 1].get("score", 0))
    var multiplier := 1.0 + 0.5 * float(chain - 1)
    var gained := int(round(float(base) * multiplier))
    score += gained

    _refresh_hud()
    _juice_effect(pos)

    print("ZINCIR x%d  +%d  (toplam: %d)" % [chain, gained, score])


func _process(delta: float) -> void:
    if game_over:
        return

    if chain > 0:
        chain_timer -= delta
        if chain_timer <= 0.0:
            chain = 0
            _refresh_hud()

    _update_death_line(delta)


func _update_death_line(delta: float) -> void:
    var danger := false

    for child in world.get_children():
        if child is Drink:
            var drink := child as Drink
            if not drink.freeze and not drink.is_queued_for_deletion():
                # Top edge crossing the line is what counts. The 1-second tolerance
                # prevents a normal upward shot from immediately ending the game.
                if drink.position.y - drink.radius < death_line_y:
                    danger = true
                    break

    _line_timer = _line_timer + delta if danger else 0.0

    if _line_timer >= death_tolerance:
        _game_over()


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

    if score > best_score:
        best_score = score
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
        _chain_label.text = "ZINCIR x%d" % chain


func _build_walls() -> void:
    var size := get_board_size()
    var thickness := 30.0

    _add_wall(Vector2(size.x * 0.5, size.y - thickness * 0.5), Vector2(size.x, thickness), "Floor")
    _add_wall(Vector2(thickness * 0.5, size.y * 0.5), Vector2(thickness, size.y), "LeftWall")
    _add_wall(Vector2(size.x - thickness * 0.5, size.y * 0.5), Vector2(thickness, size.y), "RightWall")


func _add_wall(pos: Vector2, size: Vector2, wall_name: String) -> void:
    var wall := StaticBody2D.new()
    wall.name = wall_name
    wall.position = pos
    wall.collision_layer = 1
    wall.collision_mask = 1

    var collision := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    collision.shape = rect
    wall.add_child(collision)

    var mat := PhysicsMaterial.new()
    mat.friction = 0.2
    mat.bounce = 0.35
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

    _chain_label = _make_label(Vector2(28, 134), Vector2(board_size.x - 56, 44), 25, HORIZONTAL_ALIGNMENT_CENTER)
    _chain_label.add_theme_color_override("font_color", Color(1.0, 0.83, 0.28, 1.0))
    _chain_label.visible = false
    hud.add_child(_chain_label)

    var hint := _make_label(Vector2(30, board_size.y - 62), Vector2(board_size.x - 60, 34), 17, HORIZONTAL_ALIGNMENT_CENTER)
    hint.text = "Surukle: X konumu   •   Birak: firlat"
    hint.add_theme_color_override("font_color", Color(0.78, 0.82, 0.9, 0.82))
    hud.add_child(hint)

    # Game-over overlay.
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
    # Lightweight merge flash; no external assets required.
    var flash := Polygon2D.new()
    flash.position = pos
    flash.polygon = Drink._circle_points(28.0, 20)
    flash.color = Color(1.0, 0.92, 0.45, 0.8)
    world.add_child(flash)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(flash, "scale", Vector2(2.4, 2.4), 0.22)
    tween.tween_property(flash, "modulate:a", 0.0, 0.22)
    tween.chain().tween_callback(flash.queue_free)


func _draw() -> void:
    var size := get_board_size()

    draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.045, 0.075, 1.0), true)

    # Subtle playfield stripes for readability without external art assets.
    for y in range(0, int(size.y), 80):
        if int(y / 80) % 2 == 0:
            draw_rect(Rect2(0, y, size.x, 80), Color(0.045, 0.058, 0.092, 1.0), true)

    draw_line(Vector2(30, death_line_y), Vector2(size.x - 30, death_line_y), Color(1.0, 0.30, 0.30, 0.8), 4.0)
    draw_line(Vector2(30, size.y - 30), Vector2(size.x - 30, size.y - 30), Color(0.28, 0.34, 0.48, 1.0), 3.0)
