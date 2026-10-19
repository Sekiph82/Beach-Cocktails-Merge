extends "res://tests/support/isolated_test_scene_tree.gd"

const BCM_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")


const MANIFEST_PATH := "res://data/campaign/content_manifest_m33.json"
const NAVIGATION_SCRIPT := preload("res://scripts/campaign/campaign_navigation_controller.gd")
const APP_SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")

var failures: Array[String] = []


func _init() -> void:
	if not BCM_SANDBOX_GUARD.enforce(self):
		return
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_UNAVAILABLE PASS: %s" % label)
	else:
		failures.append(label)
		print("M33_UNAVAILABLE FAIL: %s" % label)


func _run() -> void:
	var original := FileAccess.get_file_as_bytes(MANIFEST_PATH)
	var corrupt_file := FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	if corrupt_file == null:
		print("M33_UNAVAILABLE_RESULT=FAIL could_not_open_sandbox_manifest")
		quit(1)
		return
	corrupt_file.store_string("{\"schema_version\":999}")
	corrupt_file.close()
	var navigation = NAVIGATION_SCRIPT.new()
	get_root().add_child(navigation)
	await process_frame
	_check("invalid content is rejected before campaign save manager creation", not navigation.get_content_load_error().is_empty() and navigation.save_manager == null and navigation.campaign_manager == null and navigation.level_database == null)
	_check("invalid content does not enable campaign persistence or gameplay", not navigation._persistence_enabled and navigation.get_gameplay_instance_count() == 0)
	var shell = APP_SHELL_SCENE.instantiate()
	get_root().add_child(shell)
	await process_frame
	var controls: Dictionary = shell.get_menu_controls()
	_check("player sees content unavailable and cannot enter Play or World Map", controls.get("play") != null and controls["play"].disabled and controls.get("world_map") != null and controls["world_map"].disabled and shell._home_value_labels.get("continue").text == "CONTENT UNAVAILABLE")
	var restore := FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	if restore != null:
		restore.store_buffer(original)
		restore.close()
	navigation.queue_free()
	shell.queue_free()
	await process_frame
	if failures.is_empty():
		print("M33_UNAVAILABLE_RESULT=PASS")
		quit(0)
	else:
		print("M33_UNAVAILABLE_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
