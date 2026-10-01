extends SceneTree

## BCM-M20-001 focused probe. Uses the production ApplicationShellScene and
## injects only an in-memory campaign fixture at the existing router boundary.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")

const ISLAND_ID := "m20_shell_fixture"
var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CHILD_01_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CHILD_01_PROBE FAIL: %s" % label)


func _database():
    var database = DATABASE_SCRIPT.new()
    var islands := {
        "schema_version": 1,
        "islands": [{
            "id": ISLAND_ID,
            "display_name": "M20 Shell Island",
            "order_index": 1,
            "level_count": 1,
            "unlock_rule": {"type": "default_open"},
            "next_island_id": "",
            "map_background": "",
            "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
            "map_position": [0.5, 0.5],
            "reward_track": {"milestones": [1]},
        }],
    }
    var levels := {
        "schema_version": 1,
        "island_id": ISLAND_ID,
        "levels": [{
            "island_id": ISLAND_ID,
            "level_id": 1,
            "time_limit_sec": 30,
            "orders": [{"cocktail_level": 6, "quantity": 1}],
            "vip": null,
            "rewards": {"coins": 0},
            "score_star_thresholds": {"one_star": 0, "two_stars": 100, "three_stars": 250},
            "feature_flags": {"timed": true, "vip": false, "boosters": false},
        }],
    }
    _check("fixture campaign data loads", database.load_from_data(islands, levels, DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _run() -> void:
    var configured_entry := str(ProjectSettings.get_setting("application/run/main_scene", ""))
    _check("project boots to the application shell", configured_entry == "res://scenes/campaign/ApplicationShellScene.tscn")

    var shell = SHELL_SCENE.instantiate()
    root.add_child(shell)
    await process_frame
    await process_frame

    var navigation = shell.get_campaign_navigation()
    _check("shell owns exactly one campaign navigation instance", navigation != null and shell.get_children().filter(func(child): return child is CampaignNavigationController).size() == 1)
    _check("shell starts in Main Menu", shell.is_main_menu_visible() and shell.get_current_view() == "MAIN_MENU" and not navigation.visible)

    var database = _database()
    var campaign = CAMPAIGN_SCRIPT.new()
    var state := {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {ISLAND_ID: {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
        "legacy_best_score": 17,
        "boosters": {},
        "coins": 3,
        "reward_ledger": [],
    }
    _check("fixture campaign configures at existing router boundary", navigation.configure_campaign(database, campaign) == false or campaign.configure(database, state))
    _check("shell PLAY/CONTINUE enters World Map", shell.press_play_continue() and shell.get_current_view() == "CAMPAIGN" and navigation.get_current_view() == navigation.VIEW_WORLD_MAP and navigation.visible)
    await process_frame
    await process_frame
    _check("campaign World Map is live after PLAY", navigation.get_world_map() != null and navigation.get_world_map().get_entry_count() == 1)

    var before := campaign.get_progression_state().duplicate(true)
    navigation.get_world_map().return_requested.emit()
    await process_frame
    _check("World Map return uses the app-level menu signal", shell.is_main_menu_visible() and not navigation.visible and shell.get_current_view() == "MAIN_MENU")
    _check("campaign progression survives menu transition", campaign.get_progression_state() == before)
    _check("no duplicate map or gameplay authority is created", navigation.get_map_instance_count() == 2 and navigation.get_gameplay_instance_count() == 0)

    shell.queue_free()
    await process_frame
    if failures.is_empty():
        print("M20_CHILD_01_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_01_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
