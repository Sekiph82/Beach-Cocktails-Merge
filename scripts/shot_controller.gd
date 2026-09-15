class_name ShotController
extends Node

## Desktop + mobile input for the tabletop shot.
## Drag horizontally to choose the launch lane, release to slide upward.

@export var launch_speed: float = 700.0
@export var spawn_y_offset: float = 92.0

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

    var bounds := _manager.get_horizontal_bounds_at_y(_current_drink.position.y, _current_drink.radius)
    _current_drink.position.x = clampf(x_pos, bounds.x, bounds.y)


func _end_drag_and_fire() -> void:
    _dragging = false
    _launch()


func _launch() -> void:
    if not is_instance_valid(_current_drink) or _manager.game_over:
        return

    var fired := _current_drink
    _current_drink = null
    _can_shoot = false

    # Held preview has no collision. It enters the physics world only here.
    # A fresh held glass is spawned immediately; the fired glass does NOT need
    # to settle or merge first. Multiple glasses may be moving at the same time.
    fired.launch_up(launch_speed)
    shot_fired.emit(fired, Vector2(0.0, -launch_speed))

    if _manager == null or _manager.game_over:
        return

    _can_shoot = true
    _spawn_next()
