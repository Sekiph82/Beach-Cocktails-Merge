class_name GameEconomy
extends RefCounted

## The single in-memory campaign economy authority. Purchases, ads, and
## monetized services are intentionally outside this bounded M15 surface.

const BOOSTER_TIME := "time"
const ENERGY_CAP := 100
const ENERGY_PER_ATTEMPT := 20
const ENERGY_REGEN_INTERVAL_SEC := 180
const ENERGY_REFILL_GEM_COST := 25

var coins := 0
var gems := 0
var energy := ENERGY_CAP
var energy_last_update_unix := 0
var energy_regen_remainder_sec := 0
var retired_focus_inventory := 0
var boosters: Dictionary = {}
var _granted_reward_ids: Dictionary = {}
var _transaction_ids: Dictionary = {}


func configure(initial_coins: int = 0, initial_boosters: Dictionary = {}, initial_reward_ledger: Array = [], initial_gems: int = 0, initial_transaction_ledger: Array = [], initial_energy: int = ENERGY_CAP, initial_energy_last_update_unix: int = 0, initial_energy_regen_remainder_sec: int = 0, initial_retired_focus_inventory: int = 0) -> void:
    coins = maxi(0, initial_coins)
    gems = maxi(0, initial_gems)
    energy = clampi(initial_energy, 0, ENERGY_CAP)
    energy_last_update_unix = maxi(0, initial_energy_last_update_unix)
    energy_regen_remainder_sec = clampi(initial_energy_regen_remainder_sec, 0, ENERGY_REGEN_INTERVAL_SEC - 1)
    retired_focus_inventory = maxi(0, initial_retired_focus_inventory)
    boosters = _sanitize_boosters(initial_boosters)
    _granted_reward_ids.clear()
    for reward_id in initial_reward_ledger:
        if typeof(reward_id) == TYPE_STRING and not str(reward_id).is_empty():
            _granted_reward_ids[str(reward_id)] = true
    _transaction_ids.clear()
    for transaction_id in initial_transaction_ledger:
        if typeof(transaction_id) == TYPE_STRING and not str(transaction_id).is_empty():
            _transaction_ids[str(transaction_id)] = true


func configure_from_state(state: Dictionary) -> Dictionary:
    var candidate := {
        "coins": state.get("coins", 0),
        "boosters": state.get("boosters", {}),
        "reward_ledger": state.get("reward_ledger", state.get("granted_reward_ids", [])),
        "gems": state.get("gems", 0),
        "transaction_ledger": state.get("transaction_ledger", []),
        "energy": state.get("energy", ENERGY_CAP),
        "energy_last_update_unix": state.get("energy_last_update_unix", 0),
        "energy_regen_remainder_sec": state.get("energy_regen_remainder_sec", 0),
        "retired_focus_inventory": state.get("retired_focus_inventory", 0),
    }
    var validation := validate_state(candidate)
    if not validation["ok"]:
        return validation
    configure(int(candidate["coins"]), candidate["boosters"], candidate["reward_ledger"], int(candidate["gems"]), candidate["transaction_ledger"], int(candidate["energy"]), int(candidate["energy_last_update_unix"]), int(candidate["energy_regen_remainder_sec"]), int(candidate["retired_focus_inventory"]))
    if energy_last_update_unix <= 0:
        energy_last_update_unix = _now_unix()
    return {"ok": true, "reason": "ECONOMY_CONFIGURED"}


func refresh_energy(now_unix: int = -1) -> Dictionary:
    var now := now_unix if now_unix >= 0 else _now_unix()
    if energy_last_update_unix <= 0:
        energy_last_update_unix = now
        energy_regen_remainder_sec = 0
        return get_energy_state()
    # A rollback never lowers the durable high-water mark or grants energy.
    if now < energy_last_update_unix:
        return get_energy_state()
    var elapsed := now - energy_last_update_unix
    if energy >= ENERGY_CAP:
        energy = ENERGY_CAP
        energy_regen_remainder_sec = 0
        energy_last_update_unix = now
        return get_energy_state()
    var accumulated := energy_regen_remainder_sec + elapsed
    var earned := int(accumulated / ENERGY_REGEN_INTERVAL_SEC)
    if earned > 0:
        energy = mini(ENERGY_CAP, energy + earned)
        energy_last_update_unix = now
        energy_regen_remainder_sec = 0 if energy >= ENERGY_CAP else accumulated % ENERGY_REGEN_INTERVAL_SEC
    return get_energy_state()


func get_energy_state(now_unix: int = -1) -> Dictionary:
    if now_unix >= 0:
        refresh_energy(now_unix)
    var now := now_unix if now_unix >= 0 else _now_unix()
    var seconds_to_next := 0
    if energy < ENERGY_CAP:
        var elapsed := maxi(0, now - energy_last_update_unix)
        seconds_to_next = maxi(0, ENERGY_REGEN_INTERVAL_SEC - ((energy_regen_remainder_sec + elapsed) % ENERGY_REGEN_INTERVAL_SEC))
    return {"energy": energy, "cap": ENERGY_CAP, "seconds_to_next": seconds_to_next, "last_update_unix": energy_last_update_unix, "remainder_sec": energy_regen_remainder_sec}


func start_attempt_once(transaction_id: String, now_unix: int = -1) -> Dictionary:
    if transaction_id.is_empty():
        return {"ok": false, "reason": "TRANSACTION_ID_REQUIRED"}
    if _transaction_ids.has(transaction_id):
        return {"ok": true, "duplicate": true, "transaction_id": transaction_id, "energy": energy}
    refresh_energy(now_unix)
    if energy < ENERGY_PER_ATTEMPT:
        return {"ok": false, "reason": "INSUFFICIENT_ENERGY", "energy": energy, "required": ENERGY_PER_ATTEMPT}
    energy -= ENERGY_PER_ATTEMPT
    _transaction_ids[transaction_id] = true
    return {"ok": true, "started": true, "duplicate": false, "transaction_id": transaction_id, "energy": energy}


func buy_full_energy_refill(transaction_id: String, now_unix: int = -1) -> Dictionary:
    if transaction_id.is_empty():
        return {"ok": false, "reason": "TRANSACTION_ID_REQUIRED"}
    if _transaction_ids.has(transaction_id):
        return {"ok": true, "duplicate": true, "transaction_id": transaction_id, "energy": energy, "gems": gems}
    refresh_energy(now_unix)
    if energy >= ENERGY_CAP:
        return {"ok": false, "reason": "ENERGY_ALREADY_FULL", "energy": energy}
    if gems < ENERGY_REFILL_GEM_COST:
        return {"ok": false, "reason": "INSUFFICIENT_GEMS", "available": gems, "required": ENERGY_REFILL_GEM_COST}
    gems -= ENERGY_REFILL_GEM_COST
    energy = ENERGY_CAP
    energy_regen_remainder_sec = 0
    energy_last_update_unix = now_unix if now_unix >= 0 else _now_unix()
    _transaction_ids[transaction_id] = true
    return {"ok": true, "refilled": true, "energy": energy, "gems": gems, "transaction_id": transaction_id}


func grant_verified_ad_energy(transaction_id: String, verified_provider_receipt: String, now_unix: int = -1) -> Dictionary:
    if transaction_id.is_empty() or verified_provider_receipt.is_empty():
        return {"ok": false, "reason": "VERIFIED_AD_RECEIPT_REQUIRED"}
    if _transaction_ids.has(transaction_id):
        return {"ok": true, "duplicate": true, "transaction_id": transaction_id, "energy": energy}
    refresh_energy(now_unix)
    if energy >= ENERGY_CAP:
        return {"ok": false, "reason": "ENERGY_ALREADY_FULL", "energy": energy}
    var before_energy := energy
    energy = mini(ENERGY_CAP, energy + 20)
    energy_regen_remainder_sec = 0 if energy >= ENERGY_CAP else energy_regen_remainder_sec
    _transaction_ids[transaction_id] = true
    return {"ok": true, "granted": true, "energy_delta": energy - before_energy, "energy": energy, "transaction_id": transaction_id}


func apply_level_star_reward(global_level_id: int, old_stars: int, new_stars: int) -> Dictionary:
    if global_level_id <= 0 or new_stars <= old_stars:
        return {"ok": true, "granted": false, "reason": "NO_STAR_IMPROVEMENT"}
    var payout := [0, 20, 30, 40]
    var delta: int = payout[clampi(new_stars, 0, 3)] - payout[clampi(old_stars, 0, 3)]
    var result := {"ok": true, "granted": false, "coins_delta": 0, "gems_delta": 0}
    if delta > 0:
        result = grant_reward("level-stars:%d:%d" % [global_level_id, new_stars], {"coins": delta})
        if not bool(result.get("ok", false)):
            return result
    if new_stars >= 3 and global_level_id % 5 == 0:
        var gem_result := grant_reward("level-first-three-star:%d" % global_level_id, {"gems": 1})
        if not bool(gem_result.get("ok", false)):
            return gem_result
        result["gems_delta"] = int(gem_result.get("gems_delta", 0))
        result["three_star_gem"] = gem_result.get("granted", false)
    return result


func grant_island_completion_once(island_id: String) -> Dictionary:
    if island_id.is_empty():
        return {"ok": false, "reason": "ISLAND_ID_REQUIRED"}
    return grant_reward("island-complete:%s" % island_id, {"coins": 200, "gems": 10})


func get_booster_count(booster_id: String) -> int:
    return maxi(0, int(boosters.get(booster_id, 0)))


func get_booster_inventory() -> Dictionary:
    return boosters.duplicate(true)


func grant_booster(booster_id: String, quantity: int) -> Dictionary:
    if booster_id.is_empty():
        return {"ok": false, "reason": "BOOSTER_ID_REQUIRED"}
    if booster_id == "focus":
        return {"ok": false, "reason": "BOOSTER_RETIRED"}
    if quantity <= 0:
        return {"ok": false, "reason": "BOOSTER_QUANTITY_MUST_BE_POSITIVE"}
    boosters[booster_id] = get_booster_count(booster_id) + quantity
    return {"ok": true, "granted": true, "booster_id": booster_id, "quantity": quantity, "count": get_booster_count(booster_id)}


func consume_booster(booster_id: String, quantity: int = 1) -> Dictionary:
    if booster_id.is_empty():
        return {"ok": false, "reason": "BOOSTER_ID_REQUIRED"}
    if booster_id == "focus":
        return {"ok": false, "reason": "BOOSTER_RETIRED"}
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


func grant_gems(quantity: int) -> Dictionary:
    if quantity < 0:
        return {"ok": false, "reason": "NEGATIVE_GEM_REWARD"}
    gems += quantity
    return {"ok": true, "gems_delta": quantity, "gems": gems}


func spend_coins(transaction_id: String, quantity: int) -> Dictionary:
    return _spend_currency(transaction_id, quantity, false)


func spend_gems(transaction_id: String, quantity: int) -> Dictionary:
    return _spend_currency(transaction_id, quantity, true)


func purchase_booster(transaction_id: String, booster_id: String, quantity: int, currency: String, cost: int) -> Dictionary:
    if transaction_id.is_empty() or booster_id.is_empty() or quantity <= 0 or cost < 0 or currency not in ["coins", "gems"]:
        return {"ok": false, "reason": "INVALID_PURCHASE"}
    if booster_id == "focus":
        return {"ok": false, "reason": "BOOSTER_RETIRED"}
    if _transaction_ids.has(transaction_id):
        return {"ok": true, "duplicate": true, "transaction_id": transaction_id}
    var available := coins if currency == "coins" else gems
    if available < cost:
        return {"ok": false, "reason": "INSUFFICIENT_FUNDS", "currency": currency, "available": available, "requested": cost}
    var next_inventory := boosters.duplicate(true)
    next_inventory[booster_id] = get_booster_count(booster_id) + quantity
    if currency == "coins":
        coins -= cost
    else:
        gems -= cost
    boosters = next_inventory
    _transaction_ids[transaction_id] = true
    return {"ok": true, "purchased": true, "transaction_id": transaction_id, "booster_id": booster_id, "quantity": quantity, "currency": currency, "cost": cost}


func consume_booster_once(transaction_id: String, booster_id: String, quantity: int = 1) -> Dictionary:
    if transaction_id.is_empty():
        return {"ok": false, "reason": "TRANSACTION_ID_REQUIRED"}
    if _transaction_ids.has(transaction_id):
        return {"ok": true, "duplicate": true, "transaction_id": transaction_id}
    var result := consume_booster(booster_id, quantity)
    if bool(result.get("ok", false)):
        _transaction_ids[transaction_id] = true
    result["transaction_id"] = transaction_id
    return result


func _spend_currency(transaction_id: String, quantity: int, use_gems: bool) -> Dictionary:
    if transaction_id.is_empty() or quantity <= 0:
        return {"ok": false, "reason": "INVALID_SPEND"}
    if _transaction_ids.has(transaction_id):
        return {"ok": true, "duplicate": true, "transaction_id": transaction_id}
    var balance := gems if use_gems else coins
    if balance < quantity:
        return {"ok": false, "reason": "INSUFFICIENT_FUNDS", "available": balance, "requested": quantity}
    if use_gems:
        gems -= quantity
    else:
        coins -= quantity
    _transaction_ids[transaction_id] = true
    return {"ok": true, "spent": quantity, "currency": "gems" if use_gems else "coins", "balance": gems if use_gems else coins, "transaction_id": transaction_id}


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
    var next_gems := gems + int(normalized["gems"])
    var next_boosters := boosters.duplicate(true)
    var booster_id := str(normalized["booster_id"])
    var booster_quantity := int(normalized["booster_quantity"])
    if not booster_id.is_empty():
        next_boosters[booster_id] = get_booster_count(booster_id) + booster_quantity

    coins = next_coins
    gems = next_gems
    boosters = next_boosters
    _granted_reward_ids[reward_id] = true
    return {"ok": true, "granted": true, "duplicate": false, "reward_id": reward_id, "coins_delta": int(normalized["coins"]), "gems_delta": int(normalized["gems"]), "booster_id": booster_id, "booster_quantity": booster_quantity}


func has_granted_reward(reward_id: String) -> bool:
    return _granted_reward_ids.has(reward_id)


func export_state() -> Dictionary:
    var ledger: Array[String] = []
    for reward_id in _granted_reward_ids:
        ledger.append(str(reward_id))
    ledger.sort()
    return {
        "coins": coins,
        "gems": gems,
        "energy": energy,
        "energy_last_update_unix": energy_last_update_unix,
        "energy_regen_remainder_sec": energy_regen_remainder_sec,
        "retired_focus_inventory": retired_focus_inventory,
        "boosters": boosters.duplicate(true),
        "reward_ledger": ledger,
        "transaction_ledger": _sorted_transaction_ids(),
    }


func get_ledger_state() -> Dictionary:
    var state := export_state()
    # Preserve the original read API while the persisted field uses the clearer
    # M15 reward_ledger name.
    state["granted_reward_ids"] = state["reward_ledger"].duplicate(true)
    return state


func validate_state(state: Dictionary) -> Dictionary:
    if not _is_non_negative_integer(state.get("coins", -1)) or not _is_non_negative_integer(state.get("gems", 0)):
        return {"ok": false, "reason": "INVALID_COINS"}
    if not _is_non_negative_integer(state.get("energy", ENERGY_CAP)) or int(state.get("energy", ENERGY_CAP)) > ENERGY_CAP or not _is_non_negative_integer(state.get("energy_last_update_unix", 0)) or not _is_non_negative_integer(state.get("energy_regen_remainder_sec", 0)) or int(state.get("energy_regen_remainder_sec", 0)) >= ENERGY_REGEN_INTERVAL_SEC or not _is_non_negative_integer(state.get("retired_focus_inventory", 0)):
        return {"ok": false, "reason": "INVALID_ENERGY_STATE"}
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
    var transactions = state.get("transaction_ledger", [])
    if not transactions is Array:
        return {"ok": false, "reason": "INVALID_TRANSACTION_LEDGER"}
    for transaction_id in transactions:
        if typeof(transaction_id) != TYPE_STRING or str(transaction_id).is_empty():
            return {"ok": false, "reason": "INVALID_TRANSACTION_ID"}
    return {"ok": true, "reason": "VALID"}


func _normalize_reward(reward: Dictionary) -> Dictionary:
    var reward_type := str(reward.get("type", ""))
    var coins_delta := 0
    var gems_delta := 0
    var booster_id := ""
    var booster_quantity := 0
    if reward_type == "coins":
        if not reward.has("quantity") or not _is_non_negative_integer(reward["quantity"]):
            return {"ok": false, "reason": "INVALID_COIN_REWARD"}
        coins_delta = int(reward["quantity"])
    elif reward_type == "gems":
        if not reward.has("quantity") or not _is_non_negative_integer(reward["quantity"]):
            return {"ok": false, "reason": "INVALID_GEM_REWARD"}
        gems_delta = int(reward["quantity"])
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
        if reward.has("gems"):
            if not _is_non_negative_integer(reward["gems"]):
                return {"ok": false, "reason": "INVALID_GEM_REWARD"}
            gems_delta = int(reward["gems"])
        if reward.has("booster_id") or reward.has("booster_quantity"):
            booster_id = str(reward.get("booster_id", ""))
            if booster_id.is_empty() or not _is_positive_integer(reward.get("booster_quantity", 0)):
                return {"ok": false, "reason": "INVALID_BOOSTER_REWARD"}
            booster_quantity = int(reward["booster_quantity"])
        if not reward.has("coins") and not reward.has("gems") and not reward.has("booster_id") and not reward.has("booster_quantity"):
            return {"ok": false, "reason": "EMPTY_REWARD"}
    return {"ok": true, "coins": coins_delta, "gems": gems_delta, "booster_id": booster_id, "booster_quantity": booster_quantity}


func _sorted_transaction_ids() -> Array[String]:
    var result: Array[String] = []
    for transaction_id in _transaction_ids:
        result.append(str(transaction_id))
    result.sort()
    return result


func _sanitize_boosters(value: Dictionary) -> Dictionary:
    var sanitized: Dictionary = {}
    for booster_id in value:
        if typeof(booster_id) != TYPE_STRING or str(booster_id).is_empty():
            continue
        var quantity := int(value[booster_id])
        if str(booster_id) == "focus":
            retired_focus_inventory += maxi(0, quantity)
            continue
        if quantity > 0:
            sanitized[str(booster_id)] = quantity
    return sanitized


func _now_unix() -> int:
    return int(Time.get_unix_time_from_system())


func _is_positive_integer(value: Variant) -> bool:
    return _is_non_negative_integer(value) and int(value) > 0


func _is_non_negative_integer(value: Variant) -> bool:
    if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
        return false
    return float(value) >= 0.0 and is_equal_approx(float(value), float(int(value)))
