extends SceneTree

## BCM-M20-002 focused probe for the production shell onboarding boundary.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CHILD_02_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CHILD_02_PROBE FAIL: %s" % label)


func _mount(storage_path: String):
    var shell = SHELL_SCENE.instantiate()
    shell.onboarding_storage_path = storage_path
    root.add_child(shell)
    await process_frame
    await process_frame
    return shell


func _run() -> void:
    var suffix := str(Time.get_unix_time_from_system())
    var skip_path := "user://m20_onboarding_skip_%s.json" % suffix
    var complete_path := "user://m20_onboarding_complete_%s.json" % suffix

    var first = await _mount(skip_path)
    _check("true first run shows onboarding", first.is_onboarding_visible())
    _check("onboarding has five required concept pages", first.get_onboarding_page_count() == 5)
    var page_text := ""
    for page_index in range(first.get_onboarding_page_count()):
        page_text += " " + str(first.get_node("FirstRunOnboarding/OnboardingTitle").text)
        page_text += " " + str(first.get_node("FirstRunOnboarding/OnboardingBody").text)
        if page_index < first.get_onboarding_page_count() - 1:
            first.next_onboarding_page()
            await process_frame
    _check("pages cover World Map, Island Map, timed To-Go, optional VIP, and completion/replay", page_text.contains("World Map") and page_text.contains("Island Map") and page_text.contains("To-Go") and page_text.contains("VIP") and page_text.contains("REPLAY"))

    first.reset_onboarding_state()
    await process_frame
    var campaign_before: Dictionary = first.get_campaign_navigation().campaign_manager.get_progression_state().duplicate(true)
    _check("reset is an explicit onboarding-only QA path", first.is_onboarding_visible() and first.get_campaign_navigation().campaign_manager.get_progression_state() == campaign_before)
    _check("skip is available and returns to menu", first.skip_onboarding() and first.is_main_menu_visible())
    _check("skip persists in the onboarding store", bool(first.get_onboarding_state().get("completed", false)))
    first.queue_free()
    await process_frame

    var returning = await _mount(skip_path)
    _check("returning user is not forced through onboarding", not returning.is_onboarding_visible() and returning.is_main_menu_visible())
    _check("campaign progression remains unchanged after restart", returning.get_campaign_navigation().campaign_manager.get_progression_state() == campaign_before)
    returning.queue_free()
    await process_frame

    var completing = await _mount(complete_path)
    _check("second fresh storage shows onboarding independently", completing.is_onboarding_visible())
    for _page_index in range(completing.get_onboarding_page_count()):
        completing.next_onboarding_page()
        await process_frame
    _check("completion persists separately from skip", not completing.is_onboarding_visible() and completing.is_main_menu_visible() and bool(completing.get_onboarding_state().get("completed", false)))
    _check("completion does not create a campaign progression delta", completing.get_campaign_navigation().campaign_manager.get_progression_state() == campaign_before)
    completing.queue_free()
    await process_frame

    if failures.is_empty():
        print("M20_CHILD_02_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_02_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
