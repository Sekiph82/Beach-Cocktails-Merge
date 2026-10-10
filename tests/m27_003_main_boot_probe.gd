extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		push_error("M27_003_BOOT_FAIL: main scene did not load")
		quit(1)
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	for frame in range(120):
		await process_frame
	var manager_ok := instance is GameManager
	var bridge_ok := manager_ok and instance.presentation_feedback_bridge is PresentationFeedbackBridge and is_instance_valid(instance.presentation_feedback_bridge)
	if manager_ok and bridge_ok:
		print("M27_003_BOOT_RESULT=PASS frames=120 game_manager=true presentation_bridge=true")
		quit(0)
	else:
		push_error("M27_003_BOOT_FAIL manager=%s bridge=%s" % [manager_ok, bridge_ok])
		quit(1)
