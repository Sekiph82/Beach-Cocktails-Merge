class_name CampaignNavigationController
extends Control

## Production campaign router for the M12 World Map, M13 Island Map, and the
## M14 session boundary. It owns one instance of each reusable map and one
## existing gameplay scene at a time.

signal world_map_entered
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
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")

var level_database
var campaign_manager
var current_view := VIEW_WORLD_MAP
var active_island_id := ""

var _world_map
var _island_map
var _gameplay
var _session_bridge
var _restoration_by_island: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if level_database == null or campaign_manager == null:
		_configure_default_campaign()
	_ensure_map_instances()


func configure_campaign(database, manager) -> bool:
	if database == null or manager == null or not database.is_loaded():
		return false
	level_database = database
	campaign_manager = manager
	if _session_bridge == null:
		_session_bridge = BRIDGE_SCRIPT.new()
		_session_bridge.island_map_requested.connect(_on_session_island_map_requested)
		_session_bridge.session_terminal.connect(_on_session_terminal)
	_session_bridge.configure(level_database, campaign_manager)
	if is_inside_tree():
		_ensure_map_instances()
	return true


func show_island_map(island_id: String) -> bool:
	if not _ensure_map_instances() or island_id.is_empty():
		return false
	if level_database.get_island(island_id).is_empty():
		return false
	var restoration: Dictionary = _restoration_by_island.get(island_id, {})
	if not _island_map.configure_island(island_id, level_database, campaign_manager, restoration):
		return false
	_world_map.visible = false
	_island_map.visible = true
	current_view = VIEW_ISLAND_MAP
	active_island_id = island_id
	island_map_entered.emit(island_id)
	return true


func show_world_map() -> bool:
	if not _ensure_map_instances():
		return false
	if current_view == VIEW_ISLAND_MAP and not active_island_id.is_empty():
		_restoration_by_island[active_island_id] = _island_map.get_restoration_state()
	if current_view == VIEW_GAMEPLAY:
		_dispose_gameplay()
		if _session_bridge != null:
			_session_bridge.clear_session()
	_island_map.visible = false
	_world_map.visible = true
	_world_map.refresh()
	current_view = VIEW_WORLD_MAP
	world_map_entered.emit()
	return true


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


func retry_level() -> bool:
	if _session_bridge == null or not _session_bridge.is_terminal():
		return false
	var configuration: Dictionary = _session_bridge.retry_session()
	if configuration.is_empty():
		return false
	_dispose_gameplay()
	current_view = VIEW_GAMEPLAY
	call_deferred("_instantiate_gameplay", configuration)
	return true


func next_level() -> bool:
	if _session_bridge == null or not _session_bridge.is_terminal():
		return false
	var configuration: Dictionary = _session_bridge.next_level_session()
	if configuration.is_empty():
		return false
	_dispose_gameplay()
	current_view = VIEW_GAMEPLAY
	call_deferred("_instantiate_gameplay", configuration)
	return true


func return_to_island_map() -> bool:
	if _session_bridge == null or not _session_bridge.is_terminal():
		return false
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
		_session_bridge.configure(level_database, campaign_manager)
	if _world_map == null:
		_world_map = WORLD_MAP_SCENE.instantiate()
		_world_map.level_database = level_database
		_world_map.campaign_manager = campaign_manager
		_world_map.island_map_requested.connect(_on_island_map_requested)
		_world_map.return_requested.connect(show_world_map)
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
	_world_map.visible = current_view == VIEW_WORLD_MAP
	_island_map.visible = current_view == VIEW_ISLAND_MAP
	return true


func _on_island_map_requested(island_id: String) -> void:
	show_island_map(island_id)


func _on_level_selected(island_id: String, level_id: int) -> void:
	level_selected.emit(island_id, level_id)
	_launch_selected_level(island_id, level_id)


func _launch_selected_level(island_id: String, level_id: int) -> bool:
	if _session_bridge == null or is_instance_valid(_gameplay):
		return false
	var configuration: Dictionary = _session_bridge.start_session(island_id, level_id)
	if configuration.is_empty():
		return false
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
		_gameplay.queue_free()
	_gameplay = null


func _on_session_terminal(result: Dictionary) -> void:
	gameplay_session_finished.emit(result)


func _on_session_island_map_requested(island_id: String) -> void:
	_dispose_gameplay()
	show_island_map(island_id)


func _configure_default_campaign() -> void:
	level_database = DATABASE_SCRIPT.new()
	if not level_database.load_canonical():
		return
	campaign_manager = CAMPAIGN_SCRIPT.new()
	if not campaign_manager.configure(level_database, SAVE_SCRIPT.new().create_default_state()):
		return
