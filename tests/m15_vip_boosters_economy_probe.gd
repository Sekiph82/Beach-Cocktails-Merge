extends SceneTree

## Focused M15 probe. It exercises the production economy/session/navigation
## seams with deterministic in-memory campaign data and writes only probe
## screenshots under user://m15_screenshots/.

const ISLAND_ID := "m15_fixture"
const TEST_ROOT := "user://m15_economy_probe"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M15_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M15_PROBE FAIL: %s" % label)


func _islands() -> Dictionary:
	return {
		"schema_version": 1,
		"islands": [{
			"id": ISLAND_ID,
			"display_name": "M15 Fixture Island",
			"order_index": 1,
			"level_count": 2,
			"unlock_rule": {"type": "default_open"},
			"next_island_id": "",
			"map_background": "",
			"map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
			"map_position": [0.5, 0.5],
			"reward_track": {
				"milestones": [1, 2],
				"rewards": {
					"1": {"type": "coins", "quantity": 25},
					"2": {"type": "booster", "id": "time", "quantity": 1},
				},
			},
		}],
	}


func _level(level_id: int, vip: Variant, level_reward: Dictionary) -> Dictionary:
	return {
		"island_id": ISLAND_ID,
		"level_id": level_id,
		"time_limit_sec": 20,
		"orders": [{"cocktail_level": 6, "quantity": 1}],
		"vip": vip,
		"rewards": level_reward,
		"score_star_thresholds": {"one_star": 0, "two_stars": 100, "three_stars": 200},
		"feature_flags": {"timed": true, "vip": vip != null, "boosters": true},
	}


func _levels() -> Dictionary:
	return {
		"schema_version": 1,
		"island_id": ISLAND_ID,
		"levels": [
			_level(1, {"enabled": true, "cocktail_level": 12, "quantity": 1, "reward": {"type": "booster", "id": "upgrade", "quantity": 1}}, {"type": "coins", "quantity": 10}),
			_level(2, null, {"type": "coins", "quantity": 5}),
		],
	}


func _state() -> Dictionary:
	return {
		"schema_version": 2,
		"unlocked_islands": [ISLAND_ID],
		"islands": {ISLAND_ID: {"highest_unlocked_level": 2, "completed_levels": {}, "claimed_milestones": []}},
		"legacy_best_score": 0,
		"boosters": {"time": 2},
		"coins": 0,
		"reward_ledger": [],
	}


func _database():
	var database = DATABASE_SCRIPT.new()
	_check("M15 fixture loads in FULL validation", database.load_from_data(_islands(), _levels(), DATABASE_SCRIPT.ValidationMode.FULL))
	return database


func _campaign(database, economy):
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("CampaignManager configures with shared economy", campaign.configure(database, _state(), economy))
	return campaign


func _bridge(database, campaign, economy):
	var bridge = BRIDGE_SCRIPT.new()
	_check("GameplaySessionBridge configures with shared economy", bridge.configure(database, campaign, economy))
	return bridge


func _path(name: String) -> String:
	return "%s/%s" % [TEST_ROOT, name]


func _clean(path: String) -> void:
	for suffix in ["", ".bak", ".tmp"]:
		var candidate: String = path + suffix
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))


func _capture(name: String) -> String:
	var path := "user://m15_screenshots/%s.png" % name
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	if DisplayServer.get_name() == "headless":
		print("M15_CAPTURE_UNAVAILABLE name=%s reason=HEADLESS_DISPLAY" % name)
		return "UNAVAILABLE"
	var texture: Texture2D = get_root().get_texture()
	if texture == null:
		print("M15_CAPTURE_UNAVAILABLE name=%s reason=NO_VIEWPORT_TEXTURE" % name)
		return "UNAVAILABLE"
	var image: Image = texture.get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	_check("screenshot captured: %s" % name, error == OK)
	return path


func _run() -> void:
	var database = _database()
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(10, {"time": 2})
	var starting_state := economy.export_state()
	var grant := economy.grant_reward("fixture:booster", {"type": "booster", "id": "shuffle", "quantity": 1})
	var duplicate := economy.grant_reward("fixture:booster", {"type": "booster", "id": "shuffle", "quantity": 1})
	_check("typed booster reward grants inventory", grant.get("granted", false) and economy.get_booster_count("shuffle") == 1)
	_check("reward ledger makes replay idempotent", duplicate.get("duplicate", false) and economy.get_booster_count("shuffle") == 1)
	var before_invalid := economy.export_state()
	_check("invalid reward fails closed without partial mutation", not economy.grant_reward("fixture:bad", {"type": "booster", "id": "", "quantity": -1}).get("ok", false) and economy.export_state() == before_invalid)
	_check("insufficient booster consumption is non-mutating", not economy.consume_booster("time", 99).get("ok", false) and economy.get_booster_count("time") == 2)
	_check("successful booster consumption is exact", economy.consume_booster("time").get("ok", false) and economy.get_booster_count("time") == 1)

	var save = SAVE_SCRIPT.new()
	var save_path := _path("economy.json")
	_clean(save_path)
	var persisted_state: Dictionary = save.create_default_state()
	persisted_state["coins"] = 41
	persisted_state["boosters"] = {"time": 1, "upgrade": 1}
	persisted_state["reward_ledger"] = ["fixture:booster"]
	var write_result := save.write_state(persisted_state, save_path, save_path + ".bak")
	var reload_result := save.read_state(save_path, save_path + ".bak", _path("legacy.cfg"))
	_check("SaveManager persists economy balances and ledger", write_result.get("ok", false) and reload_result["state"]["coins"] == 41 and reload_result["state"]["boosters"]["upgrade"] == 1 and reload_result["state"]["reward_ledger"].has("fixture:booster"))
	var old_state := persisted_state.duplicate(true)
	old_state.erase("reward_ledger")
	old_state["schema_version"] = 2
	var old_path := _path("old_v2.json")
	_clean(old_path)
	var old_file := FileAccess.open(old_path, FileAccess.WRITE)
	old_file.store_string(JSON.stringify(old_state))
	old_file.close()
	var old_reload := save.read_state(old_path, old_path + ".bak", _path("old_legacy.cfg"))
	_check("pre-M15 valid save loads with empty ledger", old_reload["ok"] and old_reload["state"].has("reward_ledger") and old_reload["state"]["reward_ledger"].is_empty() and old_reload["state"]["coins"] == 41)

	var campaign = _campaign(database, economy)
	var bridge = _bridge(database, campaign, economy)
	var config: Dictionary = bridge.start_session(ISLAND_ID, 1)
	_check("VIP session exposes exact target and pending state", config["vip"]["cocktail_level"] == 12 and bridge.get_vip_state()["status"] == "PENDING")
	bridge.mark_gameplay_ready()
	var base_time := float(config["time_limit_sec"])
	var before_time: float = bridge.timer_remaining_sec
	var time_result: Dictionary = bridge.apply_time_booster(5.0)
	_check("+Time applies positive extension and consumes one item", time_result.get("ok", false) and is_equal_approx(bridge.timer_remaining_sec, before_time + 5.0) and economy.get_booster_count("time") == 0 and is_equal_approx(float(config["time_limit_sec"]), base_time))
	var failed_time: Dictionary = bridge.apply_time_booster(5.0)
	_check("+Time with empty inventory does not consume or extend", not failed_time.get("ok", false) and is_equal_approx(bridge.timer_remaining_sec, before_time + 5.0))

	var incomplete_vip_bridge = _bridge(database, campaign, economy)
	incomplete_vip_bridge.start_session(ISLAND_ID, 1)
	incomplete_vip_bridge.mark_gameplay_ready()
	var incomplete_result: Dictionary = incomplete_vip_bridge.record_to_go_delivery(6, 1, "m15-incomplete") ["terminal"]
	_check("incomplete VIP still produces normal WIN", incomplete_result["outcome"] == "WIN" and not incomplete_result["vip_completed"])
	_check("incomplete VIP grants no VIP booster", economy.get_booster_count("upgrade") == 0 and not economy.has_granted_reward("vip:%s:1" % ISLAND_ID))

	var vip_bridge = _bridge(database, campaign, economy)
	vip_bridge.start_session(ISLAND_ID, 1)
	vip_bridge.mark_gameplay_ready()
	vip_bridge.record_vip_delivery(12, 1)
	_check("VIP badge state becomes completed only after requirement", vip_bridge.get_vip_state()["status"] == "COMPLETED")
	var vip_win: Dictionary = vip_bridge.record_to_go_delivery(6, 1, "m15-vip-win")["terminal"]
	_check("completed VIP reward dispatches only on normal WIN", vip_win["outcome"] == "WIN" and economy.get_booster_count("upgrade") == 1 and economy.has_granted_reward("vip:%s:1" % ISLAND_ID))
	var replay_config: Dictionary = vip_bridge.retry_session()
	vip_bridge.mark_gameplay_ready()
	vip_bridge.set_vip_completed(true)
	vip_bridge.record_to_go_delivery(6, 1, "m15-vip-replay")
	_check("VIP replay after retry does not duplicate reward", economy.get_booster_count("upgrade") == 1)

	var lose_economy = ECONOMY_SCRIPT.new()
	lose_economy.configure()
	var lose_campaign = _campaign(database, lose_economy)
	var lose_bridge = _bridge(database, lose_campaign, lose_economy)
	lose_bridge.start_session(ISLAND_ID, 1)
	lose_bridge.mark_gameplay_ready()
	lose_bridge.resolve_lose("TEST_LOSE")
	_check("LOSE does not dispatch configured level or VIP rewards", lose_economy.coins == 0 and lose_economy.get_booster_count("upgrade") == 0 and lose_economy.get_ledger_state()["reward_ledger"].is_empty() and not lose_campaign.is_level_completed(ISLAND_ID, 1))

	var before_milestone_coins: int = economy.coins
	var milestone_before: Dictionary = campaign.claim_milestone(ISLAND_ID, 2)
	_check("ineligible milestone is rejected without reward", not milestone_before.get("ok", false) and economy.coins == before_milestone_coins)
	var milestone_one := campaign.claim_milestone(ISLAND_ID, 1)
	var milestone_one_duplicate := campaign.claim_milestone(ISLAND_ID, 1)
	_check("eligible milestone grants once and records claim", milestone_one.get("changed", false) and milestone_one.get("reward", {}).get("granted", false) and milestone_one_duplicate.get("duplicate", false) and campaign.is_milestone_claimed(ISLAND_ID, 1))
	var completed_level_two := campaign.mark_level_completed(ISLAND_ID, 2, {"stars": 1, "score": 1})
	var milestone_two := campaign.claim_milestone(ISLAND_ID, 2)
	_check("milestone reward dispatch preserves progression independence", completed_level_two.get("ok", false) and milestone_two.get("reward", {}).get("granted", false) and economy.get_booster_count("time") == 1)

	var navigation_scene := load("res://scenes/campaign/CampaignNavigationScene.tscn") as PackedScene
	var navigation = navigation_scene.instantiate()
	_check("production navigation exposes the same economy authority", navigation.configure_campaign(database, campaign, economy) and navigation.get_economy() == economy and navigation.get_session_bridge().get_economy() == economy)
	root.add_child(navigation)
	await process_frame
	await process_frame
	var opened: bool = navigation.get_world_map().select_island(ISLAND_ID)
	await process_frame
	await process_frame
	var selected: bool = navigation.get_island_map().select_level(1)
	await process_frame
	await process_frame
	var gameplay = navigation.get_node_or_null("CampaignGameplay")
	_check("runtime selection reuses the shared bridge/economy", opened and selected and gameplay != null and navigation.get_session_bridge().get_economy() == economy)
	_capture("vip_pending")
	navigation.get_session_bridge().set_vip_completed(true)
	await process_frame
	_capture("vip_completed")
	navigation.get_session_bridge().resolve_lose("SCREENSHOT_EXIT")
	navigation.return_to_island_map()
	await process_frame
	await process_frame
	navigation.get_island_map().select_level(2)
	await process_frame
	await process_frame
	_capture("non_vip")
	_check("non-VIP runtime hides the compact VIP badge", navigation.get_node_or_null("CampaignGameplay") != null and not navigation.get_node("CampaignGameplay")._vip_badge_label.visible)
	navigation.queue_free()
	await process_frame

	if failures.is_empty():
		print("M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS")
		quit(0)
		return
	print("M15_VIP_BOOSTERS_ECONOMY_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
