class_name DailyRewardService
extends RefCounted

## Five UTC-day claims. Ad-gated slots settle only from AdsService's verified
## provider signal; this service never fabricates a provider result.

const POLICY_PATH := "res://data/campaign/daily_rewards.json"
const SLOT_COUNT := 5

var rewards: Dictionary = {}
var reset_policy := "UTC_MIDNIGHT"
var _pending: Dictionary = {}


func _init() -> void:
	if not FileAccess.file_exists(POLICY_PATH):
		return
	var file := FileAccess.open(POLICY_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or int(parsed.get("schema_version", 0)) != 1:
		return
	reset_policy = str(parsed.get("reset_policy", "UTC_MIDNIGHT"))
	for entry in parsed.get("slots", []):
		if entry is Dictionary:
			var slot := int(entry.get("slot", 0))
			if slot > 0:
				rewards[slot] = entry.duplicate(true)


func get_slot_state(slot: int, economy, ads_service = null, now_unix: int = -1) -> Dictionary:
	if not rewards.has(slot):
		return {"available": false, "reason": "UNKNOWN_SLOT"}
	if reset_policy != "UTC_MIDNIGHT":
		return {"available": false, "reason": "RESET_POLICY_INVALID"}
	if not bool(rewards[slot].get("enabled", false)):
		return {"available": false, "reason": "SLOT_DISABLED"}
	if economy == null:
		return {"available": false, "reason": "ECONOMY_UNAVAILABLE"}
	var day: String = economy.effective_utc_date(now_unix)
	if slot == 2:
		economy.refresh_energy(now_unix)
	if economy.daily_slot_claimed(day, slot):
		return {"available": false, "claimed": true, "day": day, "reason": "ALREADY_CLAIMED"}
	if slot == 2 and int(economy.energy) >= int(economy.ENERGY_CAP):
		return {"available": false, "day": day, "reason": "ENERGY_ALREADY_FULL"}
	if slot > 1:
		if ads_service == null or ads_service.provider_adapter == null:
			return {"available": false, "day": day, "reason": "REWARDED_AD_PROVIDER_UNAVAILABLE"}
		if not _pending.is_empty():
			return {"available": false, "day": day, "reason": "REWARDED_CLAIM_IN_PROGRESS"}
	return {"available": true, "day": day, "reason": "READY", "reward": rewards[slot]["reward"]}


func claim(slot: int, economy, ads_service = null, now_unix: int = -1) -> Dictionary:
	if economy != null and slot >= 1 and slot <= SLOT_COUNT:
		var current_day: String = economy.effective_utc_date(now_unix)
		if economy.daily_slot_claimed(current_day, slot):
			return {"ok": true, "duplicate": true, "slot": slot, "claim_key": "%s:%d" % [current_day, slot]}
	var status := get_slot_state(slot, economy, ads_service, now_unix)
	if not bool(status.get("available", false)):
		return {"ok": false, "reason": str(status.get("reason", "SLOT_UNAVAILABLE")), "slot": slot}
	var day := str(status["day"])
	var transaction_id := "daily:%s:%d" % [day, slot]
	if slot == 1:
		var free_result: Dictionary = economy.claim_daily_reward_once(day, slot, transaction_id, "", now_unix)
		return free_result
	var requested: Dictionary = ads_service.request_rewarded("daily_slot_%d" % slot, transaction_id)
	if not bool(requested.get("ok", false)):
		return {"ok": false, "reason": str(requested.get("reason", "REWARDED_AD_UNAVAILABLE")), "slot": slot}
	_pending[transaction_id] = {"day": day, "slot": slot}
	var shown: Dictionary = ads_service.show_rewarded()
	if not bool(shown.get("ok", false)):
		_pending.erase(transaction_id)
		return {"ok": false, "reason": str(shown.get("reason", "REWARDED_AD_FAILED")), "slot": slot}
	return {"ok": true, "pending": true, "slot": slot, "transaction_id": transaction_id}


func accept_verified_reward(placement_id: String, transaction_id: String, provider_receipt: String, economy, now_unix: int = -1) -> Dictionary:
	if not _pending.has(transaction_id):
		return {"ok": false, "reason": "NO_MATCHING_DAILY_CLAIM"}
	var pending: Dictionary = _pending[transaction_id]
	if placement_id != "daily_slot_%d" % int(pending["slot"]):
		return {"ok": false, "reason": "DAILY_PLACEMENT_MISMATCH"}
	_pending.erase(transaction_id)
	return economy.claim_daily_reward_once(str(pending["day"]), int(pending["slot"]), transaction_id, provider_receipt, now_unix)


func cancel_pending() -> void:
	_pending.clear()
