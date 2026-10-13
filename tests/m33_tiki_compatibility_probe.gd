extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const HARNESS_SCRIPT := preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
var PROGRESSION_PATH := "user://m33_tiki_compat_progression_%d.json" % Time.get_ticks_usec()
var PROGRESSION_BACKUP := PROGRESSION_PATH + ".bak"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_TIKI_COMPAT_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M33_TIKI_COMPAT_PROBE FAIL: %s" % label)


func _seed_through_sunny_99() -> Dictionary:
	var completed: Dictionary = {}
	for level_id in range(1, 100):
		completed[str(level_id)] = {"stars": 1, "best_score": 0, "completed": true}
	return {
		"schema_version": 2,
		"unlocked_islands": ["sunny_cove"],
		"islands": {"sunny_cove": {"highest_unlocked_level": 100, "completed_levels": completed, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.SEED)
	_check("all currently authored canonical roots load in staged mode", loaded)
	if not loaded:
		print("M32_DATABASE_ERROR=%s" % database.get_last_error())
		quit(1)
		return
	var tiki_levels: Array[Dictionary] = database.get_levels_for_island("tiki_island")
	_check("Tiki has one hundred actual levels bound to its existing R04 theme", tiki_levels.size() == 100 and database.get_island_theme("tiki_island").get("gameplay_surface", "") == "res://assets/ui_assets/campaign/islands/tiki_island/gameplay_surface.png")
	var unique_signatures: Dictionary = {}
	var level_records_valid := true
	for level in tiki_levels:
		var signature := JSON.stringify({"orders": level.get("orders", []), "vip": level.get("vip", null)})
		unique_signatures[signature] = true
		level_records_valid = level_records_valid and float(level.get("time_limit_sec", -1.0)) == 0.0 and level.get("feature_flags", {}).get("timed", true) == false and database.is_campaign_target_level_eligible("tiki_island", int(level.get("orders", [])[0].get("cocktail_level", 0)))
	_check("slice objectives provide at least 25 distinct patterns, stay within island target policy, and remain untimed", unique_signatures.size() >= 25 and level_records_valid)
	var campaign = CAMPAIGN_SCRIPT.new()
	var economy = ECONOMY_SCRIPT.new()
	_check("prior Sunny Cove completion frontier configures", campaign.configure(database, _seed_through_sunny_99(), economy))
	_check("Tiki remains locked before Sunny Cove L100", not campaign.is_island_unlocked("tiki_island"))
	var sunny_final := campaign.mark_level_completed("sunny_cove", 100, {"stars": 1, "score": 0})
	_check("Sunny Cove L100 completion unlocks only the next island", sunny_final.get("ok", false) and campaign.is_island_complete("sunny_cove") and campaign.is_island_unlocked("tiki_island") and not campaign.is_island_unlocked("azure_bay"))
	var harness = HARNESS_SCRIPT.new(get_root())
	var physical_trial: Dictionary = await harness.run_trial(database, "tiki_island", 1, 32002001, [], HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01)
	_check("Tiki L1 completes through production GameManager, Drink physics, merges, and objective delivery", physical_trial.get("outcome", "") == HARNESS_SCRIPT.OUTCOME_COMPLETED and physical_trial.get("normal_objective_complete", false))
	if physical_trial.get("outcome", "") != HARNESS_SCRIPT.OUTCOME_COMPLETED:
		print("M33_TIKI_PHYSICS_TRIAL=%s" % JSON.stringify(physical_trial))
		quit(1)
		return
	var navigation = NAVIGATION_SCENE.instantiate()
	get_root().add_child(navigation)
	await process_frame
	_check("production campaign navigation accepts the unlocked campaign", navigation.configure_campaign(database, campaign, economy))
	navigation.visible = true
	_check("world map is shown", navigation.show_world_map())
	var world_map = navigation.get_world_map()
	world_map.refresh()
	await process_frame
	await process_frame
	var tiki_selectable: bool = world_map.is_entry_selectable("tiki_island")
	var tiki_selected: bool = world_map.select_island("tiki_island")
	print("M33_TIKI_MAP_STATE unlocked=%s selectable=%s selected=%s view=%s" % [campaign.is_island_unlocked("tiki_island"), tiki_selectable, tiki_selected, navigation.get_current_view()])
	_check("Tiki is unlocked and selectable through the production World Map controller", tiki_selectable and tiki_selected)
	await process_frame
	await process_frame
	var island_map = navigation.get_island_map()
	_check("production navigation opens the Tiki Island Map", navigation.get_current_view() == "ISLAND_MAP" and island_map.get_island_id() == "tiki_island")
	_check("all one hundred Tiki level nodes are present", island_map.get_level_button_count() == 100)
	_check("the first Tiki level is selectable", island_map.select_level(1))
	await process_frame
	var bridge = navigation.get_session_bridge()
	_check("level selection starts the production Tiki gameplay scene", navigation.get_current_view() == "GAMEPLAY" and navigation.get_gameplay_instance_count() == 1 and bridge.get_session_configuration().get("level_id", 0) == 1)
	var shot_sync_ok := true
	for shot_index in int(physical_trial.get("shot_count", 0)):
		shot_sync_ok = shot_sync_ok and bool(bridge.record_committed_shot("m32:tiki:l1:shot:%d" % shot_index).get("ok", false))
	var delivery_index := 0
	for order in tiki_levels[0].get("orders", []):
		for _quantity in int(order.get("quantity", 0)):
			var delivery: Dictionary = bridge.record_to_go_delivery(int(order.get("cocktail_level", 0)), 1, "m32:tiki:l1:delivery:%d" % delivery_index, int(physical_trial.get("score", 0)))
			shot_sync_ok = shot_sync_ok and bool(delivery.get("ok", false))
			delivery_index += 1
	var win_result: Dictionary = bridge.resolve_win(int(physical_trial.get("score", 0))) if shot_sync_ok else {"ok": false, "reason": "PHYSICS_RESULT_SYNC_FAILED"}
	_check("validated physics outcome resolves through production results and progression", win_result.get("outcome", "") == "WIN" and campaign.is_level_completed("tiki_island", 1))
	await process_frame
	await process_frame
	_check("production Results overlay presents the actual completed level", navigation._result_presentation_count > 0 and navigation.get_result_feedback_overlay().get_feedback_kind() == "RESULT_WIN")
	_check("Retry launches the same playable Tiki level", navigation.retry_level())
	await process_frame
	_check("retry returns to Tiki L1 without duplicate completion credit", navigation.get_current_view() == "GAMEPLAY" and bridge.get_session_configuration().get("island_id", "") == "tiki_island" and bridge.get_session_configuration().get("level_id", 0) == 1 and campaign.get_island_progress("tiki_island").get("completed", 0) == 1)
	var save_manager = SAVE_SCRIPT.new()
	var saved_state: Dictionary = save_manager.create_default_state()
	saved_state.merge(campaign.get_progression_state(), true)
	saved_state.merge(economy.export_state(), true)
	saved_state["schema_version"] = save_manager.schema_version()
	var written: Dictionary = save_manager.write_state(saved_state, PROGRESSION_PATH, PROGRESSION_BACKUP)
	var reloaded: Dictionary = SAVE_SCRIPT.new().read_state(PROGRESSION_PATH, PROGRESSION_BACKUP, "user://m33_tiki_legacy_%d.cfg" % Time.get_ticks_usec())
	print("M33_TIKI_SAVE write=%s read_status=%s read_reason=%s saved_schema=%s" % [JSON.stringify(written), str(reloaded.get("status", "")), str(reloaded.get("reason", "")), str(saved_state.get("schema_version", "missing"))])
	_check("save and reload preserve Tiki completion and unlock L2 exactly once", written.get("ok", false) and reloaded.get("status", "") == SAVE_SCRIPT.STATUS_VALID and reloaded.get("state", {}).get("islands", {}).get("tiki_island", {}).get("completed_levels", {}).has("1") and bool(reloaded.get("state", {}).get("islands", {}).get("tiki_island", {}).get("completed_levels", {}).get("1", {}).get("completed", false)))
	var restored = CAMPAIGN_SCRIPT.new()
	_check("reloaded progression still unlocks Tiki L2 but not the next island", restored.configure(database, reloaded.get("state", {}), economy) and restored.is_level_unlocked("tiki_island", 2) and not restored.is_island_unlocked("azure_bay"))
	navigation.queue_free()
	await process_frame
	if failures.is_empty():
		print("M33_TIKI_COMPAT_RESULT=PASS")
		quit(0)
	else:
		print("M33_TIKI_COMPAT_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
