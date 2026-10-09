extends SceneTree

## BCM-M21-005 production-path persistence smoke.
## This probe uses the configured ApplicationShell and default campaign save
## authority, with unique onboarding/settings paths. The caller isolates the
## Godot user-data root outside the repository.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M21_RELEASE_PERSISTENCE PASS: %s" % label)
    else:
        failures.append(label)
        print("M21_RELEASE_PERSISTENCE FAIL: %s" % label)


func _mount(onboarding_path: String, settings_path: String):
    var shell = SHELL_SCENE.instantiate()
    shell.onboarding_storage_path = onboarding_path
    shell.settings_storage_path = settings_path
    root.add_child(shell)
    await process_frame
    await process_frame
    return shell


func _run() -> void:
    var suffix := str(Time.get_ticks_usec())
    var onboarding_path := "user://m21_release_onboarding_%s.json" % suffix
    var settings_path := "user://m21_release_settings_%s.json" % suffix
    var shell = await _mount(onboarding_path, settings_path)
    _check("configured production shell is the active scene", str(ProjectSettings.get_setting("application/run/main_scene", "")) == "res://scenes/campaign/ApplicationShellScene.tscn")
    _check("fresh production shell shows onboarding", shell.is_onboarding_visible())
    _check("debug progression bypass is not exposed by shell controls", not shell.get_menu_controls().has("debug_progression_bypass"))
    _check("onboarding dismissal writes production-path state", shell.skip_onboarding() and FileAccess.file_exists(onboarding_path))

    shell.set_setting("reduced_motion", true)
    shell.set_setting("high_contrast", true)
    shell.set_setting("haptics_enabled", false)
    _check("settings write through the production shell", FileAccess.file_exists(settings_path) and shell.get_presentation_state() == {"reduced_motion": true, "high_contrast": true, "haptics_enabled": false})

    var navigation = shell.get_campaign_navigation()
    var campaign = navigation.campaign_manager
    var completion: Dictionary = campaign.mark_level_completed("sunny_cove", 1, {"stars": 3, "score": 987})
    await process_frame
    var save = SAVE_SCRIPT.new()
    var campaign_save_path := ProjectSettings.globalize_path("user://campaign_save.json")
    var stored := save.read_state()
    _check("campaign completion uses production save authority", completion.get("ok", false) and completion.get("record", {}).get("stars", 0) == 3 and FileAccess.file_exists(campaign_save_path) and stored.get("state", {}).get("islands", {}).get("sunny_cove", {}).get("completed_levels", {}).get("1", {}).get("best_score", 0) == 987)
    shell.queue_free()
    await process_frame

    var returning = await _mount(onboarding_path, settings_path)
    var returning_campaign = returning.get_campaign_navigation().campaign_manager
    var returning_record: Dictionary = returning_campaign.get_progression_state().get("islands", {}).get("sunny_cove", {}).get("completed_levels", {}).get("1", {})
    _check("onboarding persists across production shell restart", not returning.is_onboarding_visible() and returning.is_main_menu_visible())
    _check("settings persist across production shell restart", returning.get_presentation_state() == {"reduced_motion": true, "high_contrast": true, "haptics_enabled": false})
    _check("campaign completion persists across production shell restart", bool(returning_record.get("completed", false)) and int(returning_record.get("stars", 0)) == 3 and int(returning_record.get("best_score", 0)) == 987)
    returning.queue_free()
    await process_frame

    if failures.is_empty():
        print("M21_RELEASE_PERSISTENCE_RESULT=PASS")
        quit(0)
        return
    print("M21_RELEASE_PERSISTENCE_RESULT=FAIL failures=%s" % str(failures))
    quit(1)

