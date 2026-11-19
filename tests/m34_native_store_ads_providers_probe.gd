extends SceneTree

## Native store / rewarded-ad providers (owner 2026-11-19, ScrubBots pattern) driven by
## doubles of the GodotGooglePlayBilling singleton, the inappstore singleton and the
## godot-admob node. Nothing native or networked runs here.

const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const STORE_SCRIPT := preload("res://scripts/campaign/store_service.gd")
const PLAY_SCRIPT := preload("res://scripts/campaign/play_billing_store_provider.gd")
const APP_STORE_SCRIPT := preload("res://scripts/campaign/app_store_provider.gd")
const ADS_SCRIPT := preload("res://scripts/campaign/ads_service.gd")
const ADMOB_SCRIPT := preload("res://scripts/campaign/admob_rewarded_provider.gd")

var failures: Array[String] = []


class FakePlay extends RefCounted:
	signal connected
	signal disconnected
	signal query_product_details_response(response: Dictionary)
	signal query_purchases_response(response: Dictionary)
	signal on_purchase_updated(response: Dictionary)
	var calls: Array = []
	var owned: Array = []
	func initPlugin() -> void:
		calls.append("init")
	func startConnection() -> void:
		calls.append("start")
	func queryProductDetails(ids: PackedStringArray, type: String) -> void:
		calls.append("details:" + type)
		var out: Array = []
		for id in ids:
			out.append({"product_id": id, "one_time_purchase_offer_details_list": [{"formatted_price": "TRY %d,99" % id.length()}]})
		query_product_details_response.emit({"response_code": 0, "product_details": out})
	func queryPurchases(type: String, _subs: bool) -> void:
		calls.append("purchases:" + type)
		query_purchases_response.emit({"response_code": 0, "purchases": owned})
	func purchase(id: String, _option: String, _offer: String, _personal: bool) -> Dictionary:
		calls.append("purchase:" + id)
		return {"response_code": 0}
	func consumePurchase(token: String) -> void:
		calls.append("consume:" + token)
	func acknowledgePurchase(token: String) -> void:
		calls.append("ack:" + token)


class FakeAppStore extends RefCounted:
	var calls: Array = []
	var events: Array = []
	var auto_finish := true
	func set_auto_finish_transaction(b: bool) -> void:
		auto_finish = b
	func request_product_info(p: Dictionary) -> int:
		calls.append("info")
		events.append({"type": "product_info", "result": "ok", "ids": PackedStringArray(p["product_ids"]), "invalid_ids": PackedStringArray(),
			"localized_prices": PackedStringArray(Array(p["product_ids"]).map(func(_id): return "US$0.99"))})
		return OK
	func purchase(p: Dictionary) -> int:
		calls.append("purchase:" + String(p["product_id"]))
		return OK
	func restore_purchases() -> int:
		calls.append("restore")
		return OK
	func finish_transaction(id: String) -> void:
		calls.append("finish:" + id)
	func get_pending_event_count() -> int:
		return events.size()
	func pop_pending_event() -> Dictionary:
		return events.pop_front()


class FakeAdmob extends RefCounted:
	signal consent_info_updated
	signal consent_info_update_failed(e)
	signal consent_form_loaded
	signal consent_form_failed_to_load(e)
	signal consent_form_dismissed(e)
	signal tracking_authorization_granted
	signal tracking_authorization_denied
	signal initialization_completed(s)
	signal rewarded_ad_loaded(a, r)
	signal rewarded_ad_failed_to_load(a, e)
	signal rewarded_ad_user_earned_reward(a, r)
	signal rewarded_ad_dismissed_full_screen_content(a)
	signal rewarded_ad_failed_to_show_full_screen_content(a, e)
	class Consent:
		var s := ""
		func to_status_string() -> String:
			return s
	var is_real := false
	var android_real_rewarded_id := ""
	var ios_real_rewarded_id := ""
	var auto_show_on_resume := true
	var consent := "REQUIRED"
	var calls: Array = []
	func update_consent_info() -> void:
		calls.append("consent_info")
	func get_consent_status():
		var c := Consent.new()
		c.s = consent
		return c
	func is_consent_form_available() -> bool:
		return true
	func load_consent_form() -> void:
		calls.append("load_form")
	func show_consent_form() -> void:
		calls.append("show_form")
	func request_tracking_authorization() -> void:
		calls.append("att")
	func initialize() -> void:
		calls.append("initialize")
	func load_rewarded_ad() -> void:
		calls.append("load_rewarded")
	func show_rewarded_ad() -> void:
		calls.append("show_rewarded")


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_NATIVE_PROVIDERS PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_NATIVE_PROVIDERS FAIL: %s" % label)


func _economy():
	var e = ECONOMY_SCRIPT.new()
	e.configure(0, {}, [], 0)
	return e


func _store(saves: Array, save_ok := true):
	var store = STORE_SCRIPT.new()
	root.add_child(store)
	store.bind_economy(_economy())
	store.bind_save(func() -> Dictionary:
		saves.append(store.economy.gems)
		return {"ok": save_ok})
	return store


func _run() -> void:
	# Catalog and the unavailable default.
	var saves: Array = []
	var store = _store(saves)
	_check("catalog has the five ScrubBots-shaped gem packs", store.product_ids() == ["gems_25", "gems_140", "gems_300", "gems_650", "gems_1750"] and store.gems_of("gems_650") == 650)
	_check("null provider: unavailable, no price, purchase refused", not store.is_available() and store.price_text("gems_25").is_empty() and not store.purchase("gems_25").get("ok", false))

	# Google Play Billing.
	var play := FakePlay.new()
	var provider = PLAY_SCRIPT.new(play, Callable(store, "deliver"))
	store.set_provider(provider)
	_check("play provider starts the billing connection", play.calls.slice(0, 2) == ["init", "start"] and not store.is_available())
	play.connected.emit()
	store.refresh_prices()
	_check("play prices are the store's localized strings", store.is_available() and store.price_text("gems_140") == "TRY 8,99")
	_check("purchase opens the Play sheet", store.purchase("gems_140").get("ok", false) and play.calls.has("purchase:gems_140"))
	var pending_resolved: Array = []
	store.resolved.connect(func(id, r): pending_resolved.append([id, r]))
	play.on_purchase_updated.emit({"response_code": 0, "purchases": [{"product_ids": PackedStringArray(["gems_140"]), "purchase_token": "tok-1", "purchase_state": 2}]})
	_check("PENDING grants nothing and consumes nothing", store.economy.gems == 0 and not play.calls.has("consume:tok-1"))
	play.on_purchase_updated.emit({"response_code": 0, "purchases": [{"product_ids": PackedStringArray(["gems_140"]), "purchase_token": "tok-1", "purchase_state": 1}]})
	_check("PURCHASED grants 140 gems, saved before consume", store.economy.gems == 140 and saves == [140] and play.calls.has("consume:tok-1"))
	play.on_purchase_updated.emit({"response_code": 0, "purchases": [{"product_ids": PackedStringArray(["gems_140"]), "purchase_token": "tok-1", "purchase_state": 1}]})
	_check("a re-delivered token never grants twice", store.economy.gems == 140 and str(pending_resolved.back()[1].get("reason", "")) == "duplicate")
	_check("the grant is in the saved reward ledger", store.economy.export_state().get("reward_ledger", []).has("store:tok-1"))
	store.purchase("gems_25")
	play.on_purchase_updated.emit({"response_code": 1})
	_check("USER_CANCELED grants nothing", store.economy.gems == 140 and str(pending_resolved.back()[1].get("reason", "")) == "cancelled")

	# A failed save leaves the purchase unconsumed so Play re-delivers it.
	var fail_saves: Array = []
	var store2 = _store(fail_saves, false)
	var play2 := FakePlay.new()
	store2.set_provider(PLAY_SCRIPT.new(play2, Callable(store2, "deliver")))
	play2.owned = [{"product_ids": PackedStringArray(["gems_25"]), "purchase_token": "tok-crash", "purchase_state": 1, "is_acknowledged": false}]
	play2.connected.emit()
	_check("launch reconciliation delivers an unfinished purchase", store2.economy.gems == 25)
	_check("a failed save does not consume", not play2.calls.has("consume:tok-crash"))

	# Apple StoreKit (inappstore event queue).
	var app := FakeAppStore.new()
	var store3 = _store([])
	var app_provider = APP_STORE_SCRIPT.new(app, Callable(store3, "deliver"))
	store3.set_provider(app_provider)
	_check("auto-finish is turned off", not app.auto_finish)
	store3.refresh_prices()
	app_provider.poll()
	_check("app store prices arrive through the event queue", store3.price_text("gems_300") == "US$0.99")
	store3.purchase("gems_300")
	app.events.append({"type": "purchase", "result": "ok", "product_id": "gems_300", "transaction_id": "ios-tx-1"})
	app_provider.poll()
	# inappstore's finish_transaction takes the product id; the transaction id is the grant token.
	_check("StoreKit purchase grants 300 gems then finishes the transaction", store3.economy.gems == 300 and app.calls.has("finish:gems_300") and store3.economy.export_state().get("reward_ledger", []).has("store:ios-tx-1"))

	# AdMob rewarded: UMP -> (ATT) -> init -> load -> earned-before-close.
	var ads = ADS_SCRIPT.new()
	root.add_child(ads)
	var admob := FakeAdmob.new()
	var ad_provider = ADMOB_SCRIPT.new(admob, ads, false)
	_check("native provider attaches to AdsService", ads.set_native_provider(ad_provider) and ads.production_enabled)
	ad_provider.start()
	admob.consent_info_updated.emit()
	_check("consent form loads when UMP says REQUIRED", admob.calls.has("load_form"))
	admob.consent_form_loaded.emit()
	admob.consent_form_dismissed.emit(null)
	_check("Android initializes the SDK after consent (no ATT)", admob.calls.has("initialize") and not admob.calls.has("att"))
	admob.initialization_completed.emit(null)
	_check("one rewarded ad loads after init, TEST units by default", admob.calls.has("load_rewarded") and ad_provider.is_test_provider())
	admob.rewarded_ad_loaded.emit(null, null)
	var rewarded: Array = []
	ads.verified_rewarded.connect(func(p, tx, receipt): rewarded.append([p, tx, receipt]))
	var req: Dictionary = ads.request_rewarded("energy_20", "energy-ad-1")
	var shown: Dictionary = ads.show_rewarded()
	_check("ready ad is requested and shown", req.get("ok", false) and shown.get("ok", false) and admob.calls.has("show_rewarded"))
	admob.rewarded_ad_dismissed_full_screen_content.emit(null)
	_check("closing without the earned callback grants nothing", rewarded.is_empty() and ads.state == "CANCELLED")
	admob.rewarded_ad_loaded.emit(null, null)
	ads.request_rewarded("energy_20", "energy-ad-2")
	ads.show_rewarded()
	admob.rewarded_ad_user_earned_reward.emit(null, null)
	admob.rewarded_ad_dismissed_full_screen_content.emit(null)
	_check("earned-before-close grants exactly once", rewarded.size() == 1 and rewarded[0][0] == "energy_20" and rewarded[0][1] == "energy-ad-2" and str(rewarded[0][2]).begins_with("admob-client:") and ads.state == "REWARDED")
	var economy = _economy()
	economy.energy = 40
	_check("the client receipt refills energy through the existing economy rule", economy.grant_verified_ad_energy(rewarded[0][1], rewarded[0][2]).get("ok", false) and economy.energy == 60)
	ads.request_rewarded("daily_slot_3", "daily-wait")
	var deferred: Dictionary = ads.show_rewarded()
	_check("a still-loading ad is shown as soon as it loads", deferred.get("pending", false) and ads.state == "LOADING")
	admob.rewarded_ad_loaded.emit(null, null)
	_check("loaded -> shown automatically", ads.state == "SHOWING")

	# iOS: ATT after UMP, before init.
	var ios_ads = ADS_SCRIPT.new()
	root.add_child(ios_ads)
	var ios_admob := FakeAdmob.new()
	ios_admob.consent = "NOT_REQUIRED"
	var ios_provider = ADMOB_SCRIPT.new(ios_admob, ios_ads, true)
	ios_ads.set_native_provider(ios_provider)
	ios_provider.start()
	ios_admob.consent_info_updated.emit()
	_check("iOS asks ATT before the SDK initializes", ios_admob.calls.has("att") and not ios_admob.calls.has("initialize"))
	ios_admob.tracking_authorization_denied.emit()
	_check("ATT denied still initializes (non-personalised ads)", ios_admob.calls.has("initialize"))

	# Break provider <-> double signal cycles so nothing leaks at exit.
	for double in [admob, ios_admob, play, play2]:
		for sig in double.get_signal_list():
			for connection in double.get_signal_connection_list(sig["name"]):
				double.disconnect(sig["name"], connection["callable"])
	for node in [store, store2, store3, ads, ios_ads]:
		node.free()
	if failures.is_empty():
		print("M34_NATIVE_PROVIDERS_RESULT=PASS")
		quit(0)
	else:
		print("M34_NATIVE_PROVIDERS_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
