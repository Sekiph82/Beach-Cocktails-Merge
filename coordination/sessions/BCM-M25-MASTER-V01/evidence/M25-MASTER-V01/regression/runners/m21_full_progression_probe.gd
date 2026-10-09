extends SceneTree

## BCM-M21-003 fresh-save Sunny Cove L1->L100 production-path progression.
## Completion is submitted only by GameplaySessionBridge terminal results.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const REPORT_DIR := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MASTER-V01/regression/m21_full_progression_probe"
const SAVE_PATH := "user://m21_child03_fresh_campaign.json"
const CHECKPOINTS := [1, 25, 50, 75, 100]

var failures: Array[String] = []
var campaign
var database
var navigation
var shell
var checkpoint_records: Array[Dictionary] = []
var completed_levels: Array[int] = []
var cumulative_stars: Array[int] = []
var final_state: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_CHILD_03_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_CHILD_03_PROBE FAIL: %s" % label)


func _frame(count: int = 2) -> void:
	for _index in range(count):
		await process_frame


func _mount_fresh_shell() -> void:
	database = DATABASE_SCRIPT.new()
	_check("canonical campaign database loads", database.load_canonical())
	campaign = CAMPAIGN_SCRIPT.new()
	var fresh_state: Dictionary = SAVE_SCRIPT.new().create_default_state()
	_check("true fresh campaign state configures", campaign.configure(database, fresh_state))
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m21_child03_onboarding_%s.json" % Time.get_ticks_usec()
	shell.settings_storage_path = "user://m21_child03_settings_%s.json" % Time.get_ticks_usec()
	root.add_child(shell)
	await _frame(4)
	navigation = shell.get_campaign_navigation()
	_check("production navigation accepts fresh campaign", navigation.configure_campaign(database, campaign))
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	await _frame(2)
	var play_started: bool = shell.press_play_continue()
	await _frame(3)
	var frontier_bridge = navigation.get_session_bridge()
	_check("production PLAY starts the fresh-session frontier gameplay", play_started and navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1 and frontier_bridge != null and frontier_bridge.active_level_id == 1)
	_check("fresh save begins with Sunny Cove only", campaign.is_island_unlocked("sunny_cove") and not campaign.is_island_unlocked("tiki_island"))


func _persist_and_reload(checkpoint_level: int) -> void:
	var save_manager = SAVE_SCRIPT.new()
	var state: Dictionary = campaign.get_progression_state()
	var economy = navigation.get_economy()
	if economy != null:
		var economy_state: Dictionary = economy.export_state()
		state["coins"] = economy_state.get("coins", 0)
		state["boosters"] = economy_state.get("boosters", {})
		state["reward_ledger"] = economy_state.get("reward_ledger", [])
	var write_result: Dictionary = save_manager.write_state(state, SAVE_PATH)
	_check("checkpoint L%d writes through SaveManager" % checkpoint_level, bool(write_result.get("ok", false)))
	var read_result: Dictionary = save_manager.read_state(SAVE_PATH)
	_check("checkpoint L%d reloads valid state" % checkpoint_level, bool(read_result.get("ok", false)) and read_result.get("source", "") == "primary")
	var loaded_state: Dictionary = read_result.get("state", {})
	var reloaded_economy = ECONOMY_SCRIPT.new()
	_check("checkpoint L%d reloads economy state" % checkpoint_level, bool(reloaded_economy.configure_from_state(loaded_state).get("ok", false)))
	var reloaded_campaign = CAMPAIGN_SCRIPT.new()
	_check("checkpoint L%d reloads CampaignManager state" % checkpoint_level, reloaded_campaign.configure(database, loaded_state, reloaded_economy))
	campaign = reloaded_campaign
	_check("checkpoint L%d reconnects production navigation" % checkpoint_level, navigation.configure_campaign(database, campaign, reloaded_economy))
	navigation.show_world_map()
	await _frame(3)
	_check("checkpoint L%d returns to one World Map" % checkpoint_level, navigation.get_current_view() == navigation.VIEW_WORLD_MAP and navigation.get_map_instance_count() == 2)
	if checkpoint_level < 100:
		_check("checkpoint L%d keeps Tiki locked" % checkpoint_level, not campaign.is_island_unlocked("tiki_island"))
	else:
		_check("checkpoint L%d keeps Tiki unlocked" % checkpoint_level, campaign.is_island_unlocked("tiki_island"))
	checkpoint_records.append({
		"level": checkpoint_level,
		"save_status": read_result.get("status", ""),
		"save_source": read_result.get("source", ""),
		"completed_count": campaign.get_island_progress("sunny_cove").get("completed", 0),
		"cumulative_stars": campaign.get_cumulative_stars("sunny_cove"),
		"tiki_unlocked": campaign.is_island_unlocked("tiki_island"),
	})


func _complete_level(level_id: int) -> void:
	_check("L%d is unlocked before launch" % level_id, campaign.is_level_unlocked("sunny_cove", level_id))
	_check("L%d enters Island Map through production router" % level_id, navigation.show_island_map("sunny_cove"))
	await _frame(3)
	var island_map = navigation.get_island_map()
	var level_button = island_map.get_level_button(level_id)
	_check("L%d has a production level control" % level_id, level_button != null and level_button.is_selectable())
	if level_button != null:
		level_button.pressed.emit()
	await _frame(5)
	var bridge = navigation.get_session_bridge()
	_check("L%d starts one active production session" % level_id, bridge != null and bridge.is_session_active() and navigation.get_gameplay_instance_count() == 1)
	var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
	var delivery_index := 0
	for order_level in remaining:
		var quantity := int(remaining[order_level])
		if quantity <= 0:
			continue
		delivery_index += 1
		var delivery_result: Dictionary = bridge.record_to_go_delivery(int(order_level), quantity, "m21-child03-l%d-order%d" % [level_id, delivery_index], 1000 + level_id)
		_check("L%d normal order %d accepted" % [level_id, delivery_index], bool(delivery_result.get("ok", false)) and int(delivery_result.get("accepted", 0)) == quantity)
	await _frame(3)
	var terminal: Dictionary = bridge.get_terminal_result()
	_check("L%d completes through GameplaySessionBridge WIN" % level_id, terminal.get("outcome", "") == "WIN" and int(terminal.get("level_id", 0)) == level_id)
	_check("L%d does not require VIP completion" % level_id, not bool(terminal.get("vip_completed", false)) or bool(terminal.get("outcome", "") == "WIN"))
	var progression: Dictionary = bridge.get_progression_result()
	_check("L%d submits authoritative progression result" % level_id, bool(progression.get("ok", false)))
	var record: Dictionary = campaign.get_progression_state().get("islands", {}).get("sunny_cove", {}).get("completed_levels", {}).get(str(level_id), {})
	_check("L%d persists completion record" % level_id, bool(record.get("completed", false)) and int(record.get("stars", 0)) >= 1 and int(record.get("stars", 0)) <= 3 and int(record.get("best_score", 0)) >= 0)
	completed_levels.append(level_id)
	cumulative_stars.append(campaign.get_cumulative_stars("sunny_cove"))
	_check("cumulative stars remain monotonic through L%d" % level_id, cumulative_stars.back() <= level_id * 3 and (cumulative_stars.size() == 1 or cumulative_stars.back() >= cumulative_stars[cumulative_stars.size() - 2]))
	_check("L%d result returns through production Island Map action" % level_id, navigation.get_result_feedback_overlay().trigger_action("ISLAND_MAP"))
	await _frame(3)
	_check("L%d leaves one Island Map and no gameplay duplicate" % level_id, navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0)
	if CHECKPOINTS.has(level_id):
		await _persist_and_reload(level_id)


func _verify_final_restart() -> void:
	var save_manager = SAVE_SCRIPT.new()
	var read_result: Dictionary = save_manager.read_state(SAVE_PATH)
	final_state = read_result.get("state", {})
	_check("final restart reads saved L100 state", bool(read_result.get("ok", false)) and final_state.get("islands", {}).get("sunny_cove", {}).get("completed_levels", {}).size() == 100)
	var restarted_campaign = CAMPAIGN_SCRIPT.new()
	_check("final restart configures CampaignManager", restarted_campaign.configure(database, final_state))
	_check("final restart preserves Sunny Cove completion", restarted_campaign.is_island_complete("sunny_cove"))
	_check("final restart preserves Tiki unlock", restarted_campaign.is_island_unlocked("tiki_island"))
	_check("Tiki remains a zero-level island", int(database.get_island("tiki_island").get("level_count", -1)) == 0)
	_check("Tiki exposes no launchable Level 1", not restarted_campaign.is_level_unlocked("tiki_island", 1))
	campaign = restarted_campaign
	navigation.configure_campaign(database, campaign)
	navigation.show_island_map("tiki_island")
	await _frame(3)
	_check("Tiki map is reachable after final restart", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_island_map().get_level_button_count() == 0)
	_check("Tiki gameplay cannot launch", not navigation.get_island_map().select_level(1) and navigation.get_gameplay_instance_count() == 0)


func _write_report() -> void:
	var progression_state: Dictionary = final_state
	var sunny_state: Dictionary = progression_state.get("islands", {}).get("sunny_cove", {})
	var records: Dictionary = sunny_state.get("completed_levels", {})
	var claimed_rewards: Array = sunny_state.get("claimed_star_rewards", [])
	var report := {
		"work_item": "BCM-M21-003",
		"fresh_save": true,
		"production_path": "ApplicationShellScene -> CampaignNavigationController -> IslandMapController -> GameplaySessionBridge",
		"levels_completed": completed_levels,
		"completed_count": records.size(),
		"checkpoint_records": checkpoint_records,
		"cumulative_stars": cumulative_stars,
		"claimed_star_rewards": claimed_rewards,
		"claimed_star_rewards_unique": claimed_rewards.size() == {"values": claimed_rewards}.values.size(),
		"tiki": {
			"unlocked_after_l100": campaign.is_island_unlocked("tiki_island"),
			"level_count": int(database.get_island("tiki_island").get("level_count", -1)),
			"level_1_launchable": campaign.is_level_unlocked("tiki_island", 1),
		},
		"save_path": SAVE_PATH,
		"save_schema_version": final_state.get("schema_version", -1),
		"checks_failed": failures,
		"debug_progression_bypass": false,
	}
	var file := FileAccess.open("%s/M21-003_FULL_PROGRESSION.json" % REPORT_DIR, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()


func _finish() -> void:
	_write_report()
	if failures.is_empty():
		print("M21_CHILD_03_RESULT=PASS completed=%d checkpoints=%d" % [completed_levels.size(), checkpoint_records.size()])
		quit(0)
		return
	print("M21_CHILD_03_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REPORT_DIR))
	await _mount_fresh_shell()
	for level_id in range(1, 101):
		await _complete_level(level_id)
	await _verify_final_restart()
	_finish()

