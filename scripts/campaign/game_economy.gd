class_name GameEconomy
extends RefCounted

## Bounded campaign economy API. This is a ledger/inventory boundary only;
## purchases, ads, and booster gameplay are intentionally deferred.

var coins := 0
var boosters: Dictionary = {}
var _granted_reward_ids: Dictionary = {}


func configure(initial_coins: int = 0, initial_boosters: Dictionary = {}) -> void:
    coins = maxi(0, initial_coins)
    boosters = initial_boosters.duplicate(true)


func get_booster_count(booster_id: String) -> int:
    return maxi(0, int(boosters.get(booster_id, 0)))


func grant_reward(reward_id: String, reward: Dictionary) -> Dictionary:
    if reward_id.is_empty():
        return {"ok": false, "reason": "REWARD_ID_REQUIRED"}
    if _granted_reward_ids.has(reward_id):
        return {"ok": true, "granted": false, "duplicate": true}
    var coins_delta := int(reward.get("coins", 0))
    if coins_delta < 0:
        return {"ok": false, "reason": "NEGATIVE_COIN_REWARD"}
    coins += coins_delta
    var booster_id := str(reward.get("booster_id", ""))
    var booster_quantity := int(reward.get("booster_quantity", 0))
    if not booster_id.is_empty() and booster_quantity > 0:
        boosters[booster_id] = get_booster_count(booster_id) + booster_quantity
    _granted_reward_ids[reward_id] = true
    return {"ok": true, "granted": true, "duplicate": false}


func has_granted_reward(reward_id: String) -> bool:
    return _granted_reward_ids.has(reward_id)


func get_ledger_state() -> Dictionary:
    return {
        "coins": coins,
        "boosters": boosters.duplicate(true),
        "granted_reward_ids": _granted_reward_ids.keys(),
    }
