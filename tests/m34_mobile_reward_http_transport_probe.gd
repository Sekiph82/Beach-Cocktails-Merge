extends SceneTree

const TRANSPORT_SCRIPT := preload("res://scripts/campaign/mobile_reward_http_transport.gd")

var failures: Array[String] = []
var emitted: Dictionary = {}


class FakeIdentityProvider extends RefCounted:
	func get_bearer_token() -> String:
		return "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0In0.c2lnbmF0dXJl"
	func get_subject() -> String:
		return "test-player"


class UnsafeIdentityProvider extends RefCounted:
	func get_bearer_token() -> String:
		return "unsafe\r\nAuthorization: forged"
	func get_subject() -> String:
		return "test-player"


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_REWARD_HTTP PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_REWARD_HTTP FAIL: %s" % label)


func _on_pending(subject: String, response: Dictionary) -> void:
	emitted["pending"] = {"subject": subject, "response": response}


func _on_ack(subject: String, transaction_id: String, response: Dictionary) -> void:
	emitted["ack"] = {"subject": subject, "transaction_id": transaction_id, "response": response}


func _on_claim(placement: String, client_transaction_id: String, session_id: String, response: Dictionary) -> void:
	emitted["claim"] = {"placement": placement, "client_transaction_id": client_transaction_id, "session_id": session_id, "response": response}


func _run() -> void:
	var transport: MobileRewardHttpTransport = TRANSPORT_SCRIPT.new()
	root.add_child(transport)
	var provider := FakeIdentityProvider.new()
	var disabled := transport.configure("https://rewards.example", provider)
	_check("HTTPS transport remains disabled by default", not disabled.get("ok", false) and not transport.enabled)
	var insecure := transport.configure("http://rewards.example", provider, true)
	_check("cleartext HTTP endpoint is rejected", not insecure.get("ok", false) and not transport.enabled)
	var missing_identity := transport.configure("https://rewards.example", null, true)
	_check("owner enablement cannot bypass missing authenticated identity provider", not missing_identity.get("ok", false) and not transport.enabled)
	var configured := transport.configure("https://rewards.example/mobile", provider, true)
	_check("owner enabled HTTPS config requires a bearer JWT and subject provider", configured.get("ok", false) and transport.enabled)
	var unconsented_claim := transport.request_ad_claim("energy_20", "android", "", "test-session", "UNSET")
	_check("test claim endpoint rejects unresolved UMP state before network activity", not unconsented_claim.get("ok", false) and unconsented_claim.get("reason", "") == "UMP_CONSENT_NOT_RESOLVED")
	transport.pending_rewards_received.connect(_on_pending)
	transport.acknowledgement_received.connect(_on_ack)
	transport.ad_claim_created.connect(_on_claim)
	transport._operation = "pending"
	transport._subject = "test-player"
	var valid_row := {"transaction_id": "tx-1", "user_id": "test-player", "placement_id": "energy_20", "reward_item": "energy", "reward_amount": 20}
	transport._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify({"rewards": [valid_row]}).to_utf8_buffer())
	_check("pending response is accepted only when every row is bound to authenticated subject", emitted.get("pending", {}).get("response", {}).get("ok", false) and emitted["pending"]["subject"] == "test-player")
	transport._operation = "pending"
	transport._subject = "test-player"
	var wrong_user_row := valid_row.duplicate(true)
	wrong_user_row["user_id"] = "other-player"
	transport._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify({"rewards": [wrong_user_row]}).to_utf8_buffer())
	_check("cross-user Worker rows fail closed", not emitted["pending"]["response"].get("ok", true) and emitted["pending"]["response"].get("reason", "") == "WORKER_PENDING_USER_MISMATCH")
	transport._operation = "pending"
	transport._subject = "test-player"
	transport._on_request_completed(HTTPRequest.RESULT_SUCCESS, 503, PackedStringArray(), PackedByteArray())
	_check("HTTP status failure emits no reward rows", not emitted["pending"]["response"].get("ok", true) and emitted["pending"]["response"].get("reason", "") == "WORKER_HTTP_REQUEST_FAILED")
	transport._operation = "ack"
	transport._subject = "test-player"
	transport._transaction_id = "tx-1"
	transport._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify({"ok": true, "transaction_id": "wrong-tx"}).to_utf8_buffer())
	_check("ACK response must echo the exact pending transaction id", not emitted["ack"]["response"].get("ok", true) and emitted["ack"]["response"].get("reason", "") == "WORKER_ACK_RESPONSE_INVALID")
	transport._operation = "claim"
	transport._subject = "test-player"
	transport._transaction_id = "daily:2026-10-18:3"
	transport._claim_placement = "daily_slot_3"
	transport._claim_session_id = "daily-session-3"
	var claim_body := {"nonce": "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a471", "user_id": "test-player", "placement_id": "daily_slot_3", "client_transaction_id": "daily:2026-10-18:3", "ad_unit": "ca-app-pub-1234567890123456/1234567890", "reward_item": "coins", "reward_amount": 40}
	transport._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(claim_body).to_utf8_buffer())
	_check("claim response binds nonce to user, placement, and separate UTC business transaction", emitted["claim"]["response"].get("ok", false) and emitted["claim"]["client_transaction_id"] == "daily:2026-10-18:3" and emitted["claim"]["session_id"] == "daily-session-3")
	var invalid_token := UnsafeIdentityProvider.new()
	transport.configure("https://rewards.example", invalid_token, true)
	_check("malformed bearer values cannot be sent in HTTP headers", not transport.request_pending_rewards().get("ok", false))
	transport.queue_free()
	if failures.is_empty():
		print("M34_REWARD_HTTP_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_REWARD_HTTP_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
