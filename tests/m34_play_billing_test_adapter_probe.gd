extends SceneTree

const STORE_SCRIPT := preload("res://scripts/campaign/store_service.gd")
const ADAPTER_SCRIPT := preload("res://scripts/campaign/play_billing_test_adapter.gd")
const BILLING_SCRIPT := preload("res://addons/GodotGooglePlayBilling/BillingClient.gd")

var failures: Array[String] = []


class FakeVerifier extends RefCounted:
	var verified := true
	func verify_store_transaction(transaction: Dictionary) -> Dictionary:
		if not verified:
			return {"verified": false}
		return {"verified": true, "transaction_id": "server-%s" % str(transaction.get("purchase_token", "")), "product_key": str(transaction.get("product_key", ""))}


class FakeBilling extends RefCounted:
	signal connected
	signal query_purchases_response(response: Dictionary)
	signal on_purchase_updated(response: Dictionary)
	signal consume_purchase_response(response: Dictionary)
	signal acknowledge_purchase_response(response: Dictionary)
	var purchase_calls := 0
	var ack_tokens: Array[String] = []
	var consume_tokens: Array[String] = []
	var query_calls := 0
	func start_connection() -> void: pass
	func query_purchases(_product_type: int) -> void: query_calls += 1
	func purchase(_product_id: String) -> Dictionary:
		purchase_calls += 1
		return {"ok": true}
	func consume_purchase(token: String) -> void: consume_tokens.append(token)
	func acknowledge_purchase(token: String) -> void: ack_tokens.append(token)
	func is_ready() -> bool: return true


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_PLAY_BILLING PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_PLAY_BILLING FAIL: %s" % label)


func _catalog_row(kind: String, buyable: bool = true) -> Dictionary:
	return {"key": "remove_ads" if kind == "non_consumable" else "currency_pack_placeholder", "kind": kind, "product_type": kind, "android_product_id": "test.product", "ios_product_id": "", "price": null, "buyable": buyable}


func _purchase(token: String, state: int = BILLING_SCRIPT.PurchaseState.PURCHASED, acknowledged: bool = false) -> Dictionary:
	return {"purchase_token": token, "product_id": "test.product", "purchase_state": state, "is_acknowledged": acknowledged}


func _run() -> void:
	var store: StoreService = STORE_SCRIPT.new()
	root.add_child(store)
	var billing := FakeBilling.new()
	var verifier := FakeVerifier.new()
	var adapter: PlayBillingTestAdapter = ADAPTER_SCRIPT.new()
	var configured := adapter.configure_test(billing, store, verifier)
	_check("adapter binds only the installed BillingClient signals and methods in debug test mode", configured.get("ok", false) and configured.get("test_only", false))
	store._catalog = {"schema_version": 1, "products": [_catalog_row("non_consumable", false)]}
	var blocked_purchase := adapter.purchase("remove_ads")
	_check("unapproved catalog cannot reach BillingClient.purchase", not blocked_purchase.get("ok", false) and billing.purchase_calls == 0)
	var pending := adapter.process_purchase_response({"response_code": 0, "purchases": [_purchase("pending-token", BILLING_SCRIPT.PurchaseState.PENDING)]})
	_check("pending Play purchase is not verified, acknowledged, or granted", not pending.get("ok", false) and billing.ack_tokens.is_empty() and billing.consume_tokens.is_empty() and store.entitlements.is_empty())
	store._catalog = {"schema_version": 1, "products": [_catalog_row("non_consumable", true)]}
	verifier.verified = false
	var fraud := adapter.process_purchase_response({"response_code": 0, "purchases": [_purchase("fraud-token")]})
	_check("server rejection blocks entitlement and provider acknowledgement", not fraud.get("ok", false) and billing.ack_tokens.is_empty() and store.entitlements.is_empty())
	verifier.verified = true
	var invalid := adapter.process_purchase_response({"response_code": 0, "purchases": [_purchase("")]})
	_check("missing purchase token fails closed", not invalid.get("ok", false) and billing.ack_tokens.is_empty())
	var verified := adapter.process_purchase_response({"response_code": 0, "purchases": [_purchase("valid-token")]})
	_check("server-verified non-consumable is acknowledged after verification", verified.get("ok", false) and billing.ack_tokens == ["valid-token"] and store.entitlements.get("remove_ads", false))
	billing.acknowledge_purchase_response.emit({"purchase_token": "valid-token", "response_code": 0})
	var replay := adapter.process_purchase_response({"response_code": 0, "purchases": [_purchase("valid-token")]})
	_check("acknowledged purchase replay remains idempotent", replay.get("ok", false) and replay.get("results", [])[0].get("duplicate", false) and billing.ack_tokens.size() == 1)
	store._catalog = {"schema_version": 1, "products": [_catalog_row("consumable", true)]}
	var consumed := adapter.process_purchase_response({"response_code": 0, "purchases": [_purchase("consume-token")]})
	_check("server-verified consumable uses consume rather than acknowledge", consumed.get("ok", false) and billing.consume_tokens == ["consume-token"] and billing.ack_tokens.size() == 1)
	billing.consume_purchase_response.emit({"purchase_token": "consume-token", "response_code": 0})
	verifier.verified = false
	var entitlement_count := store.entitlements.size()
	var restore := adapter.restore_purchases()
	billing.query_purchases_response.emit({"response_code": 0, "purchases": [_purchase("restore-fraud-token")]})
	_check("restore remains a server-verified query and fraudulent restore grants nothing", restore.get("pending", false) and billing.query_calls == 1 and store.entitlements.size() == entitlement_count)
	store.queue_free()
	if failures.is_empty():
		print("M34_PLAY_BILLING_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_PLAY_BILLING_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
