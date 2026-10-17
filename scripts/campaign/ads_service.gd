class_name AdsService
extends Node

## Rewarded-ad boundary. Production stays fail-closed until a compatible native
## provider, owner privacy decisions, device authorization, and server-side
## reward verification are all present. Debug fixtures can exercise lifecycle
## behavior without enabling production ads.

signal state_changed(state: String, placement_id: String)
signal verified_rewarded(placement_id: String, transaction_id: String, provider_receipt: String)

const STATE_IDLE := "IDLE"
const STATE_LOADING := "LOADING"
const STATE_RETRY_WAIT := "RETRY_WAIT"
const STATE_READY := "READY"
const STATE_SHOWING := "SHOWING"
const STATE_REWARDED := "REWARDED"
const STATE_FAILED := "FAILED"
const STATE_CANCELLED := "CANCELLED"

const MAX_LOAD_ATTEMPTS := 3
const BASE_RETRY_DELAY_SEC := 0.5
const MAX_RETRY_DELAY_SEC := 2.0
const LOAD_TIMEOUT_SEC := 8.0
const SHOW_TIMEOUT_SEC := 90.0

var state := STATE_IDLE
var consent_status := "UNSET"
var provider_adapter: Object
var production_enabled := false
var provider_status := "NOT_DEVICE_VERIFIED"
var _active_placement := ""
var _active_transaction_id := ""
var _active_session_id := ""
var _session_sequence := 0
var _load_attempt := 0
var _accepted_receipts: Dictionary = {}
var _seen_transactions: Dictionary = {}
var _timer: Timer
var _timer_kind := ""


func _ready() -> void:
	_ensure_timer()


func _exit_tree() -> void:
	_cancel_timer()
	_cancel_provider_session()
	provider_adapter = null
	consent_status = "UNSET"
	production_enabled = false
	_active_session_id = ""


## Runtime injection is intentionally limited to debug builds. A production
## adapter must be wired through a future reviewed native integration.
func set_provider_adapter(adapter: Object, approved_consent_status: String) -> bool:
	_cancel_timer()
	_cancel_provider_session()
	provider_adapter = null
	consent_status = "UNSET"
	production_enabled = false
	provider_status = "NOT_DEVICE_VERIFIED"
	if not OS.is_debug_build():
		return false
	if adapter == null or not adapter.has_method("is_test_provider") or not bool(adapter.is_test_provider()) or not adapter.has_method("request_rewarded") or not adapter.has_method("show_rewarded"):
		return false
	if approved_consent_status not in ["GRANTED_PERSONALIZED", "GRANTED_NONPERSONALIZED"]:
		return false
	provider_adapter = adapter
	consent_status = approved_consent_status
	provider_status = "DEBUG_FIXTURE_ONLY"
	return true


## This pass does not enable production ads. Diagnostics contain only booleans
## and state labels, never app IDs, ad-unit IDs, URLs, receipts, or user IDs.
func configure_production(_configuration: Dictionary) -> Dictionary:
	provider_adapter = null
	consent_status = "UNSET"
	production_enabled = false
	provider_status = "BLOCKED_ON_OWNER_AND_SDK"
	return {"ok": false, "reason": provider_status, "diagnostics": get_sanitized_diagnostics()}


func get_sanitized_diagnostics() -> Dictionary:
	return {
		"provider_status": provider_status,
		"production_enabled": production_enabled,
		"consent_granted": consent_status in ["GRANTED_PERSONALIZED", "GRANTED_NONPERSONALIZED"],
		"provider_attached": provider_adapter != null,
		"state": state
	}


func request_rewarded(placement_id: String, transaction_id: String) -> Dictionary:
	if placement_id.is_empty() or transaction_id.is_empty():
		return {"ok": false, "reason": "PLACEMENT_AND_TRANSACTION_REQUIRED"}
	if state in [STATE_LOADING, STATE_RETRY_WAIT, STATE_READY, STATE_SHOWING]:
		return {"ok": false, "reason": "REWARDED_REQUEST_BUSY", "state": state}
	if _seen_transactions.has(transaction_id):
		return {"ok": false, "reason": "DUPLICATE_REWARDED_TRANSACTION"}
	if consent_status not in ["GRANTED_PERSONALIZED", "GRANTED_NONPERSONALIZED"]:
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "CONSENT_REQUIRED", "state": state}
	if provider_adapter == null or not provider_adapter.has_method("request_rewarded"):
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "PROVIDER_UNAVAILABLE", "state": state}
	_active_placement = placement_id
	_active_transaction_id = transaction_id
	_session_sequence += 1
	_active_session_id = "%s:%d" % [transaction_id, _session_sequence]
	_load_attempt = 0
	return _request_provider_load()


func _request_provider_load() -> Dictionary:
	if provider_adapter == null or _active_transaction_id.is_empty():
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "PROVIDER_UNAVAILABLE", "state": state}
	_load_attempt += 1
	_set_state(STATE_LOADING)
	var provider_result: Dictionary = provider_adapter.request_rewarded(_active_placement, _active_transaction_id)
	if bool(provider_result.get("ok", false)):
		if bool(provider_result.get("pending", false)):
			_start_timer("load", LOAD_TIMEOUT_SEC)
			return {"ok": true, "pending": true, "state": state, "attempt": _load_attempt, "session_id": _active_session_id}
		_cancel_timer()
		_set_state(STATE_READY)
		return {"ok": true, "ready": true, "state": state, "attempt": _load_attempt}
	var reason := str(provider_result.get("reason", "PROVIDER_UNAVAILABLE"))
	var retryable := bool(provider_result.get("retryable", false))
	if retryable and _load_attempt < MAX_LOAD_ATTEMPTS:
		_set_state(STATE_RETRY_WAIT)
		_start_timer("retry", minf(BASE_RETRY_DELAY_SEC * pow(2.0, _load_attempt - 1), MAX_RETRY_DELAY_SEC))
		return {"ok": false, "retry_scheduled": true, "reason": reason, "state": state, "attempt": _load_attempt}
	_cancel_timer()
	_set_state(STATE_FAILED)
	return {"ok": false, "reason": reason, "state": state, "attempt": _load_attempt}


## Native adapters may report asynchronous completion through these guarded
## entry points. The unique session token rejects late callbacks after cancel,
## timeout, retry, or restart.
func notify_provider_loaded(transaction_id: String, session_id: String) -> Dictionary:
	if state != STATE_LOADING or transaction_id != _active_transaction_id or session_id != _active_session_id:
		return {"ok": false, "reason": "STALE_PROVIDER_LOAD_CALLBACK"}
	_cancel_timer()
	_set_state(STATE_READY)
	return {"ok": true, "state": state}


func notify_provider_load_failed(transaction_id: String, session_id: String, reason: String, retryable: bool) -> Dictionary:
	if state != STATE_LOADING or transaction_id != _active_transaction_id or session_id != _active_session_id:
		return {"ok": false, "reason": "STALE_PROVIDER_LOAD_CALLBACK"}
	_cancel_timer()
	if retryable and _load_attempt < MAX_LOAD_ATTEMPTS:
		_set_state(STATE_RETRY_WAIT)
		_start_timer("retry", minf(BASE_RETRY_DELAY_SEC * pow(2.0, _load_attempt - 1), MAX_RETRY_DELAY_SEC))
		return {"ok": false, "retry_scheduled": true, "reason": reason, "state": state}
	_set_state(STATE_FAILED)
	return {"ok": false, "reason": reason, "state": state}


func notify_provider_show_failed(transaction_id: String, session_id: String, reason: String) -> Dictionary:
	if state != STATE_SHOWING or transaction_id != _active_transaction_id or session_id != _active_session_id:
		return {"ok": false, "reason": "STALE_PROVIDER_SHOW_CALLBACK"}
	_cancel_timer()
	_cancel_provider_session()
	_active_session_id = ""
	_active_transaction_id = ""
	_set_state(STATE_FAILED)
	return {"ok": false, "reason": reason, "state": state}


func notify_provider_closed_without_reward(transaction_id: String, session_id: String) -> Dictionary:
	if state not in [STATE_LOADING, STATE_READY, STATE_SHOWING] or transaction_id != _active_transaction_id or session_id != _active_session_id:
		return {"ok": false, "reason": "STALE_PROVIDER_CLOSE_CALLBACK"}
	_cancel_timer()
	_cancel_provider_session()
	_active_session_id = ""
	_active_transaction_id = ""
	_set_state(STATE_CANCELLED)
	return {"ok": true, "state": state}


func show_rewarded() -> Dictionary:
	if state != STATE_READY or provider_adapter == null or not provider_adapter.has_method("show_rewarded"):
		return {"ok": false, "reason": "REWARDED_NOT_READY", "state": state}
	_set_state(STATE_SHOWING)
	_start_timer("show", SHOW_TIMEOUT_SEC)
	var result: Dictionary = provider_adapter.show_rewarded(_active_transaction_id)
	if not bool(result.get("ok", false)):
		_cancel_timer()
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": str(result.get("reason", "SHOW_FAILED")), "state": state}
	return {"ok": true, "state": state, "session_id": _active_session_id}


## The caller must supply a receipt already verified by a trusted backend. A
## native earned callback or nonempty client receipt alone is never sufficient.
func accept_provider_reward(transaction_id: String, provider_receipt: String, ssv_verified: bool = false, session_id: String = "") -> Dictionary:
	if not OS.is_debug_build():
		return {"ok": false, "reason": "PRODUCTION_SSV_ADAPTER_UNAVAILABLE"}
	if state != STATE_SHOWING or transaction_id != _active_transaction_id:
		return {"ok": false, "reason": "NO_MATCHING_REWARDED_SESSION"}
	if not session_id.is_empty() and session_id != _active_session_id:
		return {"ok": false, "reason": "STALE_REWARDED_SESSION"}
	if not ssv_verified:
		return {"ok": false, "reason": "SERVER_VERIFICATION_REQUIRED"}
	if provider_receipt.is_empty() or _accepted_receipts.has(provider_receipt) or _seen_transactions.has(transaction_id):
		_cancel_timer()
		_set_state(STATE_FAILED)
		return {"ok": false, "reason": "INVALID_OR_DUPLICATE_PROVIDER_RECEIPT"}
	_cancel_timer()
	_accepted_receipts[provider_receipt] = true
	_seen_transactions[transaction_id] = true
	_set_state(STATE_REWARDED)
	verified_rewarded.emit(_active_placement, transaction_id, provider_receipt)
	_active_transaction_id = ""
	_active_session_id = ""
	return {"ok": true, "verified": true, "transaction_id": transaction_id}


func notify_skipped_or_closed_without_reward() -> void:
	if state in [STATE_LOADING, STATE_RETRY_WAIT, STATE_READY, STATE_SHOWING]:
		_cancel_timer()
		_cancel_provider_session()
		_active_session_id = ""
		_active_transaction_id = ""
		_set_state(STATE_CANCELLED)


## Public deterministic hook for harnesses that cannot wait for wall-clock
## timers. Production timeout handling is driven by the owned Timer node.
func expire_active_request() -> void:
	_on_timer_timeout()


func _ensure_timer() -> void:
	if _timer != null:
		return
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)


func _start_timer(kind: String, delay_sec: float) -> void:
	_ensure_timer()
	_timer_kind = kind
	_timer.wait_time = maxf(delay_sec, 0.01)
	_timer.start()


func _cancel_timer() -> void:
	if _timer != null:
		_timer.stop()
	_timer_kind = ""


func _on_timer_timeout() -> void:
	var kind := _timer_kind
	_timer_kind = ""
	if kind == "retry" and state == STATE_RETRY_WAIT:
		_request_provider_load()
	elif kind == "load" and state == STATE_LOADING:
		_cancel_provider_session()
		_set_state(STATE_FAILED)
	elif kind == "show" and state == STATE_SHOWING:
		_cancel_provider_session()
		_active_session_id = ""
		_active_transaction_id = ""
		_set_state(STATE_FAILED)


func _cancel_provider_session() -> void:
	if provider_adapter != null and provider_adapter.has_method("cancel_rewarded"):
		provider_adapter.cancel_rewarded(_active_transaction_id, _active_session_id)


func _set_state(next_state: String) -> void:
	state = next_state
	state_changed.emit(state, _active_placement)
