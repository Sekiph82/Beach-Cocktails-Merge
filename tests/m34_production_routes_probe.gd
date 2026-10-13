extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const NAVIGATION_SCRIPT := preload("res://scripts/campaign/campaign_navigation_controller.gd")
const ISLAND_IDS := ["sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island"]

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_ROUTES PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_ROUTES FAIL: %s" % label)


func _frame(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _mouse_event(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	return event


func _press_production_button(control: BaseButton) -> bool:
	if not is_instance_valid(control) or not control.is_visible_in_tree() or control.get_global_rect().size == Vector2.ZERO:
		return false
	# Exercise the visible production Control's connected press signal. This is
	# a deterministic control-flow probe, not a physical mouse/device claim.
	control.pressed.emit()
	await _frame(3)
	return true


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var loaded: bool = database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("full canonical dataset validates", loaded)
	if not loaded:
		quit(1)
		return
	var state: Dictionary = SAVE_SCRIPT.new().create_default_state()
	state["unlocked_islands"] = ISLAND_IDS.duplicate()
	for island_id in ISLAND_IDS:
		state["islands"][island_id] = {"highest_unlocked_level": 100, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}
	var economy = ECONOMY_SCRIPT.new()
	economy.configure_from_state(state)
	var campaign = CAMPAIGN_SCRIPT.new()
	var configured: bool = campaign.configure(database, state, economy)
	_check("test campaign exposes the ten already-unlocked canonical islands", configured and ISLAND_IDS.all(func(id): return campaign.is_island_unlocked(id)))
	var navigation = NAVIGATION_SCRIPT.new()
	navigation.name = "M34ProductionNavigation"
	get_root().add_child(navigation)
	_check("production navigation accepts the validated campaign", navigation.configure_campaign(database, campaign, economy))
	navigation.visible = true
	_check("production World Map opens", navigation.show_world_map())
	await _frame(4)
	var all_route_steps := true
	for island_id in ISLAND_IDS:
		var sample_ok := true
		var world_map = navigation.get_world_map()
		print("M34_ROUTE_ENTRY id=%s visible=%s selectable=%s unlock=%s view=%s" % [island_id, str(world_map._entries[island_id].is_visible_in_tree()), str(world_map.is_entry_selectable(island_id)), str(campaign.is_island_unlocked(island_id)), navigation.get_current_view()])
		var island_pressed: bool = await _press_production_button(world_map._entries[island_id])
		sample_ok = sample_ok and island_pressed and navigation.get_current_view() == NAVIGATION_SCRIPT.VIEW_ISLAND_MAP and navigation.get_active_island_id() == island_id
		await _frame(2)
		var island_map = navigation.get_island_map()
		var level_button = island_map.get_level_button(1)
		var level_pressed: bool = await _press_production_button(level_button)
		sample_ok = sample_ok and level_pressed
		await _frame(4)
		var bridge = navigation.get_session_bridge()
		var gameplay = navigation.get_node_or_null("CampaignGameplay")
		var config: Dictionary = bridge.get_session_configuration()
		print("M34_ROUTE_SAMPLE island=%s view=%s active=%s level=%d game=%s energy=%d" % [island_id, navigation.get_current_view(), str(config.get("island_id", "")), int(config.get("level_id", 0)), str(is_instance_valid(gameplay)), economy.energy])
		sample_ok = sample_ok and navigation.get_current_view() == NAVIGATION_SCRIPT.VIEW_GAMEPLAY and config.get("island_id", "") == island_id and config.get("level_id", 0) == 1 and is_instance_valid(gameplay)
		sample_ok = sample_ok and economy.energy == 80 and gameplay.get_node_or_null("UI/HUD/FocusBoosterButton") == null
		var gameplay_active: bool = bridge.session_state == "ACTIVE" or bridge.mark_gameplay_ready()
		sample_ok = sample_ok and gameplay_active
		var lost: Dictionary = bridge.resolve_lose("M34_ROUTE_RETRY_PROBE")
		await _frame(4)
		var retried: bool = navigation.retry_level()
		await _frame(4)
		sample_ok = sample_ok and lost.get("outcome", "") == "LOSE" and retried and bridge.get_session_configuration().get("island_id", "") == island_id and economy.energy == 60
		print("M34_ROUTE_RETRY island=%s lost=%s retried=%s view=%s energy=%d" % [island_id, str(lost.get("outcome", "")), str(retried), navigation.get_current_view(), economy.energy])
		bridge.return_to_island_map()
		await _frame(3)
		print("M34_ROUTE_RETURN island=%s view=%s" % [island_id, navigation.get_current_view()])
		sample_ok = sample_ok and navigation.get_current_view() == NAVIGATION_SCRIPT.VIEW_ISLAND_MAP
		navigation.show_world_map()
		await _frame(3)
		print("M34_ROUTE_WORLD island=%s view=%s" % [island_id, navigation.get_current_view()])
		sample_ok = sample_ok and navigation.get_current_view() == NAVIGATION_SCRIPT.VIEW_WORLD_MAP
		_check("production button route, start, LOSE, Retry and second energy charge on %s" % island_id, sample_ok)
		all_route_steps = all_route_steps and sample_ok
		# Every sample has a task-local economy; reset only the in-memory fixture
		# before the next actual session so all ten input paths remain testable.
		economy.energy = 100
	_check("visible production island buttons and level buttons open gameplay for all ten islands; retry charges a second actual attempt", all_route_steps)
	var save_manager = SAVE_SCRIPT.new()
	var saved: Dictionary = save_manager.create_default_state()
	saved.merge(campaign.get_progression_state(), true)
	saved.merge(economy.export_state(), true)
	saved["schema_version"] = save_manager.schema_version()
	var save_path := "user://m34_production_routes_save_%d.json" % Time.get_ticks_usec()
	var write_result: Dictionary = SAVE_SCRIPT.new().write_state(saved, save_path)
	var read_result: Dictionary = SAVE_SCRIPT.new().read_state(save_path, "", "user://m34_production_legacy_%d.cfg" % Time.get_ticks_usec())
	print("M34_ROUTES_SAVE write=%s read_status=%s read_reason=%s energy=%s" % [JSON.stringify(write_result), str(read_result.get("status", "")), str(read_result.get("reason", "")), str(read_result.get("state", {}).get("energy", "missing"))])
	_check("post-route campaign and economy state roundtrip in isolated user data", write_result.get("ok", false) and read_result.get("status", "") == SAVE_SCRIPT.STATUS_VALID and read_result.get("state", {}).get("energy", -1) == economy.energy)
	navigation.queue_free()
	await _frame()
	if failures.is_empty():
		print("M34_ROUTES_RESULT=PASS")
		quit(0)
	else:
		print("M34_ROUTES_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
