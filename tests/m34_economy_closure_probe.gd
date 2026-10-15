extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ADS_SCRIPT := preload("res://scripts/campaign/ads_service.gd")
const STORE_SCRIPT := preload("res://scripts/campaign/store_service.gd")
const DAILY_SCRIPT := preload("res://scripts/campaign/daily_reward_service.gd")

class MockRewardProvider extends RefCounted:
	func request_rewarded(_placement_id: String, _transaction_id: String) -> Dictionary:
		return {"ok": true}

	func show_rewarded(_transaction_id: String) -> Dictionary:
		return {"ok": true}

class MockStoreProvider extends RefCounted:
	pass

class MockStoreVerifier extends RefCounted:
	func verify_store_transaction(transaction: Dictionary) -> Dictionary:
		return {"verified": true, "transaction_id": str(transaction.get("transaction_id", "")), "product_key": str(transaction.get("product_key", ""))}

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_ECONOMY PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_ECONOMY FAIL: %s" % label)


func _run() -> void:
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(100, {"focus": 2, "upgrade": 1}, [], 25, [], 100, 1000)
	_check("legacy Focus inventory is preserved in a retired counter with unrelated boosters intact", economy.retired_focus_inventory == 2 and not economy.boosters.has("focus") and economy.get_booster_count("upgrade") == 1)
	_check("Focus cannot be granted, spent, or purchased", not economy.grant_booster("focus", 1).get("ok", false) and not economy.consume_booster("focus").get("ok", false) and not economy.purchase_booster("focus-buy", "focus", 1, "coins", 1).get("ok", false) and economy.coins == 100 and economy.gems == 25)
	var first_attempt: Dictionary = economy.begin_energy_attempt("attempt-win", "sunny_cove", 1, 1000)
	var replay_attempt: Dictionary = economy.begin_energy_attempt("attempt-win", "sunny_cove", 1, 1000)
	var win_settlement: Dictionary = economy.settle_energy_attempt("attempt-win", "WIN", 1000)
	var duplicate_win_settlement: Dictionary = economy.settle_energy_attempt("attempt-win", "LOSE", 1000)
	_check("starting and winning costs no Energy; a second terminal callback cannot convert or charge the WIN", first_attempt.get("started", false) and replay_attempt.get("duplicate", false) and win_settlement.get("energy_delta", -1) == 0 and duplicate_win_settlement.get("duplicate", false) and economy.energy == 100)
	var next_level_attempt: Dictionary = economy.begin_energy_attempt("attempt-next-level", "sunny_cove", 2, 1000)
	var abandoned_next_level: Dictionary = economy.settle_energy_attempt("attempt-next-level", "QUIT", 1000)
	_check("owner example keeps 100 through WIN and next-level entry, then charges 20 once on abandonment", next_level_attempt.get("started", false) and economy.energy == 80 and abandoned_next_level.get("energy_delta", 0) == -20)
	var lost_attempt: Dictionary = economy.begin_energy_attempt("attempt-lose", "sunny_cove", 2, 1000)
	var lost_settlement: Dictionary = economy.settle_energy_attempt("attempt-lose", "LOSE", 1000)
	var duplicate_loss: Dictionary = economy.settle_energy_attempt("attempt-lose", "LOSE", 1000)
	_check("a genuine LOSE after abandonment charges another 20 exactly once", lost_attempt.get("started", false) and lost_settlement.get("energy_delta", 0) == -20 and duplicate_loss.get("duplicate", false) and economy.energy == 60)
	var low_energy = ECONOMY_SCRIPT.new()
	low_energy.configure(0, {}, [], 0, [], 19, 1000)
	_check("the existing 20-Energy entry eligibility gate remains at zero-charge entry", not low_energy.begin_energy_attempt("low-energy-attempt", "sunny_cove", 1, 1000).get("ok", false) and low_energy.energy == 19)
	low_energy.energy = 20
	low_energy.energy_last_update_unix = 1000
	var clamp_start: Dictionary = low_energy.begin_energy_attempt("clamped-loss", "sunny_cove", 1, 1000)
	low_energy.energy = 5
	var clamped_loss: Dictionary = low_energy.settle_energy_attempt("clamped-loss", "LOSE", 1000)
	_check("LOST attempts clamp the 20-point deduction at zero", clamp_start.get("started", false) and clamped_loss.get("energy_delta", 0) == -5 and low_energy.energy == 0)
	_check("energy regenerates one every 180 seconds and preserves partial interval", economy.refresh_energy(1180).get("energy", -1) == 61 and economy.refresh_energy(1260).get("energy", -1) == 61 and economy.refresh_energy(1360).get("energy", -1) == 62)
	_check("clock rollback does not grant energy or lower the stored high-water mark", economy.refresh_energy(1200).get("energy", -1) == 62 and economy.energy_last_update_unix == 1360)
	var refill: Dictionary = economy.buy_full_energy_refill("refill-1", 1360)
	_check("full refill spends 25 Gems and caps Energy at 100", refill.get("refilled", false) and economy.energy == 100 and economy.gems == 0)
	_check("full Energy prevents an additional refill charge", not economy.buy_full_energy_refill("refill-2", 1360).get("ok", false) and economy.gems == 0)
	var ad_economy = ECONOMY_SCRIPT.new()
	ad_economy.configure(0, {}, [], 0, [], 60, 1000)
	var ad_grant: Dictionary = ad_economy.grant_verified_ad_energy("ad-1", "provider-receipt-1", 1000)
	var ad_duplicate: Dictionary = ad_economy.grant_verified_ad_energy("ad-1", "provider-receipt-1", 1000)
	_check("verified rewarded callback grants +20 once; empty receipt is rejected", ad_grant.get("energy_delta", 0) == 20 and ad_duplicate.get("duplicate", false) and not ad_economy.grant_verified_ad_energy("ad-2", "", 1000).get("ok", false) and ad_economy.energy == 80)
	var capped_ad: Dictionary = ad_economy.grant_verified_ad_energy("ad-3", "provider-receipt-3", 1000)
	_check("rewarded Energy is capped at 100", capped_ad.get("energy_delta", 0) == 20 and ad_economy.energy == 100)
	var save := SAVE_SCRIPT.new()
	var legacy := save.create_default_state()
	legacy["schema_version"] = 2
	legacy["coins"] = 63
	legacy["gems"] = 7
	legacy["boosters"] = {"focus": 3, "upgrade": 2}
	legacy["reward_ledger"] = ["legacy-earned"]
	legacy["transaction_ledger"] = ["legacy-spend"]
	legacy.erase("energy")
	legacy.erase("energy_last_update_unix")
	legacy.erase("energy_regen_remainder_sec")
	legacy.erase("retired_focus_inventory")
	var migrated: Dictionary = save.migrate_state(legacy, 2)
	var migrated_state: Dictionary = migrated.get("state", {})
	_check("schema-two migration preserves balances, ledgers and non-Focus boosters while retiring Focus", migrated.get("ok", false) and migrated_state.get("coins", -1) == 63 and migrated_state.get("gems", -1) == 7 and migrated_state.get("retired_focus_inventory", -1) == 3 and migrated_state.get("boosters", {}).get("upgrade", 0) == 2 and not migrated_state.get("boosters", {}).has("focus") and migrated_state.get("reward_ledger", []).has("legacy-earned") and migrated_state.get("transaction_ledger", []).has("legacy-spend") and migrated_state.get("energy_attempt_ledger", {}) is Dictionary)
	_check("fresh wallet matches owner-approved 100 Energy, 100 Coins and 5 Gems", save.create_default_state().get("energy", -1) == 100 and save.create_default_state().get("coins", -1) == 100 and save.create_default_state().get("gems", -1) == 5)
	var interrupted_economy = ECONOMY_SCRIPT.new()
	var interrupted_state: Dictionary = save.create_default_state()
	_check("interrupted-attempt fixture accepts the current save", interrupted_economy.configure_from_state(interrupted_state).get("ok", false))
	interrupted_economy.begin_energy_attempt("crash-attempt", "sunny_cove", 1, 1000)
	interrupted_state.merge(interrupted_economy.export_state(), true)
	var encoded_interrupted := save.encode_state(interrupted_state)
	var reloaded_interrupted: Dictionary = JSON.parse_string(encoded_interrupted)
	var recovered_economy = ECONOMY_SCRIPT.new()
	var recovery_load: Dictionary = recovered_economy.configure_from_state(reloaded_interrupted)
	var recovery: Dictionary = recovered_economy.settle_interrupted_energy_attempts(1100)
	var duplicate_recovery: Dictionary = recovered_economy.settle_interrupted_energy_attempts(1200)
	_check("an interrupted persisted attempt becomes one QUIT settlement after reload", recovery_load.get("ok", false) and recovery.get("changed", false) and recovery.get("energy", -1) == 80 and not duplicate_recovery.get("changed", true) and recovered_economy.energy_attempt_ledger.get("crash-attempt", {}).get("status", "") == "QUIT")
	var database = DATABASE_SCRIPT.new()
	var database_ok: bool = database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("canonical campaign database validates for production session charges", database_ok)
	if database_ok:
		var state: Dictionary = save.create_default_state()
		state["islands"]["sunny_cove"]["highest_unlocked_level"] = 5
		var progression_economy = ECONOMY_SCRIPT.new()
		progression_economy.configure_from_state(state)
		var campaign = CAMPAIGN_SCRIPT.new()
		_check("campaign accepts current economy state", campaign.configure(database, state, progression_economy))
		var never_ready_bridge = BRIDGE_SCRIPT.new()
		never_ready_bridge.configure(database, campaign, progression_economy)
		var never_ready_configuration: Dictionary = never_ready_bridge.start_session("sunny_cove", 1)
		var never_ready_exit: Dictionary = never_ready_bridge.abandon_active_attempt("scene_failed_before_ready")
		_check("a selected level that never became gameplay-ready exits without a persisted attempt or charge", not never_ready_configuration.is_empty() and never_ready_exit.get("energy_delta", 1) == 0 and progression_economy.energy == 100 and progression_economy.energy_attempt_ledger.is_empty())
		never_ready_bridge.clear_session()
		var bridge = BRIDGE_SCRIPT.new()
		var bridge_configured: bool = bridge.configure(database, campaign, progression_economy)
		var first_configuration: Dictionary = bridge.start_session("sunny_cove", 1)
		_check("selected first Sunny Cove level preserves the 20-Energy gate but does not persist a started attempt early", bridge_configured and not first_configuration.is_empty() and progression_economy.energy == 100 and progression_economy.energy_attempt_ledger.is_empty())
		_check("production gameplay-ready transition records the attempt without an entry deduction", bridge.mark_gameplay_ready() and progression_economy.energy == 100 and progression_economy.energy_attempt_ledger.size() == 1)
		bridge.resolve_lose("probe-loss")
		var loss_callback_replay: Dictionary = bridge.resolve_lose("probe-loss-replay")
		_check("production LOSE deducts once across repeated terminal callbacks", progression_economy.energy == 80 and loss_callback_replay.get("outcome", "") == "LOSE")
		var retry_configuration: Dictionary = bridge.retry_session()
		_check("production Retry selects a new attempt without an entry charge", not retry_configuration.is_empty() and progression_economy.energy == 80)
		_check("retried gameplay-ready attempt is tracked independently", bridge.mark_gameplay_ready() and progression_economy.energy == 80 and progression_economy.energy_attempt_ledger.size() == 2)
		bridge.abandon_active_attempt("probe-abandon")
		_check("abandoning the retry deducts one further 20", progression_economy.energy == 60)
		var one_star: Dictionary = campaign.mark_level_completed("sunny_cove", 5, {"stars": 1, "score": 500})
		var two_star: Dictionary = campaign.mark_level_completed("sunny_cove", 5, {"stars": 2, "score": 600})
		var three_star: Dictionary = campaign.mark_level_completed("sunny_cove", 5, {"stars": 3, "score": 700, "vip_completed": true})
		_check("legacy Sunny Cove IDs resolve globally and star improvements pay 20/30/40 cumulative Coins plus one fifth-level Gem", one_star.get("star_economy_reward", {}).get("coins_delta", 0) == 20 and two_star.get("star_economy_reward", {}).get("coins_delta", 0) == 10 and three_star.get("star_economy_reward", {}).get("coins_delta", 0) == 10 and three_star.get("star_economy_reward", {}).get("gems_delta", 0) == 1 and progression_economy.coins == 140 and progression_economy.gems == 6)
		var replay: Dictionary = campaign.mark_level_completed("sunny_cove", 5, {"stars": 3, "score": 700, "vip_completed": true})
		_check("same-star replay and VIP completion grant no extra currency", replay.get("star_economy_reward", {}).get("granted", true) == false and progression_economy.coins == 140 and progression_economy.gems == 6)
	var ads = ADS_SCRIPT.new()
	var no_consent: Dictionary = ads.request_rewarded("energy_20", "no-consent")
	_check("rewarded Ads fail closed without explicit consent and provider", not no_consent.get("ok", false) and no_consent.get("reason", "") == "CONSENT_REQUIRED")
	var mocked_ads = ADS_SCRIPT.new()
	var accepted_ad_callbacks: Array[String] = []
	mocked_ads.verified_rewarded.connect(func(_placement: String, transaction_id: String, _receipt: String) -> void: accepted_ad_callbacks.append(transaction_id))
	mocked_ads.set_provider_adapter(MockRewardProvider.new(), "GRANTED_NONPERSONALIZED")
	var ad_ready: Dictionary = mocked_ads.request_rewarded("energy_20", "mock-ad-1")
	var ad_show: Dictionary = mocked_ads.show_rewarded()
	var ad_receipt: Dictionary = mocked_ads.accept_provider_reward("mock-ad-1", "mock-receipt-1")
	_check("mocked opt-in rewarded callback grants only after matching displayed transaction", ad_ready.get("state", "") == ADS_SCRIPT.STATE_READY and ad_show.get("ok", false) and ad_receipt.get("verified", false) and accepted_ad_callbacks == ["mock-ad-1"])
	mocked_ads.request_rewarded("energy_20", "mock-ad-2")
	mocked_ads.show_rewarded()
	_check("mocked duplicate receipt and skip/close yield no extra verified reward", not mocked_ads.accept_provider_reward("mock-ad-2", "mock-receipt-1").get("ok", false) and accepted_ad_callbacks.size() == 1)
	mocked_ads.request_rewarded("energy_20", "mock-ad-3")
	mocked_ads.show_rewarded()
	mocked_ads.notify_skipped_or_closed_without_reward()
	_check("skip/close cancels the active ad and cannot later pay", mocked_ads.state == ADS_SCRIPT.STATE_CANCELLED and not mocked_ads.accept_provider_reward("mock-ad-3", "late-receipt").get("ok", false) and accepted_ad_callbacks.size() == 1)
	var store = STORE_SCRIPT.new()
	_check("IAP placeholders have no buyable products or local purchase fulfillment", store.get_catalog().values().all(func(item): return not item.get("buyable", false)) and not store.purchase("remove_ads").get("ok", false) and not store.accept_verified_transaction({"receipt": "client"}).get("ok", false))
	store.configure(MockStoreProvider.new(), MockStoreVerifier.new())
	_check("even a mocked verifier cannot grant an unapproved nonbuyable placeholder", not store.accept_verified_transaction({"product_key": "remove_ads", "transaction_id": "mock-paid"}).get("ok", false) and store.entitlements.is_empty())
	var daily = DAILY_SCRIPT.new()
	_check("Daily Rewards use the locked five rewards while ad claims stay unavailable without a provider", [1, 2, 3, 4, 5].all(func(slot): return daily.rewards.has(slot)) and daily.rewards[3]["reward"].get("quantity", 0) == 40 and daily.rewards[3]["reward"].get("type", "") == "coins" and not daily.claim(3, economy).get("ok", false) and daily.get_slot_state(3, economy).get("reason", "") == "REWARDED_AD_PROVIDER_UNAVAILABLE")
	# AdsService and StoreService are Nodes in production. Release all three
	# standalone probe nodes before SceneTree shutdown to avoid fixture leaks.
	ads.free()
	mocked_ads.free()
	store.free()
	if failures.is_empty():
		print("M34_ECONOMY_RESULT=PASS")
		quit(0)
	else:
		print("M34_ECONOMY_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
