extends RefCounted

const TEST_MODE_ENV := "BCM_TEST_MODE"
const SANDBOX_ROOT_ENV := "BCM_TEST_SANDBOX_ROOT"
const BUILD_MARKER_ENV := "BCM_TEST_BUILD_MARKER"
const EXPECTED_BUILD_MARKER := "NONSHIPPING_LOCAL_TEST"


static func validate() -> Dictionary:
	if OS.get_environment(TEST_MODE_ENV) != "1":
		return {"ok": false, "reason": "TEST_MODE_MARKER_MISSING"}
	if OS.get_environment(BUILD_MARKER_ENV) != EXPECTED_BUILD_MARKER:
		return {"ok": false, "reason": "NONSHIPPING_TEST_MARKER_MISSING"}
	var sandbox := _normalize(OS.get_environment(SANDBOX_ROOT_ENV))
	if sandbox.is_empty():
		return {"ok": false, "reason": "TEST_SANDBOX_ROOT_MISSING"}
	var repo_sandbox_root := _normalize(ProjectSettings.globalize_path("res://.godot/bcm_sandboxes"))
	if not sandbox.begins_with(repo_sandbox_root + "/"):
		return {"ok": false, "reason": "TEST_SANDBOX_OUTSIDE_PROJECT"}
	var expected_app_data := sandbox.path_join("r")
	var expected_local_app_data := sandbox.path_join("l")
	if _normalize(OS.get_environment("APPDATA")) != expected_app_data:
		return {"ok": false, "reason": "APPDATA_NOT_ISOLATED"}
	if _normalize(OS.get_environment("LOCALAPPDATA")) != expected_local_app_data:
		return {"ok": false, "reason": "LOCALAPPDATA_NOT_ISOLATED"}
	var user_path := _normalize(ProjectSettings.globalize_path("user://"))
	var os_user_path := _normalize(OS.get_user_data_dir())
	if user_path.is_empty() or user_path != os_user_path:
		return {"ok": false, "reason": "GODOT_USER_PATH_DISAGREEMENT"}
	if not user_path.begins_with(expected_app_data + "/godot/app_userdata/"):
		return {"ok": false, "reason": "USER_DATA_OUTSIDE_ISOLATED_APPDATA"}
	return {"ok": true, "reason": "ISOLATED", "sandbox_root": sandbox, "user_data_path": user_path}


static func enforce(tree: SceneTree) -> bool:
	var result: Dictionary = validate()
	if not bool(result.get("ok", false)):
		printerr("BCM_TEST_SANDBOX_ABORT=%s" % str(result.get("reason", "UNKNOWN")))
		tree.quit(70)
		return false
	print("BCM_TEST_SANDBOX_OK root=%s user_data=%s" % [result["sandbox_root"], result["user_data_path"]])
	return true


static func _normalize(path: String) -> String:
	return path.replace("\\", "/").simplify_path().trim_suffix("/").to_lower()
