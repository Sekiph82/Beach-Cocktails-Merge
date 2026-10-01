extends SceneTree

## BCM-M20-003 focused probe for the independent user-settings boundary.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const FEEDBACK_SCRIPT := preload("res://scripts/feedback_service.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CHILD_03_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CHILD_03_PROBE FAIL: %s" % label)


func _mount(settings_path: String):
    var shell = SHELL_SCENE.instantiate()
    shell.settings_storage_path = settings_path
    shell.onboarding_storage_path = "user://m20_settings_onboarding_%s.json" % str(Time.get_unix_time_from_system())
    root.add_child(shell)
    await process_frame
    await process_frame
    if shell.is_onboarding_visible():
        shell.skip_onboarding()
        await process_frame
    return shell


func _run() -> void:
    var suffix := str(Time.get_unix_time_from_system())
    var settings_path := "user://m20_settings_%s.json" % suffix
    var shell = await _mount(settings_path)
    var store = shell.get_user_settings()
    var campaign_before: Dictionary = shell.get_campaign_navigation().campaign_manager.get_progression_state().duplicate(true)

    _check("settings UI is a separate app-shell surface", shell.show_settings() and shell.is_settings_visible() and shell.get_current_view() == "SETTINGS")
    _check("all minimum settings have controls", shell._settings_controls.has_all(["master_volume", "master_muted", "music_volume", "music_muted", "sfx_volume", "sfx_muted", "haptics_enabled", "reduced_motion", "high_contrast"]))
    _check("safe defaults are loaded", is_equal_approx(float(store.get_value("master_volume")), 1.0) and bool(store.get_value("haptics_enabled")) and not bool(store.get_value("reduced_motion")))

    shell.set_setting("master_volume", 0.35)
    shell.set_setting("master_muted", true)
    shell.set_setting("music_volume", 0.20)
    shell.set_setting("music_muted", true)
    shell.set_setting("sfx_volume", 0.70)
    shell.set_setting("sfx_muted", false)
    shell.set_setting("haptics_enabled", false)
    shell.set_setting("reduced_motion", true)
    shell.set_setting("high_contrast", true)
    _check("all settings persist in their own schema", is_equal_approx(float(store.get_value("master_volume")), 0.35) and bool(store.get_value("master_muted")) and bool(store.get_value("music_muted")) and is_equal_approx(float(store.get_value("sfx_volume")), 0.70) and not store.can_emit_haptics())
    _check("presentation state exposes accessibility values", store.get_presentation_state() == {"reduced_motion": true, "high_contrast": true, "haptics_enabled": false})
    _check("missing audio buses degrade safely", store.apply_audio().has_all(["Master", "Music", "SFX"]))
    _check("campaign save state is untouched by preferences", shell.get_campaign_navigation().campaign_manager.get_progression_state() == campaign_before)
    _check("settings close returns to Main Menu", shell.close_settings() and shell.is_main_menu_visible())
    shell.queue_free()
    await process_frame

    var returning = await _mount(settings_path)
    var reloaded = returning.get_user_settings()
    _check("settings persist across shell restart", is_equal_approx(float(reloaded.get_value("master_volume")), 0.35) and bool(reloaded.get_value("master_muted")) and bool(reloaded.get_value("high_contrast")) and not bool(reloaded.get_value("haptics_enabled")))
    returning.queue_free()
    await process_frame

    var corrupt_path := "user://m20_settings_corrupt_%s.json" % suffix
    var corrupt_file := FileAccess.open(corrupt_path, FileAccess.WRITE)
    corrupt_file.store_string("not-json")
    corrupt_file = null
    var corrupt = await _mount(corrupt_path)
    _check("corrupt settings fall back to safe defaults", is_equal_approx(float(corrupt.get_user_settings().get_value("master_volume")), 1.0) and not bool(corrupt.get_user_settings().get_value("master_muted")) and bool(corrupt.get_user_settings().get_value("haptics_enabled")))
    corrupt.queue_free()
    await process_frame

    var feedback := FEEDBACK_SCRIPT.new()
    root.add_child(feedback)
    feedback.set_haptics_supported_for_testing(true)
    feedback.set_haptics_enabled(false)
    var before_haptics := feedback.haptic_call_count
    feedback.emit_ui_tap()
    _check("haptic feedback remains setting-gated", feedback.haptic_call_count == before_haptics)
    feedback.queue_free()
    await process_frame

    if failures.is_empty():
        print("M20_CHILD_03_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_03_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
