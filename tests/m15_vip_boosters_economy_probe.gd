extends SceneTree

## Focused M15 V05 probe. It exercises the production economy/session/navigation
## seams with deterministic in-memory campaign data and writes inspectable
## runtime evidence under the committed M15 session evidence folder.

const ISLAND_ID := "m15_fixture"
const TEST_ROOT := "user://m15_economy_probe"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06"

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
			"level_count": 3,
			"unlock_rule": {"type": "default_open"},
			"next_island_id": "",
			"map_background": "",
            "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
            "map_position": [0.5, 0.5],
            "target_policy": {"min_level": 5, "max_level": 8},
            "reward_track": {
				"milestones": [1, 2],
				"rewards": {
					"1": {"type": "coins", "quantity": 25},
					"2": {"type": "booster", "id": "upgrade", "quantity": 1},
				},
			},
		}],
	}


func _level(level_id: int, vip: Variant, level_reward: Dictionary) -> Dictionary:
	return {
		"island_id": ISLAND_ID,
		"level_id": level_id,
		"time_limit_sec": 0,
		"orders": [{"cocktail_level": 6, "quantity": 1}],
		"vip": vip,
		"rewards": level_reward,
		"score_star_thresholds": {"one_star": 0, "two_stars": 100, "three_stars": 200},
		"feature_flags": {"timed": false, "vip": vip != null, "boosters": true},
	}


func _levels() -> Dictionary:
	return {
		"schema_version": 1,
		"island_id": ISLAND_ID,
		"levels": [
            _level(1, {"enabled": true, "cocktail_level": 8, "quantity": 2, "reward": {"type": "booster", "id": "upgrade", "quantity": 1}}, {"type": "coins", "quantity": 10}),
            _level(2, null, {"type": "coins", "quantity": 5}),
            {
                "island_id": ISLAND_ID,
                "level_id": 3,
                "time_limit_sec": 0,
                "orders": [{"cocktail_level": 6, "quantity": 1}, {"cocktail_level": 8, "quantity": 1}],
                "vip": {"enabled": true, "cocktail_level": 6, "quantity": 1},
				"rewards": {},
				"score_star_thresholds": {"one_star": 0, "two_stars": 100, "three_stars": 200},
				"feature_flags": {"timed": false, "vip": true, "boosters": true},
			},
		],
	}


func _state() -> Dictionary:
	return {
		"schema_version": 2,
		"unlocked_islands": [ISLAND_ID],
		"islands": {ISLAND_ID: {"highest_unlocked_level": 3, "completed_levels": {}, "claimed_milestones": []}},
		"legacy_best_score": 0,
		"boosters": {"time": 2},
		"coins": 0,
		"reward_ledger": [],
	}


func _database():
	var database = DATABASE_SCRIPT.new()
	_check("M15 fixture loads in FULL validation", database.load_from_data(_islands(), _levels(), DATABASE_SCRIPT.ValidationMode.FULL))
	return database


func _database_with_vip(vip: Variant):
	var levels := _levels()
	levels["levels"][0]["vip"] = vip
	var database = DATABASE_SCRIPT.new()
	return database if database.load_from_data(_islands(), levels, DATABASE_SCRIPT.ValidationMode.FULL) else null


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
	var path := "%s/%s.png" % [EVIDENCE_DIR, name]
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


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout
	await process_frame


func _run() -> void:
	var database = _database()
	var valid_l5_database = _database_with_vip({"enabled": true, "cocktail_level": 5, "quantity": 1})
	var valid_l8_database = _database_with_vip({"enabled": true, "cocktail_level": 8, "quantity": 1})
	var invalid_l4_database = _database_with_vip({"enabled": true, "cocktail_level": 4, "quantity": 1})
	var invalid_l9_database = _database_with_vip({"enabled": true, "cocktail_level": 9, "quantity": 1})
	var zero_quantity_database = _database_with_vip({"enabled": true, "cocktail_level": 6, "quantity": 0})
	var fractional_quantity_database = _database_with_vip({"enabled": true, "cocktail_level": 6, "quantity": 1.5})
	var disabled_database = _database_with_vip({"enabled": false})
	_check("shared policy accepts normal/VIP L5", valid_l5_database != null and database.is_campaign_target_level_eligible(ISLAND_ID, 5))
	_check("shared policy accepts normal/VIP L8", valid_l8_database != null and database.is_campaign_target_level_eligible(ISLAND_ID, 8))
	_check("shared policy rejects normal/VIP L4", invalid_l4_database == null and not database.is_campaign_target_level_eligible(ISLAND_ID, 4))
	_check("shared policy rejects normal/VIP L9", invalid_l9_database == null and not database.is_campaign_target_level_eligible(ISLAND_ID, 9))
	_check("VIP zero quantity rejects", zero_quantity_database == null)
	_check("VIP fractional quantity rejects", fractional_quantity_database == null)
	_check("disabled VIP metadata remains valid", disabled_database != null)
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
	_check("VIP session exposes exact target and pending 0/2 state", config["vip"]["cocktail_level"] == 8 and bridge.get_vip_state()["status"] == "PENDING" and bridge.get_vip_state()["required"] == 2 and bridge.get_vip_state()["delivered"] == 0 and bridge.get_vip_state()["remaining"] == 2)
	bridge.mark_gameplay_ready()
	var base_time := float(config["time_limit_sec"])
	var before_time: float = bridge.timer_remaining_sec
	var time_result: Dictionary = bridge.apply_time_booster(5.0)
	_check("retired +Time is rejected without consuming legacy inventory", not time_result.get("ok", false) and time_result.get("reason", "") == "TIME_BOOSTER_RETIRED" and is_equal_approx(bridge.timer_remaining_sec, before_time) and economy.get_booster_count("time") == 1 and is_equal_approx(float(config["time_limit_sec"]), base_time))
	var failed_time: Dictionary = bridge.apply_time_booster(5.0)
	_check("retired +Time remains rejected and does not extend", not failed_time.get("ok", false) and failed_time.get("reason", "") == "TIME_BOOSTER_RETIRED" and is_equal_approx(bridge.timer_remaining_sec, before_time) and economy.get_booster_count("time") == 1)
	var mismatched_vip := bridge.record_vip_delivery(7, 1)
	var nonpositive_vip := bridge.record_vip_delivery(8, 0)
	_check("mismatched and nonpositive VIP deliveries pay zero", not mismatched_vip.get("ok", false) and not nonpositive_vip.get("ok", false) and bridge.get_vip_state()["delivered"] == 0)
	_check("paused VIP delivery pays zero", bridge.pause_session("M15_TEST_PAUSE") and not bridge.record_vip_delivery(8, 1).get("ok", false) and bridge.resume_session() and bridge.get_vip_state()["delivered"] == 0)

	var incomplete_vip_bridge = _bridge(database, campaign, economy)
	incomplete_vip_bridge.start_session(ISLAND_ID, 1)
	incomplete_vip_bridge.mark_gameplay_ready()
	var incomplete_result: Dictionary = incomplete_vip_bridge.record_to_go_delivery(6, 1, "m15-incomplete") ["terminal"]
	_check("incomplete VIP still produces normal WIN", incomplete_result["outcome"] == "WIN" and not incomplete_result["vip_completed"])
	_check("incomplete VIP grants no VIP booster", economy.get_booster_count("upgrade") == 0 and not economy.has_granted_reward("vip:%s:1" % ISLAND_ID))

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
	_check("milestone reward dispatch preserves progression independence", completed_level_two.get("ok", false) and milestone_two.get("reward", {}).get("granted", false) and economy.get_booster_count("upgrade") == 1)

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
	_check("production normal target is L6 and VIP target is L8", gameplay != null and gameplay._target_level == 6 and navigation.get_session_bridge().get_vip_state()["cocktail_level"] == 8)
	var to_go_panel: Control = gameplay._to_go_panel if gameplay != null else null
	var vip_state_before_delivery: Dictionary = navigation.get_session_bridge().get_vip_state()
	var to_go_artwork := to_go_panel.get_node("Artwork") as Sprite2D if to_go_panel != null else null
	_check("combined owner-approved V06 HUD asset is active", to_go_artwork != null and to_go_artwork.texture.resource_path == "res://assets/ui/panel_to_go_vip_orders.png" and to_go_artwork.texture.get_width() == 1132 and to_go_artwork.texture.get_height() == 1698)
	_check("combined HUD keeps width and derives the tall V06 height", to_go_panel != null and is_equal_approx(to_go_panel.size.x, 210.0 * gameplay._ui_scale) and is_equal_approx(to_go_panel.size.y, 210.0 * gameplay._ui_scale * 1698.0 / 1132.0) and is_equal_approx(to_go_panel.position.x, (gameplay.get_board_size().x - to_go_panel.size.x) * 0.5) and is_equal_approx(to_go_panel.position.y, 0.0))
	_check("obsolete procedural VIP card is absent", gameplay != null and gameplay.get_node_or_null("UI/HUD/VipCard") == null)
	_check("normal target uses canonical cocktail and authoritative 0/1 progress", gameplay != null and gameplay._to_go_target_sprite.texture == Drink.texture_for_level(6) and gameplay._to_go_progress_label.text == "0/1")
	_check("normal reward remains Drink.order_reward", gameplay != null and gameplay._to_go_reward_label.text == "%d" % Drink.order_reward(6))
	_check("VIP target reuses canonical cocktail texture", gameplay != null and gameplay._vip_target_sprite.texture == Drink.texture_for_level(int(vip_state_before_delivery["cocktail_level"])))
	_check("normal and VIP cocktail slots share one scaling policy", gameplay != null and is_equal_approx(gameplay._to_go_target_sprite.scale.x, gameplay._to_go_cocktail_scale(6)) and is_equal_approx(gameplay._vip_target_sprite.scale.x, gameplay._to_go_cocktail_scale(8)))
	_check("VIP pending presentation shows 0/N and doubled reward", gameplay != null and gameplay._vip_progress_label.text == "0/2" and gameplay._vip_reward_label.text == "%d" % (2 * Drink.order_reward(8)))
	_capture("normal_vip_pending")

	# Production VIP proof: on_merged is the same GameManager callback used by
	# MergeQueue. The drink is consumed by the independent VIP capture route,
	# while the mandatory normal L6 target remains untouched.
	var merged_vip: Drink = gameplay.spawn_drink(8, Vector2(360.0, gameplay.launch_y - 160.0), false)
	gameplay.on_merged(8, merged_vip)
	_check("newly merged VIP drink enters production capture", gameplay._vip_target_transition and gameplay._vip_target_drink == merged_vip and merged_vip.motion_state == Drink.MotionState.TARGET_CAPTURE)
	var merged_vip_score_before_delivery: int = int(gameplay.score)
	await _wait_seconds(0.52)
	var first_vip_state: Dictionary = navigation.get_session_bridge().get_vip_state()
	_check("merged VIP receives exact 2x unit payout", not is_instance_valid(merged_vip) and gameplay.score == merged_vip_score_before_delivery + 2 * Drink.order_reward(8))
	_check("first actual VIP delivery accumulates 1/2", first_vip_state["delivered"] == 1 and first_vip_state["remaining"] == 1 and not first_vip_state["completed"])
	_check("VIP partial presentation shows 1/N without debug words", gameplay._vip_progress_label.text == "1/2" and not gameplay._vip_progress_label.text.contains("PENDING") and not gameplay._vip_progress_label.text.contains("COMPLETED"))
	_capture("normal_vip_partial")

	# Stored drinks use the same production target-selection seam and must also
	# satisfy the distinct VIP objective without becoming normal To-Go rewards.
	var stored_vip: Drink = gameplay.spawn_drink(8, Vector2(460.0, gameplay.launch_y - 220.0), false)
	stored_vip.set_settled()
	gameplay._try_collect_stocked_target()
	_check("stored VIP drink enters production capture", gameplay._vip_target_transition and gameplay._vip_target_drink == stored_vip and stored_vip.motion_state == Drink.MotionState.TARGET_CAPTURE)
	var stored_vip_score_before_delivery: int = int(gameplay.score)
	await _wait_seconds(0.52)
	var completed_vip_state: Dictionary = navigation.get_session_bridge().get_vip_state()
	_check("stored VIP receives exact 2x unit payout", not is_instance_valid(stored_vip) and gameplay.score == stored_vip_score_before_delivery + 2 * Drink.order_reward(8))
	_check("second actual VIP delivery completes cumulative 2/2", completed_vip_state["delivered"] == 2 and completed_vip_state["remaining"] == 0 and completed_vip_state["completed"])
	_check("VIP completed presentation replaces the fraction with a check mark", gameplay._vip_progress_label.text == "✓" and gameplay._to_go_panel.visible and gameplay._vip_target_sprite.visible)
	_capture("normal_vip_completed")

	var extra_vip: Drink = gameplay.spawn_drink(8, Vector2(520.0, gameplay.launch_y - 280.0), false)
	gameplay.on_merged(8, extra_vip)
	await process_frame
	var extra_state: Dictionary = navigation.get_session_bridge().get_vip_state()
	var extra_score: int = int(gameplay.score)
	_check("extra VIP delivery after completion is idempotent", is_instance_valid(extra_vip) and extra_state["delivered"] == 2 and extra_state["remaining"] == 0 and extra_state["completed"])
	_check("extra VIP delivery after completion pays zero", gameplay.score == extra_score)
	extra_vip.queue_free()

	# The normal objective remains separately mandatory and is the only path
	# that resolves WIN. VIP completion alone has not ended the session.
	var normal_drink: Drink = gameplay.spawn_drink(6, Vector2(300.0, gameplay.launch_y - 120.0), false)
	normal_drink.set_settled()
	gameplay._try_collect_stocked_target()
	_check("normal L6 enters its separate production capture", gameplay._target_transition and gameplay._target_drink == normal_drink)
	var normal_score_before_delivery: int = int(gameplay.score)
	await _wait_seconds(0.52)
	var vip_win: Dictionary = navigation.get_session_bridge().get_terminal_result()
	_check("normal L6 delivery remains 1x payout", gameplay.score == normal_score_before_delivery + Drink.order_reward(6))
	_check("normal progress reflects authoritative completed/required state", gameplay._to_go_progress_label.text == "1/1")
	_check("terminal result score includes VIP bonuses", vip_win.get("score", -1) == gameplay.score)
	_check("normal WIN follows VIP completion and grants the configured upgrade once", vip_win.get("outcome", "") == "WIN" and vip_win.get("vip_completed", false) and economy.get_booster_count("upgrade") == 2 and economy.has_granted_reward("vip:%s:1" % ISLAND_ID))
	var upgrade_count_after_win := economy.get_booster_count("upgrade")
	var repeated_terminal: Dictionary = navigation.get_session_bridge().resolve_win()
	_check("repeated WIN resolution does not duplicate reward", repeated_terminal.get("outcome", "") == "WIN" and economy.get_booster_count("upgrade") == upgrade_count_after_win)

	# Same-level normal/VIP precedence: normal L6 claims first, then a
	# subsequent L6 can satisfy VIP after the normal claim is complete.
	navigation.return_to_island_map()
	await process_frame
	await process_frame
	navigation.get_island_map().select_level(3)
	await process_frame
	await process_frame
	var same_level_gameplay = navigation.get_node_or_null("CampaignGameplay")
	var same_level_bridge = navigation.get_session_bridge()
	var same_level_drink: Drink = same_level_gameplay.spawn_drink(6, Vector2(300.0, same_level_gameplay.launch_y - 120.0), false)
	same_level_gameplay.on_merged(6, same_level_drink)
	var same_level_pre_delivery_score: int = int(same_level_gameplay.score)
	await _wait_seconds(0.52)
	var same_level_state: Dictionary = same_level_bridge.get_vip_state()
	_check("same-level normal delivery claims first", same_level_state["delivered"] == 0 and same_level_gameplay.score == same_level_pre_delivery_score + Drink.order_reward(6))
	var later_vip: Drink = same_level_gameplay.spawn_drink(6, Vector2(420.0, same_level_gameplay.launch_y - 180.0), false)
	later_vip.set_settled()
	same_level_gameplay._try_collect_stocked_target()
	var same_level_vip_score_before: int = int(same_level_gameplay.score)
	await _wait_seconds(0.52)
	_check("same-level later L6 remains protected while useful for mandatory L8", is_instance_valid(later_vip) and same_level_bridge.get_vip_state()["delivered"] == 0 and same_level_gameplay.score == same_level_vip_score_before)

	same_level_bridge.resolve_lose("SAME_LEVEL_EXIT")
	navigation.return_to_island_map()
	await process_frame
	await process_frame

	await process_frame
	navigation.get_session_bridge().resolve_lose("SCREENSHOT_EXIT")
	navigation.return_to_island_map()
	await process_frame
	await process_frame
	navigation.get_island_map().select_level(2)
	await process_frame
	await process_frame
	_capture("non_vip_0_of_0")
	var non_vip_gameplay = navigation.get_node_or_null("CampaignGameplay")
	_check("non-VIP keeps the combined panel visible", non_vip_gameplay != null and non_vip_gameplay._to_go_panel.visible)
	_check("non-VIP shows persistent 0/0 with no VIP reward", non_vip_gameplay != null and non_vip_gameplay._vip_progress_label.text == "0/0" and non_vip_gameplay._vip_reward_label.text.is_empty() and not non_vip_gameplay._vip_target_sprite.visible)
	navigation.queue_free()
	await process_frame

	if failures.is_empty():
		print("M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS")
		quit(0)
		return
	print("M15_VIP_BOOSTERS_ECONOMY_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
