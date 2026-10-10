extends SceneTree

const ISLAND_ID := "sunny_cove"
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-002/M26-island-map"
const REPORT_PATH := EVIDENCE_DIR + "/m26_001_island_map_presentation.json"

var failures: Array[String] = []
var captures: Array[Dictionary] = []
var max_active_spark_particles := 0


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M26_001_ISLAND_MAP PASS: %s" % label)
	else:
		failures.append(label)
		print("M26_001_ISLAND_MAP FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _settle(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout


func _set_viewport_size(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_root().size = size
	get_root().get_window().content_scale_size = size
	DisplayServer.window_set_size(size)
	await _frames(6)
	_check("real project viewport matches requested %dx%d" % [size.x, size.y], get_root().get_viewport().get_visible_rect().size == Vector2(size))


func _capture(map, label: String, size: Vector2i) -> void:
	await _frames(2)
	if DisplayServer.get_name() == "headless":
		return
	var image := get_root().get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE_DIR, label]
	var saved := not image.is_empty() and image.save_png(ProjectSettings.globalize_path(path)) == OK
	_check("real GL framebuffer saved: %s" % label, saved)
	captures.append({
		"label": label,
		"path": path,
		"image_width": image.get_width(),
		"image_height": image.get_height(),
		"window_size": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"viewport_size": [int(get_root().get_viewport().get_visible_rect().size.x), int(get_root().get_viewport().get_visible_rect().size.y)],
		"renderer": "running_project_viewport",
	})
	_check("capture is %dx%d" % [size.x, size.y], image.get_width() == size.x and image.get_height() == size.y)
	_check("capture target is the affected production level node", map.get_level_button(2).get_node("NodeArt").is_in_group("presentation_effect_target"))


func _new_campaign(database, state: Dictionary = {}) -> CampaignManager:
	var manager := CAMPAIGN_SCRIPT.new() as CampaignManager
	if state.is_empty():
		state = {
			"schema_version": 2,
			"unlocked_islands": [ISLAND_ID],
			"islands": {ISLAND_ID: {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
			"legacy_best_score": 0,
			"boosters": {},
			"coins": 0,
			"reward_ledger": [],
		}
	_check("campaign fixture configures", manager.configure(database, state))
	return manager


func _new_navigation(database, manager):
	var navigation = NAVIGATION_SCENE.instantiate()
	_check("navigation accepts campaign fixture", navigation.configure_campaign(database, manager))
	get_root().add_child(navigation)
	return navigation


func _trace_has_kind(bridge, kind: String, mode: String = "") -> bool:
	for trace in bridge.get_visual_diagnostic_trace():
		if str(trace.get("kind", "")) == kind:
			var plan: Dictionary = trace.get("plan", {})
			if mode.is_empty() or str(plan.get("mode", "")) == mode:
				return true
	return false


func _last_trace_for(bridge, kind: String) -> Dictionary:
	var traces: Array[Dictionary] = bridge.get_visual_diagnostic_trace()
	for index in range(traces.size() - 1, -1, -1):
		if str(traces[index].get("kind", "")) == kind:
			return traces[index]
	return {}


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	await _set_viewport_size(Vector2i(720, 1280))
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign definitions load with full validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	var manager := _new_campaign(database)
	var navigation = _new_navigation(database, manager)
	await _frames(5)
	_check("production Island Map opens", navigation.show_island_map(ISLAND_ID))
	await _frames(5)
	var map = navigation.get_island_map()
	var bridge: PresentationFeedbackBridge = map._presentation_bridge
	var service: FeedbackService = map._feedback_service
	bridge.set_visual_diagnostics_enabled(true)
	_check("Island Map bridge enables production dispatch", bridge._production_dispatch_enabled)
	_check("level 2 starts locked and cannot be selected", map.get_level_state(2) == "LOCKED" and not map.select_level(2))
	map.get_feedback_overlay().hide_feedback()
	await _frames(2)
	var locked_rect: Rect2 = map.get_level_button(2).get_rect()
	_check("first level completion advances CampaignManager authority", manager.mark_level_completed(ISLAND_ID, 1, {"stars": 1, "score": 101}).get("ok", false) and manager.is_level_unlocked(ISLAND_ID, 2))
	await _frames(4)
	max_active_spark_particles = maxi(max_active_spark_particles, bridge._active_spark_particle_count())
	_check("new locked-to-open transition updates affected node", map.get_level_state(2) == "OPEN" and map.get_level_button(2).is_selectable())
	_check("first level unlock enters bridge exactly once", int(service.semantic_counts.get("level_unlock", 0)) == 1 and _trace_has_kind(bridge, "level_unlock", "FULL"))
	_check("level unlock keeps the existing button geometry", map.get_level_button(2).get_rect() == locked_rect)
	await _capture(map, "full_level_unlock_720x1280", Vector2i(720, 1280))
	await _settle(0.38)
	map.refresh()
	await _frames(4)
	max_active_spark_particles = maxi(max_active_spark_particles, bridge._active_spark_particle_count())
	_check("refresh does not replay level unlock", int(service.semantic_counts.get("level_unlock", 0)) == 1)
	_check("refresh keeps node layout and hitbox size", map.get_level_button(2).get_rect().size == locked_rect.size)
	_check("newly unlocked level accepts normal selection", map.select_level(2) and manager.selected_level_id == 2)
	_check("return from selected level disposes gameplay through the world-map route", navigation.show_world_map() and navigation.get_gameplay_instance_count() == 0)
	_check("world-map route restores the production Island Map", navigation.show_island_map(ISLAND_ID))
	await _frames(6)

	# Advance through the real campaign authority to the configured L10 milestone.
	for level_id in range(2, 9):
		_check("level %d completion succeeds" % level_id, manager.mark_level_completed(ISLAND_ID, level_id, {"stars": 1, "score": 100 + level_id}).get("ok", false))
		await _settle(0.38)
	await _set_viewport_size(Vector2i(720, 1440))
	_check("level 10 milestone is configured from campaign data", map.is_level_milestone(10))
	await _frames(6)
	_check("level 8 completion opens level 9", map.get_level_state(9) == "OPEN")
	_check("level 9 completion opens level 10", manager.mark_level_completed(ISLAND_ID, 9, {"stars": 1, "score": 109}).get("ok", false))
	await _frames(4)
	_check("level unlock bridge count reaches nine", int(service.semantic_counts.get("level_unlock", 0)) == 9)
	await _capture(map, "full_level_unlock_720x1440", Vector2i(720, 1440))
	_check("level 10 first completion is authoritative", manager.mark_level_completed(ISLAND_ID, 10, {"stars": 1, "score": 110}).get("ok", false))
	await _frames(4)
	max_active_spark_particles = maxi(max_active_spark_particles, bridge._active_spark_particle_count())
	_check("newly reached configured milestone enters bridge", int(service.semantic_counts.get("island_milestone", 0)) == 1 and _trace_has_kind(bridge, "island_milestone", "FULL"))
	_check("level 10 completion unlocks level 11", map.get_level_state(11) == "OPEN")
	await _capture(map, "full_milestone_10_720x1440", Vector2i(720, 1440))
	await _settle(0.62)
	var full_milestone_trace := _last_trace_for(bridge, "island_milestone")
	_check("FULL milestone remains within 18 particles and 0.55 seconds", int(full_milestone_trace.get("plan", {}).get("spark_overrides", {}).get("amount", 0)) <= 18 and float(full_milestone_trace.get("plan", {}).get("spark_overrides", {}).get("lifetime", 0.0)) <= 0.55)
	_check("milestone marker remains a separate visual-only target", map.get_level_button(10).get_node("MilestoneMarker").is_in_group("presentation_effect_target") and map.get_level_button(10).get_node("MilestoneMarker").mouse_filter == Control.MOUSE_FILTER_IGNORE)
	var counts_before_refresh := service.semantic_counts.duplicate(true)
	map.refresh()
	await _frames(4)
	max_active_spark_particles = maxi(max_active_spark_particles, bridge._active_spark_particle_count())
	_check("refresh does not replay level or milestone presentation", service.semantic_counts == counts_before_refresh)
	var configured_milestones: Array = database.get_island(ISLAND_ID).get("reward_track", {}).get("milestones", [])
	var milestone_id: Variant = configured_milestones[0] if not configured_milestones.is_empty() else 10
	var claim_result: Dictionary = manager.claim_milestone(ISLAND_ID, milestone_id)
	await _frames(4)
	_check("new milestone claim enters bridge once", claim_result.get("changed", false) and int(service.semantic_counts.get("island_milestone", 0)) == int(counts_before_refresh.get("island_milestone", 0)) + 1 and _trace_has_kind(bridge, "island_milestone", "FULL"))
	var counts_after_claim := service.semantic_counts.duplicate(true)
	_check("map re-entry does not replay consumed progress events", navigation.show_world_map() and navigation.show_island_map(ISLAND_ID))
	await _frames(5)
	_check("re-entry preserves consumed event counts", service.semantic_counts == counts_after_claim)
	_check("level replay creates no unlock cue", manager.mark_level_completed(ISLAND_ID, 10, {"stars": 2, "score": 120}).get("changed", false) and service.semantic_counts == counts_after_claim)

	map.apply_presentation_settings({"reduced_motion": true})
	await _set_viewport_size(Vector2i(720, 1280))
	_check("reduced motion completes level 11 and opens level 12", manager.mark_level_completed(ISLAND_ID, 11, {"stars": 1, "score": 111}).get("ok", false) and manager.is_level_unlocked(ISLAND_ID, 12))
	await _frames(4)
	var reduced_level_trace := _last_trace_for(bridge, "level_unlock")
	_check("REDUCED level cue has no Spark particles", str(reduced_level_trace.get("plan", {}).get("mode", "")) == "REDUCED" and not reduced_level_trace.get("plan", {}).has("spark_preset"))
	await _capture(map, "reduced_level_unlock_720x1280", Vector2i(720, 1280))
	await _settle(0.28)
	_check("REDUCED level color restores exactly", not bridge.get_color_lifecycle_diagnostics().is_empty() and bool(bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))
	for level_id in range(12, 20):
		_check("reduced level %d completion succeeds" % level_id, manager.mark_level_completed(ISLAND_ID, level_id, {"stars": 1, "score": 100 + level_id}).get("ok", false))
		await _frames(3)
	await _set_viewport_size(Vector2i(720, 1440))
	_check("level 20 milestone is newly reached", manager.mark_level_completed(ISLAND_ID, 20, {"stars": 1, "score": 120}).get("ok", false))
	await _frames(4)
	var reduced_milestone_trace := _last_trace_for(bridge, "island_milestone")
	_check("REDUCED milestone uses at most four low-speed particles", str(reduced_milestone_trace.get("plan", {}).get("mode", "")) == "REDUCED" and int(reduced_milestone_trace.get("plan", {}).get("spark_overrides", {}).get("amount", 0)) <= 4 and float(reduced_milestone_trace.get("plan", {}).get("spark_overrides", {}).get("speed", 99.0)) <= 35.0)
	await _capture(map, "reduced_milestone_20_720x1440", Vector2i(720, 1440))
	await _settle(0.28)
	_check("REDUCED milestone color restores exactly", bool(bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))

	var persisted_state: Dictionary = manager.get_progression_state()
	var final_semantic_counts: Dictionary = service.semantic_counts.duplicate(true)
	var final_dispatch_count := bridge.dispatch_count
	var final_no_op_count := bridge.no_op_count
	var final_color_diagnostics := bridge.get_color_lifecycle_diagnostics()
	navigation.queue_free()
	await _frames(4)
	var restarted_manager := _new_campaign(database, persisted_state)
	var restarted_navigation = _new_navigation(database, restarted_manager)
	await _frames(4)
	_check("restored map opens without old level or milestone replay", restarted_navigation.show_island_map(ISLAND_ID))
	await _frames(5)
	var restarted_map = restarted_navigation.get_island_map()
	_check("restart has no synthetic progression semantic request", restarted_map._feedback_service.semantic_counts.is_empty() and restarted_map._presentation_bridge.dispatch_count == 0)
	_check("restart retains authoritative unlocked and completed map states", restarted_map.get_level_state(21) == "CURRENT" and restarted_map.get_level_state(20) == "COMPLETE")
	_check("all emitted bridge effects stay under the global 48-particle cap", max_active_spark_particles <= 48)
	restarted_navigation.queue_free()
	await _frames(3)
	var result := {
		"probe": "BCM-M26-001-island-map-progression-presentation",
		"renderer": "running Godot project viewport with GL Compatibility",
		"requested_sizes": [[720, 1280], [720, 1440]],
		"captures": captures,
		"semantic_counts": final_semantic_counts,
		"bridge_dispatch_count": final_dispatch_count,
		"bridge_no_op_count": final_no_op_count,
		"max_active_requested_spark_particles": max_active_spark_particles,
		"color_lifecycle": final_color_diagnostics,
		"failures": failures,
		"owner_visual_acceptance": "PENDING_OWNER_REVIEW",
	}
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		failures.append("evidence report could not be written")
	else:
		file.store_string(JSON.stringify(result, "\t") + "\n")
		file.close()
	print("M26_001_ISLAND_MAP_RESULT=%s captures=%d failures=%d dispatches=%d" % ["PASS" if failures.is_empty() else "FAIL", captures.size(), failures.size(), final_dispatch_count])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)

