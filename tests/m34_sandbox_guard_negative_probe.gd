extends SceneTree

const TEST_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")


func _init() -> void:
	var result: Dictionary = TEST_SANDBOX_GUARD.validate()
	if bool(result.get("ok", false)):
		printerr("M34_SANDBOX_NEGATIVE=FAIL guard accepted an invocation without explicit markers")
		quit(1)
		return
	print("M34_SANDBOX_NEGATIVE=PASS refused=%s" % str(result.get("reason", "UNKNOWN")))
	quit(0)
