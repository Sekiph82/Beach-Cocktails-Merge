extends SceneTree

const BASE_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")


func _init() -> void:
	BASE_SANDBOX_GUARD.enforce(self)
