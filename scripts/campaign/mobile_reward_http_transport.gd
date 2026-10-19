class_name MobileRewardHttpTransport
extends Node

## HTTPS-only Worker transport. It has no compiled-in endpoint, identity, or
## token and remains disabled unless an owner supplies all three at runtime.

signal pending_rewards_received(authenticated_subject: String, response: Dictionary)
signal acknowledgement_received(authenticated_subject: String, transaction_id: String, response: Dictionary)
signal ad_claim_created(placement_id: String, client_transaction_id: String, session_id: String, response: Dictionary)

const MAX_RESPONSE_BYTES := 262144
const MAX_PENDING_ROWS := 50
const TRANSACTION_PATTERN := "^[A-Za-z0-9._:-]{1,128}$"

var enabled := false
var endpoint := ""
var identity_provider: Object
var _request: Object
var _operation := ""
var _subject := ""
var _transaction_id := ""


func configure(worker_endpoint: String, provider: Object, owner_enabled: bool = false) -> Dictionary:
	enabled = false
	endpoint = ""
	identity_provider = null
	if not owner_enabled:
		return {"ok": false, "reason": "MOBILE_REWARD_TRANSPORT_DISABLED"}
	var parsed := worker_endpoint.strip_edges()
	if not _https_endpoint_matches(parsed):
		return {"ok": false, "reason": "HTTPS_WORKER_ENDPOINT_REQUIRED"}
	if provider == null or not provider.has_method("get_bearer_token") or not provider.has_method("get_subject") or not provider.has_method("is_subject_bound_to_active_profile"):
		return {"ok": false, "reason": "APPROVED_IDENTITY_AND_PROFILE_BINDING_REQUIRED"}
	endpoint = parsed.trim_suffix("/")
	identity_provider = provider
	enabled = true
	return {"ok": true, "enabled": true, "transport": "HTTPS"}


func request_pending_rewards() -> Dictionary:
	var auth := _get_auth_context()
	if not bool(auth.get("ok", false)):
		return auth
	if not _begin_request("pending"):
		return {"ok": false, "reason": "MOBILE_REWARD_REQUEST_BUSY"}
	_subject = str(auth["subject"])
	var err: Error = _request.request(endpoint + "/v1/ads/rewards/pending", PackedStringArray(["Accept: application/json", "Authorization: Bearer %s" % str(auth["token"])]), HTTPClient.METHOD_GET)
	if err != OK:
		_operation = ""
		return {"ok": false, "reason": "WORKER_REQUEST_START_FAILED"}
	return {"ok": true, "pending": true}


func request_ad_claim(placement_id: String, platform: String, client_transaction_id: String, session_id: String, ump_consent_state: String) -> Dictionary:
	if not OS.is_debug_build():
		return {"ok": false, "reason": "TEST_AD_CLAIMS_DISABLED_IN_RELEASE"}
	if placement_id not in ["energy_20", "daily_slot_2", "daily_slot_3", "daily_slot_4", "daily_slot_5"] or platform not in ["android", "ios"] or session_id.is_empty():
		return {"ok": false, "reason": "AD_CLAIM_REQUEST_INVALID"}
	if ump_consent_state not in ["UMP_OBTAINED", "UMP_NOT_REQUIRED"]:
		return {"ok": false, "reason": "UMP_CONSENT_NOT_RESOLVED"}
	if placement_id.begins_with("daily_slot_") and not _transaction_id_matches(client_transaction_id):
		return {"ok": false, "reason": "DAILY_CLIENT_TRANSACTION_REQUIRED"}
	var auth := _get_auth_context()
	if not bool(auth.get("ok", false)):
		return auth
	if not _begin_request("claim"):
		return {"ok": false, "reason": "MOBILE_REWARD_REQUEST_BUSY"}
	_subject = str(auth["subject"])
	_transaction_id = client_transaction_id
	_claim_placement = placement_id
	_claim_session_id = session_id
	_claim_platform = platform
	var body := {"placement": placement_id, "platform": platform, "consent_granted": true, "consent_state": ump_consent_state}
	if not client_transaction_id.is_empty():
		body["client_transaction_id"] = client_transaction_id
	var err: Error = _request.request(endpoint + "/v1/ads/claims", PackedStringArray(["Accept: application/json", "Content-Type: application/json", "Authorization: Bearer %s" % str(auth["token"])]), HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		_operation = ""
		_claim_placement = ""
		_claim_session_id = ""
		return {"ok": false, "reason": "WORKER_REQUEST_START_FAILED"}
	return {"ok": true, "pending": true}


func acknowledge_reward(transaction_id: String) -> Dictionary:
	if not _transaction_id_matches(transaction_id):
		return {"ok": false, "reason": "ACK_TRANSACTION_INVALID"}
	var auth := _get_auth_context()
	if not bool(auth.get("ok", false)):
		return auth
	if not _begin_request("ack"):
		return {"ok": false, "reason": "MOBILE_REWARD_REQUEST_BUSY"}
	_subject = str(auth["subject"])
	_transaction_id = transaction_id
	var url := endpoint + "/v1/ads/rewards/%s/ack" % transaction_id
	var err: Error = _request.request(url, PackedStringArray(["Accept: application/json", "Authorization: Bearer %s" % str(auth["token"])]), HTTPClient.METHOD_POST, "")
	if err != OK:
		_operation = ""
		return {"ok": false, "reason": "WORKER_REQUEST_START_FAILED"}
	return {"ok": true, "pending": true}


func _get_auth_context() -> Dictionary:
	if not enabled or endpoint.is_empty() or identity_provider == null:
		return {"ok": false, "reason": "MOBILE_REWARD_TRANSPORT_DISABLED"}
	var token := str(identity_provider.get_bearer_token())
	var subject := str(identity_provider.get_subject())
	if not _jwt_token_matches(token) or subject.is_empty() or subject.length() > 128:
		return {"ok": false, "reason": "AUTHENTICATED_IDENTITY_REQUIRED"}
	var profile_binding: Variant = identity_provider.is_subject_bound_to_active_profile(subject)
	if typeof(profile_binding) != TYPE_BOOL or not profile_binding:
		return {"ok": false, "reason": "AUTHENTICATED_PROFILE_BINDING_REQUIRED"}
	return {"ok": true, "token": token, "subject": subject}


func get_authenticated_subject() -> String:
	var auth := _get_auth_context()
	return str(auth.get("subject", "")) if bool(auth.get("ok", false)) else ""


func is_authenticated_subject_bound_to_active_profile(subject: String) -> bool:
	if subject.is_empty():
		return false
	var auth := _get_auth_context()
	return bool(auth.get("ok", false)) and str(auth.get("subject", "")) == subject


func set_http_request_driver_for_test(driver: Node) -> bool:
	if not OS.is_debug_build() or driver == null or _request != null or not driver.has_signal("request_completed") or not driver.has_method("request"):
		return false
	_request = driver
	if driver.get_parent() == null:
		add_child(driver)
	driver.request_completed.connect(_on_request_completed)
	return true


func _begin_request(operation: String) -> bool:
	if not enabled or _operation != "":
		return false
	if _request == null:
		_request = HTTPRequest.new()
		_request.timeout = 20.0
		_request.body_size_limit = MAX_RESPONSE_BYTES
		_request.request_completed.connect(_on_request_completed)
		add_child(_request as Node)
	_operation = operation
	return true


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var operation := _operation
	var subject := _subject
	var transaction_id := _transaction_id
	var claim_placement := _claim_placement
	var claim_session_id := _claim_session_id
	var claim_platform := _claim_platform
	_operation = ""
	_transaction_id = ""
	_claim_placement = ""
	_claim_session_id = ""
	_claim_platform = ""
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300 or body.size() > MAX_RESPONSE_BYTES:
		_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_HTTP_REQUEST_FAILED")
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not parsed is Dictionary:
		_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_RESPONSE_INVALID")
		return
	if operation == "pending":
		if not is_authenticated_subject_bound_to_active_profile(subject):
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "AUTHENTICATED_PROFILE_CHANGED")
			return
		var rows: Variant = parsed.get("rewards", null)
		if not rows is Array or rows.size() > MAX_PENDING_ROWS:
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_PENDING_RESPONSE_INVALID")
			return
		var normalized_rows: Array[Dictionary] = []
		for row_value in rows:
			if not row_value is Dictionary:
				_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_PENDING_RESPONSE_INVALID")
				return
			var row: Dictionary = row_value.duplicate(true)
			if typeof(row.get("user_id")) != TYPE_STRING or str(row["user_id"]) != subject:
				_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_PENDING_USER_MISMATCH")
				return
			if typeof(row.get("reward_amount")) not in [TYPE_INT, TYPE_FLOAT] or not _valid_positive_integer(row["reward_amount"]):
				_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_PENDING_REWARD_AMOUNT_INVALID")
				return
			row["reward_amount"] = int(row["reward_amount"])
			normalized_rows.append(row)
		pending_rewards_received.emit(subject, {"ok": true, "rewards": normalized_rows})
	elif operation == "claim":
		if not is_authenticated_subject_bound_to_active_profile(subject):
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "AUTHENTICATED_PROFILE_CHANGED")
			return
		if str(parsed.get("user_id", "")) != subject:
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_CLAIM_USER_MISMATCH")
			return
		if str(parsed.get("placement_id", "")) != claim_placement or str(parsed.get("client_transaction_id", "")) != transaction_id:
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_CLAIM_BINDING_MISMATCH")
			return
		if not _transaction_id_matches(str(parsed.get("nonce", ""))) or not _valid_ad_unit(str(parsed.get("ad_unit", ""))) or not _valid_positive_integer(parsed.get("reward_amount", null)) or str(parsed.get("reward_item", "")) not in ["energy", "coins", "gems"]:
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_CLAIM_FIELDS_INVALID")
			return
		ad_claim_created.emit(str(parsed["placement_id"]), str(parsed.get("client_transaction_id", "")), claim_session_id, {"ok": true, "nonce": str(parsed["nonce"]), "user_id": str(parsed["user_id"]), "placement_id": str(parsed["placement_id"]), "client_transaction_id": str(parsed.get("client_transaction_id", "")), "session_id": claim_session_id, "platform": claim_platform, "ad_unit": str(parsed["ad_unit"]), "reward_item": str(parsed.get("reward_item", "")), "reward_amount": int(parsed["reward_amount"])})
	elif operation == "ack":
		if parsed.get("ok", false) != true or str(parsed.get("transaction_id", "")) != transaction_id:
			_emit_failure(operation, subject, transaction_id, claim_placement, claim_session_id, "WORKER_ACK_RESPONSE_INVALID")
			return
		acknowledgement_received.emit(subject, transaction_id, {"ok": true, "duplicate": bool(parsed.get("duplicate", false))})


func _emit_failure(operation: String, subject: String, transaction_id: String, claim_placement: String, claim_session_id: String, reason: String) -> void:
	if operation == "pending":
		pending_rewards_received.emit(subject, {"ok": false, "reason": reason})
	elif operation == "ack":
		acknowledgement_received.emit(subject, transaction_id, {"ok": false, "reason": reason})
	elif operation == "claim":
		ad_claim_created.emit(claim_placement, transaction_id, claim_session_id, {"ok": false, "reason": reason})


var _claim_placement := ""
var _claim_session_id := ""
var _claim_platform := ""


func _transaction_id_matches(value: String) -> bool:
	var regex := RegEx.new()
	if regex.compile(TRANSACTION_PATTERN) != OK:
		return false
	return regex.search(value) != null


func _https_endpoint_matches(value: String) -> bool:
	var regex := RegEx.new()
	if regex.compile("^https://[A-Za-z0-9.-]+(:[0-9]{1,5})?(/[A-Za-z0-9._~/-]*)?$") != OK:
		return false
	return regex.search(value) != null and not value.contains("..")


func _jwt_token_matches(value: String) -> bool:
	var regex := RegEx.new()
	if regex.compile("^[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+$") != OK:
		return false
	return regex.search(value) != null


func _valid_ad_unit(value: String) -> bool:
	var regex := RegEx.new()
	if regex.compile("^ca-app-pub-[0-9]{16}/[0-9]{10}$") != OK:
		return false
	return regex.search(value) != null


func _valid_positive_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return int(value) > 0 and int(value) <= 10000
	if typeof(value) == TYPE_FLOAT:
		return is_finite(float(value)) and float(value) > 0.0 and float(value) <= 10000.0 and floorf(float(value)) == float(value)
	return false
