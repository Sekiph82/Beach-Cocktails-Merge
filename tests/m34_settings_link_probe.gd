extends "res://tests/support/isolated_test_scene_tree.gd"

const BCM_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")
const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const LINKS_SCRIPT := preload("res://scripts/campaign/settings_link_config.gd")

var failures: Array[String] = []


func _init() -> void:
	if not BCM_SANDBOX_GUARD.enforce(self):
		return
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_SETTINGS_LINK_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_SETTINGS_LINK_PROBE FAIL: %s" % label)


func _write_json(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))


func _run() -> void:
	var default_links: Dictionary = LINKS_SCRIPT.load_from_path()
	_check("default policy and support URLs are empty", default_links == {"privacy_policy_url": "", "support_url": ""})
	_check("valid reserved HTTPS domain accepted", LINKS_SCRIPT.is_public_https_url("https://support.example.invalid/contact"))
	_check("HTTP rejected", not LINKS_SCRIPT.is_public_https_url("http://support.example.invalid"))
	_check("credentials rejected", not LINKS_SCRIPT.is_public_https_url("https://user@support.example.invalid"))
	_check("loopback rejected", not LINKS_SCRIPT.is_public_https_url("https://localhost/privacy"))
	_check("single-label host rejected", not LINKS_SCRIPT.is_public_https_url("https://intranet/privacy"))
	_check("invalid port rejected", not LINKS_SCRIPT.is_public_https_url("https://support.example.invalid:65536"))

	var settings_path := "user://m34_settings_links_%d.json" % Time.get_ticks_usec()
	_write_json(settings_path, {"schema_version": 1, "privacy_policy_url": "", "support_url": "https://support.example.invalid/contact"})
	var shell = SHELL_SCENE.instantiate()
	shell.settings_links_config_path = settings_path
	shell.onboarding_storage_path = "user://m34_onboarding_%d.json" % Time.get_ticks_usec()
	root.add_child(shell)
	await process_frame
	await process_frame
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
		await process_frame

	_check("Privacy and Support entries exist in Settings", shell._settings_layer.has_node("PrivacyPolicyButton") and shell._settings_layer.has_node("SupportLinkButton"))
	_check("unconfigured privacy entry remains disabled", shell._privacy_policy_button.disabled and shell._privacy_policy_button.text.contains("NOT CONFIGURED"))
	_check("validated support URL enables its entry", not shell._support_button.disabled and shell._support_button.text == "SUPPORT")
	_check("settings route remains reachable", shell.show_settings() and shell.get_current_view() == "SETTINGS")
	var privacy_rect := Rect2(shell._privacy_policy_button.position, shell._privacy_policy_button.size)
	var support_rect := Rect2(shell._support_button.position, shell._support_button.size)
	var replay_button: Button = shell._settings_layer.get_node("ReplayGameplayTutorialButton")
	var replay_rect := Rect2(replay_button.position, replay_button.size)
	var column: VBoxContainer = shell._settings_layer.get_node("SettingsColumn")
	var last_control: Control = column.get_child(column.get_child_count() - 1)
	var settings_controls_end_y := last_control.get_global_rect().end.y
	print("M34_SETTINGS_LINK_LAYOUT privacy=%s support=%s replay=%s viewport=%s" % [str(privacy_rect), str(support_rect), str(replay_rect), str(shell.get_viewport_rect())])
	_check("link entries fit mobile shell and avoid settings and tutorial controls", privacy_rect.end.y <= 1280.0 and support_rect.end.y <= 1280.0 and settings_controls_end_y <= privacy_rect.position.y and not privacy_rect.intersects(support_rect) and not support_rect.intersects(replay_rect))
	var opened: Array[String] = []
	shell.set_settings_link_opener_for_testing(func(url: String) -> void: opened.append(url))
	shell._privacy_policy_button.pressed.emit()
	shell._support_button.pressed.emit()
	_check("unconfigured URL cannot launch and support routes through injected opener", opened == ["https://support.example.invalid/contact"])
	shell.queue_free()
	await process_frame

	var invalid_path := "user://m34_settings_links_invalid_%d.json" % Time.get_ticks_usec()
	_write_json(invalid_path, {"schema_version": 1, "privacy_policy_url": "https://good.example.invalid", "support_url": "javascript:alert(1)"})
	_check("invalid config fails closed as an empty pair", LINKS_SCRIPT.load_from_path(invalid_path) == {"privacy_policy_url": "", "support_url": ""})

	if failures.is_empty():
		print("M34_SETTINGS_LINK_PROBE_RESULT=PASS")
		quit(0)
		return
	printerr("M34_SETTINGS_LINK_PROBE_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
