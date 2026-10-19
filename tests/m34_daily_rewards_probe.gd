extends "res://tests/support/isolated_test_scene_tree.gd"

const BCM_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")


const DAILY_SCRIPT := preload("res://scripts/campaign/daily_reward_service.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ADS_SCRIPT := preload("res://scripts/campaign/ads_service.gd")
const SHELL_SCRIPT := preload("res://scripts/campaign/application_shell.gd")

class TestRewardProvider extends RefCounted:
	func is_test_provider() -> bool:
		return true

	func request_rewarded(_placement: String, _transaction: String) -> Dictionary:
		return {"ok": true}
	func show_rewarded(_transaction: String) -> Dictionary:
		return {"ok": true}

var failures: Array[String] = []


func _init() -> void:
	if not BCM_SANDBOX_GUARD.enforce(self):
		return
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_DAILY PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_DAILY FAIL: %s" % label)


func _new_ads_service():
	var service = ADS_SCRIPT.new()
	root.add_child(service)
	return service


func _utc(year: int, month: int, day: int, hour: int, minute: int, second: int) -> int:
	return int(Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": hour, "minute": minute, "second": second}))


func _write_json(path: String, value: Variant) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value))
	file.close()
	return true


func _run() -> void:
	var daily = DAILY_SCRIPT.new()
	_check("tracked Daily Rewards JSON loads as the runtime source of truth", daily.config_valid and daily.config_error.is_empty())
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(100, {}, [], 5, [], 80, _utc(2026, 10, 14, 23, 0, 0))
	var boundary_before := _utc(2026, 10, 14, 23, 59, 59)
	var boundary_after := _utc(2026, 10, 15, 0, 0, 0)
	var free := daily.claim(1, economy, null, boundary_before)
	_check("slot 1 grants 40 Coins once at 23:59:59 UTC", free.get("ok", false) and economy.coins == 140 and economy.daily_slot_claimed("2026-10-14", 1))
	_check("duplicate free claim is idempotent", daily.claim(1, economy, null, boundary_before).get("duplicate", false) and economy.coins == 140)
	_check("exact UTC midnight opens a new dated claim key", economy.effective_utc_date(boundary_after) == "2026-10-15" and not economy.daily_slot_claimed("2026-10-15", 1))
	var next_day_free := daily.claim(1, economy, null, boundary_after)
	_check("free slot resets at UTC midnight and records a distinct day key", next_day_free.get("ok", false) and economy.coins == 180 and economy.daily_slot_claimed("2026-10-14", 1) and economy.daily_slot_claimed("2026-10-15", 1))
	_check("clock rollback retains UTC high-water and blocks old-day replay", economy.effective_utc_date(boundary_before) == "2026-10-15" and not economy.claim_daily_reward_once("2026-10-14", 2, "old-day", "receipt", boundary_before).get("ok", false))
	_check("local timezone changes cannot alter the UTC date key", economy.effective_utc_date(boundary_after) == "2026-10-15" and economy.effective_utc_date(boundary_after) == "2026-10-15")
	var offline_slot_one: Dictionary = daily.get_slot_state(1, economy, null, boundary_after)
	var full_energy_claim: Dictionary = daily.claim(2, economy, null, boundary_after)
	_check("offline free claim is saved and full Energy cannot consume slot 2", offline_slot_one.get("claimed", false) and full_energy_claim.get("reason", "") == "ENERGY_ALREADY_FULL" and not economy.daily_slot_claimed("2026-10-15", 2))
	economy.energy = 80
	economy.energy_last_update_unix = boundary_after
	var unavailable_ad_claim: Dictionary = daily.claim(2, economy, null, boundary_after)
	_check("ad slot remains unavailable offline without consuming claim", unavailable_ad_claim.get("reason", "") == "REWARDED_AD_PROVIDER_UNAVAILABLE" and not economy.daily_slot_claimed("2026-10-15", 2))
	economy.energy = 100
	var unavailable_ads = _new_ads_service()
	_check("slot 2 is unavailable at full Energy without consuming its date key", daily.get_slot_state(2, economy, unavailable_ads, boundary_after).get("reason", "") == "ENERGY_ALREADY_FULL" and not economy.daily_slot_claimed("2026-10-15", 2))
	economy.energy = 80
	for slot in [2, 3, 4, 5]:
		_check("rewarded slot %d never claims without a provider" % slot, not daily.claim(slot, economy, unavailable_ads, boundary_after).get("ok", false) and not economy.daily_slot_claimed("2026-10-15", slot))
	_check("runtime JSON supplies UTC reset and all five locked values", daily.reset_policy == "UTC_MIDNIGHT" and int(daily.rewards[1]["reward"].get("quantity", -1)) == 40 and str(daily.rewards[1]["reward"].get("type", "")) == "coins" and int(daily.rewards[2]["reward"].get("quantity", -1)) == 20 and str(daily.rewards[2]["reward"].get("type", "")) == "energy" and int(daily.rewards[3]["reward"].get("quantity", -1)) == 40 and str(daily.rewards[3]["reward"].get("type", "")) == "coins" and int(daily.rewards[4]["reward"].get("quantity", -1)) == 2 and str(daily.rewards[4]["reward"].get("type", "")) == "gems" and int(daily.rewards[5]["reward"].get("quantity", -1)) == 80 and str(daily.rewards[5]["reward"].get("type", "")) == "coins")
	_check("Daily Rewards labels are derived from the loaded config", daily.describe_slot(1) == "40 COINS · FREE" and daily.describe_slot(2) == "+20 ENERGY · REWARDED AD" and daily.describe_slot(3) == "40 COINS · REWARDED AD")

	var slot3_economy = ECONOMY_SCRIPT.new()
	slot3_economy.configure(10, {}, [], 0, [], 80, boundary_after)
	var slot3_ads = _new_ads_service()
	slot3_ads.set_provider_adapter(TestRewardProvider.new(), "GRANTED_NONPERSONALIZED")
	var slot3_service = DAILY_SCRIPT.new()
	slot3_ads.verified_rewarded.connect(func(placement: String, transaction: String, receipt: String) -> void: slot3_service.accept_verified_reward(placement, transaction, receipt, slot3_economy, boundary_after))
	var slot3_pending: Dictionary = slot3_service.claim(3, slot3_economy, slot3_ads, boundary_after)
	var slot3_receipt: Dictionary = slot3_ads.accept_provider_reward(str(slot3_pending.get("transaction_id", "")), "slot3-provider-receipt", true)
	_check("verified slot 3 callback grants exactly +40 Coins from config", slot3_pending.get("pending", false) and slot3_receipt.get("verified", false) and slot3_economy.coins == 50 and slot3_economy.daily_slot_claimed("2026-10-15", 3))
	_check("slot 3 duplicate receipt cannot grant twice", not slot3_ads.accept_provider_reward(str(slot3_pending.get("transaction_id", "")), "slot3-provider-receipt", true).get("ok", false) and slot3_economy.coins == 50)
	slot3_ads.free()

	var tamper_root := "user://m34_r02_config_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(tamper_root))
	var config_file := FileAccess.open(DAILY_SCRIPT.CONFIG_PATH, FileAccess.READ)
	var canonical_config: Dictionary = JSON.parse_string(config_file.get_as_text())
	config_file.close()
	var tampered_config: Dictionary = canonical_config.duplicate(true)
	tampered_config["slots"][2]["reward"]["quantity"] = "40"
	var tampered_path := tamper_root + "/tampered.json"
	var tampered_written := _write_json(tampered_path, tampered_config)
	var tampered_service = DAILY_SCRIPT.new()
	var tampered_loaded: bool = tampered_service.load_config(tampered_path)
	_check("invalid tampered reward field is rejected and service fails closed", tampered_written and not tampered_loaded and not tampered_service.config_valid and tampered_service.get_slot_state(3, economy, null, boundary_after).get("reason", "") == "CONFIG_INVALID" and not tampered_service.claim(3, economy, null, boundary_after).get("ok", false))
	var bad_policy: Dictionary = canonical_config.duplicate(true)
	bad_policy["reset_policy"] = "LOCAL_MIDNIGHT"
	var bad_policy_path := tamper_root + "/bad_policy.json"
	var policy_written := _write_json(bad_policy_path, bad_policy)
	_check("invalid reset policy is rejected", policy_written and not tampered_service.load_config(bad_policy_path) and not tampered_service.config_valid)
	_check("missing config file fails closed", not tampered_service.load_config(tamper_root + "/missing.json") and tampered_service.config_error == "CONFIG_MISSING")
	var alternate_config: Dictionary = canonical_config.duplicate(true)
	alternate_config["slots"][2]["reward"]["quantity"] = 41
	var alternate_path := tamper_root + "/alternate_valid.json"
	var alternate_written := _write_json(alternate_path, alternate_config)
	var alternate_service = DAILY_SCRIPT.new()
	var alternate_loaded := alternate_service.load_config(alternate_path)
	var alternate_economy = ECONOMY_SCRIPT.new()
	alternate_economy.configure(0, {}, [], 0, [], 80, boundary_after)
	var alternate_ads = _new_ads_service()
	alternate_ads.set_provider_adapter(TestRewardProvider.new(), "GRANTED_NONPERSONALIZED")
	alternate_ads.verified_rewarded.connect(func(placement: String, transaction: String, receipt: String) -> void: alternate_service.accept_verified_reward(placement, transaction, receipt, alternate_economy, boundary_after))
	var alternate_pending: Dictionary = alternate_service.claim(3, alternate_economy, alternate_ads, boundary_after)
	var alternate_receipt: Dictionary = alternate_ads.accept_provider_reward(str(alternate_pending.get("transaction_id", "")), "alternate-provider-receipt", true)
	_check("settlement consumes loaded config quantity instead of a second hardcoded reward table", alternate_written and alternate_loaded and alternate_receipt.get("verified", false) and alternate_economy.coins == 41)
	alternate_ads.free()

	var cancel_ads = _new_ads_service()
	cancel_ads.set_provider_adapter(TestRewardProvider.new(), "GRANTED_NONPERSONALIZED")
	var cancel_service = DAILY_SCRIPT.new()
	var pending: Dictionary = cancel_service.claim(3, economy, cancel_ads, boundary_after)
	cancel_ads.notify_skipped_or_closed_without_reward()
	cancel_service.cancel_pending()
	_check("ad skip/cancel leaves claim unpaid and removes pending claim", pending.get("pending", false) and cancel_ads.state == ADS_SCRIPT.STATE_CANCELLED and not economy.daily_slot_claimed("2026-10-15", 3))
	_check("late and replay callback without an active claim is rejected", not cancel_service.accept_verified_reward("daily_slot_3", str(pending.get("transaction_id", "")), "late-receipt", economy, boundary_after).get("ok", false) and not economy.daily_slot_claimed("2026-10-15", 3))
	_check("missing provider receipt cannot settle a rewarded claim", not economy.claim_daily_reward_once("2026-10-15", 3, "daily:2026-10-15:3", "", boundary_after).get("ok", false) and not economy.daily_slot_claimed("2026-10-15", 3))
	var no_consent_ads = _new_ads_service()
	_check("ad failure without consent returns unavailable without reward", not no_consent_ads.request_rewarded("daily_slot_2", "failure-probe").get("ok", false) and no_consent_ads.state == ADS_SCRIPT.STATE_FAILED)
	no_consent_ads.free()
	unavailable_ads.free()
	cancel_ads.free()

	var save = SAVE_SCRIPT.new()
	var migration_root := "user://m34_r01_migrations_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(migration_root))
	for version in [1, 2, 3]:
		var old: Dictionary = save.create_default_state()
		old["schema_version"] = version
		old.erase("daily_claim_ledger")
		old.erase("daily_high_water_utc_date")
		if version < 3:
			old.erase("energy")
			old.erase("energy_last_update_unix")
			old.erase("energy_regen_remainder_sec")
			old.erase("retired_focus_inventory")
		var migration: Dictionary = save.migrate_state(old, version)
		_check("schema %d migrates to schema 4 preserving wallet and adding daily ledger" % version, migration.get("ok", false) and migration.get("state", {}).get("schema_version", -1) == 4 and migration.get("state", {}).get("coins", -1) == 100 and migration.get("state", {}).get("daily_claim_ledger", {}) == {})
		var legacy_path := "%s/schema%d.json" % [migration_root, version]
		var legacy_file := FileAccess.open(legacy_path, FileAccess.WRITE)
		legacy_file.store_string(JSON.stringify(old))
		legacy_file.close()
		var loaded_legacy: Dictionary = save.read_state(legacy_path, legacy_path + ".bak", migration_root + "/missing.cfg")
		_check("schema %d on-disk save loads and persists its schema 4 upgrade" % version, loaded_legacy.get("status", "") == save.STATUS_MIGRATED and loaded_legacy.get("state", {}).get("schema_version", -1) == 4 and save.read_state(legacy_path, legacy_path + ".bak", migration_root + "/missing.cfg").get("status", "") == save.STATUS_VALID)
	var invalid_old := save.create_default_state()
	invalid_old["schema_version"] = 0
	_check("unsupported pre-schema saves fail safely", not save.migrate_state(invalid_old, 0).get("ok", false))

	var claimed_economy = ECONOMY_SCRIPT.new()
	claimed_economy.configure(180, {}, ["daily:2026-10-14:1", "daily:2026-10-15:1"], 5, ["daily:2026-10-14:1", "daily:2026-10-15:1"], 80, boundary_before, 0, 0, {"2026-10-14:1": {"transaction_id": "daily:2026-10-14:1", "receipt": ""}, "2026-10-15:1": {"transaction_id": "daily:2026-10-15:1", "receipt": ""}}, "2026-10-15")
	var persisted_state: Dictionary = save.create_default_state()
	persisted_state.merge(claimed_economy.export_state(), true)
	var save_path := "user://m34_r01_daily_probe_%d/campaign_save.json" % Time.get_ticks_usec()
	var write_result: Dictionary = save.write_state(persisted_state, save_path)
	var reopened: Dictionary = save.read_state(save_path, save_path + ".bak", "user://m34_r01_daily_probe_missing.cfg")
	var restored = ECONOMY_SCRIPT.new()
	var restored_result: Dictionary = restored.configure_from_state(reopened.get("state", {}))
	_check("claim ledger and UTC high-water persist through save close/reopen", write_result.get("ok", false) and reopened.get("status", "") == save.STATUS_VALID and restored_result.get("ok", false) and restored.coins == 180 and restored.daily_slot_claimed("2026-10-14", 1) and restored.daily_slot_claimed("2026-10-15", 1) and restored.daily_high_water_utc_date == "2026-10-15")
	_check("new default saves validate and retain schema 4", save.validate_state(save.create_default_state()).get("ok", false) and save.schema_version() == 4)

	var shell = SHELL_SCRIPT.new()
	shell._menu_layer = Control.new()
	shell._settings_layer = Control.new()
	shell._shop_layer = Control.new()
	shell.add_child(shell._menu_layer)
	shell.add_child(shell._settings_layer)
	shell.add_child(shell._shop_layer)
	shell._build_daily_rewards()
	for size in [Vector2(390, 844), Vector2(432, 960)]:
		shell._daily_layer.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		shell._daily_layer.size = size
		shell._resize_daily_rewards()
		var close_button := shell._daily_layer.get_node("CloseDailyRewardsButton") as BaseButton
		var slot_label := shell._daily_layer.get_node("DailySlotLabel5") as Label
		var rect := close_button.get_rect()
		_check("claims UI fits %dx%d viewport with visible final slot and back control" % [int(size.x), int(size.y)], rect.position.x >= 0.0 and rect.position.y >= 0.0 and rect.end.x <= size.x + 0.5 and rect.end.y <= size.y + 0.5 and slot_label.size.x > 0.0)
	_check("Daily Rewards panel opens, closes, and reopens", shell.show_daily_rewards() and shell.get_current_view() == "DAILY_REWARDS" and shell.close_daily_rewards() and shell.show_daily_rewards())
	shell.free()
	if failures.is_empty():
		print("M34_DAILY_RESULT=PASS")
		quit(0)
	else:
		print("M34_DAILY_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
