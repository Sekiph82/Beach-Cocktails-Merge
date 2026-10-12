extends SceneTree

const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const TUTORIAL_SCRIPT := preload("res://scripts/campaign/gameplay_tutorial.gd")
const APPLICATION_SHELL_SCRIPT := preload("res://scripts/campaign/application_shell.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M32_ECONOMY_TUTORIAL PASS: %s" % label)
	else:
		failures.append(label)
		print("M32_ECONOMY_TUTORIAL FAIL: %s" % label)


func _run() -> void:
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(100, {"focus": 1}, [], 2, [])
	var purchase: Dictionary = economy.purchase_booster("shop:test:coin", "focus", 1, "coins", 40)
	_check("coin purchase atomically spends and adds booster", purchase.get("purchased", false) and economy.coins == 60 and economy.get_booster_count("focus") == 2)
	var duplicate: Dictionary = economy.purchase_booster("shop:test:coin", "focus", 1, "coins", 40)
	_check("purchase replay is idempotent", duplicate.get("duplicate", false) and economy.coins == 60 and economy.get_booster_count("focus") == 2)
	var no_funds: Dictionary = economy.purchase_booster("shop:test:large", "focus", 5, "gems", 3)
	_check("insufficient gem funds leave all balances and inventory untouched", not no_funds.get("ok", false) and economy.gems == 2 and economy.get_booster_count("focus") == 2)
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
	state["coins"] = economy.coins
	state["gems"] = economy.gems
	state["boosters"] = economy.get_booster_inventory()
	state.merge(economy.export_state(), true)
	_check("currency inventory and transaction receipts pass save validation", save.validate_state(state).get("ok", false))
	var legacy := state.duplicate(true)
	legacy.erase("gems")
	legacy.erase("transaction_ledger")
	_check("existing schema two saves without gems migrate with earned assets unchanged", save.validate_state(legacy).get("ok", false) and legacy["coins"] == state["coins"] and legacy["boosters"] == state["boosters"])
	var tutorial = TUTORIAL_SCRIPT.new()
	tutorial.storage_path = "user://m32_economy_tutorial_probe.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tutorial.storage_path))
	root.add_child(tutorial)
	_check("tutorial opens at launch instruction", tutorial.start() and tutorial.visible and tutorial.current_step == 0)
	tutorial.on_shot_launched()
	tutorial.on_merge()
	tutorial.on_delivery()
	_check("real event hooks advance launch, merge, and delivery", tutorial.current_step == 3)
	tutorial.set_presentation_state({"reduced_motion": true, "high_contrast": true})
	tutorial._advance_button.pressed.emit()
	tutorial._advance_button.pressed.emit()
	_check("VIP and move/star explanations require explicit touch continuation", tutorial.current_step == 5)
	tutorial.on_retry()
	_check("retry completes tutorial and persists one-time completion", tutorial.completed and not tutorial.visible)
	var restored_tutorial = TUTORIAL_SCRIPT.new()
	restored_tutorial.storage_path = tutorial.storage_path
	root.add_child(restored_tutorial)
	_check("completed tutorial remains completed across reconstruction", restored_tutorial.completed and not restored_tutorial.start())
	var shell = APPLICATION_SHELL_SCRIPT.new()
	root.add_child(shell)
	await process_frame
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	var shell_economy = shell.campaign_navigation.economy
	shell_economy.configure(100, {}, [], 2, [])
	shell._refresh_home_values()
	_check("Home Gems display reads the saved economy balance", shell._home_value_labels.get("gems").text == "2")
	var shop_button = shell.get_node_or_null("MainMenu/HomeShop") as BaseButton
	if shop_button != null:
		shop_button.pressed.emit()
	_check("Home Shop art opens the live free Shop", shop_button != null and shell.get_current_view() == "SHOP")
	var coin_purchase_button = shell.get_node_or_null("FreeShop/ShopBuyCoins") as BaseButton
	if coin_purchase_button != null:
		coin_purchase_button.pressed.emit()
	_check("Shop touch purchase updates currency and booster inventory", coin_purchase_button != null and shell_economy.coins == 60 and shell_economy.get_booster_count("focus") == 1)
	var saved_economy: Dictionary = SAVE_SCRIPT.new().read_state().get("state", {})
	_check("Shop transaction and balances persist after purchase", saved_economy.get("coins", -1) == 60 and saved_economy.get("boosters", {}).get("focus", 0) == 1 and not saved_economy.get("transaction_ledger", []).is_empty())
	shell.close_shop()
	var settings_button = shell.get_node_or_null("MainMenu/HomeSettings") as BaseButton
	if settings_button != null:
		settings_button.pressed.emit()
	var replay_button = shell.get_node_or_null("Settings/ReplayGameplayTutorialButton") as BaseButton
	if replay_button != null:
		replay_button.pressed.emit()
	await process_frame
	var active_gameplay = shell.campaign_navigation.get_node_or_null("CampaignGameplay")
	_check("Settings replay starts the touch tutorial inside real campaign gameplay", replay_button != null and is_instance_valid(active_gameplay) and active_gameplay.gameplay_tutorial.visible)
	if is_instance_valid(active_gameplay) and is_instance_valid(active_gameplay.gameplay_tutorial):
		var held_drink = active_gameplay.shot_controller._current_drink
		var touch_down := InputEventScreenTouch.new()
		touch_down.index = 0
		touch_down.pressed = true
		touch_down.position = held_drink.global_position
		active_gameplay.shot_controller._unhandled_input(touch_down)
		var touch_up := InputEventScreenTouch.new()
		touch_up.index = 0
		touch_up.pressed = false
		touch_up.position = held_drink.global_position + Vector2(8.0, 0.0)
		active_gameplay.shot_controller._unhandled_input(touch_up)
		_check("a production touch launch advances the guided lesson", active_gameplay.gameplay_tutorial.current_step == 1)
		var lesson_merge = active_gameplay.spawn_drink(3, Vector2(360.0, 650.0), false)
		active_gameplay.on_merged(3, lesson_merge)
		_check("production merge handling advances the guided lesson", active_gameplay.gameplay_tutorial.current_step == 2)
		var gameplay_bridge = shell.campaign_navigation.get_session_bridge()
		var remaining_orders: Dictionary = gameplay_bridge.get_objective_state().get("normal_remaining", {})
		var delivery_serial := 0
		for order_level in remaining_orders:
			var quantity := int(remaining_orders[order_level])
			if quantity > 0:
				gameplay_bridge.record_to_go_delivery(int(order_level), quantity, "m32:tutorial:delivery:%d" % delivery_serial, 0)
				delivery_serial += 1
		await process_frame
		await process_frame
		_check("normal To-Go completion advances to the optional-VIP explanation", active_gameplay.gameplay_tutorial.current_step == 3)
		active_gameplay.gameplay_tutorial._advance_button.pressed.emit()
		active_gameplay.gameplay_tutorial._advance_button.pressed.emit()
		_check("the tutorial covers move/star rules and directs to retry", active_gameplay.gameplay_tutorial.current_step == 5)
		var result_overlay = shell.campaign_navigation.get_result_feedback_overlay()
		_check("the actual Results surface offers Retry for the tutorial", result_overlay.get_visible_actions().has("RETRY"))
		result_overlay.trigger_action("RETRY")
		_check("the real Retry action completes and saves the one-time tutorial", active_gameplay.gameplay_tutorial.completed)
	shell.queue_free()
	await process_frame
	if failures.is_empty():
		print("M32_ECONOMY_TUTORIAL_RESULT=PASS")
		quit(0)
	else:
		print("M32_ECONOMY_TUTORIAL_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
