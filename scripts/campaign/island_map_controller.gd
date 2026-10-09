class_name IslandMapController
extends Control

## Generic, data-driven Island Map. It presents progression and emits bounded
## selection/navigation signals; it never launches gameplay.

signal level_selected(island_id: String, level_id: int)
signal return_requested
signal world_map_requested

const STATE_OPEN := "OPEN"
const STATE_LOCKED := "LOCKED"
const STATE_CURRENT := "CURRENT"
const STATE_COMPLETE := "COMPLETE"
const MAP_WIDTH := 720.0
const NODE_HEIGHT := 126.0
const NODE_SIZE := Vector2(116.0, 112.0)
const DEFAULT_MILESTONES := [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
const ISLAND_PLAQUE_TEXTURE_SIZE := Vector2(440.0, 190.0)
const ISLAND_PLAQUE_INNER_TEXTURE_RECT := Rect2(74.0, 65.0, 291.0, 66.0)

const LEVEL_BUTTON_SCENE := preload("res://scenes/campaign/LevelButton.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const FEEDBACK_SCENE := preload("res://scripts/campaign/campaign_feedback_overlay.gd")
const FEEDBACK_SERVICE_SCRIPT := preload("res://scripts/feedback_service.gd")
const PRESENTATION_BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")

var island_id := ""
var level_database
var campaign_manager
var selected_level_id := 0
var _focus_level_id := 0
var _restoration_state: Dictionary = {}
var _has_restoration_state := false
var _restored_scroll_vertical := -1
var _refresh_queued := false
var _level_buttons: Dictionary = {}
var _milestone_levels: Array[int] = []
var _last_progression_snapshot: Dictionary = {}
var _presented_progression_events: Dictionary = {}
var _pending_progression_events: Array[Dictionary] = []
var _page_backgrounds: Array[TextureRect] = []
var _active_layout: Dictionary = {}
var _feedback_service: FeedbackService
var _presentation_bridge: PresentationFeedbackBridge

var _background_texture: TextureRect
var _background_fallback: ColorRect
var _scroll: ScrollContainer
var _content: Control
var _path_line: Line2D
var _node_layer: Control
var _title_label: Label
var _summary_label: Label
var _focus_label: Label
var _feedback_overlay


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_shell()
	_configure_presentation_feedback()
	if level_database == null or campaign_manager == null:
		_configure_default_campaign()
	_bind_campaign_progression_signal()
	_last_progression_snapshot = _capture_progression_snapshot()
	if not island_id.is_empty():
		refresh()


func _exit_tree() -> void:
	if campaign_manager != null and campaign_manager.has_signal("progression_changed"):
		var callback := Callable(self, "_on_campaign_progression_changed")
		if campaign_manager.progression_changed.is_connected(callback):
			campaign_manager.progression_changed.disconnect(callback)
	if is_instance_valid(_presentation_bridge):
		_presentation_bridge.cancel_presentation()


func set_presentation_mode(mode: String) -> bool:
	return _presentation_bridge != null and _presentation_bridge.set_presentation_mode(mode)


func apply_presentation_settings(state: Dictionary) -> void:
	set_presentation_mode("REDUCED" if bool(state.get("reduced_motion", false)) else "FULL")


func present_island_completion(transition: Dictionary) -> bool:
	if transition.is_empty() or campaign_manager == null or island_id.is_empty():
		return false
	if str(transition.get("completed_island_id", "")) != island_id:
		return false
	if not bool(transition.get("island_completion_transition", false)) or not campaign_manager.is_island_complete(island_id):
		return false
	if _title_label == null or _presentation_bridge == null or _feedback_service == null:
		return false
	_title_label.add_to_group("presentation_effect_target")
	return _feedback_service.request_semantic("island_complete", {
		"island_id": island_id,
		"new_transition": true,
		"presentation_target": _title_label,
	}, "%s:island-complete:%s" % [str(transition.get("transition_token", "")), island_id], {"source": "campaign_island_map"})


func configure_island(
		configured_island_id: String,
		database,
		manager,
		restoration: Dictionary = {}
	) -> bool:
	if database == null or manager == null or not database.is_loaded():
		return false
	var definition: Dictionary = database.get_island(configured_island_id)
	if definition.is_empty():
		return false
	island_id = configured_island_id
	level_database = database
	var previous_manager = campaign_manager
	campaign_manager = manager
	if previous_manager != campaign_manager:
		if previous_manager != null and previous_manager.has_signal("progression_changed"):
			var previous_callback := Callable(self, "_on_campaign_progression_changed")
			if previous_manager.progression_changed.is_connected(previous_callback):
				previous_manager.progression_changed.disconnect(previous_callback)
		_bind_campaign_progression_signal()
	_refresh_milestones(definition)
	_last_progression_snapshot = _capture_progression_snapshot()
	_restoration_state = restoration.duplicate(true)
	_has_restoration_state = not restoration.is_empty()
	_restored_scroll_vertical = int(restoration.get("scroll_vertical", -1)) if _has_restoration_state else -1
	var frontier_level := int(campaign_manager.get_frontier_level_id(island_id))
	var restored_frontier := int(restoration.get("frontier_level_id", frontier_level))
	var frontier_advanced := _has_restoration_state and frontier_level > restored_frontier
	selected_level_id = int(_restoration_state.get("selected_level_id", 0))
	if selected_level_id <= 0 and campaign_manager.current_island_id == island_id:
		selected_level_id = int(campaign_manager.selected_level_id)
	if selected_level_id <= 0:
		selected_level_id = 1
	_focus_level_id = frontier_level if frontier_advanced else int(_restoration_state.get("scroll_focus_level_id", 0))
	if _has_restoration_state and _focus_level_id <= 0:
		_focus_level_id = selected_level_id
	if frontier_advanced:
		_restored_scroll_vertical = -1
	if not _has_restoration_state:
		# First entry is intentionally independent from CampaignManager's
		# currently selected level. _refresh_deferred computes the focus from
		# unlocked/unfinished state after the configured level count is known.
		_focus_level_id = 0
	_set_island_map_background()
	refresh()
	return true


func configure_campaign(database, manager, configured_island_id: String, restoration: Dictionary = {}) -> bool:
	return configure_island(configured_island_id, database, manager, restoration)


func refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh_deferred")


func select_level(level_id: int) -> bool:
	var button = _level_buttons.get(level_id)
	if button == null:
		return false
	if not button.try_select():
		_show_locked_level_feedback(level_id)
		return false
	return true


func get_feedback_overlay():
	return _feedback_overlay


func get_island_map_background_path() -> String:
	if _background_texture != null and _background_texture.visible and _background_texture.texture != null:
		return str(_background_texture.texture.resource_path)
	for background in _page_backgrounds:
		if is_instance_valid(background) and background.texture != null:
			return str(background.texture.resource_path)
	return ""


func request_back_to_world_map() -> void:
	return_requested.emit()
	world_map_requested.emit()


func get_level_button_count() -> int:
	return _level_buttons.size()


func get_level_button(level_id: int):
	return _level_buttons.get(level_id)


func get_level_state(level_id: int) -> String:
	var button = _level_buttons.get(level_id)
	return str(button.get_state()) if button != null else ""


func get_level_stars(level_id: int) -> int:
	var button = _level_buttons.get(level_id)
	return int(button.get_stars()) if button != null else 0


func is_level_milestone(level_id: int) -> bool:
	return _milestone_levels.has(level_id)


func get_selected_level_id() -> int:
	return selected_level_id


func get_focus_level_id() -> int:
	return _focus_level_id


func get_scroll_focus_level_id() -> int:
	return _focus_level_id


func get_scroll_vertical() -> int:
	return _scroll.scroll_vertical if _scroll != null else 0


func set_scroll_vertical(value: int) -> void:
	if _scroll == null or _content == null:
		return
	var viewport_height := _scroll.size.y
	if viewport_height <= 0.0:
		viewport_height = 1030.0
	var max_scroll := maxi(0, int(_content.size.y - viewport_height))
	_scroll.scroll_vertical = clampi(value, 0, max_scroll)


func get_island_id() -> String:
	return island_id


func get_restoration_state() -> Dictionary:
	return {
		"island_id": island_id,
		"selected_level_id": selected_level_id,
		"scroll_focus_level_id": _focus_level_id,
		"scroll_vertical": get_scroll_vertical(),
		"frontier_level_id": int(campaign_manager.get_frontier_level_id(island_id)) if campaign_manager != null else 0,
	}


func restore_state(restoration: Dictionary) -> bool:
	if str(restoration.get("island_id", island_id)) != island_id:
		return false
	_restoration_state = restoration.duplicate(true)
	_has_restoration_state = true
	_restored_scroll_vertical = int(restoration.get("scroll_vertical", -1))
	var frontier_level := int(campaign_manager.get_frontier_level_id(island_id)) if campaign_manager != null else 0
	var restored_frontier := int(restoration.get("frontier_level_id", frontier_level))
	var frontier_advanced := frontier_level > restored_frontier
	var restored_selected := int(restoration.get("selected_level_id", 0))
	if restored_selected > 0 and campaign_manager != null and campaign_manager.is_level_unlocked(island_id, restored_selected):
		selected_level_id = restored_selected
	var restored_focus := frontier_level if frontier_advanced else int(restoration.get("scroll_focus_level_id", 0))
	if restored_focus > 0:
		_focus_level_id = restored_focus
	if frontier_advanced:
		_restored_scroll_vertical = -1
	refresh()
	return true


func get_summary() -> Dictionary:
	var definition: Dictionary = level_database.get_island(island_id) if level_database != null else {}
	var progress: Dictionary = campaign_manager.get_island_progress(island_id) if campaign_manager != null else {"completed": 0, "total": int(definition.get("level_count", 0)), "island_complete": false}
	var completed := int(progress.get("completed", 0))
	var total := int(progress.get("total", definition.get("level_count", 0)))
	var stars := _earned_stars()
	var next_milestone := 0
	for milestone_level in _milestone_levels:
		if milestone_level > completed:
			next_milestone = milestone_level
			break
	return {
		"island_id": island_id,
		"display_name": str(definition.get("display_name", island_id)),
		"completed": completed,
		"total": total,
		"stars": stars,
		"next_milestone": next_milestone,
		"island_complete": bool(progress.get("island_complete", false)),
	}


func get_layout_report(reference_size: Vector2 = Vector2(720.0, 1280.0)) -> Dictionary:
	var page_size := maxi(1, int(_active_layout.get("page_size", 1)))
	var page_count := ceili(float(_level_buttons.size()) / float(page_size)) if not _active_layout.is_empty() else 1
	var report := {
		"reference_size": reference_size,
		"node_count": _level_buttons.size(),
		"reusable_scene_count": 1 if _level_buttons.size() > 0 else 0,
		"horizontal_clipping": false,
		"vertical_scrollable": false,
		"duplicate_nodes": _node_layer != null and _node_layer.get_child_count() != _level_buttons.size(),
		"page_size": int(_active_layout.get("page_size", 0)),
		"page_count": page_count,
		"connector_lines": _path_line != null and _path_line.visible,
		"page_background_count": _page_backgrounds.size(),
		"content_width": MAP_WIDTH,
		"content_height": _content.size.y if _content != null else 0.0,
	}
	if _content == null:
		return report
	report["vertical_scrollable"] = _content.size.y > reference_size.y - 250.0
	for level_id in _level_buttons:
		var button: Control = _level_buttons[level_id]
		var rect := Rect2(button.position, button.size)
		if rect.position.x < 0.0 or rect.end.x > reference_size.x:
			report["horizontal_clipping"] = true
	return report


func _refresh_deferred() -> void:
	_refresh_queued = false
	if _content == null or level_database == null or campaign_manager == null or island_id.is_empty():
		return
	for child in _node_layer.get_children():
		_node_layer.remove_child(child)
		child.queue_free()
	_level_buttons.clear()

	var definition: Dictionary = level_database.get_island(island_id)
	var level_count := maxi(0, int(definition.get("level_count", 0)))
	_active_layout = _layout_metadata(definition)
	var page_size := maxi(1, int(_active_layout.get("page_size", level_count)))
	var page_height := maxf(1.0, float(_active_layout.get("page_height", 164.0 + float(page_size) * NODE_HEIGHT)))
	var page_count := ceili(float(level_count) / float(page_size)) if level_count > 0 else 0
	var content_height := 164.0 + float(level_count) * NODE_HEIGHT
	if not _active_layout.is_empty():
		content_height = maxf(page_height * float(page_count), 1.0)
	_content.custom_minimum_size = Vector2(MAP_WIDTH, content_height)
	_content.size = _content.custom_minimum_size
	_node_layer.size = _content.size
	_rebuild_page_backgrounds(definition, page_count, page_height)
	_ensure_path_line(bool(_active_layout.get("connector_lines", true)))
	var points := PackedVector2Array()
	for level_id in range(1, level_count + 1):
		var button = LEVEL_BUTTON_SCENE.instantiate()
		var center := _level_center_for(level_id, _active_layout, page_size, page_height)
		button.position = center - NODE_SIZE * 0.5
		button.size = NODE_SIZE
		button.configure(island_id, level_id, _state_for(level_id), _stars_for(level_id), _milestone_levels.has(level_id), _is_vip_level(level_id), _best_score_for(level_id))
		button.level_selected.connect(_on_level_button_selected)
		_node_layer.add_child(button)
		_level_buttons[level_id] = button
		points.append(center)
	if _path_line != null:
		_path_line.points = points
	_last_progression_snapshot = _capture_progression_snapshot()
	_update_summary()
	call_deferred("_flush_pending_progression_events")
	if not _has_restoration_state:
		_focus_level_id = _entry_focus_level(level_count)
	elif _focus_level_id <= 0 or not _level_buttons.has(_focus_level_id):
		_focus_level_id = _entry_focus_level(level_count)
	call_deferred("_apply_focus")


func _state_for(level_id: int) -> String:
	if campaign_manager.is_level_completed(island_id, level_id):
		return STATE_COMPLETE
	if not campaign_manager.is_level_unlocked(island_id, level_id):
		return STATE_LOCKED
	if level_id == selected_level_id or level_id == int(campaign_manager.selected_level_id):
		return STATE_CURRENT
	return STATE_OPEN


func _configure_presentation_feedback() -> void:
	_feedback_service = FEEDBACK_SERVICE_SCRIPT.new() as FeedbackService
	_feedback_service.name = "IslandMapFeedbackService"
	add_child(_feedback_service)
	_presentation_bridge = PRESENTATION_BRIDGE_SCRIPT.new() as PresentationFeedbackBridge
	_presentation_bridge.name = "IslandMapPresentationFeedbackBridge"
	add_child(_presentation_bridge)
	_presentation_bridge.configure(_feedback_service, get_tree().root)
	_presentation_bridge.set_presentation_mode("FULL")
	_presentation_bridge.set_production_dispatch_enabled(true)


func _bind_campaign_progression_signal() -> void:
	if campaign_manager == null or not campaign_manager.has_signal("progression_changed"):
		return
	var callback := Callable(self, "_on_campaign_progression_changed")
	if not campaign_manager.progression_changed.is_connected(callback):
		campaign_manager.progression_changed.connect(callback)


func _capture_progression_snapshot() -> Dictionary:
	if level_database == null or campaign_manager == null or island_id.is_empty():
		return {}
	var definition: Dictionary = level_database.get_island(island_id)
	var level_count := int(definition.get("level_count", 0))
	var levels: Dictionary = {}
	for level_id in range(1, level_count + 1):
		levels[level_id] = {
			"unlocked": campaign_manager.is_level_unlocked(island_id, level_id),
			"completed": campaign_manager.is_level_completed(island_id, level_id),
		}
	var state: Dictionary = campaign_manager.get_progression_state().get("islands", {}).get(island_id, {})
	return {
		"levels": levels,
		"claimed_milestones": state.get("claimed_milestones", []).duplicate(true),
	}


func _on_campaign_progression_changed(changed_island_id: String, _changed_level_id: int) -> void:
	if changed_island_id != island_id:
		return
	var previous := _last_progression_snapshot
	var current := _capture_progression_snapshot()
	_last_progression_snapshot = current
	var old_levels: Dictionary = previous.get("levels", {})
	var new_levels: Dictionary = current.get("levels", {})
	for level_id_value in new_levels:
		var level_id := int(level_id_value)
		var old_level: Dictionary = old_levels.get(level_id, {})
		var new_level: Dictionary = new_levels[level_id]
		if not bool(old_level.get("unlocked", false)) and bool(new_level.get("unlocked", false)):
			_queue_progression_event({"kind": "level_unlock", "level_id": level_id})
		if _milestone_levels.has(level_id) and not bool(old_level.get("completed", false)) and bool(new_level.get("completed", false)):
			_queue_progression_event({"kind": "island_milestone", "level_id": level_id, "transition": "reached"})
	var old_claimed: Array = previous.get("claimed_milestones", [])
	for milestone_value in current.get("claimed_milestones", []):
		if not old_claimed.has(milestone_value) and _milestone_levels.has(int(milestone_value)):
			_queue_progression_event({"kind": "island_milestone", "level_id": int(milestone_value), "transition": "claimed"})
	refresh()


func _queue_progression_event(event: Dictionary) -> void:
	var kind := str(event.get("kind", ""))
	var level_id := int(event.get("level_id", 0))
	var transition := str(event.get("transition", "reached"))
	var event_id := "level-unlock:%s:%d" % [island_id, level_id] if kind == "level_unlock" else "island-milestone:%s:%d:%s" % [island_id, level_id, transition]
	if _presented_progression_events.has(event_id):
		return
	for pending in _pending_progression_events:
		var pending_id := "level-unlock:%s:%d" % [island_id, int(pending.get("level_id", 0))] if str(pending.get("kind", "")) == "level_unlock" else "island-milestone:%s:%d:%s" % [island_id, int(pending.get("level_id", 0)), str(pending.get("transition", "reached"))]
		if pending_id == event_id:
			return
	_pending_progression_events.append(event.duplicate(true))


func _flush_pending_progression_events() -> void:
	if not is_visible_in_tree() or _level_buttons.is_empty():
		return
	var pending := _pending_progression_events.duplicate(true)
	_pending_progression_events.clear()
	for event in pending:
		if str(event.get("kind", "")) == "level_unlock":
			_present_level_unlock(int(event.get("level_id", 0)))
		else:
			_present_island_milestone(int(event.get("level_id", 0)), str(event.get("transition", "reached")))


func _present_level_unlock(level_id: int) -> void:
	var event_id := "level-unlock:%s:%d" % [island_id, level_id]
	if _presented_progression_events.has(event_id):
		return
	var button = _level_buttons.get(level_id)
	var target = button.get_node_or_null("NodeArt") if is_instance_valid(button) else null
	if not is_instance_valid(target):
		return
	_presented_progression_events[event_id] = true
	_feedback_service.request_semantic("level_unlock", {
		"island_id": island_id,
		"level_id": level_id,
		"presentation_target": target,
	}, event_id, {"source": "island_map_controller"})


func _present_island_milestone(level_id: int, transition: String) -> void:
	var event_id := "island-milestone:%s:%d:%s" % [island_id, level_id, transition]
	if _presented_progression_events.has(event_id):
		return
	var button = _level_buttons.get(level_id)
	var target = button.get_node_or_null("MilestoneMarker") if is_instance_valid(button) else null
	if not is_instance_valid(target):
		return
	_presented_progression_events[event_id] = true
	_feedback_service.request_semantic("island_milestone", {
		"island_id": island_id,
		"milestone_id": level_id,
		"transition": transition,
		"presentation_target": target,
	}, event_id, {"source": "island_map_controller"})


func _is_vip_level(level_id: int) -> bool:
	if level_database == null:
		return false
	var level: Dictionary = level_database.get_level(island_id, level_id)
	var vip: Variant = level.get("vip", null)
	return vip is Dictionary and bool(vip.get("enabled", false))


func _entry_focus_level(level_count: int) -> int:
	if campaign_manager == null or level_count <= 0:
		return 0
	return clampi(int(campaign_manager.get_frontier_level_id(island_id)), 1, level_count)


func _on_level_button_selected(level_id: int) -> void:
	if campaign_manager == null or not campaign_manager.is_level_unlocked(island_id, level_id):
		return
	if _feedback_overlay != null:
		_feedback_overlay.hide_feedback()
	if not campaign_manager.select_level(island_id, level_id):
		return
	selected_level_id = level_id
	_focus_level_id = level_id
	_has_restoration_state = false
	_restored_scroll_vertical = -1
	level_selected.emit(island_id, level_id)
	_update_summary()
	refresh()
	call_deferred("_apply_focus")


func _apply_focus() -> void:
	if _scroll == null or _content == null or _focus_level_id <= 0:
		return
	var button = _level_buttons.get(_focus_level_id)
	if button == null:
		return
	var viewport_height := _scroll.size.y
	if viewport_height <= 0.0:
		viewport_height = 1030.0
	var target := int(button.position.y + button.size.y * 0.5 - viewport_height * 0.5)
	var max_scroll := maxi(0, int(_content.size.y - viewport_height))
	if not _active_layout.is_empty():
		var page_size := maxi(1, int(_active_layout.get("page_size", 1)))
		var page_height := maxf(1.0, float(_active_layout.get("page_height", 1.0)))
		var page_top := int(floor(float(_focus_level_id - 1) / float(page_size)) * page_height)
		target = page_top
		if _has_restoration_state and _restored_scroll_vertical >= 0 and int(floor(float(_restored_scroll_vertical) / page_height)) == int(floor(float(page_top) / page_height)):
			target = _restored_scroll_vertical
		_scroll.scroll_vertical = clampi(target, 0, max_scroll)
	elif _has_restoration_state and _restored_scroll_vertical >= 0:
		_scroll.scroll_vertical = clampi(_restored_scroll_vertical, 0, max_scroll)
	else:
		_scroll.scroll_vertical = clampi(target, 0, max_scroll)
	_focus_label.text = "FOCUS  •  Level %d" % _focus_level_id


func _update_summary() -> void:
	if _title_label == null:
		return
	var summary := get_summary()
	_title_label.text = str(summary.get("display_name", island_id)).to_upper()
	var milestone_text := "COMPLETE" if int(summary.get("next_milestone", 0)) == 0 else "Level %d" % int(summary["next_milestone"])
	var completion_text := "ISLAND COMPLETE" if bool(summary.get("island_complete", false)) else "IN PROGRESS"
	_summary_label.text = "%d / %d LEVELS   •   %d / %d STARS   •   NEXT MILESTONE: %s\n%s" % [int(summary["completed"]), int(summary["total"]), int(summary["stars"]), int(summary["total"]) * 3, milestone_text, completion_text]


func _earned_stars() -> int:
	if campaign_manager == null:
		return 0
	var state: Dictionary = campaign_manager.get_progression_state()
	var island_state: Dictionary = state.get("islands", {}).get(island_id, {})
	var completed: Dictionary = island_state.get("completed_levels", {})
	var stars := 0
	for record in completed.values():
		if record is Dictionary and bool(record.get("completed", false)):
			stars += clampi(int(record.get("stars", 0)), 0, 3)
	return stars


func _stars_for(level_id: int) -> int:
	if campaign_manager == null:
		return 0
	var state: Dictionary = campaign_manager.get_progression_state()
	var record: Dictionary = state.get("islands", {}).get(island_id, {}).get("completed_levels", {}).get(str(level_id), {})
	return clampi(int(record.get("stars", 0)), 0, 3)


func _best_score_for(level_id: int) -> int:
	if campaign_manager == null:
		return 0
	var state: Dictionary = campaign_manager.get_progression_state()
	var record: Dictionary = state.get("islands", {}).get(island_id, {}).get("completed_levels", {}).get(str(level_id), {})
	return maxi(0, int(record.get("best_score", 0)))


func _refresh_milestones(definition: Dictionary) -> void:
	_milestone_levels.clear()
	var configured: Variant = definition.get("reward_track", {}).get("milestones", [])
	if configured is Array:
		for value in configured:
			var milestone_level := int(value)
			if milestone_level > 0 and not _milestone_levels.has(milestone_level):
				_milestone_levels.append(milestone_level)
	if _milestone_levels.is_empty():
		var total := int(definition.get("level_count", 0))
		for milestone_level in DEFAULT_MILESTONES:
			if milestone_level <= total:
				_milestone_levels.append(milestone_level)
	_milestone_levels.sort()


func _build_shell() -> void:
	_background_fallback = ColorRect.new()
	_background_fallback.name = "IslandMapFallbackBackground"
	_background_fallback.color = Color("#08283c")
	_background_fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background_fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background_fallback)

	_background_texture = TextureRect.new()
	_background_texture.name = "IslandMapThemeBackground"
	_background_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_texture.stretch_mode = TextureRect.STRETCH_SCALE
	_background_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background_texture.visible = false
	add_child(_background_texture)

	# This header contains explicitly positioned title/subtitle/summary controls.
	# A PanelContainer would relayout those controls into the same container slot
	# on the lower-map scroll presentation, so use a plain Panel as the visual
	# surface and preserve their production coordinates.
	var header := Control.new()
	header.name = "IslandMapHeader"
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 112.0
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.z_index = 5
	add_child(header)
	var sky_gradient := Gradient.new()
	sky_gradient.colors = PackedColorArray([Color("#7db8df"), Color("#ffcf8b")])
	var sky_texture := GradientTexture2D.new()
	sky_texture.gradient = sky_gradient
	sky_texture.width = 2
	sky_texture.height = 112
	sky_texture.fill_from = Vector2.ZERO
	sky_texture.fill_to = Vector2(0.0, 1.0)
	var sky_band := TextureRect.new()
	sky_band.name = "IslandMapSkyBand"
	sky_band.texture = sky_texture
	sky_band.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky_band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky_band.stretch_mode = TextureRect.STRETCH_SCALE
	sky_band.modulate.a = 0.0
	sky_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(sky_band)

	var back := Button.new()
	back.name = "BackToWorldMap"
	back.text = "‹"
	back.position = Vector2(18.0, 18.0)
	back.size = Vector2(62.0, 62.0)
	back.add_theme_font_size_override("font_size", 40)
	back.add_theme_color_override("font_color", Color("#fff0c6"))
	back.add_theme_stylebox_override("normal", _panel_style(Color("#0b2b40"), Color("#f1bd64")))
	back.pressed.connect(request_back_to_world_map)
	header.add_child(back)
	back.mouse_filter = Control.MOUSE_FILTER_STOP
	header.mouse_filter = Control.MOUSE_FILTER_PASS

	var plaque := TextureRect.new()
	plaque.name = "IslandNamePlaque"
	plaque.texture = load("res://assets/ui_assets/campaign/world_map/island_name_panel.png") as Texture2D
	plaque.position = Vector2(176.0, 4.0)
	plaque.size = Vector2(368.0, 88.0)
	plaque.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plaque.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(plaque)

	_title_label = Label.new()
	_title_label.name = "IslandName"
	var texture_scale := minf(plaque.size.x / ISLAND_PLAQUE_TEXTURE_SIZE.x, plaque.size.y / ISLAND_PLAQUE_TEXTURE_SIZE.y)
	var displayed_texture_size := ISLAND_PLAQUE_TEXTURE_SIZE * texture_scale
	var displayed_texture_origin := plaque.position + (plaque.size - displayed_texture_size) * 0.5
	var plaque_inner_rect := Rect2(
		displayed_texture_origin + ISLAND_PLAQUE_INNER_TEXTURE_RECT.position * texture_scale,
		ISLAND_PLAQUE_INNER_TEXTURE_RECT.size * texture_scale
	)
	_title_label.position = plaque_inner_rect.position
	_title_label.size = plaque_inner_rect.size
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.add_theme_color_override("font_color", Color("#fff0c6"))
	_title_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.16, 0.17, 0.9))
	_title_label.add_theme_constant_override("shadow_offset_x", 1)
	_title_label.add_theme_constant_override("shadow_offset_y", 2)
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_title_label)

	_summary_label = Label.new()
	_summary_label.name = "ProgressSummaryData"
	_summary_label.visible = false
	_summary_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_summary_label)

	_scroll = ScrollContainer.new()
	_scroll.name = "LevelPathScroll"
	_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	_scroll.z_index = 2
	add_child(_scroll)

	_content = Control.new()
	_content.name = "LevelPathContent"
	_content.custom_minimum_size = Vector2(MAP_WIDTH, 400.0)
	_content.size = _content.custom_minimum_size
	_scroll.add_child(_content)

	_node_layer = Control.new()
	_node_layer.name = "LevelNodes"
	_node_layer.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_node_layer.size = _content.size
	_node_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_node_layer.z_index = 1
	_content.add_child(_node_layer)

	_focus_label = Label.new()
	_focus_label.name = "FocusStatus"
	_focus_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_focus_label.offset_left = 24.0
	_focus_label.offset_top = -54.0
	_focus_label.offset_right = -24.0
	_focus_label.offset_bottom = -20.0
	_focus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_focus_label.add_theme_font_size_override("font_size", 14)
	_focus_label.modulate = Color("#c3e8df")
	_focus_label.z_index = 5
	add_child(_focus_label)

	_feedback_overlay = FEEDBACK_SCENE.new()
	_feedback_overlay.name = "CampaignFeedbackOverlay"
	_feedback_overlay.action_requested.connect(_on_feedback_action)
	add_child(_feedback_overlay)

	# Keep the Back button in the root viewport's input layer. The long level
	# path lives inside ScrollContainer's embedded viewport and otherwise wins
	# GUI hit testing over the header despite the header's higher draw z-index.
	header.remove_child(back)
	add_child(back)
	back.z_index = 10


func _set_island_map_background() -> void:
	if _background_texture == null or _background_fallback == null or level_database == null:
		return
	var theme: Dictionary = level_database.get_island_theme(island_id)
	var path := str(theme.get("island_map_background", ""))
	var texture := load(path) as Texture2D if not path.is_empty() and ResourceLoader.exists(path) else null
	var valid := texture != null
	_background_texture.texture = texture
	var layout := _layout_metadata(level_database.get_island(island_id))
	var paged := not layout.is_empty() and bool(layout.get("repeat_background_per_page", true))
	_background_texture.visible = valid and not paged
	_background_fallback.visible = not valid and not paged


func _layout_metadata(definition: Dictionary) -> Dictionary:
	var value: Variant = definition.get("island_map_layout", {})
	return value.duplicate(true) if value is Dictionary else {}


func _level_center_for(level_id: int, layout: Dictionary, page_size: int, page_height: float) -> Vector2:
	if layout.is_empty():
		var x := 92.0 if level_id % 2 == 1 else 512.0
		var y := 26.0 + float(level_id - 1) * NODE_HEIGHT
		return Vector2(x + NODE_SIZE.x * 0.5, y + NODE_SIZE.y * 0.5)
	var landmarks: Variant = layout.get("landmark_centers", [])
	if not landmarks is Array or landmarks.is_empty():
		return Vector2(MAP_WIDTH * 0.5, float(level_id - 1) * NODE_HEIGHT + NODE_HEIGHT * 0.5)
	var slot := (level_id - 1) % page_size
	var page := int(floor(float(level_id - 1) / float(page_size)))
	var raw: Variant = landmarks[slot % landmarks.size()]
	if not raw is Array or raw.size() != 2:
		return Vector2(MAP_WIDTH * 0.5, float(page) * page_height + NODE_HEIGHT * 0.5)
	return Vector2(float(raw[0]), float(page) * page_height + float(raw[1]))


func _rebuild_page_backgrounds(definition: Dictionary, page_count: int, page_height: float) -> void:
	for background in _page_backgrounds:
		if is_instance_valid(background):
			background.queue_free()
	_page_backgrounds.clear()
	if _active_layout.is_empty() or not bool(_active_layout.get("repeat_background_per_page", true)):
		return
	var theme: Dictionary = level_database.get_island_theme(island_id)
	var path := str(theme.get("island_map_background", ""))
	var texture := load(path) as Texture2D if not path.is_empty() and ResourceLoader.exists(path) else null
	if texture == null:
		return
	var origin_y := float(_active_layout.get("background_origin_y", -178.0))
	for page in range(page_count):
		var background := TextureRect.new()
		background.name = "IslandMapPageBackground_%02d" % (page + 1)
		background.texture = texture
		background.position = Vector2(0.0, float(page) * page_height + origin_y)
		background.size = Vector2(MAP_WIDTH, page_height)
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_SCALE
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_content.add_child(background)
		_content.move_child(background, 0)
		_page_backgrounds.append(background)


func _ensure_path_line(enabled: bool) -> void:
	if not enabled:
		if _path_line != null and is_instance_valid(_path_line):
			_content.remove_child(_path_line)
			_path_line.queue_free()
		_path_line = null
		return
	if _path_line != null and is_instance_valid(_path_line):
		_path_line.clear_points()
		return
	_path_line = Line2D.new()
	_path_line.name = "DeterministicLevelPath"
	_path_line.width = 8.0
	_path_line.default_color = Color("#d9a957")
	_path_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_path_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_path_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_path_line.z_index = 0
	_content.add_child(_path_line)
	_content.move_child(_path_line, 0)


func _show_locked_level_feedback(level_id: int) -> void:
	if _feedback_overlay == null or campaign_manager == null:
		return
	var island_state: Dictionary = campaign_manager.get_progression_state().get("islands", {}).get(island_id, {})
	_feedback_overlay.show_locked_level(level_id, int(island_state.get("highest_unlocked_level", 1)))


func _on_feedback_action(action: String) -> void:
	if action == "DISMISS" and _feedback_overlay != null:
		_feedback_overlay.hide_feedback()


func _configure_default_campaign() -> void:
	level_database = DATABASE_SCRIPT.new()
	if not level_database.load_canonical():
		return
	campaign_manager = CAMPAIGN_SCRIPT.new()
	if not campaign_manager.configure(level_database, SAVE_SCRIPT.new().create_default_state()):
		return
	island_id = campaign_manager.current_island_id
	selected_level_id = campaign_manager.selected_level_id
	_refresh_milestones(level_database.get_island(island_id))


func _panel_style(fill: Color, border: Color, alpha: float = 1.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	return style
