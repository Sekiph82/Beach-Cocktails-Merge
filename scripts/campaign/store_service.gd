class_name StoreService
extends Node

## The ONE authority that turns a real-money store result into a grant (ported from
## ScrubBots scripts/economy/store_service.gd, owner 2026-11-19). Products come from
## data/campaign/store_catalog.json (bad config = no products, fail closed). The provider
## (StoreProvider; default = the unavailable base class) only talks to Google Play / the
## App Store; every grant goes through GameEconomy.grant_reward under reward id
## "store:<purchase token>", whose ledger is saved with the campaign, so a duplicate
## callback, a relaunch re-delivery or an imported save can never grant twice.
##
## Only outcome "purchased" with a token commits. Every purchased delivery (new grant or
## duplicate re-delivery) is saved before the store is acknowledged; a failed save leaves
## the purchase unacknowledged so the store re-delivers it.
## Prices are only the store's localized strings (price_text); this service never formats one.

const StoreProvider = preload("res://scripts/campaign/store_provider.gd")

signal prices_changed
signal resolved(product_id: String, result: Dictionary)
signal restored(result: Dictionary)

const CATALOG_PATH := "res://data/campaign/store_catalog.json"
const TX_PREFIX := "store:"
const PURCHASED := "purchased"

var economy
var _provider = StoreProvider.new()
var _save_cb: Callable = Callable()
var _products: Dictionary = {}   ## id -> catalog entry (catalog order)
var _prices: Dictionary = {}     ## id -> localized price string from the provider
var _pending: Dictionary = {}    ## product id -> true while its purchase sheet is open


func _init(catalog_path: String = CATALOG_PATH) -> void:
	_load(catalog_path)


func _load(path: String) -> void:
	_products = {}
	var cfg = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	if typeof(cfg) != TYPE_DICTIONARY or int(cfg.get("schema_version", 0)) != 2 or typeof(cfg.get("products")) != TYPE_ARRAY:
		return
	var out := {}
	for p in cfg["products"]:
		if typeof(p) != TYPE_DICTIONARY or typeof(p.get("id")) != TYPE_STRING or String(p["id"]).is_empty() or out.has(p["id"]):
			return
		if p.get("kind") != "consumable" or typeof(p.get("gems")) != TYPE_FLOAT or int(p["gems"]) <= 0 or float(p["gems"]) != float(int(p["gems"])):
			return
		out[String(p["id"])] = p
	_products = out


func bind_economy(value) -> void:
	economy = value


func bind_save(cb: Callable) -> void:
	_save_cb = cb


func set_provider(p) -> void:
	_provider = p if p != null else StoreProvider.new()
	_prices.clear()
	_pending.clear()
	prices_changed.emit()


func get_provider():
	return _provider


# ------------------------------------------------------------------- catalog ----

func product_ids() -> Array:
	return _products.keys()


func gems_of(id: String) -> int:
	return int(_products[id].get("gems", 0)) if _products.has(id) else 0


## Keyed product dictionaries (read-only copy) for tooling and probes.
func get_catalog() -> Dictionary:
	return _products.duplicate(true)


func is_available() -> bool:
	return _provider != null and _provider.is_available()


## Ask the store for localized prices; prices_changed fires when they arrive.
func refresh_prices() -> void:
	if is_available():
		_provider.query_products(product_ids(), Callable(self, "_on_prices"))


func _on_prices(prices: Dictionary) -> void:
	for id in prices:
		if _products.has(id) and typeof(prices[id]) == TYPE_STRING and not String(prices[id]).is_empty():
			_prices[id] = String(prices[id])
	prices_changed.emit()


## The store's localized price string, "" when the store has not priced it (= unavailable).
func price_text(id: String) -> String:
	return String(_prices.get(id, "")) if is_available() else ""


# ------------------------------------------------------------------ purchase ----

## {ok} when `id` may be bought right now, else {ok:false, reason}.
func can_purchase(id: String) -> Dictionary:
	if not _products.has(id):
		return {"ok": false, "reason": "unknown_product"}
	if economy == null:
		return {"ok": false, "reason": "economy_unavailable"}
	if price_text(id).is_empty():
		return {"ok": false, "reason": "unavailable"}
	if _pending.has(id):
		return {"ok": false, "reason": "pending"}
	return {"ok": true}


## Open the store purchase sheet. The result arrives through deliver() / `resolved`.
func purchase(id: String) -> Dictionary:
	var c := can_purchase(id)
	if not c["ok"]:
		return c
	_pending[id] = true
	_provider.last_error = ""
	if not _provider.purchase(id, Callable(self, "deliver")):
		_pending.erase(id)
		return {"ok": false, "reason": "provider_refused", "error": String(_provider.last_error)}
	return {"ok": true, "product_id": id}


## Provider callback (also used for unfinished purchases the store re-delivers at launch).
func deliver(r: Dictionary) -> Dictionary:
	var id := String(r.get("product_id", ""))
	var token := String(r.get("token", ""))
	var outcome := String(r.get("outcome", ""))
	_pending.erase(id)
	var out: Dictionary
	if not _products.has(id):
		out = {"ok": false, "reason": "unknown_product"}
	elif outcome != PURCHASED:
		out = {"ok": false, "reason": outcome if not outcome.is_empty() else "failed"}
		if not String(r.get("error", "")).is_empty():
			out["error"] = String(r["error"])
	elif token.is_empty():
		out = {"ok": false, "reason": "no_token"}
	elif economy == null:
		# Leave the purchase unacknowledged: the store re-delivers it at the next launch.
		out = {"ok": false, "reason": "economy_unavailable"}
	else:
		var grant: Dictionary = economy.grant_reward(TX_PREFIX + token, {"type": "gems", "quantity": gems_of(id)})
		if not bool(grant.get("ok", false)):
			out = {"ok": false, "reason": str(grant.get("reason", "grant_failed"))}
		else:
			out = {"ok": true} if bool(grant.get("granted", false)) else {"ok": false, "reason": "duplicate"}
			out["gems"] = gems_of(id) if bool(grant.get("granted", false)) else 0
			# A duplicate may be the re-delivery after a failed save: save again before acknowledging.
			var saved := true
			if _save_cb.is_valid():
				out["save"] = _save_cb.call()
				saved = bool(out["save"].get("ok", false))
			if saved:
				_provider.acknowledge(token, true)
	out["product_id"] = id
	out["token"] = token
	resolved.emit(id, out.duplicate(true))
	return out


## Restore purchases. The catalog has only consumables (never restored), so this only
## asks the store and reports what it returned.
func restore() -> Dictionary:
	if not is_available():
		return {"ok": false, "reason": "unavailable"}
	if not _provider.restore(Callable(self, "_on_restore")):
		return {"ok": false, "reason": "provider_refused"}
	return {"ok": true}


func _on_restore(owned: Array) -> Dictionary:
	var out := {"ok": true, "restored": 0, "owned": owned.size()}
	restored.emit(out.duplicate(true))
	return out
