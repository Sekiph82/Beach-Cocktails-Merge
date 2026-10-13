extends SceneTree

const APPLICATION_SHELL_SCRIPT := preload("res://scripts/campaign/application_shell.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_SHOP PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_SHOP FAIL: %s" % label)


func _run() -> void:
	var shell = APPLICATION_SHELL_SCRIPT.new()
	root.add_child(shell)
	await process_frame
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	var economy = shell.campaign_navigation.economy
	economy.configure(100, {}, [], 25, [], 60, int(Time.get_unix_time_from_system()))
	shell._refresh_home_values()
	_check("Home Energy, Coins and Gems read persisted economy values", shell._home_value_labels.get("energy").text == "60" and shell._home_value_labels.get("coins").text == "100" and shell._home_value_labels.get("gems").text == "25")
	var shop_button = shell.get_node_or_null("MainMenu/HomeShop") as BaseButton
	if shop_button != null:
		shop_button.pressed.emit()
	_check("Home Shop opens and contains only energy recovery", shop_button != null and shell.get_current_view() == "SHOP" and shell.get_node_or_null("FreeShop/ShopBuyCoins") == null and shell.get_node_or_null("FreeShop/ShopBuyGems") == null and shell.get_node_or_null("FreeShop/ShopEnergyRefill") != null)
	_check("Shop contains no Focus labels or actions", not str(shell._shop_status.text).to_upper().contains("FOCUS") and shell.get_node_or_null("FreeShop/ShopBuyFocus") == null)
	var refill: Dictionary = shell.purchase_energy_refill()
	_check("approved 25-Gem refill reaches cap and saves zero remaining Gems", refill.get("refilled", false) and economy.energy == 100 and economy.gems == 0)
	var rewarded_button := shell.get_node_or_null("FreeShop/ShopEnergyRewardedAd") as BaseButton
	_check("rewarded ad stays unavailable without a verified provider", is_instance_valid(rewarded_button) and rewarded_button.disabled and not shell.request_energy_rewarded_ad().get("ok", false))
	shell.queue_free()
	await process_frame
	if failures.is_empty():
		print("M34_SHOP_RESULT=PASS")
		quit(0)
	else:
		print("M34_SHOP_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
