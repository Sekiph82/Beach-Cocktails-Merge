extends "res://tests/support/isolated_test_scene_tree.gd"

const BCM_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")



func _initialize() -> void:
	if not BCM_SANDBOX_GUARD.enforce(self):
		return
	var expected_dir := OS.get_environment("BCM_M27_EXPECTED_USER_DATA_DIR")
	var actual_dir := ProjectSettings.globalize_path("user://").simplify_path()
	var os_dir := OS.get_user_data_dir().simplify_path()
	var expected_log := (expected_dir.path_join("logs").path_join("godot.log")).simplify_path()
	print("M27_ISOLATION_USER_DATA=%s" % actual_dir)
	print("M27_ISOLATION_OS_USER_DATA=%s" % os_dir)
	print("M27_ISOLATION_EXPECTED_LOG=%s" % expected_log)
	if expected_dir.is_empty() or actual_dir.to_lower() != expected_dir.simplify_path().to_lower() or os_dir.to_lower() != expected_dir.simplify_path().to_lower():
		push_error("M27 isolation path mismatch; refusing subsequent milestone tests.")
		print("M27_ISOLATION_PROBE=FAIL")
		quit(2)
		return
	print("M27_ISOLATION_PROBE=PASS")
	quit(0)
