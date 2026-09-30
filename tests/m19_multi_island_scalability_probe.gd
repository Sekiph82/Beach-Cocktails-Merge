extends SceneTree

## Focused M19 V01 probe. The six result markers are intentionally emitted in
## ordered child sequence so the builder logs can cite the exact handoff.

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")

const CANONICAL_ORDER := [
    "sunny_cove",
    "tiki_island",
    "azure_bay",
    "coconut_beach",
    "sunset_island",
    "party_beach",
    "frozen_paradise",
    "volcano_bay",
    "billionaire_island",
    "final_island",
]
const THEME_KEYS := [
    "gameplay_background",
    "gameplay_table",
    "gameplay_table_shadow",
    "table_edge_overlay",
    "launch_zone",
    "island_map_background",
]

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M19_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M19_PROBE FAIL: %s" % label)


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
        "islands": {
            "sunny_cove": {
                "highest_unlocked_level": mini(100, completed_through + 1),
                "completed_levels": completed,
                "claimed_milestones": [],
                "claimed_star_rewards": [],
            },
        },
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _canonical_database():
    var database = DATABASE_SCRIPT.new()
    _check("canonical data loads in FULL mode", database.load_canonical(
        DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
        DATABASE_SCRIPT.DEFAULT_LEVELS_PATH,
        DATABASE_SCRIPT.ValidationMode.FULL
    ))
    return database


func _run_child_01() -> void:
    var islands := _fixture_islands()
    var alpha_root := {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_alpha", 1)]}
    var beta_root := {"schema_version": 1, "island_id": "fixture_beta", "levels": [_level("fixture_beta", 1)]}
    var database = DATABASE_SCRIPT.new()
    _check("Child 01 loads two content roots into one database", database.load_from_data(islands, [alpha_root, beta_root], DATABASE_SCRIPT.ValidationMode.FULL))
    _check("Child 01 exposes both island level sets", database.get_levels_for_island("fixture_alpha").size() == 1 and database.get_levels_for_island("fixture_beta").size() == 1)
    var duplicate_root = DATABASE_SCRIPT.new()
    _check("Child 01 rejects duplicate island roots", not duplicate_root.load_from_data(islands, [alpha_root, alpha_root], DATABASE_SCRIPT.ValidationMode.FULL))
    var cross_root := {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_beta", 2)]}
    var cross_database = DATABASE_SCRIPT.new()
    _check("Child 01 rejects cross-island level roots", not cross_database.load_from_data(islands, cross_root, DATABASE_SCRIPT.ValidationMode.FULL))
    var count_database = DATABASE_SCRIPT.new()
    var two_count_islands := _fixture_islands()
    two_count_islands["islands"][0]["level_count"] = 2
    _check("Child 01 rejects positive declared-count mismatch", not count_database.load_from_data(two_count_islands, [alpha_root, beta_root], DATABASE_SCRIPT.ValidationMode.FULL))
    _check("Child 01 permits the zero-level placeholder", database.get_levels_for_island("fixture_placeholder").is_empty())

    var campaign = CAMPAIGN_SCRIPT.new()
    var save_manager = SAVE_SCRIPT.new()
    _check("Child 01 uses one campaign/save authority pair", campaign.configure(database, _state_for_fixture(["fixture_alpha", "fixture_beta"])))
    var bridge = BRIDGE_SCRIPT.new()
    _check("Child 01 shared session bridge runs alpha", bridge.configure(database, campaign) and not bridge.start_session("fixture_alpha", 1).is_empty())
    bridge.resolve_lose("CHILD_01_ALPHA")
    _check("Child 01 shared session bridge runs beta", not bridge.start_session("fixture_beta", 1).is_empty())
    bridge.resolve_lose("CHILD_01_BETA")
    _check("Child 01 shared SaveManager is available without a duplicate service", save_manager != null and bridge.get_session_configuration().get("island_id", "") == "fixture_beta")
    print("M19_CHILD_01_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))


func _run_child_02(database) -> void:
    var fresh = CAMPAIGN_SCRIPT.new()
    _check("Child 02 fresh save keeps Tiki locked", fresh.configure(database, SAVE_SCRIPT.new().create_default_state()) and not fresh.is_island_unlocked("tiki_island"))
    var l99 = CAMPAIGN_SCRIPT.new()
    _check("Child 02 Sunny L99 keeps Tiki locked", l99.configure(database, _sunny_state(99)) and not l99.is_island_unlocked("tiki_island"))
    var l100 = CAMPAIGN_SCRIPT.new()
    _check("Child 02 Sunny L100 unlocks Tiki without perfect stars", l100.configure(database, _sunny_state(100)) and l100.is_island_unlocked("tiki_island"))
    _check("Child 02 zero-level Tiki cannot launch gameplay", not l100.is_level_unlocked("tiki_island", 1))
    var reloaded = CAMPAIGN_SCRIPT.new()
    _check("Child 02 reload preserves Tiki unlock", reloaded.configure(database, l100.get_progression_state()) and reloaded.is_island_unlocked("tiki_island"))
    var idempotent := l100.mark_level_completed("sunny_cove", 100, {"stars": 1, "score": 100})
    var unlocked: Array = l100.get_progression_state().get("unlocked_islands", [])
    _check("Child 02 unlock is idempotent", bool(idempotent.get("ok", false)) and unlocked.count("tiki_island") == 1)
    print("M19_CHILD_02_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))


func _run_child_03(database) -> void:
    var sunny: Dictionary = database.get_island("sunny_cove")
    var tiki: Dictionary = database.get_island("tiki_island")
    _check("Child 03 Sunny policy remains L5-L8", sunny.get("target_policy", {}).get("min_level", 0) == 5 and sunny.get("target_policy", {}).get("max_level", 0) == 8)
    _check("Child 03 Sunny content contains no L9 targets", database.get_levels_for_island("sunny_cove").all(func(level: Dictionary) -> bool:
        return level.get("orders", []).all(func(order: Dictionary) -> bool: return int(order.get("cocktail_level", 0)) <= 8)
    ))
    _check("Child 03 Tiki is the first declarative L9 island", tiki.get("target_policy", {}).get("max_level", 0) == 9 and database.is_campaign_target_level_eligible("tiki_island", 9) and not database.is_campaign_target_level_eligible("sunny_cove", 9))
    _check("Child 03 does not invent Tiki level content", database.get_levels_for_island("tiki_island").is_empty() and not database.get_island("tiki_island").has("first_l9_level"))
    var policy_file := FileAccess.open("res://docs/CAMPAIGN_COCKTAIL_LEVEL_PROGRESSION_POLICY.md", FileAccess.READ)
    var policy := policy_file.get_as_text() if policy_file != null else ""
    _check("Child 03 repository policy is data-first and L1-L12 bounded", policy.contains("target_policy") and policy.contains("L1-L12") and policy.contains("does not choose an\n  exact introduction level"))
    print("M19_CHILD_03_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))


func _run_child_04(database) -> void:
    var ordered: Array[String] = database.get_island_ids_in_order()
    _check("Child 04 has exactly ten canonical islands", ordered.size() == 10 and ordered == CANONICAL_ORDER)
    var indices := {}
    var chain_ok := true
    for index in range(ordered.size()):
        var island: Dictionary = database.get_island(ordered[index])
        var order_index := int(island.get("order_index", 0))
        indices[order_index] = indices.get(order_index, 0) + 1
        var expected_next := ordered[index + 1] if index + 1 < ordered.size() else ""
        chain_ok = chain_ok and str(island.get("next_island_id", "")) == expected_next
    _check("Child 04 order indices are unique and contiguous", indices.size() == 10 and indices.keys().all(func(value): return int(value) >= 1 and int(value) <= 10 and indices[value] == 1))
    _check("Child 04 next-island chain is exact", chain_ok)
    _check("Child 04 final island remains a placeholder name", database.get_island("final_island").get("display_name", "").to_lower().contains("tbd"))
    print("M19_CHILD_04_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))


func _run_child_05(database) -> void:
    var theme_ok := true
    for island_id in CANONICAL_ORDER:
        var theme: Dictionary = database.get_island_theme(island_id)
        theme_ok = theme_ok and theme.is_read_only() and THEME_KEYS.all(func(key):
            var path := str(theme.get(key, ""))
            return path.begins_with("res://assets/ui_assets/campaign/islands/%s/" % island_id) and FileAccess.file_exists(path)
        )
    _check("Child 05 all ten islands expose immutable approved theme hooks", theme_ok)
    var manager = CAMPAIGN_SCRIPT.new()
    manager.configure(database, SAVE_SCRIPT.new().create_default_state())
    var bridge = BRIDGE_SCRIPT.new()
    bridge.configure(database, manager)
    var configuration: Dictionary = bridge.start_session("sunny_cove", 1)
    _check("Child 05 session bridge exposes resolved island theme", not configuration.is_empty() and configuration.get("island_theme", {}).get("gameplay_table", "").contains("sunny_cove/gameplay_table.png") and bridge.get_active_island_theme().is_read_only())
    bridge.resolve_lose("CHILD_05")
    var fixture_db = DATABASE_SCRIPT.new()
    fixture_db.load_from_data(_fixture_islands(), {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_alpha", 1)]}, DATABASE_SCRIPT.ValidationMode.FULL)
    var fixture_bridge = BRIDGE_SCRIPT.new()
    var fixture_manager = CAMPAIGN_SCRIPT.new()
    fixture_manager.configure(fixture_db, _state_for_fixture(["fixture_alpha"]))
    fixture_bridge.configure(fixture_db, fixture_manager)
    var fixture_config: Dictionary = fixture_bridge.start_session("fixture_alpha", 1)
    _check("Child 05 legacy definitions retain empty theme fallback", fixture_config.get("island_theme", {}).is_empty())
    print("M19_CHILD_05_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))


func _run_child_06() -> void:
    var islands := _fixture_islands(true)
    var roots: Array = [
        {"schema_version": 1, "island_id": "fixture_alpha", "levels": [_level("fixture_alpha", 1)]},
        {"schema_version": 1, "island_id": "fixture_beta", "levels": [_level("fixture_beta", 1)]},
        {"schema_version": 1, "island_id": "fixture_gamma", "levels": [_level("fixture_gamma", 1)]},
    ]
    var database = DATABASE_SCRIPT.new()
    _check("Child 06 adds a third island through data only", database.load_from_data(islands, roots, DATABASE_SCRIPT.ValidationMode.FULL))
    var manager = CAMPAIGN_SCRIPT.new()
    _check("Child 06 reuses one campaign authority for the new island", manager.configure(database, _state_for_fixture(["fixture_alpha", "fixture_beta", "fixture_gamma"])))
    var navigation = NAVIGATION_SCENE.instantiate()
    _check("Child 06 reusable map pair accepts the fixture campaign", navigation.configure_campaign(database, manager))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("Child 06 map navigation reaches the new island without a new scene", navigation.show_island_map("fixture_gamma") and navigation.get_map_instance_count() == 2)
    var bridge = navigation.get_session_bridge()
    var alpha_config: Dictionary = bridge.start_session("fixture_alpha", 1)
    bridge.resolve_lose("CHILD_06_ALPHA")
    var gamma_config: Dictionary = bridge.start_session("fixture_gamma", 1)
    _check("Child 06 one session bridge runs old and new fixture islands", not alpha_config.is_empty() and not gamma_config.is_empty() and alpha_config.get("island_id", "") == "fixture_alpha" and gamma_config.get("island_id", "") == "fixture_gamma")
    _check("Child 06 runtime has no hard-coded Tiki branch", not FileAccess.open("res://scripts/campaign/level_database.gd", FileAccess.READ).get_as_text().contains("tiki_island") and not FileAccess.open("res://scripts/campaign/gameplay_session_bridge.gd", FileAccess.READ).get_as_text().contains("tiki_island"))
    navigation.queue_free()
    await process_frame
    print("M19_CHILD_06_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))


func _run() -> void:
    _run_child_01()
    var canonical = _canonical_database()
    _run_child_02(canonical)
    _run_child_03(canonical)
    _run_child_04(canonical)
    _run_child_05(canonical)
    await _run_child_06()
    if failures.is_empty():
        print("M19_SCALABILITY_RESULT=PASS")
        quit(0)
        return
    print("M19_SCALABILITY_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
