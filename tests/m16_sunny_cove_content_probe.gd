extends SceneTree

## Focused M16 V01 probe for the canonical Sunny Cove normal-content table.
## The expected signatures and timers mirror the locked V1 progression table.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT = preload("res://scripts/campaign/campaign_manager.gd")

const EXPECTED_TIMERS: Array = [
    20, 20, 40, 40, 40, 60, 60, 60, 80, 80,
    60, 80, 80, 80, 100, 80, 100, 100, 100, 120,
    80, 100, 100, 120, 100, 120, 120, 120, 140, 140,
    100, 120, 120, 140, 120, 140, 140, 160, 140, 160,
    120, 140, 160, 140, 160, 160, 180, 160, 180, 180,
    140, 160, 180, 160, 180, 200, 180, 200, 200, 220,
    160, 180, 200, 180, 200, 220, 200, 220, 240, 220,
    180, 200, 220, 200, 220, 240, 220, 240, 260, 240,
    200, 220, 240, 220, 240, 260, 240, 260, 280, 260,
    220, 240, 260, 240, 260, 280, 260, 280, 280, 300,
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


func _run() -> void:
    _check("approved expected table contains 100 timers", EXPECTED_TIMERS.size() == 100)
    _check("approved expected table contains 100 costs", EXPECTED_COSTS.size() == 100)
    _check("approved expected table contains 100 order rows", EXPECTED_ORDER_SIGNATURES.size() == 100)

    var database = DATABASE_SCRIPT.new()
    var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL)
    _check("canonical Sunny Cove loads in FULL validation mode", loaded)
    _check("Sunny Cove declares 100 levels", int(database.get_island("sunny_cove").get("level_count", 0)) == 100)

    var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
    _check("canonical Sunny Cove has exactly 100 loaded levels", levels.size() == 100)
    for index in range(levels.size()):
        var level: Dictionary = levels[index]
        var expected_id := index + 1
        var level_id := int(level.get("level_id", 0))
        var orders: Array = level.get("orders", [])
        _check("L%d id is sequential" % expected_id, level_id == expected_id)
        _check("L%d island reference is Sunny Cove" % expected_id, str(level.get("island_id", "")) == "sunny_cove")
        _check("L%d matches the approved normal objective row" % expected_id, _order_signature(orders) == EXPECTED_ORDER_SIGNATURES[index])
        _check("L%d matches the approved timer row" % expected_id, int(level.get("time_limit_sec", 0)) == EXPECTED_TIMERS[index])
        _check("L%d matches the approved merge-cost row" % expected_id, _objective_cost(orders) == EXPECTED_COSTS[index])
        _check("L%d normal targets stay within L5-L8" % expected_id, orders.all(func(order: Dictionary) -> bool: return int(order.get("cocktail_level", 0)) >= 5 and int(order.get("cocktail_level", 0)) <= 8))
        _check("L%d keeps VIP content neutral in V01" % expected_id, level.get("vip", null) == null and not bool(level.get("feature_flags", {}).get("vip", true)))
        _check("L%d normal objective cost follows the merge model" % expected_id, _objective_cost(orders) > 0)

    _check("merge cost L5 is 16", _merge_cost(5) == 16)
    _check("merge cost L6 is 32", _merge_cost(6) == 32)
    _check("merge cost L7 is 64", _merge_cost(7) == 64)
    _check("merge cost L8 is 128", _merge_cost(8) == 128)
    _check("Level 1 anchor is 1xL5 at 20 seconds", _objective_cost(levels[0]["orders"]) == 16 and int(levels[0]["time_limit_sec"]) == 20 and _order_signature(levels[0]["orders"]) == "5:1")
    _check("Level 100 anchor is L8+L7+L6+L5 at 300 seconds", _objective_cost(levels[99]["orders"]) == 240 and int(levels[99]["time_limit_sec"]) == 300 and _order_signature(levels[99]["orders"]) == "8:1,7:1,6:1,5:1")
    _check("VIP cost is excluded from normal timer validation", levels.all(func(level: Dictionary) -> bool: return level.get("vip", null) == null and _objective_cost(level["orders"]) >= 0))

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

    if failures.is_empty():
        print("M16_SUNNY_COVE_CONTENT_RESULT=PASS")
        quit(0)
        return
    print("M16_SUNNY_COVE_CONTENT_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
