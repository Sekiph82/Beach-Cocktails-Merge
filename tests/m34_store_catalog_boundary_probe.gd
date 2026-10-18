extends SceneTree

const STORE_SCRIPT := preload("res://scripts/campaign/store_service.gd")

var failures: Array[String] = []


class TestProvider extends RefCounted:
	pass


class ForgedVerifier extends RefCounted:
	func verify_store_transaction(_transaction: Dictionary) -> Dictionary:
		return {"verified": true, "transaction_id": "forged", "product_key": "remove_ads"}


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_STORE PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_STORE FAIL: %s" % label)


func _run() -> void:
	var store: StoreService = STORE_SCRIPT.new()
	root.add_child(store)
	store.configure()
	var catalog: Dictionary = store.get_catalog()
	var catalog_document: Dictionary = store.get_catalog_document()
	var products: Array = catalog_document.get("products", [])
	_check("preserves the keyed product-dictionary get_catalog API", catalog.size() == 2 and catalog.has("remove_ads") and catalog["remove_ads"] is Dictionary)
	_check("preserves the former product_type row field while retaining schema kind", catalog["remove_ads"].get("product_type", "") == catalog["remove_ads"].get("kind", "") and not catalog["remove_ads"].get("kind", "").is_empty())
	_check("exposes the tracked, explicitly unapproved schema document separately", catalog_document.get("status", "") == "OWNER_APPROVAL_AND_VERIFIED_PROVIDER_REQUIRED" and products.size() == 2)
	_check("all proposed products remain non-buyable and unpriced", products.all(func(product: Dictionary) -> bool: return not product.get("buyable", true) and product.get("price") == null and str(product.get("android_product_id", "")).is_empty() and str(product.get("ios_product_id", "")).is_empty()))
	_check("purchase and restore fail closed without provider", not store.purchase("remove_ads").get("ok", false) and not store.restore_purchases().get("ok", false))
	store.configure(TestProvider.new(), ForgedVerifier.new())
	var forged: Dictionary = store.accept_verified_transaction({"product_key": "remove_ads", "signed_transaction": "client-assertion"})
	_check("a verifier success cannot grant a product absent owner catalog approval", not forged.get("ok", false) and store.entitlements.is_empty())
	_check("Merchant ID is not used as a product or app identifier", not JSON.stringify(catalog_document).contains("merchant.com"))
	store.free()
	if failures.is_empty():
		print("M34_STORE_RESULT=PASS")
		quit(0)
	else:
		print("M34_STORE_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
