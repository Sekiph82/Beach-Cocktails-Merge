class_name GameEconomy
extends RefCounted

## The single in-memory campaign economy authority. Purchases, ads, and
## monetized services are intentionally outside this bounded M15 surface.

const BOOSTER_TIME := "time"

var coins := 0
var boosters: Dictionary = {}
var _granted_reward_ids: Dictionary = {}


func configure(initial_coins: int = 0, initial_boosters: Dictionary = {}, initial_reward_ledger: Array = []) -> void:
    coins = maxi(0, initial_coins)
    boosters = _sanitize_boosters(initial_boosters)
    _granted_reward_ids.clear()
    for reward_id in initial_reward_ledger:
        if typeof(reward_id) == TYPE_STRING and not str(reward_id).is_empty():
            _granted_reward_ids[str(reward_id)] = true


func configure_from_state(state: Dictionary) -> Dictionary:
    var candidate := {
        "coins": state.get("coins", 0),
        "boosters": state.get("boosters", {}),
        "reward_ledger": state.get("reward_ledger", state.get("granted_reward_ids", [])),
    }
    var validation := validate_state(candidate)
    if not validation["ok"]:
        return validation
    configure(int(candidate["coins"]), candidate["boosters"], candidate["reward_ledger"])
    return {"ok": true, "reason": "ECONOMY_CONFIGURED"}


func get_booster_count(booster_id: String) -> int:
    return maxi(0, int(boosters.get(booster_id, 0)))


func get_booster_inventory() -> Dictionary:
    return boosters.duplicate(true)


func grant_booster(booster_id: String, quantity: int) -> Dictionary:
    if booster_id.is_empty():
        return {"ok": false, "reason": "BOOSTER_ID_REQUIRED"}
    if quantity <= 0:
        return {"ok": false, "reason": "BOOSTER_QUANTITY_MUST_BE_POSITIVE"}
    boosters[booster_id] = get_booster_count(booster_id) + quantity
    return {"ok": true, "granted": true, "booster_id": booster_id, "quantity": quantity, "count": get_booster_count(booster_id)}


func consume_booster(booster_id: String, quantity: int = 1) -> Dictionary:
    if booster_id.is_empty():
        return {"ok": false, "reason": "BOOSTER_ID_REQUIRED"}
    if quantity <= 0:
        return {"ok": false, "reason": "BOOSTER_QUANTITY_MUST_BE_POSITIVE"}
    var current := get_booster_count(booster_id)
    if current < quantity:
        return {"ok": false, "reason": "INSUFFICIENT_BOOSTER", "available": current, "requested": quantity}
    boosters[booster_id] = current - quantity
    return {"ok": true, "consumed": true, "booster_id": booster_id, "quantity": quantity, "count": current - quantity}


func grant_coins(quantity: int) -> Dictionary:
    if quantity < 0:
        return {"ok": false, "reason": "NEGATIVE_COIN_REWARD"}
    coins += quantity
    return {"ok": true, "coins_delta": quantity, "coins": coins}


func grant_reward(reward_id: String, reward: Dictionary) -> Dictionary:
    if reward_id.is_empty():
        return {"ok": false, "reason": "REWARD_ID_REQUIRED"}
    if _granted_reward_ids.has(reward_id):
        return {"ok": true, "granted": false, "duplicate": true, "reward_id": reward_id}

    var normalized := _normalize_reward(reward)
    if not normalized["ok"]:
        return normalized
    # Validate the complete mutation before changing either balance. This keeps
    # malformed mixed rewards from partially granting coins or inventory.
    var next_coins := coins + int(normalized["coins"])
    var next_boosters := boosters.duplicate(true)
    var booster_id := str(normalized["booster_id"])
    var booster_quantity := int(normalized["booster_quantity"])
    if not booster_id.is_empty():
        next_boosters[booster_id] = get_booster_count(booster_id) + booster_quantity

    coins = next_coins
    boosters = next_boosters
    _granted_reward_ids[reward_id] = true
    return {"ok": true, "granted": true, "duplicate": false, "reward_id": reward_id, "coins_delta": int(normalized["coins"]), "booster_id": booster_id, "booster_quantity": booster_quantity}


func has_granted_reward(reward_id: String) -> bool:
    return _granted_reward_ids.has(reward_id)


func export_state() -> Dictionary:
    var ledger: Array[String] = []
    for reward_id in _granted_reward_ids:
        ledger.append(str(reward_id))
    ledger.sort()
    return {
        "coins": coins,
        "boosters": boosters.duplicate(true),
        "reward_ledger": ledger,
    }


func get_ledger_state() -> Dictionary:
    var state := export_state()
    # Preserve the original read API while the persisted field uses the clearer
    # M15 reward_ledger name.
    state["granted_reward_ids"] = state["reward_ledger"].duplicate(true)
    return state


func validate_state(state: Dictionary) -> Dictionary:
    if not _is_non_negative_integer(state.get("coins", -1)):
        return {"ok": false, "reason": "INVALID_COINS"}
    if not state.get("boosters", {}) is Dictionary:
        return {"ok": false, "reason": "INVALID_BOOSTER_INVENTORY"}
    for booster_id in state.get("boosters", {}):
        if typeof(booster_id) != TYPE_STRING or str(booster_id).is_empty() or not _is_non_negative_integer(state["boosters"][booster_id]):
            return {"ok": false, "reason": "INVALID_BOOSTER_ENTRY"}
    var ledger = state.get("reward_ledger", [])
    if not ledger is Array:
        return {"ok": false, "reason": "INVALID_REWARD_LEDGER"}
    for reward_id in ledger:
        if typeof(reward_id) != TYPE_STRING or str(reward_id).is_empty():
            return {"ok": false, "reason": "INVALID_REWARD_ID"}
    return {"ok": true, "reason": "VALID"}


func _normalize_reward(reward: Dictionary) -> Dictionary:
    var reward_type := str(reward.get("type", ""))
    var coins_delta := 0
    var booster_id := ""
    var booster_quantity := 0
    if reward_type == "coins":
        if not reward.has("quantity") or not _is_non_negative_integer(reward["quantity"]):
            return {"ok": false, "reason": "INVALID_COIN_REWARD"}
        coins_delta = int(reward["quantity"])
    elif reward_type == "booster":
        booster_id = str(reward.get("id", ""))
        booster_quantity = int(reward.get("quantity", 0))
        if booster_id.is_empty() or not _is_positive_integer(reward.get("quantity", 0)):
            return {"ok": false, "reason": "INVALID_BOOSTER_REWARD"}
    else:
        if reward.has("type") and not reward_type.is_empty():
            return {"ok": false, "reason": "INVALID_REWARD_TYPE"}
        # M10/M11 used the original flat shape; keep it as a compatibility form.
        if reward.has("coins"):
            if not _is_non_negative_integer(reward["coins"]):
                return {"ok": false, "reason": "NEGATIVE_OR_INVALID_COIN_REWARD"}
            coins_delta = int(reward["coins"])
        if reward.has("booster_id") or reward.has("booster_quantity"):
            booster_id = str(reward.get("booster_id", ""))
            if booster_id.is_empty() or not _is_positive_integer(reward.get("booster_quantity", 0)):
                return {"ok": false, "reason": "INVALID_BOOSTER_REWARD"}
            booster_quantity = int(reward["booster_quantity"])
        if not reward.has("coins") and not reward.has("booster_id") and not reward.has("booster_quantity"):
            return {"ok": false, "reason": "EMPTY_REWARD"}
    return {"ok": true, "coins": coins_delta, "booster_id": booster_id, "booster_quantity": booster_quantity}


func _sanitize_boosters(value: Dictionary) -> Dictionary:
    var sanitized: Dictionary = {}
    for booster_id in value:
        if typeof(booster_id) != TYPE_STRING or str(booster_id).is_empty():
            continue
        var quantity := int(value[booster_id])
        if quantity > 0:
            sanitized[str(booster_id)] = quantity
    return sanitized


func _is_positive_integer(value: Variant) -> bool:
    return _is_non_negative_integer(value) and int(value) > 0


func _is_non_negative_integer(value: Variant) -> bool:
    if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
        return false
    return float(value) >= 0.0 and is_equal_approx(float(value), float(int(value)))
