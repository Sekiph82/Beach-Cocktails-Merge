extends SceneTree

const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const GAME_MANAGER_SCRIPT := preload("res://scripts/game_manager.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_FOCUS_REMOVAL PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_FOCUS_REMOVAL FAIL: %s" % label)


func _run() -> void:
	var save := SAVE_SCRIPT.new()
	var legacy := save.create_default_state()
	legacy["schema_version"] = 2
	legacy["boosters"] = {"focus": 4, "upgrade": 2}
	legacy.erase("energy")
	legacy.erase("energy_last_update_unix")
	legacy.erase("energy_regen_remainder_sec")
	legacy.erase("retired_focus_inventory")
	var migration: Dictionary = save.migrate_state(legacy, 2)
	_check("schema-two Focus value is retained without conversion or loss", migration.get("ok", false) and migration.get("state", {}).get("retired_focus_inventory", -1) == 4 and migration.get("state", {}).get("boosters", {}).get("upgrade", 0) == 2 and not migration.get("state", {}).get("boosters", {}).has("focus"))
	var economy = ECONOMY_SCRIPT.new()
	economy.configure_from_state(migration.get("state", {}))
	_check("retired Focus cannot re-enter grant, purchase, or consumption flows", not economy.grant_booster("focus", 1).get("ok", false) and not economy.purchase_booster("legacy-focus", "focus", 1, "coins", 1).get("ok", false) and not economy.consume_booster_once("use-focus", "focus").get("ok", false) and economy.retired_focus_inventory == 4)
	var game = GAME_MANAGER_SCRIPT.new()
	root.add_child(game)
	await process_frame
	_check("production gameplay HUD has no Focus button or label", game.get_node_or_null("UI/HUD/FocusBoosterButton") == null and game.get_node_or_null("UI/HUD/FocusButton") == null)
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M34_FOCUS_REMOVAL_RESULT=PASS")
		quit(0)
	else:
		print("M34_FOCUS_REMOVAL_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
