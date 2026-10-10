extends SceneTree

## Production-path M20 capture evidence at the canonical 720x1280 viewport.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-003/M20"

var failures: Array[String] = []
var _capture_index := 0


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CAPTURE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CAPTURE FAIL: %s" % label)


func _frame(count: int = 2) -> void:
    for _index in range(count):
        await process_frame


func _capture(name: String) -> void:
    _capture_index += 1
    var texture := root.get_viewport().get_texture()
    if texture == null:
        failures.append("capture texture unavailable: %s" % name)
        return
    var image := texture.get_image()
    if image == null:
        failures.append("capture image unavailable: %s" % name)
        return
    var path := "%s/%02d_%s.png" % [CAPTURE_DIR, _capture_index, name]
    var error := image.save_png(path)
    print("M20_CAPTURE name=%s path=%s dimensions=%dx%d error=%s" % [name, path, image.get_width(), image.get_height(), error])
    if error != OK or image.get_width() != 720 or image.get_height() != 1280:
        failures.append("capture dimensions or save failed: %s" % name)


func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
    var shell = SHELL_SCENE.instantiate()
    shell.onboarding_storage_path = "user://m20_capture_onboarding_%s.json" % str(Time.get_unix_time_from_system())
    root.add_child(shell)
    await _frame(3)
    _check("production first-run onboarding is visible", shell.is_onboarding_visible())
    _capture("onboarding")

    shell.skip_onboarding()
    await _frame()
    _check("production Main Menu is visible", shell.is_main_menu_visible())
    _capture("main_menu")

    _check("production Settings surface opens", shell.show_settings() and shell.is_settings_visible())
    await _frame()
    _capture("settings")
    shell.close_settings()
    await _frame()

    var navigation = shell.get_campaign_navigation()
    shell.press_play_continue()
    await _frame(3)
    var world = navigation.get_world_map()
    _check("production World Map rejects and presents locked island", not world.select_island("tiki_island") and world.get_feedback_overlay().visible)
    await _frame()
    _capture("locked_feedback")
    world.get_feedback_overlay().trigger_action("DISMISS")
    world.select_island("sunny_cove")
    await _frame(3)

    var island_map = navigation.get_island_map()
    _check("production level selection enters gameplay", island_map.select_level(1))
    await _frame(4)
    var gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
    _check("production pause overlay opens", gameplay != null and gameplay.request_pause() and gameplay.get_pause_overlay_visible())
    await _frame()
    _capture("pause")
    gameplay.resume_campaign_gameplay()
    navigation.get_session_bridge().resolve_lose("M20_CAPTURE_LOSE")
    await _frame(3)
    _check("production LOSE result overlay opens", navigation.get_result_feedback_overlay().visible and navigation.get_result_feedback_overlay().get_feedback_kind() == "RESULT_LOSE")
    _capture("lose_result")

    navigation.retry_level()
    await _frame(4)
    var bridge = navigation.get_session_bridge()
    var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
    var delivery_index := 0
    for level in remaining:
        var quantity := int(remaining[level])
        if quantity > 0:
            delivery_index += 1
            bridge.record_to_go_delivery(int(level), quantity, "m20-capture-win-%d" % delivery_index, 444)
    await _frame(3)
    _check("production WIN result overlay opens", navigation.get_result_feedback_overlay().visible and navigation.get_result_feedback_overlay().get_feedback_kind() == "RESULT_WIN")
    _capture("win_result")

    if failures.is_empty():
        print("M20_RUNTIME_CAPTURE_RESULT=PASS captures=%d" % _capture_index)
        quit(0)
        return
    print("M20_RUNTIME_CAPTURE_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
