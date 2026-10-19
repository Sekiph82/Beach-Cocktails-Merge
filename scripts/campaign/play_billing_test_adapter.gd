class_name PlayBillingTestAdapter
extends RefCounted

## Debug-only adapter for the installed GodotGooglePlayBilling API. It requires
## server verification before granting or calling consume/acknowledge methods.

signal billing_state_changed(state: String)
signal purchase_completed(transaction_id: String, product_key: String)

const BILLING_CLIENT_SCRIPT := preload("res://addons/GodotGooglePlayBilling/BillingClient.gd")

var client: Object
var store: StoreService
var verifier: Object
var state := "DISABLED"
var _pending_completion: Dictionary = {}
var _completed_tokens: Dictionary = {}


func configure_test(client_value: Object, store_value: StoreService, verifier_value: Object) -> Dictionary:
	if not OS.is_debug_build():
		return {"ok": false, "reason": "PLAY_BILLING_TEST_ADAPTER_DEBUG_ONLY"}
	if client_value == null or store_value == null or verifier_value == null:
		return {"ok": false, "reason": "BILLING_CLIENT_STORE_AND_VERIFIER_REQUIRED"}
	for signal_name in ["connected", "query_purchases_response", "on_purchase_updated", "consume_purchase_response", "acknowledge_purchase_response"]:
		if not client_value.has_signal(signal_name):
			return {"ok": false, "reason": "PLAY_BILLING_SIGNAL_UNAVAILABLE:%s" % signal_name}
	for method_name in ["start_connection", "query_purchases", "purchase", "consume_purchase", "acknowledge_purchase"]:
		if not client_value.has_method(method_name):
			return {"ok": false, "reason": "PLAY_BILLING_METHOD_UNAVAILABLE:%s" % method_name}
	for method_name in ["verify_store_transaction", "record_provider_completion", "get_pending_provider_completions", "complete_provider_completion"]:
		if not verifier_value.has_method(method_name):
			return {"ok": false, "reason": "DURABLE_SERVER_STORE_LEDGER_METHOD_UNAVAILABLE:%s" % method_name}
	client = client_value
	store = store_value
	verifier = verifier_value
	store.configure(client, verifier)
	_connect_client_signals()
	state = "TEST_ONLY_CONNECTED_NOT_STARTED"
	billing_state_changed.emit(state)
	return {"ok": true, "test_only": true, "live_purchase_enabled": false}


func start_test_connection() -> Dictionary:
	if client == null or not OS.is_debug_build():
		return {"ok": false, "reason": "PLAY_BILLING_TEST_ADAPTER_UNAVAILABLE"}
	client.start_connection()
	state = "CONNECTING_TEST"
	billing_state_changed.emit(state)
	return {"ok": true, "pending": true, "test_only": true}


func purchase(product_key: String) -> Dictionary:
	if client == null or store == null:
		return {"ok": false, "reason": "PLAY_BILLING_UNAVAILABLE"}
	# StoreService is the authority: the current catalog is deliberately entirely
	# non-buyable, so no call to BillingClient.purchase() can start a live flow.
	return store.purchase(product_key)


func restore_purchases() -> Dictionary:
	if client == null or store == null or not client.is_ready():
		return {"ok": false, "reason": "PLAY_BILLING_NOT_READY"}
	client.query_purchases(BILLING_CLIENT_SCRIPT.ProductType.INAPP)
	state = "RESTORE_QUERY_PENDING_TEST"
	billing_state_changed.emit(state)
	return {"ok": true, "pending": true, "test_only": true}


func recover_pending_completions() -> Dictionary:
	if client == null or verifier == null or not client.is_ready():
		return {"ok": false, "reason": "PLAY_BILLING_NOT_READY"}
	var rows: Variant = verifier.get_pending_provider_completions()
	if not rows is Array or rows.size() > 50:
		return {"ok": false, "reason": "SERVER_COMPLETION_LEDGER_INVALID"}
	var recovered := 0
	for row in rows:
		if not row is Dictionary:
			return {"ok": false, "reason": "SERVER_COMPLETION_ROW_INVALID"}
		var token := str(row.get("purchase_token", ""))
		var transaction_id := str(row.get("transaction_id", ""))
		var product_key := str(row.get("product_key", ""))
		var kind := str(row.get("completion_kind", ""))
		if token.is_empty() or transaction_id.is_empty() or product_key.is_empty() or kind not in ["consume", "acknowledge"]:
			return {"ok": false, "reason": "SERVER_COMPLETION_ROW_INVALID"}
		_pending_completion[token] = {"transaction_id": transaction_id, "product_key": product_key, "kind": kind}
		_retry_provider_completion(token)
		recovered += 1
	return {"ok": true, "pending": recovered, "server_ledger": true}


func process_purchase_response(response: Variant) -> Dictionary:
	if not response is Dictionary or typeof(response.get("response_code")) != TYPE_INT or int(response["response_code"]) != 0:
		return {"ok": false, "reason": "BILLING_RESPONSE_INVALID_OR_FAILED"}
	var purchases: Variant = response.get("purchases", [])
	if not purchases is Array or purchases.size() > 20:
		return {"ok": false, "reason": "PURCHASE_LIST_INVALID"}
	var results: Array[Dictionary] = []
	for purchase_value in purchases:
		results.append(_process_purchase(purchase_value))
	return {"ok": results.all(func(row: Dictionary) -> bool: return bool(row.get("ok", false))), "results": results}


func _process_purchase(purchase_value: Variant) -> Dictionary:
	if not purchase_value is Dictionary:
		return {"ok": false, "reason": "PURCHASE_ROW_INVALID"}
	var purchase_row: Dictionary = purchase_value
	var token := str(purchase_row.get("purchase_token", ""))
	var product_id := str(purchase_row.get("product_id", ""))
	if token.is_empty() or token.length() > 4096 or product_id.is_empty() or int(purchase_row.get("purchase_state", -1)) != BILLING_CLIENT_SCRIPT.PurchaseState.PURCHASED:
		return {"ok": false, "reason": "PURCHASE_NOT_COMPLETE_OR_FIELDS_INVALID"}
	if _completed_tokens.has(token):
		return {"ok": true, "duplicate": true, "transaction_id": str(_completed_tokens[token])}
	if _pending_completion.has(token):
		return _retry_provider_completion(token)
	var product_key := _product_key_for_id(product_id)
	if product_key.is_empty():
		return {"ok": false, "reason": "PRODUCT_ID_NOT_IN_CATALOG"}
	var product: Dictionary = store.get_catalog().get(product_key, {})
	if not bool(product.get("buyable", false)):
		return {"ok": false, "reason": "PRODUCT_NOT_APPROVED_OR_CONFIGURED"}
	var accepted: Dictionary = store.accept_verified_transaction({
		"product_key": product_key,
		"platform": "google",
		"product_id": product_id,
		"purchase_token": token,
		"purchase_state": BILLING_CLIENT_SCRIPT.PurchaseState.PURCHASED,
	})
	if not bool(accepted.get("verified", false)):
		return {"ok": false, "reason": str(accepted.get("reason", "SERVER_VERIFICATION_REQUIRED"))}
	var transaction_id := str(accepted.get("transaction_id", ""))
	if transaction_id.is_empty():
		return {"ok": false, "reason": "VERIFIED_TRANSACTION_ID_REQUIRED"}
	var product_kind := str(product.get("kind", product.get("product_type", "")))
	if product_kind not in ["consumable", "non_consumable", "subscription"]:
		return {"ok": false, "reason": "PRODUCT_KIND_INVALID"}
	var completion_kind := "consume" if product_kind == "consumable" else "acknowledge"
	var journal: Variant = verifier.record_provider_completion(transaction_id, token, product_key, completion_kind)
	if not journal is Dictionary or not bool(journal.get("ok", false)):
		return {"ok": false, "reason": "DURABLE_SERVER_COMPLETION_RECORD_FAILED"}
	if bool(journal.get("completed", false)):
		_completed_tokens[token] = transaction_id
		return {"ok": true, "verified": true, "duplicate": true, "transaction_id": transaction_id}
	if completion_kind == "acknowledge" and bool(purchase_row.get("is_acknowledged", false)):
		var marked: Variant = verifier.complete_provider_completion(transaction_id, token)
		if not marked is Dictionary or not bool(marked.get("ok", false)):
			return {"ok": false, "reason": "DURABLE_SERVER_COMPLETION_FINALIZE_FAILED"}
		_completed_tokens[token] = transaction_id
		purchase_completed.emit(transaction_id, product_key)
		return {"ok": true, "verified": true, "already_acknowledged": true, "transaction_id": transaction_id}
	_pending_completion[token] = {"transaction_id": transaction_id, "product_key": product_key, "kind": completion_kind}
	return _retry_provider_completion(token)


func _retry_provider_completion(token: String) -> Dictionary:
	if not _pending_completion.has(token):
		return {"ok": false, "reason": "VERIFIED_COMPLETION_NOT_FOUND"}
	var pending: Dictionary = _pending_completion[token]
	if str(pending["kind"]) == "consume":
		client.consume_purchase(token)
		state = "CONSUMPTION_PENDING_TEST"
	else:
		client.acknowledge_purchase(token)
		state = "ACKNOWLEDGEMENT_PENDING_TEST"
	billing_state_changed.emit(state)
	return {"ok": true, "verified": true, "pending": true, "kind": str(pending["kind"]), "transaction_id": str(pending["transaction_id"])}


func _connect_client_signals() -> void:
	for pair in [["on_purchase_updated", Callable(self, "_on_purchase_updated")], ["query_purchases_response", Callable(self, "_on_query_purchases_response")], ["consume_purchase_response", Callable(self, "_on_consume_response")], ["acknowledge_purchase_response", Callable(self, "_on_acknowledge_response")]]:
		if not client.is_connected(pair[0], pair[1]):
			client.connect(pair[0], pair[1])


func _on_purchase_updated(response: Dictionary) -> void:
	var result := process_purchase_response(response)
	if not bool(result.get("ok", false)):
		state = "PURCHASE_REJECTED_TEST"
		billing_state_changed.emit(state)


func _on_query_purchases_response(response: Dictionary) -> void:
	var result := process_purchase_response(response)
	state = "RESTORE_VERIFIED_TEST" if bool(result.get("ok", false)) else "RESTORE_REJECTED_TEST"
	billing_state_changed.emit(state)


func _on_consume_response(response: Dictionary) -> void:
	_complete_provider_response(response, "consume")


func _on_acknowledge_response(response: Dictionary) -> void:
	_complete_provider_response(response, "acknowledge")


func _complete_provider_response(response: Dictionary, expected_kind: String) -> void:
	var token := str(response.get("purchase_token", ""))
	if not _pending_completion.has(token) or str(_pending_completion[token].get("kind", "")) != expected_kind:
		state = "PROVIDER_COMPLETION_RESPONSE_MISMATCH"
		billing_state_changed.emit(state)
		return
	if typeof(response.get("response_code")) != TYPE_INT or int(response["response_code"]) != 0:
		state = "PROVIDER_COMPLETION_FAILED"
		billing_state_changed.emit(state)
		return
	var pending: Dictionary = _pending_completion[token]
	var finalized: Variant = verifier.complete_provider_completion(str(pending["transaction_id"]), token)
	if not finalized is Dictionary or not bool(finalized.get("ok", false)):
		state = "SERVER_COMPLETION_FINALIZE_PENDING"
		billing_state_changed.emit(state)
		return
	_completed_tokens[token] = str(pending["transaction_id"])
	_pending_completion.erase(token)
	state = "PURCHASE_COMPLETED_TEST"
	billing_state_changed.emit(state)
	purchase_completed.emit(str(pending["transaction_id"]), str(pending["product_key"]))


func _product_key_for_id(product_id: String) -> String:
	for product_key in store.get_catalog():
		var product: Dictionary = store.get_catalog()[product_key]
		if str(product.get("android_product_id", "")) == product_id:
			return str(product_key)
	return ""
