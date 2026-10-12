extends SceneTree

const APPLICATION_SHELL_SCRIPT := preload("res://scripts/campaign/application_shell.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/evidence/M32-004-tutorial"
const PHONE_SIZES := [Vector2i(390, 844), Vector2i(432, 960)]

var failures: Array[String] = []
var shell


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M32_TUTORIAL_MOBILE PASS: %s" % label)
	else:
		failures.append(label)
		print("M32_TUTORIAL_MOBILE FAIL: %s" % label)


func _frames(count: int = 4) -> void:
	for _index in range(count):
		await process_frame


func _set_size(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_root().size = size
	get_root().get_window().content_scale_size = size
	DisplayServer.window_set_size(size)
	await _frames(8)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	shell = APPLICATION_SHELL_SCRIPT.new()
	root.add_child(shell)
	await _frames()
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	_check("campaign application shell is available for phone layout capture", is_instance_valid(shell))
	shell._replay_gameplay_tutorial()
	await _frames(8)
	var gameplay = shell.campaign_navigation.get_node_or_null("CampaignGameplay")
	var tutorial = gameplay.get("gameplay_tutorial") if is_instance_valid(gameplay) else null
	_check("real gameplay tutorial is visible in the campaign shell", is_instance_valid(tutorial) and tutorial.visible)
	if not is_instance_valid(tutorial):
		quit(1)
		return
	tutorial.set_presentation_state({"reduced_motion": true, "high_contrast": true})
	for size in PHONE_SIZES:
		await _set_size(size)
		var prompt := tutorial.get_node("TutorialOverlay/TutorialPrompt") as Control
		var prompt_rect := prompt.get_global_rect()
		var viewport_rect := Rect2(Vector2.ZERO, Vector2(size))
		_check("prompt is fully inside %dx%d portrait viewport" % [size.x, size.y], viewport_rect.encloses(prompt_rect))
		var image := get_root().get_viewport().get_texture().get_image()
		var path := "%s/tutorial_portrait_%dx%d.png" % [EVIDENCE_DIR, size.x, size.y]
		var saved: bool = not image.is_empty() and image.get_size() == size and image.save_png(ProjectSettings.globalize_path(path)) == OK
		_check("real in-game tutorial frame captured at %dx%d" % [size.x, size.y], saved)
		var report_path := ProjectSettings.globalize_path("%s/tutorial_mobile_capture.json" % EVIDENCE_DIR)
		var report := {"result": "PASS" if failures.is_empty() else "PARTIAL", "renderer": DisplayServer.get_name(), "reduced_motion": true, "high_contrast": true, "tutorial_visible": tutorial.visible, "captures": []}
		for captured_size in PHONE_SIZES:
			report.captures.append({"width": captured_size.x, "height": captured_size.y, "path": "%s/tutorial_portrait_%dx%d.png" % [EVIDENCE_DIR, captured_size.x, captured_size.y]})
		var file := FileAccess.open(report_path, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(report, "  "))
		_check("capture evidence report is writable", file != null)
	shell.queue_free()
	await _frames()
	if failures.is_empty():
		print("M32_TUTORIAL_MOBILE_RESULT=PASS")
		quit(0)
	else:
		print("M32_TUTORIAL_MOBILE_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
