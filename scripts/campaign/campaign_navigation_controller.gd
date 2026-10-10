class_name CampaignNavigationController
extends Control

## Production campaign router for the M12 World Map, M13 Island Map, and the
## M14 session boundary. It owns one instance of each reusable map and one
## existing gameplay scene at a time.

signal world_map_entered
signal main_menu_requested
signal island_map_entered(island_id: String)
signal level_selected(island_id: String, level_id: int)
signal gameplay_session_started(configuration: Dictionary)
signal gameplay_session_finished(result: Dictionary)

const VIEW_WORLD_MAP := "WORLD_MAP"
const VIEW_ISLAND_MAP := "ISLAND_MAP"
const VIEW_GAMEPLAY := "GAMEPLAY"

const WORLD_MAP_SCENE := preload("res://scenes/campaign/WorldMapScene.tscn")
const ISLAND_MAP_SCENE := preload("res://scenes/campaign/IslandMapScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const FEEDBACK_SCENE := preload("res://scripts/campaign/campaign_feedback_overlay.gd")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")

var level_database
var campaign_manager
var economy
var save_manager
var current_view := VIEW_WORLD_MAP
var active_island_id := ""

var _world_map
var _island_map
var _gameplay
var _session_bridge
var _result_canvas_layer: CanvasLayer
var _result_canvas_root: Control
var _result_feedback
var _result_feedback_creation_queued := false
var _pending_terminal_result: Dictionary = {}
var _pending_campaign_transition: Dictionary = {}
var _presented_reward_ids: Dictionary = {}
var _primary_action_sequence := 0
var _terminal_result_handled := false
var _result_presentation_count := 0
var _restoration_by_island: Dictionary = {}
var _persistence_enabled := false
var _presentation_settings: Dictionary = {"reduced_motion": false}


func _ready() -> void:
	# Campaign navigation is a routing container. Its child controls consume map
	# and result interactions, while unused gameplay pointer events must continue
	# through the viewport to ShotController._unhandled_input().
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not visibility_changed.is_connected(_on_campaign_navigation_visibility_changed):
		visibility_changed.connect(_on_campaign_navigation_visibility_changed)
	if level_database == null or campaign_manager == null:
		_configure_default_campaign()
	_ensure_map_instances()
	_ensure_result_feedback()


func _exit_tree() -> void:
	if is_instance_valid(_result_canvas_layer):
		_result_canvas_layer.queue_free()


func configure_campaign(database, manager, configured_economy = null) -> bool:
	if database == null or manager == null or not database.is_loaded():
		return false
	level_database = database
	campaign_manager = manager
	_persistence_enabled = false
	economy = configured_economy if configured_economy != null else ECONOMY_SCRIPT.new()
	if configured_economy == null:
		economy.configure_from_state(campaign_manager.get_progression_state())
	if campaign_manager.has_method("set_economy"):
		campaign_manager.set_economy(economy)
	_bind_persistence_signals()
	if _session_bridge == null:
		_session_bridge = BRIDGE_SCRIPT.new()
		_session_bridge.island_map_requested.connect(_on_session_island_map_requested)
		_session_bridge.session_terminal.connect(_on_session_terminal)
	_session_bridge.configure(level_database, campaign_manager, economy)
	_bind_persistence_signals()
	if is_inside_tree():
		_ensure_map_instances()
	return true


func show_island_map(island_id: String) -> bool:
	if not _ensure_map_instances() or island_id.is_empty():
		return false
	if level_database.get_island(island_id).is_empty():
		return false
	_hide_result_feedback()
	var restoration: Dictionary = _restoration_by_island.get(island_id, {})
	if not _island_map.configure_island(island_id, level_database, campaign_manager, restoration):
		return false
	_world_map.visible = false
	_island_map.visible = true
	current_view = VIEW_ISLAND_MAP
	active_island_id = island_id
	if str(_pending_campaign_transition.get("completed_island_id", "")) == island_id:
		_island_map.present_island_completion(_pending_campaign_transition)
		_pending_campaign_transition["island_completion_transition"] = false
	island_map_entered.emit(island_id)
	return true


func show_world_map() -> bool:
	if not _ensure_map_instances():
		return false
	_hide_result_feedback()
	if current_view == VIEW_ISLAND_MAP and not active_island_id.is_empty():
		_restoration_by_island[active_island_id] = _island_map.get_restoration_state()
	if current_view == VIEW_GAMEPLAY:
		_dispose_gameplay()
		if _session_bridge != null:
			_session_bridge.clear_session()
	_island_map.visible = false
	_world_map.visible = true
	if not _pending_campaign_transition.is_empty() and not _pending_campaign_transition.get("newly_unlocked_islands", []).is_empty():
		_world_map.present_campaign_transition(_pending_campaign_transition)
		_pending_campaign_transition["newly_unlocked_islands"] = []
	_world_map.refresh()
	current_view = VIEW_WORLD_MAP
	world_map_entered.emit()
	return true


func apply_presentation_settings(state: Dictionary) -> void:
	_presentation_settings = state.duplicate(true)
	if is_instance_valid(_world_map):
		_world_map.set_presentation_mode("REDUCED" if bool(state.get("reduced_motion", false)) else "FULL")
	if is_instance_valid(_island_map):
		_island_map.apply_presentation_settings(state)
	var gameplay := get_node_or_null("CampaignGameplay")
	if is_instance_valid(gameplay) and gameplay.has_method("apply_presentation_settings"):
		gameplay.apply_presentation_settings(state)


func continue_campaign() -> bool:
	if not _ensure_map_instances() or campaign_manager == null or level_database == null:
		return false
	var island_id := str(campaign_manager.current_island_id)
	var level_id := int(campaign_manager.get_frontier_level_id(island_id))
	var island_exists: bool = not level_database.get_island(island_id).is_empty()
	if island_exists and level_id > 0 and not level_database.get_level(island_id, level_id).is_empty() and campaign_manager.is_level_unlocked(island_id, level_id):
		return _launch_selected_level(island_id, level_id)
	if island_exists:
		return show_island_map(island_id)
	return show_world_map()


func get_continue_level_label() -> String:
	if campaign_manager == null or level_database == null:
		return "PLAY"
	var island_id := str(campaign_manager.current_island_id)
	var level_id := int(campaign_manager.get_frontier_level_id(island_id))
	if level_id > 0:
		return "LEVEL %d" % level_id
	return "PLAY"


func get_current_view() -> String:
	return current_view


func get_active_island_id() -> String:
	return active_island_id


func get_world_map():
	return _world_map


func get_island_map():
	return _island_map


func get_gameplay_instance_count() -> int:
	return 1 if is_instance_valid(_gameplay) else 0


func get_session_bridge():
	return _session_bridge


func get_economy():
	return economy


func get_save_manager():
	return save_manager


func get_result_feedback_overlay():
	return _result_feedback


func emit_primary_ui_feedback(action: String, target: Node) -> bool:
	if not ["PLAY", "NEXT", "RETRY"].has(action) or not is_instance_valid(target) or _world_map == null:
		return false
	if not target.is_in_group("presentation_effect_target"):
		return false
	if action == "PLAY" and (target.name != "HomePlay" or not target is TextureButton):
		return false
	if action in ["NEXT", "RETRY"]:
		var result_action := "NEXT_LEVEL" if action == "NEXT" else "RETRY"
		if _result_feedback == null or _result_feedback.get_action_presentation_target(result_action) != target:
			return false
	_primary_action_sequence += 1
	return _world_map._feedback_service.request_semantic("ui_primary", {
		"action": action,
		"newly_granted": true,
		"presentation_target": target,
	}, "ui-primary:%s:%d" % [action.to_lower(), _primary_action_sequence], {"source": "campaign_navigation_whitelist"})


func retry_level() -> bool:
	if _session_bridge == null or not _session_bridge.is_terminal():
		return false
	_hide_result_feedback()
	var configuration: Dictionary = _session_bridge.retry_session()
	if configuration.is_empty():
		return false
	_terminal_result_handled = false
	_dispose_gameplay()
	current_view = VIEW_GAMEPLAY
	call_deferred("_instantiate_gameplay", configuration)
	return true


func next_level() -> bool:
	if _session_bridge == null or not _session_bridge.is_terminal():
		return false
	_hide_result_feedback()
	var configuration: Dictionary = _session_bridge.next_level_session()
	if configuration.is_empty():
		return false
	_terminal_result_handled = false
	_dispose_gameplay()
	current_view = VIEW_GAMEPLAY
	call_deferred("_instantiate_gameplay", configuration)
	return true


func return_to_island_map() -> bool:
	if _session_bridge == null or not _session_bridge.is_terminal():
		return false
	_hide_result_feedback()
	var result: Dictionary = _session_bridge.return_to_island_map()
	return bool(result.get("ok", false))


func get_map_instance_count() -> int:
	var count := 0
	if _world_map != null:
		count += 1
	if _island_map != null:
		count += 1
	return count


func _ensure_map_instances() -> bool:
	if level_database == null or campaign_manager == null:
		return false
	if _session_bridge == null:
		_session_bridge = BRIDGE_SCRIPT.new()
		_session_bridge.island_map_requested.connect(_on_session_island_map_requested)
		_session_bridge.session_terminal.connect(_on_session_terminal)
		_session_bridge.configure(level_database, campaign_manager, economy)
		_bind_persistence_signals()
	if _world_map == null:
		_world_map = WORLD_MAP_SCENE.instantiate()
		_world_map.level_database = level_database
		_world_map.campaign_manager = campaign_manager
		_world_map.island_map_requested.connect(_on_island_map_requested)
		_world_map.return_requested.connect(_on_world_map_return_requested)
		add_child(_world_map)
	else:
		_world_map.configure_campaign(level_database, campaign_manager)
	if _island_map == null:
		_island_map = ISLAND_MAP_SCENE.instantiate()
		_island_map.level_selected.connect(_on_level_selected)
		_island_map.return_requested.connect(show_world_map)
		add_child(_island_map)
	else:
		_island_map.visible = false
	_island_map.apply_presentation_settings(_presentation_settings)
	_world_map.visible = current_view == VIEW_WORLD_MAP
	_island_map.visible = current_view == VIEW_ISLAND_MAP
	return true


func _ensure_result_feedback() -> void:
	if is_instance_valid(_result_feedback) or _result_feedback_creation_queued:
		return
	_result_feedback_creation_queued = true
	call_deferred("_create_result_feedback")


func _create_result_feedback() -> void:
	_result_feedback_creation_queued = false
	if is_instance_valid(_result_feedback) or not is_inside_tree():
		return
	_result_canvas_layer = CanvasLayer.new()
	_result_canvas_layer.name = "CampaignResultCanvasLayer"
	_result_canvas_layer.layer = 2
	_result_canvas_layer.visible = false
	add_child(_result_canvas_layer)
	_result_canvas_root = Control.new()
	_result_canvas_root.name = "CampaignResultCanvasRoot"
	_result_canvas_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_result_canvas_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_canvas_layer.add_child(_result_canvas_root)
	_result_feedback = FEEDBACK_SCENE.new()
	_result_feedback.name = "CampaignResultFeedback"
	_result_feedback.action_requested.connect(_on_result_feedback_action)
	_result_feedback.visible = false
	_result_canvas_root.add_child(_result_feedback)
	call_deferred("_present_pending_terminal_result")


func _hide_result_feedback() -> void:
	_pending_terminal_result.clear()
	if _result_feedback != null:
		_result_feedback.hide_feedback()
	if is_instance_valid(_result_canvas_layer):
		_result_canvas_layer.visible = false


func _on_campaign_navigation_visibility_changed() -> void:
	if not visible:
		_hide_result_feedback()
		return
	_sync_result_canvas_visibility()
	if not _pending_terminal_result.is_empty():
		call_deferred("_present_pending_terminal_result")


func _sync_result_canvas_visibility() -> void:
	if not is_instance_valid(_result_canvas_layer):
		return
	_result_canvas_layer.visible = visible and is_instance_valid(_result_feedback) and _result_feedback.visible


func _on_island_map_requested(island_id: String) -> void:
	show_island_map(island_id)


func _on_world_map_return_requested() -> void:
	## The application shell owns the menu boundary. The campaign router emits
	## this signal without creating another navigation or save authority.
	main_menu_requested.emit()


func _on_level_selected(island_id: String, level_id: int) -> void:
	level_selected.emit(island_id, level_id)
	_launch_selected_level(island_id, level_id)


func _launch_selected_level(island_id: String, level_id: int) -> bool:
	if _session_bridge == null or is_instance_valid(_gameplay):
		return false
	var configuration: Dictionary = _session_bridge.start_session(island_id, level_id)
	if configuration.is_empty():
		return false
	_terminal_result_handled = false
	_pending_terminal_result.clear()
	_restoration_by_island[island_id] = _island_map.get_restoration_state()
	_island_map.visible = false
	_world_map.visible = false
	current_view = VIEW_GAMEPLAY
	_instantiate_gameplay(configuration)
	return true


func _instantiate_gameplay(configuration: Dictionary) -> void:
	if is_instance_valid(_gameplay):
		return
	_gameplay = GAMEPLAY_SCENE.instantiate()
	_gameplay.name = "CampaignGameplay"
	add_child(_gameplay)
	if _gameplay.has_method("configure_campaign_session"):
		_gameplay.configure_campaign_session(_session_bridge)
	gameplay_session_started.emit(configuration)


func _dispose_gameplay() -> void:
	if is_instance_valid(_gameplay):
		if _gameplay.get_parent() == self:
			remove_child(_gameplay)
		_gameplay.queue_free()
	_gameplay = null


func _on_session_terminal(result: Dictionary) -> void:
	if _terminal_result_handled:
		return
	_terminal_result_handled = true
	_pending_terminal_result = result.duplicate(true)
	_pending_campaign_transition.clear()
	if str(result.get("outcome", "")) == "WIN":
		var progression: Dictionary = result.get("progression", {})
		if bool(progression.get("island_completion_transition", false)) or not progression.get("newly_unlocked_islands", []).is_empty():
			_pending_campaign_transition = {
				"transition_token": str(progression.get("transition_token", "")),
				"completed_island_id": str(result.get("island_id", "")),
				"island_completion_transition": bool(progression.get("island_completion_transition", false)),
				"newly_unlocked_islands": progression.get("newly_unlocked_islands", []).duplicate(true),
			}
	gameplay_session_finished.emit(result)
	_ensure_result_feedback()
	call_deferred("_present_pending_terminal_result")


func _present_pending_terminal_result() -> void:
	if _pending_terminal_result.is_empty():
		return
	if not is_instance_valid(_result_feedback):
		_ensure_result_feedback()
		return
	if not _result_feedback.is_node_ready():
		call_deferred("_present_pending_terminal_result")
		return
	if not visible:
		_result_canvas_layer.visible = false
		return
	var result := _pending_terminal_result.duplicate(true)
	_pending_terminal_result.clear()
	_result_canvas_layer.visible = true
	_result_feedback.show_result(result)
	_emit_new_reward_feedback(result)
	_result_presentation_count += 1
	if is_instance_valid(_gameplay) and _gameplay.has_method("present_campaign_result"):
		_gameplay.present_campaign_result(result, _result_feedback)


func _on_result_feedback_action(action: String) -> void:
	match action:
		"NEXT_LEVEL":
			var target: CanvasItem = _result_feedback.get_action_presentation_target(action) if _result_feedback != null else null
			emit_primary_ui_feedback("NEXT", target)
			next_level()
		"RETRY":
			var target: CanvasItem = _result_feedback.get_action_presentation_target(action) if _result_feedback != null else null
			emit_primary_ui_feedback("RETRY", target)
			retry_level()
		"ISLAND_MAP":
			if _session_bridge != null and _session_bridge.is_terminal():
				return_to_island_map()
		"DISMISS":
			_hide_result_feedback()


func _emit_new_reward_feedback(result: Dictionary) -> void:
	if _result_feedback == null or _world_map == null:
		return
	var reward_target: CanvasItem = _result_feedback.get_reward_presentation_target()
	if not is_instance_valid(reward_target):
		return
	var reward_ids: Array[String] = []
	var economy: Dictionary = result.get("economy", {}) if result.get("economy", {}) is Dictionary else {}
	var grants: Array = economy.get("grants", []) if economy.get("grants", []) is Array else []
	for grant_value in grants:
		if not grant_value is Dictionary or not bool(grant_value.get("granted", false)):
			continue
		var reward_id := str(grant_value.get("reward_id", ""))
		if not reward_id.is_empty() and not reward_ids.has(reward_id):
			reward_ids.append(reward_id)
	var progression: Dictionary = result.get("progression", {}) if result.get("progression", {}) is Dictionary else {}
	var cumulative: Array = progression.get("cumulative_rewards", []) if progression.get("cumulative_rewards", []) is Array else []
	for reward_value in cumulative:
		if not reward_value is Dictionary:
			continue
		var grant: Dictionary = reward_value.get("grant", {}) if reward_value.get("grant", {}) is Dictionary else {}
		if not bool(grant.get("granted", false)):
			continue
		var reward_id := str(grant.get("reward_id", ""))
		if not reward_id.is_empty() and not reward_ids.has(reward_id):
			reward_ids.append(reward_id)
	for reward_id in reward_ids:
		if _presented_reward_ids.has(reward_id):
			continue
		_presented_reward_ids[reward_id] = true
		_world_map._feedback_service.request_semantic("reward_granted", {
			"reward_id": reward_id,
			"newly_granted": true,
			"presentation_target": reward_target,
		}, "reward-granted:%s" % reward_id, {"source": "campaign_result_ledger"})


func _on_session_island_map_requested(island_id: String) -> void:
	if _island_map != null and not island_id.is_empty():
		_restoration_by_island[island_id] = _island_map.get_restoration_state()
	_dispose_gameplay()
	show_island_map(island_id)


func _configure_default_campaign() -> void:
	level_database = DATABASE_SCRIPT.new()
	if not level_database.load_canonical():
		return
	save_manager = SAVE_SCRIPT.new()
	var loaded: Dictionary = save_manager.read_state()
	var loaded_state: Dictionary = loaded.get("state", save_manager.create_default_state())
	economy = ECONOMY_SCRIPT.new()
	var economy_result: Dictionary = economy.configure_from_state(loaded_state)
	if not bool(economy_result.get("ok", false)):
		economy.configure()
	campaign_manager = CAMPAIGN_SCRIPT.new()
	if not campaign_manager.configure(level_database, loaded_state, economy):
		return
	_persistence_enabled = true
	_bind_persistence_signals()
	if loaded.get("status", "") == save_manager.STATUS_MISSING:
		_persist_campaign_state()


func _bind_persistence_signals() -> void:
	if campaign_manager != null and campaign_manager.has_signal("progression_changed") and not campaign_manager.progression_changed.is_connected(_on_campaign_changed):
		campaign_manager.progression_changed.connect(_on_campaign_changed)
	if _session_bridge != null and _session_bridge.has_signal("economy_changed") and not _session_bridge.economy_changed.is_connected(_on_economy_changed):
		_session_bridge.economy_changed.connect(_on_economy_changed)


func _on_campaign_changed(_island_id: String, _level_id: int) -> void:
	_persist_campaign_state()


func _on_economy_changed(_state: Dictionary) -> void:
	_persist_campaign_state()


func _persist_campaign_state() -> Dictionary:
	if not _persistence_enabled or save_manager == null or campaign_manager == null or economy == null:
		return {"ok": false, "reason": "PERSISTENCE_DISABLED"}
	var state: Dictionary = campaign_manager.get_progression_state()
	var economy_state: Dictionary = economy.export_state()
	state["coins"] = economy_state["coins"]
	state["boosters"] = economy_state["boosters"]
	state["reward_ledger"] = economy_state["reward_ledger"]
	state["schema_version"] = save_manager.schema_version()
	return save_manager.write_state(state)
