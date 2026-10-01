extends SceneTree

## R01-only selector harness. It deliberately accepts exactly one child selector
## and never invokes any other child, so each publication can be audited from
## repository chronology rather than from one monolithic run.

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")

const CANONICAL_ORDER := [
    "sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
    "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
const THEME_KEYS := [
    "gameplay_background", "gameplay_table", "gameplay_table_shadow",
    "table_edge_overlay", "launch_zone", "island_map_background",
]

var child_id := 0
var failures: Array[String] = []


func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 1 or not str(args[0]).begins_with("--child="):
        print("M19_R01_USAGE=--child=1|2|3|4|5|6")
        quit(2)
        return
    child_id = int(str(args[0]).trim_prefix("--child="))
    if child_id < 1 or child_id > 6:
        print("M19_R01_INVALID_CHILD=%d" % child_id)
        quit(2)
        return
    call_deferred("_run_selected_child")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M19_R01_CHILD_%02d PASS: %s" % [child_id, label])
    else:
        failures.append(label)
        print("M19_R01_CHILD_%02d FAIL: %s" % [child_id, label])


func _island(island_id: String, order_index: int, level_count: int, next_id: String) -> Dictionary:
    return {
        "id": island_id,
        "display_name": island_id,
        "order_index": order_index,
        "level_count": level_count,
        "unlock_rule": {"type": "default_open"},
        "next_island_id": next_id,
        "map_background": "",
        "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
        "reward_track": {"milestones": []},
    }


func _level(island_id: String, level_id: int, cocktail_level: int = 5) -> Dictionary:
    return {
        "island_id": island_id,
        "level_id": level_id,
        "time_limit_sec": 30,
        "orders": [{"cocktail_level": cocktail_level, "quantity": 1}],
        "vip": null,
        "rewards": {},
        "score_star_thresholds": {},
        "feature_flags": {},
    }


func _fixture_islands(include_gamma: bool = false) -> Dictionary:
    var islands: Array = [
        _island("fixture_alpha", 1, 1, "fixture_beta"),
        _island("fixture_beta", 2, 1, "fixture_placeholder"),
        _island("fixture_placeholder", 3, 0, ""),
    ]
    if include_gamma:
        islands.append(_island("fixture_gamma", 4, 1, ""))
    return {"schema_version": 1, "islands": islands}


func _state_for_fixture(ids: Array) -> Dictionary:
    var island_state := {}
    for island_id in ids:
        island_state[island_id] = {
            "highest_unlocked_level": 1,
            "completed_levels": {},
            "claimed_milestones": [],
            "claimed_star_rewards": [],
        }
    return {
        "schema_version": 2,
        "unlocked_islands": ids.duplicate(),
        "islands": island_state,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _sunny_state(completed_through: int) -> Dictionary:
    var completed := {}
    for level_id in range(1, completed_through + 1):
        completed[str(level_id)] = {
            "completed": true,
            "stars": 1,
            "best_score": level_id,
            "first_completion": true,
            "vip_completed": false,
        }
    return {
        "schema_version": 2,
        "unlocked_islands": ["sunny_cove"],
        "islands": {"sunny_cove": {
            "highest_unlocked_level": mini(100, completed_through + 1),
            "completed_levels": completed,
            "claimed_milestones": [],
            "claimed_star_rewards": [],
        }},
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _canonical_database():
    var database = DATABASE_SCRIPT.new()
    _check("canonical database loads in FULL mode", database.load_canonical(
        DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
        DATABASE_SCRIPT.DEFAULT_LEVELS_PATH,
        DATABASE_SCRIPT.ValidationMode.FULL
    ))
    return database


func _run_selected_child() -> void:
    match child_id:
        1:
            await _child_01()
        2:
            await _child_02()
        3:
            await _child_03()
        4:
            await _child_04()
        5:
            await _child_05()
        6:
            await _child_06()
    if failures.is_empty():
        print("M19_R01_CHILD_%02d_RESULT=PASS" % child_id)
        quit(0)
        return
    print("M19_R01_CHILD_%02d_RESULT=FAIL failures=%s" % [child_id, str(failures)])
    quit(1)


func _child_01() -> void:
    var islands := _fixture_islands()
    var alpha_root := {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_alpha", 1)]}
    var beta_root := {"schema_version": 1, "island_id": "fixture_beta", "levels": [_level("fixture_beta", 1)]}
    var database = DATABASE_SCRIPT.new()
    _check("multi-root load succeeds", database.load_from_data(islands, [alpha_root, beta_root], DATABASE_SCRIPT.ValidationMode.FULL))
    _check("both fixture islands are loaded", database.get_levels_for_island("fixture_alpha").size() == 1 and database.get_levels_for_island("fixture_beta").size() == 1)
    var single_islands := {"schema_version": 1, "islands": [_island("fixture_alpha", 1, 1, "fixture_placeholder"), _island("fixture_placeholder", 2, 0, "")]}
    var single_database = DATABASE_SCRIPT.new()
    _check("single-root API remains backward compatible", single_database.load_from_data(single_islands, alpha_root, DATABASE_SCRIPT.ValidationMode.FULL) and single_database.get_level("fixture_alpha", 1).size() > 0)
    var duplicate_database = DATABASE_SCRIPT.new()
    _check("duplicate roots are rejected", not duplicate_database.load_from_data(islands, [alpha_root, alpha_root], DATABASE_SCRIPT.ValidationMode.FULL))
    var cross_root := {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_beta", 2)]}
    var cross_database = DATABASE_SCRIPT.new()
    _check("cross-island rows are rejected", not cross_database.load_from_data(islands, cross_root, DATABASE_SCRIPT.ValidationMode.FULL))
    var count_islands := _fixture_islands()
    count_islands["islands"][0]["level_count"] = 2
    var count_database = DATABASE_SCRIPT.new()
    _check("positive declared-count mismatch is rejected", not count_database.load_from_data(count_islands, [alpha_root, beta_root], DATABASE_SCRIPT.ValidationMode.FULL))
    _check("zero-level placeholder remains valid", database.get_levels_for_island("fixture_placeholder").is_empty())

    var manager = CAMPAIGN_SCRIPT.new()
    var save_manager = SAVE_SCRIPT.new()
    _check("one campaign and save authority configure", manager.configure(database, _state_for_fixture(["fixture_alpha", "fixture_beta"])))
    var navigation = NAVIGATION_SCENE.instantiate()
    _check("one reusable map pair configures", navigation.configure_campaign(database, manager))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("one reusable map pair exists", navigation.get_map_instance_count() == 2)
    var bridge = navigation.get_session_bridge()
    var alpha_session: Dictionary = bridge.start_session("fixture_alpha", 1)
    bridge.resolve_lose("R01_CHILD_01_ALPHA")
    var beta_session: Dictionary = bridge.start_session("fixture_beta", 1)
    _check("one session bridge runs both islands", not alpha_session.is_empty() and not beta_session.is_empty() and save_manager != null)
    navigation.queue_free()
    await process_frame


func _child_02() -> void:
    var database = _canonical_database()
    var fresh = CAMPAIGN_SCRIPT.new()
    _check("fresh save keeps Tiki locked", fresh.configure(database, SAVE_SCRIPT.new().create_default_state()) and not fresh.is_island_unlocked("tiki_island"))
    var l99 = CAMPAIGN_SCRIPT.new()
    _check("Sunny L99 keeps Tiki locked", l99.configure(database, _sunny_state(99)) and not l99.is_island_unlocked("tiki_island"))
    var l100 = CAMPAIGN_SCRIPT.new()
    _check("one-star Sunny L100 completion unlocks Tiki", l100.configure(database, _sunny_state(99)) and l100.mark_level_completed("sunny_cove", 100, {"stars": 1, "score": 100}).get("ok", false) and l100.is_island_unlocked("tiki_island"))
    _check("Tiki remains zero-level and unplayable", int(database.get_island("tiki_island").get("level_count", -1)) == 0 and not l100.is_level_unlocked("tiki_island", 1))
    var bridge = BRIDGE_SCRIPT.new()
    bridge.configure(database, l100)
    _check("Tiki cannot start a gameplay session", bridge.start_session("tiki_island", 1).is_empty())
    var reloaded = CAMPAIGN_SCRIPT.new()
    _check("reload preserves unlock", reloaded.configure(database, l100.get_progression_state()) and reloaded.is_island_unlocked("tiki_island"))
    var repeated := l100.mark_level_completed("sunny_cove", 100, {"stars": 1, "score": 100})
    var unlocked: Array = l100.get_progression_state().get("unlocked_islands", [])
    _check("unlock is idempotent", repeated.get("ok", false) and unlocked.count("tiki_island") == 1)


func _child_03() -> void:
    var database = _canonical_database()
    var sunny: Dictionary = database.get_island("sunny_cove")
    var tiki: Dictionary = database.get_island("tiki_island")
    _check("Sunny policy is L5-L8", sunny.get("target_policy", {}).get("min_level", 0) == 5 and sunny.get("target_policy", {}).get("max_level", 0) == 8)
    _check("Sunny content has no L9", database.get_levels_for_island("sunny_cove").all(func(level: Dictionary) -> bool:
        return level.get("orders", []).all(func(order: Dictionary) -> bool: return int(order.get("cocktail_level", 0)) <= 8)
    ))
    _check("Tiki is first declarative L9 island", tiki.get("target_policy", {}).get("max_level", 0) == 9 and database.is_campaign_target_level_eligible("tiki_island", 9) and not database.is_campaign_target_level_eligible("sunny_cove", 9))
    _check("Tiki has no production levels or exact L9 level", database.get_levels_for_island("tiki_island").is_empty() and not tiki.has("first_l9_level"))
    var policy_file := FileAccess.open("res://docs/CAMPAIGN_COCKTAIL_LEVEL_PROGRESSION_POLICY.md", FileAccess.READ)
    var policy := policy_file.get_as_text() if policy_file != null else ""
    _check("policy is data-first and L1-L12 bounded", policy.contains("target_policy") and policy.contains("L1-L12") and policy.contains("does not choose an\n  exact introduction level"))
    _check("runtime has no Tiki-specific branch", not FileAccess.open("res://scripts/campaign/level_database.gd", FileAccess.READ).get_as_text().contains("tiki_island") and not FileAccess.open("res://scripts/campaign/gameplay_session_bridge.gd", FileAccess.READ).get_as_text().contains("tiki_island"))


func _child_04() -> void:
    var database = _canonical_database()
    var ordered: Array[String] = database.get_island_ids_in_order()
    _check("canonical order has exactly ten ids", ordered.size() == 10 and ordered == CANONICAL_ORDER)
    var seen := {}
    var chain_ok := true
    for index in range(ordered.size()):
        var island: Dictionary = database.get_island(ordered[index])
        var order_index := int(island.get("order_index", 0))
        seen[order_index] = seen.get(order_index, 0) + 1
        var expected_next := ordered[index + 1] if index + 1 < ordered.size() else ""
        chain_ok = chain_ok and str(island.get("next_island_id", "")) == expected_next
    _check("order indices are unique and contiguous", seen.size() == 10 and seen.keys().all(func(value): return int(value) >= 1 and int(value) <= 10 and seen[value] == 1))
    _check("next-island chain and terminal slot are exact", chain_ok and ordered[-1] == "final_island" and database.get_island("final_island").get("next_island_id", "") == "")
    _check("final public name remains TBD", str(database.get_island("final_island").get("display_name", "")).to_lower().contains("tbd"))


func _child_05() -> void:
    var database = _canonical_database()
    var hooks_ok := true
    for island_id in CANONICAL_ORDER:
        var theme: Dictionary = database.get_island_theme(island_id)
        hooks_ok = hooks_ok and theme.is_read_only() and THEME_KEYS.all(func(key):
            var path := str(theme.get(key, ""))
            return path.begins_with("res://assets/ui_assets/campaign/islands/%s/" % island_id) and FileAccess.file_exists(path)
        )
    _check("all ten theme hooks are immutable and existing", hooks_ok)
    var manager = CAMPAIGN_SCRIPT.new()
    manager.configure(database, SAVE_SCRIPT.new().create_default_state())
    var bridge = BRIDGE_SCRIPT.new()
    bridge.configure(database, manager)
    var session: Dictionary = bridge.start_session("sunny_cove", 1)
    _check("session bridge exposes immutable theme", not session.is_empty() and session.get("island_theme", {}).get("gameplay_table", "").contains("sunny_cove/gameplay_table.png") and bridge.get_active_island_theme().is_read_only())
    bridge.resolve_lose("R01_CHILD_05")
    var fixture_database = DATABASE_SCRIPT.new()
    fixture_database.load_from_data(_fixture_islands(), {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_alpha", 1)]}, DATABASE_SCRIPT.ValidationMode.FULL)
    var fixture_manager = CAMPAIGN_SCRIPT.new()
    fixture_manager.configure(fixture_database, _state_for_fixture(["fixture_alpha"]))
    var fixture_bridge = BRIDGE_SCRIPT.new()
    fixture_bridge.configure(fixture_database, fixture_manager)
    _check("theme-less legacy fixture falls back safely", fixture_bridge.start_session("fixture_alpha", 1).get("island_theme", {}).is_empty())


func _child_06() -> void:
    var islands := _fixture_islands(true)
    var roots: Array = [
        {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_alpha", 1)]},
        {"schema_version": 1, "island_id": "fixture_beta", "levels": [_level("fixture_beta", 1)]},
        {"schema_version": 1, "island_id": "fixture_gamma", "levels": [_level("fixture_gamma", 1)]},
    ]
    var database = DATABASE_SCRIPT.new()
    _check("third fixture island loads from data only", database.load_from_data(islands, roots, DATABASE_SCRIPT.ValidationMode.FULL))
    var manager = CAMPAIGN_SCRIPT.new()
    manager.configure(database, _state_for_fixture(["fixture_alpha", "fixture_beta", "fixture_gamma"]))
    var navigation = NAVIGATION_SCENE.instantiate()
    _check("same reusable navigation pair configures", navigation.configure_campaign(database, manager))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("same map pair reaches Gamma", navigation.show_island_map("fixture_gamma") and navigation.get_map_instance_count() == 2)
    var bridge = navigation.get_session_bridge()
    var alpha: Dictionary = bridge.start_session("fixture_alpha", 1)
    bridge.resolve_lose("R01_CHILD_06_ALPHA")
    var gamma: Dictionary = bridge.start_session("fixture_gamma", 1)
    _check("same bridge runs old and new fixture islands", not alpha.is_empty() and not gamma.is_empty() and alpha.get("island_id", "") == "fixture_alpha" and gamma.get("island_id", "") == "fixture_gamma")
    navigation.queue_free()
    await process_frame
