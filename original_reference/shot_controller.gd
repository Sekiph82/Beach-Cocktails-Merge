class_name ShotController
extends Node2D
## Godot 4.7.2 mobil dokunmatik girdisi: InputEventScreenTouch / InputEventScreenDrag
## Editor'de test icin fare otomatik karsilanir (mouse input varsayilan acik).

@export var launch_force: float = 900.0
@export var max_drag: float = 300.0        # guc sinir - "sut gol" bug'unu onler
@export var spawn_y_offset: float = 80.0
@export var respawn_delay: float = 0.6

var _dragging := false
var _drag_start := Vector2.ZERO
var _current_drink: Drink = null
var _can_shoot := true

signal shot_fired(drink: Drink, velocity: Vector2)

func _ready() -> void:
    _spawn_next()

func _spawn_next() -> void:
    _current_drink = Drink.create(randi_range(1, 3))   # sadece 1-3 spawn
    _current_drink.freeze = true                        # elimizde, fizik dursun
    var vp := get_viewport_rect().size
    _current_drink.position = Vector2(vp.x / 2, vp.y - spawn_y_offset)
    add_child(_current_drink)

func _unhandled_input(event: InputEvent) -> void:
    if not _can_shoot or _current_drink == null:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            _dragging = true
            _drag_start = event.position
        else:
            _dragging = false
            _fire_model_b()
    elif event is InputEventScreenDrag and _dragging:
        # Bardak x ekseninde parmagi takip eder
        var vp := get_viewport_rect().size
        _current_drink.position.x = clampf(event.position.x, 40.0, vp.x - 40.0)

# Model B: sabit kuvvet, yukari - ogrenme egrisi sifir
func _fire_model_b() -> void:
    _launch(Vector2(0, -launch_force))

# Model A (sapan): dokunmayi birakmadan onceki son drag noktasina gore
func _fire_model_a(last_drag_pos: Vector2) -> void:
    var drag := last_drag_pos - _drag_start
    drag.y = -absf(drag.y)                     # sadece yukari atis
    var power := clampf(drag.length(), 0.0, max_drag) / max_drag
    var dir := drag.normalized() if drag.length() > 1.0 else Vector2.UP
    _launch(dir * launch_force * (0.4 + 0.6 * power))

func _launch(velocity: Vector2) -> void:
    if _current_drink == null:
        return
    _current_drink.freeze = false
    _current_drink.linear_velocity = velocity
    _current_drink.angular_velocity = randf_range(-3.0, 3.0)
    shot_fired.emit(_current_drink, velocity)
    _current_drink = null
    _can_shoot = false
    await get_tree().create_timer(respawn_delay).timeout
    if GameManager.instance.game_over:
        return
    _can_shoot = true
    _spawn_next()
