extends SceneTree

## Focused M14 probe. It uses deterministic in-memory fixtures and the actual
## M13 navigation host plus the existing main gameplay scene. No canonical
## Sunny Cove production content is authored here.

const ISLAND_ID := "m14_fixture"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M14_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M14_PROBE FAIL: %s" % label)


func _islands() -> Dictionary:
    return {
        "schema_version": 1,
        "islands": [{
            "id": ISLAND_ID,
            "display_name": "M14 Fixture Island",
            "order_index": 1,
            "level_count": 2,
            "unlock_rule": {"type": "default_open"},
            "next_island_id": "",
            "map_background": "",
            "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
            "map_position": [0.5, 0.5],
            "reward_track": {"milestones": [2]},
        }],
    }


func _level(level_id: int, orders: Array, vip: Variant) -> Dictionary:
    return {
        "island_id": ISLAND_ID,
        "level_id": level_id,
        "time_limit_sec": 5,
        "orders": orders,
        "vip": vip,
        "rewards": {"coins": 0},
        "score_star_thresholds": {"one_star": 0, "two_stars": 100, "three_stars": 250},
        "feature_flags": {"timed": true, "vip": vip != null, "boosters": false},
    }


func _levels() -> Dictionary:
    return {
        "schema_version": 1,
        "island_id": ISLAND_ID,
        "levels": [
            _level(1, [{"cocktail_level": 6, "quantity": 2}, {"cocktail_level": 7, "quantity": 1}], {"enabled": true, "cocktail_level": 12, "quantity": 1, "reward": {"type": "booster", "id": "upgrade", "quantity": 1}}),
            _level(2, [{"cocktail_level": 6, "quantity": 1}], null),
        ],
    }


func _database():
    var database = DATABASE_SCRIPT.new()
    _check("M14 fixture loads in FULL validation", database.load_from_data(_islands(), _levels(), DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _state(highest_unlocked: int = 1, completed: Dictionary = {}) -> Dictionary:
    return {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {
            ISLAND_ID: {
                "highest_unlocked_level": highest_unlocked,
                "completed_levels": completed,
                "claimed_milestones": [],
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
    }


func _campaign(database, highest_unlocked: int = 1, completed: Dictionary = {}):
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("CampaignManager configures M14 fixture", campaign.configure(database, _state(highest_unlocked, completed)))
    return campaign


func _bridge(database, campaign):
    var bridge = BRIDGE_SCRIPT.new()
    _check("GameplaySessionBridge configures with database and campaign", bridge.configure(database, campaign))
    return bridge


func _run() -> void:
    var database = _database()
    var campaign = _campaign(database)
    var canonical_before: Dictionary = database.get_level(ISLAND_ID, 1)
    var bridge = _bridge(database, campaign)

    var configuration: Dictionary = bridge.start_session(ISLAND_ID, 1)
    _check("M13 selection identity enters exact session", configuration["island_id"] == ISLAND_ID and configuration["level_id"] == 1)
    _check("session snapshot includes immutable level definition", configuration["level_definition"].is_read_only() and configuration["orders"].is_read_only())
    _check("session snapshot carries timer, orders, VIP, rewards, thresholds, flags", configuration.has_all(["time_limit_sec", "orders", "vip", "rewards", "score_star_thresholds", "feature_flags"]))
    _check("duplicate active session is rejected", bridge.start_session(ISLAND_ID, 1).is_empty())
    _check("locked level selection is rejected", bridge.start_session(ISLAND_ID, 2).is_empty())
    _check("canonical definition remains unchanged after snapshot", database.get_level(ISLAND_ID, 1) == canonical_before)

    _check("timer starts only after gameplay ready", bridge.session_state == bridge.STATE_READY and is_equal_approx(bridge.timer_remaining_sec, 5.0) and bridge.mark_gameplay_ready() and bridge.session_state == bridge.STATE_ACTIVE)
    bridge.tick(1.25)
    _check("active timer decrements from one authoritative value", is_equal_approx(bridge.timer_remaining_sec, 3.75))
    var paused_time: float = bridge.timer_remaining_sec
    _check("legitimate pause freezes timer", bridge.pause_session() and bridge.session_state == bridge.STATE_PAUSED)
    bridge.tick(1.0)
    _check("paused timer does not drain", is_equal_approx(bridge.timer_remaining_sec, paused_time))
    _check("resume restores active timer", bridge.resume_session() and bridge.session_state == bridge.STATE_ACTIVE)
    _check("background pause freezes timer", bridge.set_background_paused(true) and bridge.session_state == bridge.STATE_PAUSED)
    var background_time: float = bridge.timer_remaining_sec
    bridge.tick(2.0)
    _check("background-paused timer does not drain", is_equal_approx(bridge.timer_remaining_sec, background_time))
    _check("background resume restores timer", bridge.set_background_paused(false) and bridge.session_state == bridge.STATE_ACTIVE)

    var timeout_bridge = _bridge(database, campaign)
    timeout_bridge.start_session(ISLAND_ID, 1)
    timeout_bridge.mark_gameplay_ready()
    timeout_bridge.tick(6.0)
    var timeout_result: Dictionary = timeout_bridge.get_terminal_result()
    _check("timeout resolves one deterministic LOSE", timeout_result["outcome"] == "LOSE" and timeout_result["reason"] == "TIMEOUT" and timeout_bridge.session_state == timeout_bridge.STATE_TERMINAL)
    var timeout_snapshot := timeout_bridge.get_terminal_result()
    timeout_bridge.tick(10.0)
    _check("terminal timeout does not repeat or go negative", timeout_bridge.get_terminal_result() == timeout_snapshot and timeout_bridge.timer_remaining_sec == 0.0)
    _check("timeout does not advance progression", not campaign.is_level_completed(ISLAND_ID, 1))

    var win_bridge = _bridge(database, campaign)
    win_bridge.start_session(ISLAND_ID, 1)
    win_bridge.mark_gameplay_ready()
    win_bridge.set_current_score(300)
    _check("normal quantity ledger starts at 2xL6 then L7", win_bridge.get_next_required_order_level() == 6 and win_bridge.get_objective_state()["normal_remaining"][6] == 2)
    win_bridge.record_to_go_delivery(6, 1, "stored-l6")
    _check("stored qualifying L6 can satisfy a later campaign order", win_bridge.get_objective_state()["normal_completed"][6] == 1 and win_bridge.get_next_required_order_level() == 6)
    win_bridge.record_to_go_delivery(6, 1, "new-l6")
    _check("second quantity is required before advancing order", win_bridge.get_next_required_order_level() == 7)
    var pre_vip_result := win_bridge.record_to_go_delivery(7, 1, "l7")
    var win_result: Dictionary = pre_vip_result["terminal"]
    _check("incomplete VIP never blocks normal WIN", win_result["outcome"] == "WIN" and not win_result["vip_completed"])
    _check("score-only completion cannot earn three stars", win_result["stars"] == 2)
    _check("WIN progression is submitted exactly once", campaign.is_level_completed(ISLAND_ID, 1) and win_bridge.get_progression_result()["ok"] and win_bridge.resolve_win() == win_result)
    var terminal_time: float = win_bridge.timer_remaining_sec
    win_bridge.tick(2.0)
    _check("WIN stops timer", win_bridge.timer_remaining_sec == terminal_time and win_bridge.session_state == win_bridge.STATE_TERMINAL)

    var matrix_campaign = _campaign(database)
    var vip_low_bridge = _bridge(database, matrix_campaign)
    vip_low_bridge.start_session(ISLAND_ID, 1)
    vip_low_bridge.mark_gameplay_ready()
    vip_low_bridge.set_current_score(100)
    vip_low_bridge.set_vip_completed(true)
    vip_low_bridge.record_to_go_delivery(6, 2, "vip-low-l6")
    var vip_low_result: Dictionary = vip_low_bridge.record_to_go_delivery(7, 1, "vip-low-l7")["terminal"]
    _check("VIP completion with insufficient three-star score earns two stars", vip_low_result["stars"] == 2)

    var vip_high_bridge = _bridge(database, matrix_campaign)
    vip_high_bridge.start_session(ISLAND_ID, 1)
    vip_high_bridge.mark_gameplay_ready()
    vip_high_bridge.set_current_score(300)
    vip_high_bridge.set_vip_completed(true)
    vip_high_bridge.record_to_go_delivery(6, 2, "vip-high-l6")
    var vip_high_result: Dictionary = vip_high_bridge.record_to_go_delivery(7, 1, "vip-high-l7")["terminal"]
    _check("VIP completion with three-star score earns three stars", vip_high_result["stars"] == 3)

    var plain_bridge = _bridge(database, matrix_campaign)
    plain_bridge.start_session(ISLAND_ID, 2)
    plain_bridge.mark_gameplay_ready()
    plain_bridge.set_current_score(0)
    var plain_result: Dictionary = plain_bridge.record_to_go_delivery(6, 1, "plain-normal")["terminal"]
    _check("plain normal completion earns one star", plain_result["stars"] == 1)

    var replay_configuration: Dictionary = win_bridge.retry_session()
    _check("Retry creates a fresh READY session from original definition", replay_configuration["island_id"] == ISLAND_ID and replay_configuration["level_id"] == 1 and win_bridge.session_state == win_bridge.STATE_READY and is_equal_approx(win_bridge.timer_remaining_sec, 5.0))
    win_bridge.mark_gameplay_ready()
    win_bridge.record_to_go_delivery(6, 2, "replay-l6", 1)
    win_bridge.record_to_go_delivery(7, 1, "replay-l7", 1)
    _check("worse replay cannot lower best score or stars", campaign.get_progression_state()["islands"][ISLAND_ID]["completed_levels"]["1"]["best_score"] == 300 and campaign.get_progression_state()["islands"][ISLAND_ID]["completed_levels"]["1"]["stars"] == 2)
    _check("Next Level resolves only an unlocked next level", win_bridge.next_level_session()["level_id"] == 2 and win_bridge.active_level_id == 2)
    _check("next-level session starts with clean objective/timer state", win_bridge.session_state == win_bridge.STATE_READY and win_bridge.get_objective_state()["normal_remaining"][6] == 1 and is_equal_approx(win_bridge.timer_remaining_sec, 5.0))
    win_bridge.mark_gameplay_ready()
    win_bridge.resolve_lose("TEST_LOSE")
    var map_requests: Array[String] = []
    win_bridge.island_map_requested.connect(func(island_id: String) -> void: map_requests.append(island_id))
    _check("Island Map return preserves exact island boundary", win_bridge.return_to_island_map()["ok"] and map_requests == [ISLAND_ID] and win_bridge.session_state == win_bridge.STATE_IDLE)

    var configured_entry: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
    _check("configured app entry is campaign shell", configured_entry == "res://scenes/campaign/CampaignNavigationScene.tscn")
    var app_entry_scene := load(configured_entry) as PackedScene
    var navigation = app_entry_scene.instantiate()
    _check("configured entry instantiates the real M13 navigation host", navigation is CampaignNavigationController)
    _check("M13 navigation host configures exact fixture campaign", navigation.configure_campaign(database, campaign))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("navigation owns one reusable map pair", navigation.get_map_instance_count() == 2)
    var navigation_map_opened: bool = navigation.get_world_map().select_island(ISLAND_ID)
    await process_frame
    await process_frame
    _check("real M12 World Map selection enters the exact M13 Island Map", navigation_map_opened and navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_island_map().island_id == ISLAND_ID)
    var navigation_level_selected: bool = navigation.get_island_map().select_level(2)
    _check("M13 level selection launches existing gameplay scene through M14", navigation_map_opened and navigation_level_selected)
    await process_frame
    await process_frame
    _check("production selection enters GAMEPLAY with one instance", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1 and navigation.get_session_bridge().active_level_id == 2)
    var gameplay := navigation.get_node_or_null("CampaignGameplay") as GameManager
    var production_pause_time: float = navigation.get_session_bridge().timer_remaining_sec
    _check("production gameplay pause hook pauses the active bridge", gameplay != null and gameplay.set_campaign_gameplay_paused(true) and navigation.get_session_bridge().session_state == navigation.get_session_bridge().STATE_PAUSED)
    navigation.get_session_bridge().tick(1.0)
    _check("production gameplay pause hook freezes the timer", is_equal_approx(navigation.get_session_bridge().timer_remaining_sec, production_pause_time))
    _check("production gameplay resume hook resumes the active bridge", gameplay != null and gameplay.set_campaign_gameplay_paused(false) and navigation.get_session_bridge().session_state == navigation.get_session_bridge().STATE_ACTIVE)
    var production_resume_time: float = navigation.get_session_bridge().timer_remaining_sec
    navigation.get_session_bridge().tick(0.5)
    _check("production gameplay resume hook allows timer progress", navigation.get_session_bridge().timer_remaining_sec < production_resume_time)
    var app_background_time: float = navigation.get_session_bridge().timer_remaining_sec
    gameplay._notification(NOTIFICATION_APPLICATION_PAUSED)
    navigation.get_session_bridge().tick(1.0)
    _check("production application pause notification freezes the bridge timer", navigation.get_session_bridge().session_state == navigation.get_session_bridge().STATE_PAUSED and is_equal_approx(navigation.get_session_bridge().timer_remaining_sec, app_background_time))
    gameplay._notification(NOTIFICATION_APPLICATION_RESUMED)
    var app_resume_time: float = navigation.get_session_bridge().timer_remaining_sec
    navigation.get_session_bridge().tick(0.5)
    _check("production application resume notification resumes background-paused gameplay", navigation.get_session_bridge().session_state == navigation.get_session_bridge().STATE_ACTIVE and navigation.get_session_bridge().timer_remaining_sec < app_resume_time)
    gameplay.set_campaign_gameplay_paused(true)
    gameplay._notification(NOTIFICATION_APPLICATION_PAUSED)
    gameplay._notification(NOTIFICATION_APPLICATION_RESUMED)
    _check("pre-existing user pause survives application resume", navigation.get_session_bridge().session_state == navigation.get_session_bridge().STATE_PAUSED)
    gameplay.set_campaign_gameplay_paused(false)
    navigation.get_session_bridge().resolve_lose("TEST_NAV_LOSE")
    gameplay._notification(NOTIFICATION_APPLICATION_PAUSED)
    gameplay._notification(NOTIFICATION_APPLICATION_RESUMED)
    _check("terminal gameplay is not resumed by application lifecycle", navigation.get_session_bridge().session_state == navigation.get_session_bridge().STATE_TERMINAL)
    _check("Retry path is bounded and does not duplicate gameplay", navigation.retry_level() and navigation.get_gameplay_instance_count() <= 1)
    await process_frame
    await process_frame
    _check("Retry remains the same exact level", navigation.get_session_bridge().active_level_id == 2 and navigation.get_current_view() == navigation.VIEW_GAMEPLAY)
    navigation.get_session_bridge().resolve_lose("TEST_NAV_LOSE_2")
    _check("Island Map path returns through bridge boundary", navigation.return_to_island_map())
    await process_frame
    await process_frame
    _check("Island Map return has no duplicate gameplay instance", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0 and navigation.get_map_instance_count() == 2)

    _check("final canonical definition remains unchanged", database.get_level(ISLAND_ID, 1) == canonical_before)
    navigation.queue_free()
    await process_frame

    if failures.is_empty():
        print("M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS")
        quit(0)
        return
    print("M14_GAMEPLAY_SESSION_BRIDGE_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
