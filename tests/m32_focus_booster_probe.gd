extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAME_MANAGER_SCRIPT := preload("res://scripts/game_manager.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M32_FOCUS_BOOSTER PASS: %s" % label)
	else:
		failures.append(label)
		print("M32_FOCUS_BOOSTER FAIL: %s" % label)


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var loaded: bool = database.load_canonical()
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(0, {"focus": 1})
	var campaign = CAMPAIGN_SCRIPT.new()
	var state := {"schema_version": 2, "unlocked_islands": ["sunny_cove"], "islands": {"sunny_cove": {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}}, "coins": 0, "gems": 0, "boosters": {"focus": 1}, "reward_ledger": [], "transaction_ledger": []}
	_check("staged campaign and initial booster state configure", loaded and campaign.configure(database, state, economy))
	var bridge = BRIDGE_SCRIPT.new()
	_check("Sunny Cove training-level gameplay session starts", bridge.configure(database, campaign, economy) and not bridge.start_session("sunny_cove", 1).is_empty())
	var game = GAME_MANAGER_SCRIPT.new()
	root.add_child(game)
	await process_frame
	_check("production GameManager binds the active campaign session", game.configure_campaign_session(bridge))
	var button := game.get_node_or_null("UI/HUD/FocusBoosterButton") as Button
	_check("Focus booster inventory is displayed in the live gameplay HUD", is_instance_valid(button) and button.text == "FOCUS 1" and not button.disabled)
	if is_instance_valid(button):
		button.pressed.emit()
	_check("using Focus consumes one persisted booster and gives order feedback", economy.get_booster_count("focus") == 0 and button.text == "FOCUS 0" and game._to_go_progress_label.modulate != Color.WHITE)
	_check("Focus leaves the active level objective and move budget unchanged", bridge.get_session_configuration().get("level_id", 0) == 1 and bridge.get_move_budget_state().get("moves_used", -1) == 0 and bridge.get_objective_state().get("normal_remaining", {}).get(5, 0) == 1)
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M32_FOCUS_BOOSTER_RESULT=PASS")
		quit(0)
	else:
		print("M32_FOCUS_BOOSTER_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
