extends SceneTree

const APPLICATION_SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CAPTURE_INPUT_SCRIPT := preload("res://tools/release/capture_live_game_input.gd")
const SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")


func _initialize() -> void:
	var sandbox_result: Dictionary = SANDBOX_GUARD.validate()
	if not bool(sandbox_result.get("ok", false)):
		printerr("BCM_LIVE_CAPTURE_ABORT=%s" % str(sandbox_result.get("reason", "UNKNOWN")))
		quit(70)
		return
	print("BCM_LIVE_CAPTURE_SANDBOX_OK root=%s user_data=%s" % [sandbox_result["sandbox_root"], sandbox_result["user_data_path"]])
	call_deferred("_boot_production_application")


func _boot_production_application() -> void:
	var application := APPLICATION_SHELL_SCENE.instantiate()
	root.add_child(application)
	var capture_input := Node.new()
	capture_input.name = "ReleaseMediaCaptureInput"
	capture_input.set_script(CAPTURE_INPUT_SCRIPT)
	capture_input.call("configure", application)
	root.add_child(capture_input)
	print("BCM_LIVE_CAPTURE_READY source=ApplicationShellScene trigger=F12 output=res://docs/release/store_media/captures_v03")
