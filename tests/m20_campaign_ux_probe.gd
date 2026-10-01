extends SceneTree

## BCM-M20-005 focused production UX probe. It exercises the reusable feedback
## surface through World Map, Island Map, and GameplaySessionBridge results.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const FEEDBACK_SCRIPT := preload("res://scripts/campaign/campaign_feedback_overlay.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CHILD_05_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CHILD_05_PROBE FAIL: %s" % label)


func _run() -> void:
    var shell = SHELL_SCENE.instantiate()
    shell.onboarding_storage_path = "user://m20_ux_onboarding_%s.json" % str(Time.get_unix_time_from_system())
    root.add_child(shell)
    await process_frame
    await process_frame
    if shell.is_onboarding_visible():
        shell.skip_onboarding()
        await process_frame
    var navigation = shell.get_campaign_navigation()
    shell.press_play_continue()
    await process_frame
    await process_frame
    var world = navigation.get_world_map()
    _check("locked island selection is rejected", not world.select_island("tiki_island"))
    _check("locked island feedback is reusable and visible", world.get_feedback_overlay().visible and world.get_feedback_overlay().get_feedback_kind() == "LOCKED_ISLAND")
    _check("locked island feedback explains the authoritative requirement", world.get_feedback_overlay().get_body_text().contains("Sunny Cove"))
    _check("locked island feedback can be dismissed", world.get_feedback_overlay().trigger_action("DISMISS") and not world.get_feedback_overlay().visible)

    _check("Sunny Cove opens from the World Map", world.select_island("sunny_cove"))
    await process_frame
    await process_frame
    var island_map = navigation.get_island_map()
    _check("locked level selection is rejected", not island_map.select_level(100))
    _check("locked level feedback is reusable and visible", island_map.get_feedback_overlay().visible and island_map.get_feedback_overlay().get_feedback_kind() == "LOCKED_LEVEL")
    _check("locked level feedback can be dismissed", island_map.get_feedback_overlay().trigger_action("DISMISS") and not island_map.get_feedback_overlay().visible)

    _check("level 1 enters production gameplay", island_map.select_level(1))
    await process_frame
    await process_frame
    var bridge = navigation.get_session_bridge()
    bridge.resolve_lose("M20_UX_LOSE")
    await process_frame
    var result_overlay = navigation.get_result_feedback_overlay()
    _check("LOSE result uses one reusable overlay", result_overlay.visible and result_overlay.get_feedback_kind() == "RESULT_LOSE" and result_overlay.get_visible_actions() == ["RETRY", "ISLAND_MAP"])
    _check("LOSE exposes only Retry and Island Map", result_overlay.get_title_text() == "LEVEL FAILED" and result_overlay.get_body_text().contains("Level 1"))
    _check("Retry action re-enters one production gameplay session", result_overlay.trigger_action("RETRY"))
    for _frame in range(4):
        await process_frame
    bridge = navigation.get_session_bridge()
    _check("retry session is active and singular", navigation.get_gameplay_instance_count() == 1 and bridge.is_session_active())

    var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
    var delivery_index := 0
    for level in remaining:
        var quantity := int(remaining[level])
        if quantity > 0:
            delivery_index += 1
            bridge.record_to_go_delivery(int(level), quantity, "m20-ux-win-%d" % delivery_index, 321)
    await process_frame
    result_overlay = navigation.get_result_feedback_overlay()
    var win_result: Dictionary = bridge.get_terminal_result()
    _check("WIN result uses authoritative bridge outcome and stars", win_result.get("outcome", "") == "WIN" and int(win_result.get("stars", 0)) >= 1 and result_overlay.visible and result_overlay.get_feedback_kind() == "RESULT_WIN")
    _check("WIN exposes Next Level conditionally plus Island Map", result_overlay.get_visible_actions() == ["NEXT_LEVEL", "ISLAND_MAP"])
    _check("VIP remains optional on normal WIN", not bool(win_result.get("vip_completed", false)) or int(win_result.get("stars", 0)) >= 1)
    _check("WIN has no ad or purchase continuation", not result_overlay.get_visible_actions().has("ADD_TIME") and not result_overlay.get_visible_actions().has("VIDEO_AD"))
    _check("Island Map action exits result without a duplicate overlay", result_overlay.trigger_action("ISLAND_MAP"))
    await process_frame
    await process_frame
    _check("result-to-map returns to one Island Map instance", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0 and not result_overlay.visible)

    var reward_overlay = FEEDBACK_SCRIPT.new()
    root.add_child(reward_overlay)
    await process_frame
    reward_overlay.show_result({"outcome": "WIN", "level_id": 10, "score": 100, "stars": 2, "next_level_available": false, "progression": {"record": {"stars": 2, "best_score": 100}, "cumulative_rewards": [{"threshold": 10}]}})
    _check("milestone/reward feedback is represented by the same overlay", reward_overlay.get_body_text().contains("MILESTONE REWARD EARNED") and reward_overlay.get_visible_actions() == ["ISLAND_MAP"])
    reward_overlay.queue_free()
    shell.queue_free()
    await process_frame

    if failures.is_empty():
        print("M20_CHILD_05_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_05_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
