class_name MobileRewardDelivery
extends RefCounted

## Delivers only rows returned by the authenticated, SSV-settled Worker endpoint.
## Persistence completes before ACK; an ACK retry is safe after process restart.

const TRANSACTION_PATTERN := "^[A-Za-z0-9._:-]{1,128}$"
const MAX_PENDING_ROWS := 50


func settle_pending_rows(rows: Variant, authenticated_user_id: String, economy: Object, persist: Callable, acknowledge: Callable, now_unix: int = -1) -> Dictionary:
	if authenticated_user_id.is_empty() or economy == null or not persist.is_valid() or not acknowledge.is_valid():
		return {"ok": false, "reason": "AUTH_ECONOMY_OR_CALLBACK_REQUIRED", "settled": 0}
	if not rows is Array or rows.size() > MAX_PENDING_ROWS:
		return {"ok": false, "reason": "PENDING_RESPONSE_INVALID", "settled": 0}
	var settled := 0
	for row_value in rows:
		if not row_value is Dictionary:
			return {"ok": false, "reason": "PENDING_ROW_INVALID", "settled": settled}
		var row: Dictionary = row_value
		var checked := _validate_row(row, authenticated_user_id)
		if not bool(checked.get("ok", false)):
			return {"ok": false, "reason": str(checked.get("reason", "PENDING_ROW_INVALID")), "settled": settled}
		var transaction_id := str(row["transaction_id"])
		var before_state: Dictionary = economy.export_state()
		var grant: Dictionary = economy.apply_verified_mobile_reward(transaction_id, str(row["placement_id"]), str(row["reward_item"]), int(row["reward_amount"]), str(row["client_transaction_id"]), now_unix)
		if not bool(grant.get("ok", false)):
			return {"ok": false, "reason": str(grant.get("reason", "REWARD_REJECTED")), "transaction_id": transaction_id, "settled": settled}
		if not bool(grant.get("duplicate", false)):
			var saved: Variant = persist.call()
			if not saved is Dictionary or not bool(saved.get("ok", false)):
				economy.configure_from_state(before_state)
				return {"ok": false, "reason": "LOCAL_DURABLE_SAVE_FAILED", "transaction_id": transaction_id, "settled": settled}
		var acked: Variant = acknowledge.call(transaction_id)
		if not acked is Dictionary or not bool(acked.get("ok", false)):
			return {"ok": false, "reason": "SERVER_ACK_PENDING", "transaction_id": transaction_id, "persisted": true, "settled": settled}
		settled += 1
	return {"ok": true, "settled": settled}


func _validate_row(row: Dictionary, authenticated_user_id: String) -> Dictionary:
	for key in ["transaction_id", "user_id", "placement_id", "client_transaction_id", "reward_item", "reward_amount"]:
		if not row.has(key):
			return {"ok": false, "reason": "PENDING_ROW_FIELD_MISSING:%s" % key}
	if typeof(row["transaction_id"]) != TYPE_STRING or not _transaction_id_matches(str(row["transaction_id"])):
		return {"ok": false, "reason": "PENDING_TRANSACTION_INVALID"}
	if typeof(row["user_id"]) != TYPE_STRING or str(row["user_id"]) != authenticated_user_id:
		return {"ok": false, "reason": "PENDING_USER_MISMATCH"}
	if typeof(row["placement_id"]) != TYPE_STRING or typeof(row["reward_item"]) != TYPE_STRING:
		return {"ok": false, "reason": "PENDING_REWARD_TYPE_INVALID"}
	if typeof(row["client_transaction_id"]) != TYPE_STRING:
		return {"ok": false, "reason": "PENDING_CLIENT_TRANSACTION_INVALID"}
	if str(row["placement_id"]).begins_with("daily_slot_") and str(row["client_transaction_id"]).is_empty():
		return {"ok": false, "reason": "PENDING_CLIENT_TRANSACTION_REQUIRED"}
	if typeof(row["reward_amount"]) != TYPE_INT or int(row["reward_amount"]) <= 0 or int(row["reward_amount"]) > 10000:
		return {"ok": false, "reason": "PENDING_REWARD_AMOUNT_INVALID"}
	if str(row["reward_item"]) not in ["energy", "coins", "gems"]:
		return {"ok": false, "reason": "PENDING_REWARD_ITEM_UNSUPPORTED"}
	return {"ok": true}


func _transaction_id_matches(value: String) -> bool:
	var regex := RegEx.new()
	if regex.compile(TRANSACTION_PATTERN) != OK:
		return false
	return regex.search(value) != null
