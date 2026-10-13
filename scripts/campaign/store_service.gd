class_name StoreService
extends Node

## Store boundary only. Catalog entries remain non-buyable until owner setup and
## a trusted receipt verifier are configured; client-side success never grants.

signal store_state_changed(state: String)
signal entitlement_verified(product_key: String, transaction_id: String)

const STATE_UNAVAILABLE := "UNAVAILABLE"
const STATE_DISABLED := "DISABLED"
const STATE_PENDING := "PENDING"
const STATE_FAILED := "FAILED"
const STATE_VERIFIED := "VERIFIED"

const PLACEHOLDER_CATALOG := {
	"remove_ads": {"product_type": "non_consumable", "android_product_id": "", "ios_product_id": "", "buyable": false},
	"currency_pack_placeholder": {"product_type": "consumable", "android_product_id": "", "ios_product_id": "", "buyable": false},
}

var provider_adapter: Object
var trusted_verifier: Object
var state := STATE_UNAVAILABLE
var entitlements: Dictionary = {}
var _verified_transaction_ids: Dictionary = {}


func configure(adapter: Object = null, verifier: Object = null) -> void:
	provider_adapter = adapter
	trusted_verifier = verifier
	state = STATE_UNAVAILABLE if provider_adapter == null else STATE_DISABLED
	store_state_changed.emit(state)


func get_catalog() -> Dictionary:
	return PLACEHOLDER_CATALOG.duplicate(true)


func purchase(product_key: String) -> Dictionary:
	var product: Dictionary = PLACEHOLDER_CATALOG.get(product_key, {})
	if product.is_empty() or not bool(product.get("buyable", false)):
		state = STATE_DISABLED
		store_state_changed.emit(state)
		return {"ok": false, "reason": "PRODUCT_NOT_APPROVED_OR_CONFIGURED", "state": state}
	if provider_adapter == null:
		state = STATE_UNAVAILABLE
		store_state_changed.emit(state)
		return {"ok": false, "reason": "STORE_PROVIDER_UNAVAILABLE", "state": state}
	return {"ok": false, "reason": "LIVE_PURCHASE_DISABLED", "state": STATE_DISABLED}


func restore_purchases() -> Dictionary:
	if provider_adapter == null:
		state = STATE_UNAVAILABLE
		store_state_changed.emit(state)
		return {"ok": false, "reason": "STORE_PROVIDER_UNAVAILABLE", "entitlements": entitlements.duplicate(true)}
	return {"ok": false, "reason": "TRUSTED_RESTORE_VERIFICATION_REQUIRED", "entitlements": entitlements.duplicate(true)}


func accept_verified_transaction(transaction: Dictionary) -> Dictionary:
	var product_key := str(transaction.get("product_key", ""))
	var product: Dictionary = PLACEHOLDER_CATALOG.get(product_key, {})
	if product.is_empty() or not bool(product.get("buyable", false)):
		return {"ok": false, "reason": "PRODUCT_NOT_APPROVED_OR_CONFIGURED"}
	if provider_adapter == null:
		return {"ok": false, "reason": "STORE_PROVIDER_UNAVAILABLE"}
	if trusted_verifier == null or not trusted_verifier.has_method("verify_store_transaction"):
		return {"ok": false, "reason": "TRUSTED_VERIFIER_UNAVAILABLE"}
	var verification: Dictionary = trusted_verifier.verify_store_transaction(transaction.duplicate(true))
	if not bool(verification.get("verified", false)):
		state = STATE_FAILED
		store_state_changed.emit(state)
		return {"ok": false, "reason": "STORE_TRANSACTION_NOT_VERIFIED"}
	var transaction_id := str(verification.get("transaction_id", ""))
	product_key = str(verification.get("product_key", ""))
	if transaction_id.is_empty() or product_key.is_empty() or not PLACEHOLDER_CATALOG.has(product_key):
		return {"ok": false, "reason": "VERIFIED_TRANSACTION_FIELDS_INVALID"}
	if _verified_transaction_ids.has(transaction_id):
		return {"ok": true, "duplicate": true, "transaction_id": transaction_id}
	_verified_transaction_ids[transaction_id] = true
	if str(PLACEHOLDER_CATALOG[product_key].get("product_type", "")) == "non_consumable":
		entitlements[product_key] = true
	state = STATE_VERIFIED
	store_state_changed.emit(state)
	entitlement_verified.emit(product_key, transaction_id)
	return {"ok": true, "verified": true, "transaction_id": transaction_id, "product_key": product_key}
