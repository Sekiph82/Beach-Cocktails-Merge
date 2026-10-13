class_name DailyRewardService
extends RefCounted

## Locked payload table. Claim execution stays closed until the owner chooses a
## reset boundary; ad slots additionally require AdsService verification.

const POLICY_PATH := "res://data/campaign/daily_rewards.json"

var rewards: Dictionary = {}
var reset_policy := "OWNER_DECISION_REQUIRED"


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
	reset_policy = str(parsed.get("reset_policy", "OWNER_DECISION_REQUIRED"))
	for entry in parsed.get("slots", []):
		if entry is Dictionary:
			var slot := int(entry.get("slot", 0))
			if slot > 0:
				rewards[slot] = entry.duplicate(true)


func get_slot_state(slot: int, ads_service = null) -> Dictionary:
	if not rewards.has(slot):
		return {"available": false, "reason": "UNKNOWN_SLOT"}
	var entry: Dictionary = rewards[slot]
	if slot == 3:
		return {"available": false, "reason": "OWNER_REPLACEMENT_REWARD_REQUIRED", "reward": entry.get("reward", null)}
	if reset_policy == "OWNER_DECISION_REQUIRED":
		return {"available": false, "reason": "RESET_POLICY_REQUIRED", "reward": entry.get("reward", null)}
	if slot > 1 and (ads_service == null or ads_service.provider_adapter == null):
		return {"available": false, "reason": "REWARDED_AD_PROVIDER_UNAVAILABLE", "reward": entry.get("reward", null)}
	if not bool(entry.get("enabled", false)):
		return {"available": false, "reason": "SLOT_DISABLED", "reward": entry.get("reward", null)}
	return {"available": false, "reason": "CLAIM_LEDGER_NOT_CONFIGURED", "reward": entry.get("reward", null)}


func claim(slot: int, economy, ads_service = null) -> Dictionary:
	var status := get_slot_state(slot, ads_service)
	if not bool(status.get("available", false)):
		return {"ok": false, "reason": str(status.get("reason", "SLOT_UNAVAILABLE")), "slot": slot}
	return {"ok": false, "reason": "CLAIM_NOT_CONFIGURED", "slot": slot}
