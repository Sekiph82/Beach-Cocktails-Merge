extends SceneTree
## Regression: one phone tap = one shot. On touch devices Godot sends an emulated
## mouse event (device == DEVICE_ID_EMULATION) alongside each ScreenTouch.

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var manager := (load("res://scenes/main.tscn") as PackedScene).instantiate() as GameManager
	root.add_child(manager)
	await process_frame
	await physics_frame
	var shots := [0]
	manager.shot_controller.shot_fired.connect(func(_d, _v): shots[0] += 1)
	var y := manager.shot_controller._current_drink.position.y
	var seq: Array[InputEvent] = []
	for pressed in [true, false]:
		var m := InputEventMouseButton.new()
		m.device = InputEvent.DEVICE_ID_EMULATION
		m.button_index = MOUSE_BUTTON_LEFT
		m.pressed = pressed
		m.position = Vector2(300.0, y)
		var t := InputEventScreenTouch.new()
		t.index = 0
		t.pressed = pressed
		t.position = Vector2(300.0, y)
		seq.append(m)
		seq.append(t)
	for e in seq:
		manager.shot_controller._unhandled_input(e)
	await process_frame
	var ok: bool = shots[0] == 1
	print("TOUCH_SINGLE_SHOT shots=%d RESULT=%s" % [shots[0], "PASS" if ok else "FAIL"])
	quit(0 if ok else 1)
