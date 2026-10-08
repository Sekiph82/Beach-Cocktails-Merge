extends Node

const MAIN_SCENE := preload("res://scenes/main.tscn")
const OUTPUT_DIR := "res://coordination/sessions/BCM-M23-MASTER-V01/evidence/M23-R03/real_renderer"
const REPORT_PATH := OUTPUT_DIR + "/capture_manifest.json"

var manager: GameManager
var bridge: PresentationFeedbackBridge
var service: FeedbackService
var captures: Array[Dictionary] = []
var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	manager = MAIN_SCENE.instantiate() as GameManager
	add_child(manager)
	await _settle_frames(3)
	bridge = manager.presentation_feedback_bridge
	service = manager.feedback_service
	bridge.set_presentation_mode("FULL")
	bridge.set_production_dispatch_enabled(true)
	var sizes := [Vector2i(720, 1280), Vector2i(800, 1422)]
	for size in sizes:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().content_scale_size = size
		DisplayServer.window_set_size(size)
		await _settle_frames(6)
		await _capture_profile("full", size)
	bridge.set_presentation_mode("REDUCED")
	await _settle_frames(2)
	await _capture_reduced()
	var result := {
		"probe": "BCM-M23-R03-real-renderer-capture",
		"renderer": "Godot running project framebuffer (not headless)",
		"requested_window_sizes": [[720, 1280], [800, 1422]],
		"captures": captures,
		"color_lifecycle": bridge.get_color_lifecycle_diagnostics(),
		"all_recorded_color_restorations_exact": _all_restorations_exact(),
		"failures": failures,
		"owner_visual_acceptance": "PENDING_OWNER_F5",
		"headless_capture_count": 0,
	}
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		failures.append("capture manifest could not be written")
	else:
		file.store_string(JSON.stringify(result, "\t") + "\n")
		file.close()
	print("M23_R03_REAL_RENDERER_CAPTURE_RESULT=%s captures=%d failures=%d" % ["PASS" if failures.is_empty() else "FAIL", captures.size(), failures.size()])
	for failure in failures:
		push_error(failure)
	bridge.cancel_presentation()
	get_tree().quit(0 if failures.is_empty() else 1)


func _capture_profile(mode_name: String, size: Vector2i) -> void:
	var prefix := "%s_%dx%d" % [mode_name, size.x, size.y]
	var launch: Drink = manager.shot_controller._current_drink if manager.shot_controller != null else null
	if not is_instance_valid(launch):
		failures.append("current drink missing for launch capture %s" % prefix)
		return
	service.emit_cocktail_launch(launch.level, launch.global_position, Vector2(0.0, -700.0), launch)
	await _settle_frames(2)
	_capture("%s_launch_event" % prefix)
	await _settle_seconds(0.22)
	_capture("%s_launch_settled" % prefix)

	var contact_target := _new_visual_target(Vector2(size.x * 0.5, size.y * 0.57))
	service.emit_table_contact({"source_level": 2, "contact_type": "rail", "contact_level": 0, "position": contact_target.global_position, "source_instance": "r03-%s-contact" % prefix, "presentation_target": contact_target.get_node("Visual")})
	await _settle_frames(2)
	_capture("%s_contact_event" % prefix)
	await _settle_seconds(0.24)
	_capture("%s_contact_settled" % prefix)
	contact_target.queue_free()
	await _settle_frames(2)

	for band in [{"name": "base", "chain": 1}, {"name": "surge", "chain": 3}, {"name": "peak", "chain": 5}]:
		var source := _new_visual_target(Vector2(size.x * 0.5, size.y * 0.54))
		service.emit_merge(source, {"level": 4, "chain": int(band.chain), "score": 0, "presentation_target": source.get_node("Visual")})
		await _settle_frames(2)
		_capture("%s_merge_%s_event" % [prefix, band.name])
		await _settle_seconds(0.42)
		_capture("%s_merge_%s_settled" % [prefix, band.name])
		source.queue_free()
		await _settle_frames(2)

	var score_target: CanvasItem = manager._score_value
	service.request_semantic("score_mastery", {"milestone": "three_stars", "threshold": 250, "score": 251, "presentation_target": score_target}, "r03-score-%s" % prefix, {"source": "renderer_probe"})
	await _settle_frames(2)
	_capture("%s_score_event" % prefix)
	await _settle_seconds(0.45)
	_capture("%s_score_settled" % prefix)
	var score_lifecycle := bridge.get_color_lifecycle_diagnostics()
	var last_score_record: Dictionary = score_lifecycle.back() if not score_lifecycle.is_empty() else {}
	if not bool(last_score_record.get("restored_exactly", false)):
		failures.append("score lifecycle exact restoration not recorded for %s" % prefix)


func _capture_reduced() -> void:
	var size := get_viewport().get_visible_rect().size
	var target := _new_visual_target(Vector2(size.x * 0.5, size.y * 0.55))
	service.emit_table_contact({"source_level": 2, "contact_type": "rail", "contact_level": 0, "position": target.global_position, "source_instance": "r03-reduced-contact", "presentation_target": target.get_node("Visual")})
	await _settle_frames(2)
	_capture("reduced_contact_event")
	await _settle_seconds(0.20)
	_capture("reduced_contact_settled")
	target.queue_free()
	await _settle_frames(2)
	var source := _new_visual_target(Vector2(size.x * 0.5, size.y * 0.53))
	service.emit_merge(source, {"level": 4, "chain": 5, "score": 0, "presentation_target": source.get_node("Visual")})
	await _settle_frames(2)
	_capture("reduced_merge_event")
	await _settle_seconds(0.20)
	_capture("reduced_merge_settled")
	source.queue_free()


func _new_visual_target(position: Vector2) -> Node2D:
	var drink := manager.spawn_drink(4, position, false)
	if not is_instance_valid(drink):
		failures.append("fixture drink could not be spawned at %s" % str(position))
		return Node2D.new()
	drink.linear_velocity = Vector2.ZERO
	drink.freeze = true
	return drink


func _capture(label: String) -> void:
	var image := get_viewport().get_texture().get_image()
	if image == null:
		failures.append("renderer framebuffer unavailable for %s" % label)
		return
	var path := "%s/%s.png" % [OUTPUT_DIR, label]
	var error := image.save_png(path)
	if error != OK:
		failures.append("PNG save failed for %s: %s" % [label, error])
		return
	captures.append({"label": label, "path": path, "width": image.get_width(), "height": image.get_height(), "window_size": DisplayServer.window_get_size(), "frame": Engine.get_frames_drawn(), "renderer": "running_project_viewport"})
	print("M23_R03_CAPTURE label=%s path=%s size=%dx%d frame=%d" % [label, path, image.get_width(), image.get_height(), Engine.get_frames_drawn()])


func _all_restorations_exact() -> bool:
	for record in bridge.get_color_lifecycle_diagnostics():
		if str(record.get("operation", "")) == "restored" and not bool(record.get("restored_exactly", false)):
			return false
	return true


func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _settle_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout
