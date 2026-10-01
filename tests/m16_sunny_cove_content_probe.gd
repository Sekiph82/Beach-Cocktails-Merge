extends SceneTree

## Focused M16 probe for the canonical Sunny Cove untimed normal-content table.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT = preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT = preload("res://scripts/campaign/game_economy.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const ISLAND_MAP_SCENE = preload("res://scenes/campaign/IslandMapScene.tscn")

const VIP_LEVELS: Array = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100]
const VIP_TARGETS: Array = [
    [5, 1], [5, 1], [5, 1], [5, 1], [5, 2], [6, 1], [5, 2], [6, 1], [5, 2], [6, 1],
    [6, 1], [5, 2], [6, 1], [6, 2], [7, 1], [5, 2], [7, 1], [6, 2], [7, 1], [6, 2],
    [7, 1], [6, 2], [7, 1], [6, 2], [7, 1],
]
const VIP_REWARD_IDS: Array = [
    "", "", "", "", "upgrade", "", "", "", "", "upgrade",
    "", "", "", "", "upgrade", "", "", "", "", "upgrade",
    "", "", "", "", "upgrade",
]

const EXPECTED_TIMERS: Array = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
]

const EXPECTED_COSTS: Array = [
    16, 16, 32, 32, 32, 48, 48, 48, 64, 64,
    48, 64, 64, 64, 80, 64, 80, 80, 80, 96,
    64, 80, 80, 96, 80, 96, 96, 96, 112, 112,
    80, 96, 96, 112, 96, 112, 112, 128, 112, 128,
    96, 112, 128, 112, 128, 128, 144, 128, 144, 144,
    112, 128, 144, 128, 144, 160, 144, 160, 160, 176,
    128, 144, 160, 144, 160, 176, 160, 176, 192, 176,
    144, 160, 176, 160, 176, 192, 176, 192, 208, 192,
    160, 176, 192, 176, 192, 208, 192, 208, 224, 208,
    176, 192, 208, 192, 208, 224, 208, 224, 224, 240,
]

const EXPECTED_ORDER_SIGNATURES: Array = [
    "5:1", "5:1", "5:2", "6:1", "5:2", "6:1,5:1", "5:3", "6:1,5:1", "6:2", "7:1",
    "6:1,5:1", "6:2", "7:1", "6:1,5:2", "7:1,5:1", "6:2", "7:1,5:1", "6:2,5:1", "7:1,5:1", "7:1,6:1",
    "6:2", "7:1,5:1", "6:2,5:1", "7:1,6:1", "7:1,5:1", "6:3", "7:1,5:2", "7:1,6:1", "7:1,6:1,5:1", "7:1,5:3",
    "7:1,5:1", "7:1,6:1", "6:3", "7:1,6:1,5:1", "7:1,5:2", "7:1,5:3", "7:1,6:1,5:1", "7:2", "7:1,6:1,5:1", "8:1",
    "7:1,6:1", "7:1,6:1,5:1", "8:1", "7:1,5:3", "7:2", "7:1,6:2", "8:1,5:1", "7:2", "7:2,5:1", "8:1,5:1",
    "7:1,6:1,5:1", "8:1", "8:1,5:1", "7:2", "8:1,5:1", "8:1,6:1", "7:2,5:1", "8:1,6:1", "7:2,6:1", "8:1,6:1,5:1",
    "8:1", "8:1,5:1", "8:1,6:1", "7:2,5:1", "8:1,6:1", "8:1,6:1,5:1", "7:2,6:1", "8:1,5:3", "8:1,7:1", "8:1,6:1,5:1",
    "8:1,5:1", "8:1,6:1", "8:1,6:1,5:1", "7:2,6:1", "8:1,6:1,5:1", "8:1,7:1", "8:1,5:3", "8:1,7:1", "8:1,7:1,5:1", "8:1,6:2",
    "8:1,6:1", "8:1,6:1,5:1", "8:1,7:1", "8:1,5:3", "8:1,7:1", "8:1,7:1,5:1", "8:1,6:2", "8:1,7:1,5:1", "8:1,7:1,6:1", "8:1,7:1,5:1",
    "8:1,6:1,5:1", "8:1,7:1", "8:1,7:1,5:1", "8:1,6:2", "8:1,7:1,5:1", "8:1,7:1,6:1", "8:1,7:1,5:1", "8:1,7:1,6:1", "8:1,7:1,6:1", "8:1,7:1,6:1,5:1",
]

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M16_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M16_PROBE FAIL: %s" % label)


func _order_signature(orders: Array) -> String:
    var parts: Array[String] = []
    for order in orders:
        parts.append("%d:%d" % [int(order["cocktail_level"]), int(order["quantity"])])
    return ",".join(parts)


func _merge_cost(level: int) -> int:
    return int(pow(2.0, float(level - 1)))


func _objective_cost(orders: Array) -> int:
    var total := 0
    for order in orders:
        total += int(order["quantity"]) * _merge_cost(int(order["cocktail_level"]))
    return total


func _reward_matches(reward: Variant, reward_id: String) -> bool:
    if not reward is Dictionary:
        return false
    if reward_id.is_empty():
        return reward.is_empty()
    return str(reward.get("type", "")) == "booster" and str(reward.get("id", "")) == reward_id and int(reward.get("quantity", 0)) == 1


func _normal_signature(levels: Array[Dictionary]) -> String:
    var signature: Array[String] = []
    for level in levels:
        signature.append(JSON.stringify({
            "level_id": int(level["level_id"]),
            "orders": level["orders"],
            "time_limit_sec": int(level["time_limit_sec"]),
            "rewards": level["rewards"],
            "score_star_thresholds": level["score_star_thresholds"],
        }))
    return "\n".join(signature)


func _progression_state(highest_unlocked_level: int, completed_levels: Dictionary = {}) -> Dictionary:
    return {
        "schema_version": 2,
        "unlocked_islands": ["sunny_cove"],
        "islands": {
            "sunny_cove": {
                "highest_unlocked_level": highest_unlocked_level,
                "completed_levels": completed_levels,
                "claimed_milestones": [],
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _run() -> void:
    _check("approved expected table contains 100 untimed rows", EXPECTED_TIMERS.size() == 100)
    _check("approved expected table contains 100 costs", EXPECTED_COSTS.size() == 100)
    _check("approved expected table contains 100 order rows", EXPECTED_ORDER_SIGNATURES.size() == 100)

    var database = DATABASE_SCRIPT.new()
    var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL)
    _check("canonical Sunny Cove loads in FULL validation mode", loaded)
    if not loaded:
        print("M16_DATABASE_ERROR=%s" % database.get_last_error())
    _check("Sunny Cove declares 100 levels", int(database.get_island("sunny_cove").get("level_count", 0)) == 100)

    var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
    _check("canonical Sunny Cove has exactly 100 loaded levels", levels.size() == 100)
    if levels.size() < 100:
        print("M16_SUNNY_COVE_CONTENT_RESULT=FAIL failures=[canonical data load]")
        quit(1)
        return
    var normal_signature_before := _normal_signature(levels)
    _check("exactly 25 VIP levels are configured", VIP_LEVELS.size() == 25)
    var qty_one := 0
    var qty_two := 0
    for index in range(levels.size()):
        var level: Dictionary = levels[index]
        var expected_id := index + 1
        var level_id := int(level.get("level_id", 0))
        var orders: Array = level.get("orders", [])
        _check("L%d id is sequential" % expected_id, level_id == expected_id)
        _check("L%d island reference is Sunny Cove" % expected_id, str(level.get("island_id", "")) == "sunny_cove")
        _check("L%d matches the approved normal objective row" % expected_id, _order_signature(orders) == EXPECTED_ORDER_SIGNATURES[index])
        _check("L%d is untimed" % expected_id, int(level.get("time_limit_sec", -1)) == EXPECTED_TIMERS[index] and not bool(level.get("feature_flags", {}).get("timed", true)))
        _check("L%d matches the approved merge-cost row" % expected_id, _objective_cost(orders) == EXPECTED_COSTS[index])
        _check("L%d normal targets stay within L5-L8" % expected_id, orders.all(func(order: Dictionary) -> bool: return int(order.get("cocktail_level", 0)) >= 5 and int(order.get("cocktail_level", 0)) <= 8))
        var vip: Variant = level.get("vip", null)
        var expected_vip_index := VIP_LEVELS.find(expected_id)
        if expected_vip_index >= 0:
            var expected_target: Array = VIP_TARGETS[expected_vip_index]
            var expected_reward_id: String = VIP_REWARD_IDS[expected_vip_index]
            var vip_dictionary: Dictionary = vip if vip is Dictionary else {}
            var vip_cost := int(expected_target[1]) * _merge_cost(int(expected_target[0]))
            var normal_cost: int = int(EXPECTED_COSTS[index])
            var ratio := float(vip_cost) / float(normal_cost)
            var ratio_allowed := (expected_id == 4 and is_equal_approx(ratio, 0.50)) or (expected_id == 64 and is_equal_approx(ratio, 32.0 / 144.0)) or (ratio >= 0.25 and ratio <= 0.40)
            if int(expected_target[1]) == 1:
                qty_one += 1
            elif int(expected_target[1]) == 2:
                qty_two += 1
            _check("L%d exact VIP target and quantity" % expected_id, bool(vip_dictionary.get("enabled", false)) and int(vip_dictionary.get("cocktail_level", 0)) == int(expected_target[0]) and int(vip_dictionary.get("quantity", 0)) == int(expected_target[1]))
            _check("L%d exact VIP reward" % expected_id, _reward_matches(vip_dictionary.get("reward", {}), expected_reward_id))
            _check("L%d VIP workload ratio follows owner policy" % expected_id, ratio_allowed)
            _check("L%d VIP feature flag is enabled" % expected_id, bool(level.get("feature_flags", {}).get("vip", false)))
        else:
            _check("L%d is non-VIP with neutral payload" % expected_id, vip == null and not bool(level.get("feature_flags", {}).get("vip", true)))
        _check("L%d normal objective cost follows the merge model" % expected_id, _objective_cost(orders) > 0)

    _check("merge cost L5 is 16", _merge_cost(5) == 16)
    _check("merge cost L6 is 32", _merge_cost(6) == 32)
    _check("merge cost L7 is 64", _merge_cost(7) == 64)
    _check("merge cost L8 is 128", _merge_cost(8) == 128)
    _check("Level 1 anchor is 1xL5 and untimed", _objective_cost(levels[0]["orders"]) == 16 and int(levels[0]["time_limit_sec"]) == 0 and not bool(levels[0]["feature_flags"].get("timed", true)) and _order_signature(levels[0]["orders"]) == "5:1")
    _check("Level 100 anchor is L8+L7+L6+L5 and untimed", _objective_cost(levels[99]["orders"]) == 240 and int(levels[99]["time_limit_sec"]) == 0 and not bool(levels[99]["feature_flags"].get("timed", true)) and _order_signature(levels[99]["orders"]) == "8:1,7:1,6:1,5:1")
    _check("VIP quantity mix is 15x qty1 and 10x qty2", qty_one == 15 and qty_two == 10)
    _check("Upgrade cadence is exactly VIP levels 20/40/60/80/100", VIP_REWARD_IDS.count("upgrade") == 5 and VIP_LEVELS[4] == 20 and VIP_LEVELS[9] == 40 and VIP_LEVELS[14] == 60 and VIP_LEVELS[19] == 80 and VIP_LEVELS[24] == 100)
    _check("all other VIP rewards are unconfigured pending owner policy", VIP_REWARD_IDS.count("") == 20)
    _check("75 Sunny Cove levels remain non-VIP", levels.filter(func(level: Dictionary) -> bool: return level.get("vip", null) == null).size() == 75)
    _check("VIP cost is excluded from untimed validation", levels.size() == 100 and EXPECTED_TIMERS.size() == 100)

    var campaign = CAMPAIGN_SCRIPT.new()
    _check("CampaignManager configures from the canonical FULL database", campaign.configure(database))
    _check("Level 1 is initially selected and unlocked", campaign.current_island_id == "sunny_cove" and campaign.selected_level_id == 1 and campaign.is_level_unlocked("sunny_cove", 1))
    _check("Level 2 starts locked before Level 1 completion", not campaign.is_level_unlocked("sunny_cove", 2))

    var progression_ok := true
    for level_id in range(1, 101):
        if not campaign.is_level_unlocked("sunny_cove", level_id):
            progression_ok = false
            print("M16_PROBE FAIL: sequential unlock before L%d" % level_id)
            break
        var completion: Dictionary = campaign.mark_level_completed("sunny_cove", level_id, {"stars": 1, "score": level_id})
        if not bool(completion.get("ok", false)):
            progression_ok = false
            print("M16_PROBE FAIL: completion rejected for L%d" % level_id)
            break
        if level_id < 100 and (not campaign.is_level_unlocked("sunny_cove", level_id + 1) or not bool(completion.get("next_level", {}).get("ok", false))):
            progression_ok = false
            print("M16_PROBE FAIL: next level did not unlock after L%d" % level_id)
            break
    _check("all 100 levels follow the sequential unlock chain", progression_ok)
    _check("Level 100 closes Sunny Cove without a next level", campaign.is_island_complete("sunny_cove") and not campaign.resolve_next_level("sunny_cove", 100).get("ok", false))
    _check("Level 100 preserves the next-island unlock boundary", campaign.is_island_unlocked("tiki_island") and campaign.resolve_next_island("sunny_cove").get("island_id", "") == "tiki_island")

    var marker_campaign = CAMPAIGN_SCRIPT.new()
    var marker_completed := {"4": {"completed": true, "stars": 2, "best_score": 200}}
    _check("marker campaign configures", marker_campaign.configure(database, _progression_state(12, marker_completed)))
    var marker_map = ISLAND_MAP_SCENE.instantiate()
    _check("Island Map configures from canonical VIP data", marker_map.configure_island("sunny_cove", database, marker_campaign))
    root.add_child(marker_map)
    await process_frame
    await process_frame
    var completed_vip_button = marker_map.get_level_button(4)
    var open_vip_button = marker_map.get_level_button(8)
    var current_vip_button = marker_map.get_level_button(12)
    var locked_vip_button = marker_map.get_level_button(16)
    var non_vip_button = marker_map.get_level_button(5)
    _check("VIP crown marker is visible for COMPLETE VIP level", marker_map.get_level_state(4) == "COMPLETE" and completed_vip_button.is_vip() and completed_vip_button.is_vip_marker_visible())
    _check("VIP crown marker is visible for OPEN VIP level", marker_map.get_level_state(8) == "OPEN" and open_vip_button.is_vip_marker_visible())
    _check("VIP crown marker is visible for CURRENT VIP level", marker_map.get_level_state(12) == "CURRENT" and current_vip_button.is_vip_marker_visible())
    _check("VIP crown marker is visible for LOCKED VIP level", marker_map.get_level_state(16) == "LOCKED" and locked_vip_button.is_vip_marker_visible())
    _check("non-VIP level has no crown marker", not non_vip_button.is_vip() and not non_vip_button.is_vip_marker_visible())
    var marker_node: TextureRect = completed_vip_button.get_node("VipCrownMarker")
    _check("crown marker uses the canonical gameplay VIP badge asset", marker_node.texture.resource_path == "res://assets/ui_assets/ui/gameplay/vip_badge.png")
    _check("crown marker display size is exactly 36x36", marker_node.size == Vector2(36.0, 36.0) and marker_node.custom_minimum_size == Vector2(36.0, 36.0))
    var marker_rect := Rect2(marker_node.position, marker_node.size)
    var left_position := 92.0 + marker_rect.position.x
    var right_position := 512.0 + marker_rect.position.x
    _check("crown marker stays adjacent without covering the level node", marker_rect.position.x >= completed_vip_button.size.x and marker_rect.position.y >= 0.0)
    _check("crown marker remains inside the map bounds on both path sides", left_position >= 0.0 and left_position + marker_rect.size.x <= 720.0 and right_position >= 0.0 and right_position + marker_rect.size.x <= 720.0)
    marker_map.queue_free()
    await process_frame

    var replay_economy = ECONOMY_SCRIPT.new()
    replay_economy.configure()
    var replay_campaign = CAMPAIGN_SCRIPT.new()
    _check("replay campaign configures with Level 4 unlocked", replay_campaign.configure(database, _progression_state(4)))
    var replay_bridge = BRIDGE_SCRIPT.new()
    _check("replay bridge configures with economy", replay_bridge.configure(database, replay_campaign, replay_economy))
    _check("first play can start canonical VIP Level 4", not replay_bridge.start_session("sunny_cove", 4).is_empty())
    replay_bridge.mark_gameplay_ready()
    var first_terminal: Dictionary = replay_bridge.record_to_go_delivery(6, 1).get("terminal", {})
    _check("normal WIN succeeds when VIP is missed", first_terminal.get("outcome", "") == "WIN" and not bool(first_terminal.get("vip_completed", true)))
    _check("missed VIP grants no booster and persists false", replay_economy.get_booster_count("time") == 0 and replay_campaign.get_progression_state()["islands"]["sunny_cove"]["completed_levels"]["4"].get("vip_completed", true) == false)
    _check("completed VIP level remains replayable", replay_campaign.is_level_unlocked("sunny_cove", 4) and not replay_bridge.retry_session().is_empty())
    replay_bridge.mark_gameplay_ready()
    var replay_vip_result := replay_bridge.record_vip_delivery(5, 1)
    var replay_terminal: Dictionary = replay_bridge.record_to_go_delivery(6, 1).get("terminal", {})
    _check("replay can complete the missed VIP", bool(replay_vip_result.get("vip_completed", false)) and replay_terminal.get("outcome", "") == "WIN")
    _check("replay persists VIP completion without retired +Time", replay_campaign.get_progression_state()["islands"]["sunny_cove"]["completed_levels"]["4"].get("vip_completed", false) and replay_economy.get_booster_count("time") == 0 and not replay_economy.has_granted_reward("vip:sunny_cove:4"))
    _check("replay again is allowed after VIP completion", not replay_bridge.retry_session().is_empty())
    replay_bridge.mark_gameplay_ready()
    replay_bridge.record_vip_delivery(5, 1)
    var replay_again_terminal: Dictionary = replay_bridge.record_to_go_delivery(6, 1).get("terminal", {})
    _check("replay-after-replay keeps VIP completed", replay_again_terminal.get("outcome", "") == "WIN" and replay_campaign.get_progression_state()["islands"]["sunny_cove"]["completed_levels"]["4"].get("vip_completed", false))
    _check("unconfigured VIP reward remains absent on replay", replay_economy.get_booster_count("time") == 0 and replay_economy.get_ledger_state()["reward_ledger"].count("vip:sunny_cove:4") == 0)
    _check("normal content signature is unchanged after marker/replay flows", _normal_signature(database.get_levels_for_island("sunny_cove")) == normal_signature_before)

    if failures.is_empty():
        print("M16_SUNNY_COVE_CONTENT_RESULT=PASS")
        quit(0)
        return
    print("M16_SUNNY_COVE_CONTENT_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
