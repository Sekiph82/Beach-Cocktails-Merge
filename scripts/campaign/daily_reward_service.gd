class_name DailyRewardService
extends RefCounted

## Five UTC-day claims. The tracked JSON is the single reward/reset authority.
## Ad-gated slots settle only from AdsService's verified provider signal.

const SLOT_COUNT := 5
const CONFIG_PATH := "res://data/campaign/daily_rewards.json"
const CONFIG_SCHEMA_VERSION := 1

var rewards: Dictionary = {}
var reset_policy := ""
var config_valid := false
var config_error := "NOT_LOADED"
var _pending: Dictionary = {}


func _init() -> void:
	load_config()


func _is_integer(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or (typeof(value) == TYPE_FLOAT and is_finite(float(value)) and floorf(float(value)) == float(value))


func load_config(path: String = CONFIG_PATH) -> bool:
	rewards.clear()
	reset_policy = ""
	config_valid = false
	config_error = "CONFIG_INVALID"
	_pending.clear()
	if not FileAccess.file_exists(path):
		config_error = "CONFIG_MISSING"
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		config_error = "CONFIG_UNREADABLE"
		return false
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		config_error = "CONFIG_PARSE_ERROR"
		return false
	var config = parser.data
	if not config is Dictionary or config.size() != 3:
		return false
	if not _is_integer(config.get("schema_version")) or int(config["schema_version"]) != CONFIG_SCHEMA_VERSION:
		return false
	if typeof(config.get("reset_policy")) != TYPE_STRING or str(config["reset_policy"]) != "UTC_MIDNIGHT":
		return false
	if not config.get("slots") is Array or config["slots"].size() != SLOT_COUNT:
		return false
	var parsed_rewards: Dictionary = {}
	for index in range(SLOT_COUNT):
		var row = config["slots"][index]
		if not row is Dictionary or row.size() != 4:
			return false
		if not _is_integer(row.get("slot")) or int(row["slot"]) != index + 1:
			return false
		if typeof(row.get("enabled")) != TYPE_BOOL or not bool(row["enabled"]):
			return false
		if typeof(row.get("gate")) != TYPE_STRING:
			return false
		var expected_gate := "free" if index == 0 else "verified_rewarded_ad"
		if str(row["gate"]) != expected_gate:
			return false
		var reward = row.get("reward")
		if not reward is Dictionary or reward.size() != 2:
			return false
		if typeof(reward.get("type")) != TYPE_STRING or not _is_integer(reward.get("quantity")):
			return false
		var expected_type := "energy" if index == 1 else ("gems" if index == 3 else "coins")
		if str(reward["type"]) != expected_type or int(reward["quantity"]) <= 0:
			return false
		parsed_rewards[index + 1] = row.duplicate(true)
	rewards = parsed_rewards
	reset_policy = str(config["reset_policy"])
	config_valid = true
	config_error = ""
	return true


func describe_slot(slot: int) -> String:
	if not config_valid or not rewards.has(slot):
		return "CONFIG UNAVAILABLE"
	var row: Dictionary = rewards[slot]
	var reward: Dictionary = row["reward"]
	var kind := str(reward["type"]).to_upper()
	var gate_text := "FREE" if str(row["gate"]) == "free" else "REWARDED AD"
	var prefix := "+" if kind == "ENERGY" else ""
	return "%s%d %s · %s" % [prefix, int(reward["quantity"]), kind, gate_text]


func get_slot_state(slot: int, economy, ads_service = null, now_unix: int = -1) -> Dictionary:
	if not config_valid:
		return {"available": false, "reason": config_error}
	if not rewards.has(slot):
		return {"available": false, "reason": "UNKNOWN_SLOT"}
	if reset_policy != "UTC_MIDNIGHT":
		return {"available": false, "reason": "RESET_POLICY_INVALID"}
	if economy == null:
		return {"available": false, "reason": "ECONOMY_UNAVAILABLE"}
	var row: Dictionary = rewards[slot]
	if not bool(row["enabled"]):
		return {"available": false, "reason": "SLOT_DISABLED"}
	var day: String = economy.effective_utc_date(now_unix)
	if slot == 2:
		economy.refresh_energy(now_unix)
	if economy.daily_slot_claimed(day, slot):
		return {"available": false, "claimed": true, "day": day, "reason": "ALREADY_CLAIMED"}
	if slot == 2 and int(economy.energy) >= int(economy.ENERGY_CAP):
		return {"available": false, "day": day, "reason": "ENERGY_ALREADY_FULL"}
	if str(row["gate"]) == "verified_rewarded_ad":
		if ads_service == null or ads_service.provider_adapter == null:
			return {"available": false, "day": day, "reason": "REWARDED_AD_PROVIDER_UNAVAILABLE"}
		if not _pending.is_empty():
			return {"available": false, "day": day, "reason": "REWARDED_CLAIM_IN_PROGRESS"}
	return {"available": true, "day": day, "reason": "READY", "reward": row["reward"].duplicate(true)}


func claim(slot: int, economy, ads_service = null, now_unix: int = -1) -> Dictionary:
	if config_valid and economy != null and slot >= 1 and slot <= SLOT_COUNT:
		var current_day: String = economy.effective_utc_date(now_unix)
		if economy.daily_slot_claimed(current_day, slot):
			return {"ok": true, "duplicate": true, "slot": slot, "claim_key": "%s:%d" % [current_day, slot]}
	var status := get_slot_state(slot, economy, ads_service, now_unix)
	if not bool(status.get("available", false)):
		return {"ok": false, "reason": str(status.get("reason", "SLOT_UNAVAILABLE")), "slot": slot}
	var row: Dictionary = rewards[slot]
	var day := str(status["day"])
	var transaction_id := "daily:%s:%d" % [day, slot]
	if str(row["gate"]) == "free":
		return economy.claim_daily_reward_once(day, slot, transaction_id, "", now_unix, row["reward"])
	var requested: Dictionary = ads_service.request_rewarded("daily_slot_%d" % slot, transaction_id)
	if not bool(requested.get("ok", false)):
		return {"ok": false, "reason": str(requested.get("reason", "REWARDED_AD_UNAVAILABLE")), "slot": slot}
	_pending[transaction_id] = {"day": day, "slot": slot, "reward": row["reward"].duplicate(true)}
	var shown: Dictionary = ads_service.show_rewarded()
	if not bool(shown.get("ok", false)):
		_pending.erase(transaction_id)
		return {"ok": false, "reason": str(shown.get("reason", "REWARDED_AD_FAILED")), "slot": slot}
	return {"ok": true, "pending": true, "slot": slot, "transaction_id": transaction_id}


func accept_verified_reward(placement_id: String, transaction_id: String, provider_receipt: String, economy, now_unix: int = -1) -> Dictionary:
	if not config_valid:
		return {"ok": false, "reason": config_error}
	if not _pending.has(transaction_id):
		return {"ok": false, "reason": "NO_MATCHING_DAILY_CLAIM"}
	var pending: Dictionary = _pending[transaction_id]
	if placement_id != "daily_slot_%d" % int(pending["slot"]):
		return {"ok": false, "reason": "DAILY_PLACEMENT_MISMATCH"}
	_pending.erase(transaction_id)
	return economy.claim_daily_reward_once(str(pending["day"]), int(pending["slot"]), transaction_id, provider_receipt, now_unix, pending["reward"])


func cancel_pending() -> void:
	_pending.clear()
