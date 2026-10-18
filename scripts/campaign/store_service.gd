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

const CATALOG_PATH := "res://data/campaign/store_catalog.json"
const FALLBACK_CATALOG := {
	"schema_version": 1,
	"status": "OWNER_APPROVAL_AND_VERIFIED_PROVIDER_REQUIRED",
	"products": [
		{"key": "remove_ads", "kind": "non_consumable", "android_product_id": "", "ios_product_id": "", "price": null, "buyable": false},
		{"key": "currency_pack_placeholder", "kind": "consumable", "android_product_id": "", "ios_product_id": "", "price": null, "buyable": false},
	],
}

var provider_adapter: Object
var trusted_verifier: Object
var state := STATE_UNAVAILABLE
var entitlements: Dictionary = {}
var _verified_transaction_ids: Dictionary = {}
var _catalog: Dictionary = {}


func configure(adapter: Object = null, verifier: Object = null) -> void:
	provider_adapter = adapter
	trusted_verifier = verifier
	_load_catalog()
	state = STATE_UNAVAILABLE if provider_adapter == null else STATE_DISABLED
	store_state_changed.emit(state)


func get_catalog() -> Dictionary:
	## Compatibility API: callers receive product dictionaries keyed by product ID.
	## Keep the schema envelope available through get_catalog_document().
	if _catalog.is_empty():
		_load_catalog()
	var products: Dictionary = {}
	for product_variant in _catalog.get("products", []):
		if product_variant is Dictionary:
			var product: Dictionary = product_variant
			var product_key := str(product.get("key", ""))
			if not product_key.is_empty():
				var compatible_product: Dictionary = product.duplicate(true)
				if compatible_product.has("kind") and not compatible_product.has("product_type"):
					compatible_product["product_type"] = compatible_product["kind"]
				products[product_key] = compatible_product
	return products


func get_catalog_document() -> Dictionary:
	## Full parsed catalog document for schema-aware tooling and probes.
	if _catalog.is_empty():
		_load_catalog()
	return _catalog.duplicate(true)


func purchase(product_key: String) -> Dictionary:
	var product: Dictionary = _product(product_key)
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
	var product: Dictionary = _product(product_key)
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
	var verified_product: Dictionary = _product(product_key)
	if transaction_id.is_empty() or product_key.is_empty() or verified_product.is_empty() or not bool(verified_product.get("buyable", false)):
		return {"ok": false, "reason": "VERIFIED_TRANSACTION_FIELDS_INVALID"}
	if _verified_transaction_ids.has(transaction_id):
		return {"ok": true, "duplicate": true, "transaction_id": transaction_id}
	_verified_transaction_ids[transaction_id] = true
	if str(verified_product.get("kind", "")) == "non_consumable":
		entitlements[product_key] = true
	state = STATE_VERIFIED
	store_state_changed.emit(state)
	entitlement_verified.emit(product_key, transaction_id)
	return {"ok": true, "verified": true, "transaction_id": transaction_id, "product_key": product_key}


func _load_catalog() -> void:
	_catalog = FALLBACK_CATALOG.duplicate(true)
	if not FileAccess.file_exists(CATALOG_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not parsed is Dictionary or not parsed.get("products", []) is Array:
		return
	var product_keys: Dictionary = {}
	for product_variant in parsed.products:
		if not product_variant is Dictionary:
			return
		var product: Dictionary = product_variant
		var key := str(product.get("key", ""))
		if key.is_empty() or product_keys.has(key):
			return
		product_keys[key] = true
	_catalog = parsed.duplicate(true)


func _product(product_key: String) -> Dictionary:
	if _catalog.is_empty():
		_load_catalog()
	for product_variant in _catalog.get("products", []):
		if product_variant is Dictionary and str(product_variant.get("key", "")) == product_key:
			return product_variant
	return {}
