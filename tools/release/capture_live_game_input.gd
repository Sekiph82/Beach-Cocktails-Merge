extends Node

const CAPTURE_DIRECTORY := "res://docs/release/store_media/captures_v03"
const CAPTURE_CLASSIFICATION := "DESKTOP_GAMEPLAY_CANDIDATE"

var _application: Node
var _capture_index := 0


func configure(application: Node) -> void:
	_application = application


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F12:
		get_viewport().set_input_as_handled()
		call_deferred("_capture_current_production_frame")


func _capture_current_production_frame() -> void:
	await get_tree().process_frame
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		printerr("BCM_LIVE_CAPTURE_FAIL=VIEWPORT_TEXTURE_UNAVAILABLE")
		return
	var image := viewport_texture.get_image()
	if image == null or image.is_empty():
		printerr("BCM_LIVE_CAPTURE_FAIL=VIEWPORT_IMAGE_UNAVAILABLE")
		return
	_capture_index += 1
	var view_name := "unknown"
	if is_instance_valid(_application) and _application.has_method("get_current_view"):
		view_name = str(_application.get_current_view()).to_lower().strip_edges().replace(" ", "_")
	var stem := "desktop_candidate_%02d_%s" % [_capture_index, view_name]
	var png_path := "%s/%s.png" % [CAPTURE_DIRECTORY, stem]
	var absolute_directory := ProjectSettings.globalize_path(CAPTURE_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		printerr("BCM_LIVE_CAPTURE_FAIL=OUTPUT_DIRECTORY:%s" % error_string(directory_error))
		return
	var save_error := image.save_png(png_path)
	if save_error != OK:
		printerr("BCM_LIVE_CAPTURE_FAIL=PNG_SAVE:%s" % error_string(save_error))
		return
	var metadata := {
		"classification": CAPTURE_CLASSIFICATION,
		"device_review_status": "DEVICE_REVIEW_PENDING",
		"capture_source": "Production ApplicationShellScene; real visible UI; captured after a real F12 keypress",
		"source_scene": "res://scenes/campaign/ApplicationShellScene.tscn",
		"runtime_view": view_name,
		"runtime_version": Engine.get_version_info().get("string", "unknown"),
		"source_head": OS.get_environment("BCM_GAME_SOURCE_HEAD"),
		"resolution": {"width": image.get_width(), "height": image.get_height()},
		"format": "PNG",
		"captured_at_local": Time.get_datetime_string_from_system(true, true),
		"path": png_path,
	}
	var metadata_path := "%s/%s.json" % [CAPTURE_DIRECTORY, stem]
	var metadata_file := FileAccess.open(metadata_path, FileAccess.WRITE)
	if metadata_file == null:
		printerr("BCM_LIVE_CAPTURE_FAIL=METADATA_OPEN:%s" % error_string(FileAccess.get_open_error()))
		return
	metadata_file.store_string(JSON.stringify(metadata, "  ") + "\n")
	metadata_file.close()
	print("BCM_LIVE_CAPTURE_OK path=%s view=%s size=%dx%d" % [png_path, view_name, image.get_width(), image.get_height()])
