class_name ShotController
extends Node

## Desktop + mobile shot input.
## Hold/drag horizontally to choose X, release to launch straight upward.

@export var launch_force: float = 2000.0
@export var spawn_y_offset: float = 90.0
@export var respawn_delay: float = 0.6

var _manager: GameManager
var _dragging := false
var _current_drink: Drink
var _can_shoot := true
var _active_touch_index := -1
var _next_level := 1

signal shot_fired(drink: Drink, velocity: Vector2)


func setup(manager: GameManager) -> void:
    _manager = manager
    _next_level = randi_range(1, 3)


func _ready() -> void:
    if _manager == null:
        push_error("ShotController.setup() add_child() oncesinde cagrilmali.")
        set_process_unhandled_input(false)
        return
    _spawn_next()


func stop_shooting() -> void:
    _can_shoot = false
    _dragging = false
    _active_touch_index = -1

    if is_instance_valid(_current_drink):
        _current_drink.queue_free()
    _current_drink = null


func _spawn_next() -> void:
    if _manager == null or _manager.game_over:
        return

    var current_level := _next_level
    _next_level = randi_range(1, 3)
    _manager.set_next_level(_next_level)

    var board_size := _manager.get_board_size()
    var spawn_pos := Vector2(board_size.x * 0.5, board_size.y - spawn_y_offset)
    _current_drink = _manager.spawn_drink(current_level, spawn_pos, true)

    if _current_drink == null:
        _can_shoot = false


func _unhandled_input(event: InputEvent) -> void:
    if not _can_shoot or not is_instance_valid(_current_drink):
        return

    # Desktop mouse.
    if event is InputEventMouseButton:
        var mouse_button := event as InputEventMouseButton
        if mouse_button.button_index == MOUSE_BUTTON_LEFT:
            if mouse_button.pressed:
                _begin_drag(mouse_button.position)
            elif _dragging:
                _move_current_to(mouse_button.position.x)
                _end_drag_and_fire()
        return

    if event is InputEventMouseMotion and _dragging and _active_touch_index == -1:
        var mouse_motion := event as InputEventMouseMotion
        _move_current_to(mouse_motion.position.x)
        return

    # Mobile touch. Track one finger only.
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed and _active_touch_index == -1:
            _active_touch_index = touch.index
            _begin_drag(touch.position)
        elif not touch.pressed and touch.index == _active_touch_index:
            _move_current_to(touch.position.x)
            _end_drag_and_fire()
            _active_touch_index = -1
        return

    if event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if _dragging and drag.index == _active_touch_index:
            _move_current_to(drag.position.x)


func _begin_drag(pos: Vector2) -> void:
    _dragging = true
    _move_current_to(pos.x)


func _move_current_to(x_pos: float) -> void:
    if not is_instance_valid(_current_drink):
        return

    var board_size := _manager.get_board_size()
    var margin := _current_drink.radius + 12.0
    _current_drink.position.x = clampf(x_pos, margin, board_size.x - margin)


func _end_drag_and_fire() -> void:
    _dragging = false
    _launch(Vector2(0.0, -launch_force))


func _launch(velocity: Vector2) -> void:
    if not is_instance_valid(_current_drink) or _manager.game_over:
        return

    var fired := _current_drink
    fired.freeze = false
    fired.sleeping = false
    fired.linear_velocity = velocity
    fired.angular_velocity = randf_range(-3.0, 3.0)

    shot_fired.emit(fired, velocity)
    _current_drink = null
    _can_shoot = false

    await get_tree().create_timer(respawn_delay).timeout

    if _manager == null or _manager.game_over:
        return

    _can_shoot = true
    _spawn_next()
