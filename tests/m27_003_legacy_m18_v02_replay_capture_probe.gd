extends SceneTree

## M18 V02-R01 runtime evidence probe. It drives the production campaign
## navigation/map boundary and saves four non-headless viewport captures for
## Child 05 replay states. This probe must be run with the GUI Godot binary.

const ISLAND_ID := "sunny_cove"
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-003/M18"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_REPLAY_CAPTURE_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_REPLAY_CAPTURE_PROBE FAIL: %s" % label)


func _database():
    var database = DATABASE_SCRIPT.new()
    _check("canonical Sunny Cove loads in FULL validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _state() -> Dictionary:
    var completed := {}
    for level_id in range(1, 6):
        completed[str(level_id)] = {"completed": true, "stars": 2, "best_score": 500 + level_id}
    return {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {ISLAND_ID: {"highest_unlocked_level": 6, "completed_levels": completed, "claimed_milestones": [], "claimed_star_rewards": []}},
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _capture(root_viewport: Viewport, label: String) -> bool:
    var texture := root_viewport.get_texture()
    if texture == null:
        print("M18_REPLAY_CAPTURE name=%s unavailable=no_render_texture" % label)
        return false
    var image := texture.get_image()
    var path := "%s/%s.png" % [CAPTURE_DIR, label]
    var error := image.save_png(path)
    var valid := error == OK and FileAccess.file_exists(path) and image.get_width() > 0 and image.get_height() > 0
    print("M18_REPLAY_CAPTURE name=%s path=%s dimensions=%dx%d error=%s valid=%s" % [label, path, image.get_width(), image.get_height(), error, valid])
    return valid


func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
    var database = _database()
    var campaign = CAMPAIGN_SCRIPT.new()
    campaign.configure(database, _state())
    campaign.select_level(ISLAND_ID, 5)

    var navigation = NAVIGATION_SCENE.instantiate()
    _check("navigation accepts capture campaign", navigation.configure_campaign(database, campaign))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("production Island Map opens for Child 05", navigation.show_island_map(ISLAND_ID))
    await process_frame
    await process_frame
    await process_frame
    var map = navigation.get_island_map()
    _check("completed Child 05 exposes prior stars and retains best score internally without node text", map.get_level_state(5) == "COMPLETE" and map.get_level_stars(5) == 2 and map.get_level_button(5).get_best_score() == 505 and map.get_level_button(5).get_node_or_null("BestScore") == null and map.get_level_button(5).text.is_empty())
    _check("capture 1 saved", _capture(root, "child05_completed_prior_record"))

    var worse: Dictionary = campaign.mark_level_completed(ISLAND_ID, 5, {"stars": 1, "score": 1})
    map.refresh()
    await process_frame
    await process_frame
    _check("worse replay preserves authoritative record", not worse.get("changed", true) and map.get_level_stars(5) == 2 and map.get_level_button(5).get_best_score() == 505)
    _check("capture 2 saved", _capture(root, "child05_worse_replay_preserved"))

    var better: Dictionary = campaign.mark_level_completed(ISLAND_ID, 5, {"stars": 3, "score": 900})
    map.refresh()
    await process_frame
    await process_frame
    _check("improved replay updates authoritative stars and retains best score internally", better.get("changed", false) and map.get_level_stars(5) == 3 and map.get_level_button(5).get_best_score() == 900 and map.get_level_button(5).get_node_or_null("BestScore") == null and map.get_level_button(5).text.is_empty())
    _check("capture 3 saved", _capture(root, "child05_improved_replay_updated"))

    map.set_scroll_vertical(913)
    var saved_scroll: int = map.get_scroll_vertical()
    _check("Child 05 is selected before replay return", map.select_level(5) and navigation.get_gameplay_instance_count() == 1)
    var bridge = navigation.get_session_bridge()
    bridge.resolve_lose("REPLAY_RETURN")
    _check("production gameplay boundary returns to Island Map", navigation.return_to_island_map())
    await process_frame
    await process_frame
    await process_frame
    map = navigation.get_island_map()
    print("M18_REPLAY_CAPTURE_RETURN_STATE saved_scroll=%d selected=%d focus=%d scroll=%d view=%s gameplay=%d" % [saved_scroll, map.get_selected_level_id(), map.get_focus_level_id(), map.get_scroll_vertical(), navigation.get_current_view(), navigation.get_gameplay_instance_count()])
    _check("capture 4 restores selected focus and scroll context", navigation.get_current_view() == "ISLAND_MAP" and map.get_selected_level_id() == 5 and map.get_focus_level_id() == 5 and map.get_scroll_vertical() == saved_scroll)
    _check("capture 4 saved", _capture(root, "child05_return_context_restored"))

    navigation.queue_free()
    await process_frame
    if failures.is_empty():
        print("M18_REPLAY_CAPTURE_RESULT=PASS")
        quit(0)
        return
    print("M18_REPLAY_CAPTURE_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
