extends SceneTree

## Store catalog contract (owner 2026-11-19, ScrubBots pattern): five gem packs, store
## prices only, and nothing sellable or grantable without a live store provider.

const STORE_SCRIPT := preload("res://scripts/campaign/store_service.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")

var failures: Array[String] = []


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
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(0, {}, [], 0)
	store.bind_economy(economy)
	var document = JSON.parse_string(FileAccess.get_file_as_string("res://data/campaign/store_catalog.json"))
	var catalog: Dictionary = store.get_catalog()
	_check("catalog is the owner-approved schema 2 gem-pack list", document is Dictionary and int(document.get("schema_version", 0)) == 2 and catalog.size() == 5)
	_check("every product is a consumable gem pack with a positive whole amount", catalog.values().all(func(p: Dictionary) -> bool: return p.get("kind") == "consumable" and int(p.get("gems", 0)) > 0))
	_check("product ids follow gems_<amount>", catalog.keys().all(func(id: String) -> bool: return id == "gems_%d" % store.gems_of(id)))
	_check("no displayed price lives in the catalog (store strings only)", catalog.values().all(func(p: Dictionary) -> bool: return not p.has("price")))
	_check("without a provider nothing is priced, bought or restored", store.price_text("gems_25").is_empty() and not store.purchase("gems_25").get("ok", false) and not store.restore().get("ok", false))
	var forged: Dictionary = store.deliver({"product_id": "gems_1750", "token": "", "outcome": "purchased"})
	_check("a delivery without a store token grants nothing", not forged.get("ok", false) and economy.gems == 0)
	var unknown: Dictionary = store.deliver({"product_id": "remove_ads", "token": "t", "outcome": "purchased"})
	_check("an unknown product grants nothing", not unknown.get("ok", false) and economy.gems == 0)
	_check("Merchant ID is not used as a product or app identifier", not JSON.stringify(document).contains("merchant.com"))
	store.free()
	if failures.is_empty():
		print("M34_STORE_RESULT=PASS")
		quit(0)
	else:
		print("M34_STORE_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
