extends SceneTree

## Focused V05 probe. It covers the exact reserve-planner fixtures plus real
## CampaignNavigationController/GameManager routing and replay persistence.

const MODEL_SCRIPT = preload("res://scripts/campaign/m17_vip_optionality_model.gd")
const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT = preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT = preload("res://scripts/campaign/game_economy.gd")
const ISLAND_ID := "sunny_cove"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M17_V05_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M17_V05_PROBE FAIL: %s" % label)


func _wait_seconds(seconds: float = 0.52) -> void:
	await create_timer(seconds).timeout
	await process_frame


func _fixture_islands() -> Dictionary:
	return {
		"schema_version": 1,
		"islands": [{
			"id": ISLAND_ID,
			"display_name": "M17 V05 Fixture Island",
			"order_index": 1,
			"level_count": 1,
			"unlock_rule": {"type": "default_open"},
			"next_island_id": "",
			"map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
			"map_position": [0.5, 0.5],
			"target_policy": {"min_level": 5, "max_level": 8},
			"theme": {
				"island_map_background": "res://assets/ui_assets/campaign/islands/sunny_cove/map_background.png",
				"gameplay_surface": "res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png",
				"playable_geometry_profile": "res://assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_r04.json",
			},
			"reward_track": {"milestones": [], "rewards": {}},
		}],
	}


func _fixture_levels() -> Dictionary:
	return {
		"schema_version": 1,
		"island_id": ISLAND_ID,
		"levels": [{
			"island_id": ISLAND_ID,
			"level_id": 1,
			"time_limit_sec": 60,
			"orders": [{"cocktail_level": 6, "quantity": 1}],
			"vip": {"enabled": true, "cocktail_level": 5, "quantity": 1, "reward": {"type": "booster", "id": "upgrade", "quantity": 1}},
			"rewards": {},
			"score_star_thresholds": {"one_star": 0, "two_stars": 100, "three_stars": 200},
			"feature_flags": {"timed": true, "vip": true, "boosters": true},
		}],
	}


func _fixture_state() -> Dictionary:
	return {
		"schema_version": 2,
		"unlocked_islands": [ISLAND_ID],
		"islands": {ISLAND_ID: {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}


func _fixture_database():
	var database = DATABASE_SCRIPT.new()
	_check("V05 fixture loads in FULL validation", database.load_from_data(_fixture_islands(), _fixture_levels(), DATABASE_SCRIPT.ValidationMode.FULL))
	return database


func _new_campaign(database, economy):
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("V05 fixture campaign configures", campaign.configure(database, _fixture_state(), economy))
	return campaign


func _open_gameplay(database, campaign, economy):
	var scene := load("res://scenes/campaign/CampaignNavigationScene.tscn") as PackedScene
	var navigation = scene.instantiate()
	_check("real campaign navigation configures V05 fixture", navigation.configure_campaign(database, campaign, economy))
	root.add_child(navigation)
	await process_frame
	await process_frame
	var opened: bool = navigation.get_world_map().select_island(ISLAND_ID)
	await process_frame
	await process_frame
	var selected: bool = navigation.get_island_map().select_level(1)
	await process_frame
	await process_frame
	var gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("real GameManager session opens", opened and selected and gameplay != null)
	return navigation


func _reopen_gameplay(navigation):
	_check("return to Island Map succeeds after terminal session", navigation.return_to_island_map())
	await process_frame
	await process_frame
	var selected: bool = navigation.get_island_map().select_level(1)
	await process_frame
	await process_frame
	var gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("replay creates a fresh real GameManager session", selected and gameplay != null)
	return gameplay


func _spawn_settled(gameplay, level: int, x: float) -> Drink:
	var drink: Drink = gameplay.spawn_drink(level, Vector2(x, gameplay.launch_y - 140.0), false)
	drink.set_settled()
	return drink


func _normal_win(gameplay, bridge) -> Dictionary:
	var normal: Drink = _spawn_settled(gameplay, 6, 300.0)
	gameplay._try_collect_stocked_target()
	await _wait_seconds()
	_check("protected normal L6 enters normal capture", not is_instance_valid(normal) and bridge.is_terminal())
	return bridge.get_terminal_result()


func _run_planner_fixtures() -> void:
	var l4: Dictionary = {6: 1}
	_check("F1 one L5 candidate is protected", not MODEL_SCRIPT.candidate_is_surplus(l4, [5], 5))
	_check("F1 two L5 including candidate are protected", not MODEL_SCRIPT.candidate_is_surplus(l4, [5, 5], 5))
	_check("F1 third L5 becomes surplus", MODEL_SCRIPT.candidate_is_surplus(l4, [5, 5, 5], 5))
	_check("F2 higher L8 cannot satisfy lower L5", MODEL_SCRIPT.mandatory_reserve_cost({5: 1}, [8]) == 16)
	_check("F2 exact L5 remains protected beside unsplittable L8", not MODEL_SCRIPT.candidate_is_surplus({5: 1}, [8, 5], 5))

	var database = DATABASE_SCRIPT.new()
	_check("canonical data loads for L60/L100 planner fixtures", database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL))
	for level_id in [60, 100]:
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		var normal_remaining: Dictionary = {}
		var minimal_board: Array[int] = []
		for order in definition.get("orders", []):
			var order_level := int(order.get("cocktail_level", 0))
			var quantity := int(order.get("quantity", 0))
			normal_remaining[order_level] = int(normal_remaining.get(order_level, 0)) + quantity
			for _index in quantity:
				minimal_board.append(order_level)
		var vip_level := int(definition.get("vip", {}).get("cocktail_level", 0))
		var with_surplus: Array[int] = minimal_board.duplicate()
		with_surplus.append(vip_level)
		_check("L%d mandatory reserve protects every normal piece" % level_id, minimal_board.all(func(candidate_level: int) -> bool: return not MODEL_SCRIPT.candidate_is_surplus(normal_remaining, minimal_board, candidate_level)))
		_check("L%d extra VIP L%d is surplus" % [level_id, vip_level], MODEL_SCRIPT.candidate_is_surplus(normal_remaining, with_surplus, vip_level))


func _run_production_and_replay() -> void:
	var database = _fixture_database()
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(0, {})
	var campaign = _new_campaign(database, economy)
	var navigation = await _open_gameplay(database, campaign, economy)
	var gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	var bridge = navigation.get_session_bridge()

	var protected_a := _spawn_settled(gameplay, 5, 280.0)
	var protected_b := _spawn_settled(gameplay, 5, 360.0)
	gameplay._try_collect_stocked_target()
	await process_frame
	_check("G stocked path protects first mandatory L5", is_instance_valid(protected_a) and is_instance_valid(protected_b) and bridge.get_vip_state()["delivered"] == 0 and not gameplay._vip_target_transition)
	var first_result: Dictionary = await _normal_win(gameplay, bridge)
	_check("G normal WIN succeeds with VIP intentionally missed", first_result.get("outcome", "") == "WIN" and not first_result.get("vip_completed", true))
	_check("G missed VIP receives no booster reward", economy.get_booster_count("upgrade") == 0 and not economy.has_granted_reward("vip:%s:1" % ISLAND_ID))
	_check("I first play persists vip_completed=false", not bool(campaign.get_progression_state()["islands"][ISLAND_ID]["completed_levels"]["1"].get("vip_completed", false)))

	gameplay = await _reopen_gameplay(navigation)
	bridge = navigation.get_session_bridge()
	var reserve_a := _spawn_settled(gameplay, 5, 260.0)
	var reserve_b := _spawn_settled(gameplay, 5, 340.0)
	var surplus_direct := _spawn_settled(gameplay, 5, 420.0)
	gameplay.on_merged(5, surplus_direct)
	_check("H direct merged surplus L5 enters VIP capture", gameplay._vip_target_transition and gameplay._vip_target_drink == surplus_direct)
	await _wait_seconds()
	_check("H protected reserve remains after direct VIP capture", is_instance_valid(reserve_a) and is_instance_valid(reserve_b) and bridge.get_vip_state()["delivered"] == 1)
	var replay_result: Dictionary = await _normal_win(gameplay, bridge)
	_check("H normal WIN succeeds after surplus VIP delivery", replay_result.get("outcome", "") == "WIN" and replay_result.get("vip_completed", false))
	_check("H configured VIP reward grants exactly once", economy.get_booster_count("upgrade") == 1 and economy.has_granted_reward("vip:%s:1" % ISLAND_ID))
	_check("I replay persists vip_completed=true", bool(campaign.get_progression_state()["islands"][ISLAND_ID]["completed_levels"]["1"].get("vip_completed", false)))

	gameplay = await _reopen_gameplay(navigation)
	bridge = navigation.get_session_bridge()
	var stock_a := _spawn_settled(gameplay, 5, 260.0)
	var stock_b := _spawn_settled(gameplay, 5, 340.0)
	var stock_surplus := _spawn_settled(gameplay, 5, 420.0)
	gameplay._try_collect_stocked_target()
	var stocked_target: Drink = gameplay._vip_target_drink
	_check("I stocked surplus L5 enters VIP capture", gameplay._vip_target_transition and [stock_a, stock_b, stock_surplus].has(stocked_target))
	await _wait_seconds()
	var stocked_remaining := int(is_instance_valid(stock_a)) + int(is_instance_valid(stock_b)) + int(is_instance_valid(stock_surplus))
	_check("I stocked VIP capture leaves mandatory reserve", stocked_remaining == 2 and bridge.get_vip_state()["delivered"] == 1)
	var second_replay_result: Dictionary = await _normal_win(gameplay, bridge)
	_check("I second replay still wins normally", second_replay_result.get("outcome", "") == "WIN")
	_check("I second replay does not duplicate VIP reward", economy.get_booster_count("upgrade") == 1 and economy.get_ledger_state()["reward_ledger"].count("vip:%s:1" % ISLAND_ID) == 1)
	_check("I second replay keeps persisted vip_completed=true", bool(campaign.get_progression_state()["islands"][ISLAND_ID]["completed_levels"]["1"].get("vip_completed", false)))

	navigation.queue_free()
	await process_frame


func _run() -> void:
	await _run_planner_fixtures()
	await _run_production_and_replay()
	if failures.is_empty():
		print("M17_VIP_OPTIONALITY_RESULT=PASS")
		quit(0)
		return
	print("M17_VIP_OPTIONALITY_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
