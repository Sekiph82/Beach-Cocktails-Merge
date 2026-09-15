class_name GameManager
extends Node2D
## Godot 4.7.2: Jolt fizik + Tween API (tween_property ile kamera sarsintisi)

static var instance: GameManager

var score := 0
var chain := 0
var chain_timer := 0.0
var game_over := false

@export var death_line_y := 200.0      # ekranin ust %15'i civari
@export var death_tolerance := 1.0     # saniye - frustrasyonu onler
var _line_timer := 0.0

var merge_queue: MergeQueue
var shot_controller: ShotController

func _ready() -> void:
    instance = self
    merge_queue = MergeQueue.new()
    add_child(merge_queue)
    shot_controller = ShotController.new()
    add_child(shot_controller)

    _build_walls()
    child_order_changed.connect(_hook_drinks)

func _hook_drinks() -> void:
    # Tum kokteyllerin merged sinyalini kuyruga bagla
    for d in get_children():
        if d is Drink and not d.merged.is_connected(merge_queue.request_merge):
            d.merged.connect(merge_queue.request_merge)

func _build_walls() -> void:
    var vp := get_viewport_rect().size
    _add_wall(Vector2(vp.x / 2, vp.y + 10), Vector2(vp.x, 20))        # zemin
    _add_wall(Vector2(-10, vp.y / 2), Vector2(20, vp.y * 2))           # sol
    _add_wall(Vector2(vp.x + 10, vp.y / 2), Vector2(20, vp.y * 2))     # sag
    _add_wall(Vector2(vp.x / 2, -500), Vector2(vp.x, 20))              # gorunmez ust duvar

func _add_wall(pos: Vector2, size: Vector2) -> void:
    var w := StaticBody2D.new()
    w.position = pos
    var cs := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    cs.shape = rect
    w.add_child(cs)
    var mat := PhysicsMaterial.new()
    mat.friction = 0.2
    mat.bounce = 0.35
    w.physics_material_override = mat
    add_child(w)

func on_merged(new_level: int, pos: Vector2) -> void:
    chain += 1
    chain_timer = 0.8
    var gained := int(Drink.drinks_data[new_level - 1]["score"] * (1.0 + 0.5 * (chain - 1)))
    score += gained
    print("ZINCIR x%d  +%d  (toplam: %d)" % [chain, gained, score])
    _juice_effect(pos)

func _juice_effect(pos: Vector2) -> void:
    # 4.7.2 Tween API: kamera sarsintisi
    var cam := get_viewport().get_camera_2d()
    if cam:
        var tw := create_tween()
        tw.tween_property(cam, "offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.05)
        tw.tween_property(cam, "offset", Vector2.ZERO, 0.15)
    # Merge patlamasi partikulu (OneShot)
    var ps := GPUParticles2D.new()
    ps.position = pos
    ps.one_shot = true
    ps.amount = 16
    ps.lifetime = 0.4
    ps.emitting = true
    add_child(ps)
    get_tree().create_timer(1.0).timeout.connect(ps.queue_free)

func _process(delta: float) -> void:
    if game_over:
        return
    if chain > 0:
        chain_timer -= delta
        if chain_timer <= 0.0:
            chain = 0
    # Olum cizgisi kontrolu
    var above := false
    for d in get_children():
        if d is Drink and not d.freeze and d.position.y < death_line_y:
            above = true
            break
    _line_timer = _line_timer + delta if above else 0.0
    if _line_timer >= death_tolerance:
        _game_over()

func _game_over() -> void:
    game_over = true
    print("OYUN BITTI - Skor: ", score)
    # Rekor kaydi: 4.7.2'de user:// + ConfigFile ya da FileAccess
    var cfg := ConfigFile.new()
    cfg.load("user://save.cfg")
    var best: int = cfg.get_value("records", "best", 0)
    if score > best:
        cfg.set_value("records", "best", score)
        cfg.save("user://save.cfg")
