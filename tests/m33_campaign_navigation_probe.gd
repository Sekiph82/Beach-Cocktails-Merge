extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const NAVIGATION_SCRIPT := preload("res://scripts/campaign/campaign_navigation_controller.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ISLAND_IDS := [
	"sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
	"party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
const REPRESENTATIVE_LEVELS := [1, 50, 100]

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_NAV PASS: %s" % label)
	else:
		failures.append(label)
		print("M33_NAV FAIL: %s" % label)


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var database_ok := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("strict full data is available to production navigation", database_ok)
	if not database_ok:
		print("M33_NAV_DATABASE_ERROR=%s" % database.get_last_error())
		quit(1)
		return
	var campaign = CAMPAIGN_SCRIPT.new()
	var seed_state: Dictionary = SAVE_SCRIPT.new().create_default_state()
	_check("campaign manager accepts schema-two state", campaign.configure(database, seed_state))
	if campaign.level_database == null:
		quit(1)
		return
	var all_levels_completed := true
	for island_index in ISLAND_IDS.size():
		var island_id: String = ISLAND_IDS[island_index]
		if not campaign.is_island_unlocked(island_id) or not campaign.select_island(island_id):
			print("M33_UNLOCK_GAP island=%s unlocked=%s" % [island_id, campaign.is_island_unlocked(island_id)])
			all_levels_completed = false
			break
		for level_id in range(1, 101):
			if not campaign.is_level_unlocked(island_id, level_id):
				print("M33_UNLOCK_GAP island=%s level=%d unlocked=%s frontier=%d" % [island_id, level_id, campaign.is_island_unlocked(island_id), campaign.get_frontier_level_id(island_id)])
				all_levels_completed = false
				break
			var result: Dictionary = campaign.mark_level_completed(island_id, level_id, {"stars": 1, "score": 100})
			if not bool(result.get("ok", false)):
				print("M33_COMPLETION_GAP island=%s level=%d result=%s" % [island_id, level_id, JSON.stringify(result)])
			all_levels_completed = all_levels_completed and bool(result.get("ok", false))
		if island_index + 1 < ISLAND_IDS.size():
			all_levels_completed = all_levels_completed and campaign.is_island_unlocked(ISLAND_IDS[island_index + 1])
	_check("all ordered islands unlock only after the prior 100-level completion", all_levels_completed and campaign.is_island_unlocked("final_island"))
	_check("final island completion reaches local 100 / global 1000", campaign.is_island_complete("final_island") and int(database.get_level("final_island", 100).get("global_level_id", 0)) == 1000)
	var navigation = NAVIGATION_SCRIPT.new()
	navigation.name = "M33ProductionNavigation"
	get_root().add_child(navigation)
	_check("production campaign navigator accepts validated campaign state", navigation.configure_campaign(database, campaign))
	await process_frame
	await process_frame
	var world_map = navigation.get_world_map()
	var island_map = navigation.get_island_map()
	var routes_ok := world_map != null and island_map != null
	for island_index in ISLAND_IDS.size():
		var island_id: String = ISLAND_IDS[island_index]
		if not routes_ok:
			break
		if not world_map.is_entry_selectable(island_id) or not world_map.select_island(island_id):
			routes_ok = false
			break
		await process_frame
		await process_frame
		routes_ok = routes_ok and navigation.get_current_view() == NAVIGATION_SCRIPT.VIEW_ISLAND_MAP and navigation.get_active_island_id() == island_id
		routes_ok = routes_ok and island_map.get_level_button_count() == 100
		for level_id in REPRESENTATIVE_LEVELS:
			var level_button = island_map.get_level_button(level_id)
			if not is_instance_valid(level_button) or not level_button.is_selectable() or database.get_level(island_id, level_id).is_empty():
				routes_ok = false
				break
		if not routes_ok:
			break
		_check("production World Map to Island Map exposes first/mid/final levels %s" % island_id, routes_ok)
	_check("all ten production islands expose playable representative levels", routes_ok)
	var state: Dictionary = campaign.get_progression_state()
	state["m33_forward_compatibility_marker"] = "unknown-field-preserved"
	var save = SAVE_SCRIPT.new()
	var save_path := "user://m33_campaign_navigation_probe.json"
	var backup_path := save_path + ".bak"
	var write_result: Dictionary = save.write_state(state, save_path, backup_path)
	var read_result: Dictionary = save.read_state(save_path, backup_path, "user://m33_legacy_probe.cfg")
	_check("schema-two save roundtrip preserves campaign and unknown optional M33 field", bool(write_result.get("ok", false)) and read_result.get("status", "") == SAVE_SCRIPT.STATUS_VALID and read_result.get("state", {}).get("m33_forward_compatibility_marker", "") == "unknown-field-preserved" and read_result.get("state", {}).get("islands", {}).get("final_island", {}).get("completed_levels", {}).has("100"))
	navigation.queue_free()
	await process_frame
	if failures.is_empty():
		print("M33_NAV_RESULT=PASS")
		quit(0)
	else:
		print("M33_NAV_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
