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
    _check("canonical campaign data loads", database.load_canonical())
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
    if shell.is_onboarding_visible():
        _check("first-run onboarding can be skipped before menu", shell.skip_onboarding() and shell.is_main_menu_visible())
    _check("shell exposes Main Menu after first-run boundary", shell.is_main_menu_visible() and shell.get_current_view() == "MAIN_MENU" and not navigation.visible)

    var database = _database()
    var campaign = CAMPAIGN_SCRIPT.new()
    var state := {
        "schema_version": 2,
        "unlocked_islands": ["sunny_cove"],
        "islands": {"sunny_cove": {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
        "legacy_best_score": 17,
        "boosters": {},
        "coins": 3,
        "reward_ledger": [],
    }
    _check("campaign configures before installation into the existing router", campaign.configure(database, state))
    _check("production router installs the canonical fixture campaign", navigation.configure_campaign(database, campaign))
    _check("shell World Map action enters production World Map", shell.press_world_map() and shell.get_current_view() == "CAMPAIGN" and navigation.get_current_view() == navigation.VIEW_WORLD_MAP and navigation.visible)
    await process_frame
    await process_frame
    _check("production World Map is live after explicit World Map action", navigation.get_world_map() != null and navigation.get_world_map().get_entry_count() == 10)

    var before := campaign.get_progression_state().duplicate(true)
    navigation.get_world_map().return_requested.emit()
    await process_frame
    _check("World Map return uses the app-level menu signal", shell.is_main_menu_visible() and not navigation.visible and shell.get_current_view() == "MAIN_MENU")
    var launch_configuration: Array[Dictionary] = []
    navigation.gameplay_session_started.connect(func(configuration: Dictionary) -> void: launch_configuration.append(configuration))
    _check("PLAY/CONTINUE launches the selected campaign level", shell.press_play_continue() and navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1 and launch_configuration.size() == 1 and launch_configuration[0].get("island_id", "") == "sunny_cove" and int(launch_configuration[0].get("level_id", 0)) == 1)
    _check("campaign progression survives distinct Home actions", campaign.get_progression_state() == before)
    _check("Home menu return disposes gameplay without duplicating map authority", shell.show_main_menu() and navigation.get_map_instance_count() == 2 and navigation.get_gameplay_instance_count() == 0)

    shell.queue_free()
    await process_frame
    if failures.is_empty():
        print("M20_CHILD_01_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_01_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
