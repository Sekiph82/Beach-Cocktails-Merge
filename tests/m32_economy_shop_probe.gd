extends SceneTree

const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const APPLICATION_SHELL_SCRIPT := preload("res://scripts/campaign/application_shell.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M32_ECONOMY_SHOP PASS: %s" % label)
	else:
		failures.append(label)
		print("M32_ECONOMY_SHOP FAIL: %s" % label)


func _run() -> void:
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(100, {"focus": 1}, [], 2, [])
	var purchase: Dictionary = economy.purchase_booster("shop:test:coin", "focus", 1, "coins", 40)
	_check("coin purchase atomically spends and adds booster", purchase.get("purchased", false) and economy.coins == 60 and economy.get_booster_count("focus") == 2)
	var duplicate: Dictionary = economy.purchase_booster("shop:test:coin", "focus", 1, "coins", 40)
	_check("purchase replay is idempotent", duplicate.get("duplicate", false) and economy.coins == 60 and economy.get_booster_count("focus") == 2)
	var no_funds: Dictionary = economy.purchase_booster("shop:test:large", "focus", 5, "gems", 3)
	_check("insufficient gem funds leave state untouched", not no_funds.get("ok", false) and economy.gems == 2 and economy.get_booster_count("focus") == 2)
	var gem_purchase: Dictionary = economy.purchase_booster("shop:test:gem", "focus", 1, "gems", 1)
	_check("gem purchase is functional", gem_purchase.get("purchased", false) and economy.gems == 1 and economy.get_booster_count("focus") == 3)
	var use_once: Dictionary = economy.consume_booster_once("focus-use:test", "focus")
	var use_duplicate: Dictionary = economy.consume_booster_once("focus-use:test", "focus")
	_check("booster consumption is idempotent", use_once.get("consumed", false) and use_duplicate.get("duplicate", false) and economy.get_booster_count("focus") == 2)
	var reward: Dictionary = economy.grant_reward("tiki:first-clear:1", {"coins": 10, "gems": 1})
	var replay_reward: Dictionary = economy.grant_reward("tiki:first-clear:1", {"coins": 10, "gems": 1})
	_check("first-clear currency grant is replay safe", reward.get("granted", false) and replay_reward.get("duplicate", false) and economy.coins == 70 and economy.gems == 2)
	var save := SAVE_SCRIPT.new()
	var state := save.create_default_state()
	state.merge(economy.export_state(), true)
	_check("balances, inventory, and transaction receipts validate", save.validate_state(state).get("ok", false))
	var old_schema_two := state.duplicate(true)
	old_schema_two.erase("gems")
	old_schema_two.erase("transaction_ledger")
	_check("older schema two state preserves earned currency and inventory", save.validate_state(old_schema_two).get("ok", false) and old_schema_two["coins"] == state["coins"] and old_schema_two["boosters"] == state["boosters"])

	var shell = APPLICATION_SHELL_SCRIPT.new()
	root.add_child(shell)
	await process_frame
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	var shell_economy = shell.campaign_navigation.economy
	shell_economy.configure(100, {}, [], 2, [])
	shell._refresh_home_values()
	_check("Home Gems label uses the economy balance", shell._home_value_labels.get("gems").text == "2")
	var shop_button = shell.get_node_or_null("MainMenu/HomeShop") as BaseButton
	if shop_button != null:
		shop_button.pressed.emit()
	_check("Home Shop opens the live free Shop", shop_button != null and shell.get_current_view() == "SHOP")
	var coin_button = shell.get_node_or_null("FreeShop/ShopBuyCoins") as BaseButton
	if coin_button != null:
		coin_button.pressed.emit()
	_check("Shop touch purchase updates balance and inventory", coin_button != null and shell_economy.coins == 60 and shell_economy.get_booster_count("focus") == 1)
	var persisted: Dictionary = SAVE_SCRIPT.new().read_state().get("state", {})
	_check("Shop receipts and earned assets persist", persisted.get("coins", -1) == 60 and persisted.get("boosters", {}).get("focus", 0) == 1 and not persisted.get("transaction_ledger", []).is_empty())
	shell.queue_free()
	await process_frame
	if failures.is_empty():
		print("M32_ECONOMY_SHOP_RESULT=PASS")
		quit(0)
	else:
		print("M32_ECONOMY_SHOP_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
