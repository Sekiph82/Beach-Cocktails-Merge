class_name AdsService
extends Node

## Opt-in rewarded-ad boundary. No provider is wired in this build, so every
## request fails closed until a reviewed native adapter and consent policy exist.

signal state_changed(state: String, placement_id: String)
signal verified_rewarded(placement_id: String, transaction_id: String, provider_receipt: String)

const STATE_IDLE := "IDLE"
const STATE_LOADING := "LOADING"
const STATE_READY := "READY"
const STATE_SHOWING := "SHOWING"
const STATE_REWARDED := "REWARDED"
const STATE_FAILED := "FAILED"
const STATE_CANCELLED := "CANCELLED"

var state := STATE_IDLE
var consent_status := "UNSET"
var provider_adapter: Object
var _active_placement := ""
var _active_transaction_id := ""
var _accepted_receipts: Dictionary = {}


func set_provider_adapter(adapter: Object, approved_consent_status: String) -> void:
	provider_adapter = adapter
	consent_status = approved_consent_status
	if provider_adapter == null or not consent_status in ["GRANTED_PERSONALIZED", "GRANTED_NONPERSONALIZED"]:
		provider_adapter = null
		consent_status = "UNSET"


func request_rewarded(placement_id: String, transaction_id: String) -> Dictionary:
	if placement_id.is_empty() or transaction_id.is_empty():
		return {"ok": false, "reason": "PLACEMENT_AND_TRANSACTION_REQUIRED"}
	if state in [STATE_LOADING, STATE_READY, STATE_SHOWING]:
		return {"ok": false, "reason": "REWARDED_REQUEST_BUSY", "state": state}
	_active_placement = placement_id
	_active_transaction_id = transaction_id
	if consent_status not in ["GRANTED_PERSONALIZED", "GRANTED_NONPERSONALIZED"]:
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "CONSENT_REQUIRED", "state": state}
	if provider_adapter == null or not provider_adapter.has_method("request_rewarded"):
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "PROVIDER_UNAVAILABLE", "state": state}
	_set_state(STATE_LOADING)
	var provider_result: Dictionary = provider_adapter.request_rewarded(placement_id, transaction_id)
	if not bool(provider_result.get("ok", false)):
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": str(provider_result.get("reason", "PROVIDER_UNAVAILABLE")), "state": state}
	_set_state(STATE_READY)
	return {"ok": true, "ready": true, "state": state}


func show_rewarded() -> Dictionary:
	if state != STATE_READY or provider_adapter == null or not provider_adapter.has_method("show_rewarded"):
		return {"ok": false, "reason": "REWARDED_NOT_READY", "state": state}
	_set_state(STATE_SHOWING)
	var result: Dictionary = provider_adapter.show_rewarded(_active_transaction_id)
	if not bool(result.get("ok", false)):
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": str(result.get("reason", "SHOW_FAILED")), "state": state}
	return {"ok": true, "state": state}


func accept_provider_reward(transaction_id: String, provider_receipt: String) -> Dictionary:
	if state != STATE_SHOWING or transaction_id != _active_transaction_id:
		return {"ok": false, "reason": "NO_MATCHING_REWARDED_SESSION"}
	if provider_receipt.is_empty() or _accepted_receipts.has(provider_receipt):
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "INVALID_OR_DUPLICATE_PROVIDER_RECEIPT"}
	_accepted_receipts[provider_receipt] = true
	_set_state(STATE_REWARDED)
	verified_rewarded.emit(_active_placement, transaction_id, provider_receipt)
	return {"ok": true, "verified": true, "transaction_id": transaction_id, "provider_receipt": provider_receipt}


func notify_skipped_or_closed_without_reward() -> void:
	if state in [STATE_LOADING, STATE_READY, STATE_SHOWING]:
		_set_state(STATE_CANCELLED)


func _set_state(next_state: String) -> void:
	state = next_state
	state_changed.emit(state, _active_placement)
