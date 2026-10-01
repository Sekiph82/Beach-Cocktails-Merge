extends SceneTree

## BCM-M20-004 focused probe. It uses the production shell, router, gameplay
## scene, and existing GameplaySessionBridge timer authority.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CHILD_04_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CHILD_04_PROBE FAIL: %s" % label)


func _run() -> void:
    var shell = SHELL_SCENE.instantiate()
    shell.onboarding_storage_path = "user://m20_pause_onboarding_%s.json" % str(Time.get_unix_time_from_system())
    root.add_child(shell)
    await process_frame
    await process_frame
    if shell.is_onboarding_visible():
        shell.skip_onboarding()
        await process_frame

    var navigation = shell.get_campaign_navigation()
    _check("PLAY/CONTINUE opens campaign router", shell.press_play_continue())
    _check("World Map opens Sunny Cove", navigation.show_island_map("sunny_cove"))
    await process_frame
    await process_frame
    var island_map = navigation.get_island_map()
    _check("Island Map selects an unlocked level", island_map.select_level(1))
    await process_frame
    await process_frame
    var gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
    var bridge = navigation.get_session_bridge()
    _check("production gameplay exposes one session", gameplay != null and navigation.get_gameplay_instance_count() == 1 and bridge.is_session_active())
    _check("visible pause control exists", gameplay != null and gameplay._pause_button != null and gameplay._pause_button.visible)

    var manual_time: float = bridge.timer_remaining_sec
    _check("manual pause freezes the session", gameplay.request_pause() and bridge.session_state == bridge.STATE_PAUSED and gameplay.get_pause_overlay_visible())
    bridge.tick(4.0)
    _check("manual pause freezes the authoritative timer", is_equal_approx(bridge.timer_remaining_sec, manual_time))
    gameplay.handle_application_backgrounded()
    gameplay.handle_application_resumed()
    _check("manual pause survives background/resume", bridge.session_state == bridge.STATE_PAUSED and gameplay.get_pause_overlay_visible())
    _check("Resume action returns to active session", gameplay.resume_campaign_gameplay() and bridge.session_state == bridge.STATE_ACTIVE and not gameplay.get_pause_overlay_visible())

    var background_time: float = bridge.timer_remaining_sec
    _check("active session can enter background pause", gameplay.handle_application_backgrounded() and bridge.session_state == bridge.STATE_PAUSED)
    bridge.tick(4.0)
    _check("background pause freezes the authoritative timer", is_equal_approx(bridge.timer_remaining_sec, background_time))
    _check("background resume auto-resumes only background pause", gameplay.handle_application_resumed() and bridge.session_state == bridge.STATE_ACTIVE)
    var resumed_time: float = bridge.timer_remaining_sec
    bridge.tick(0.25)
    _check("background resume allows timer progress", bridge.timer_remaining_sec < resumed_time)

    bridge.resolve_lose("M20_TEST_TERMINAL")
    _check("terminal result hides pause overlay", bridge.is_terminal() and not gameplay.get_pause_overlay_visible() and not gameplay.resume_campaign_gameplay())
    _check("terminal session cannot be resumed", bridge.session_state == bridge.STATE_TERMINAL)

    _check("retry creates one fresh gameplay instance", navigation.retry_level() and navigation.get_gameplay_instance_count() <= 1)
    for _frame in range(4):
        await process_frame
    gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
    bridge = navigation.get_session_bridge()
    _check("retry remains the same campaign level", gameplay != null and bridge.active_level_id == 1 and bridge.is_session_active())
    var completion_before_map: bool = navigation.campaign_manager.is_level_completed("sunny_cove", 1)
    gameplay.request_pause()
    _check("Island Map action leaves through bridge boundary", gameplay.request_island_map())
    await process_frame
    await process_frame
    _check("pause-to-map does not grant progression or duplicate instances", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0 and navigation.campaign_manager.is_level_completed("sunny_cove", 1) == completion_before_map)
    _check("map/session authority remains singular", navigation.get_map_instance_count() == 2)

    shell.queue_free()
    await process_frame
    if failures.is_empty():
        print("M20_CHILD_04_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_04_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
