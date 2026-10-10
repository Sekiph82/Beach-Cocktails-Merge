extends SceneTree

const ISLAND_ID := "sunny_cove"
const NEXT_ISLAND_ID := "tiki_island"
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-002/M26-campaign-unlock"
const REPORT_PATH := EVIDENCE_DIR + "/m26_002_campaign_unlock_presentation.json"

var failures: Array[String] = []
var captures: Array[Dictionary] = []
var max_active_particles := 0


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M26_002_CAMPAIGN_MAP PASS: %s" % label)
	else:
		failures.append(label)
		print("M26_002_CAMPAIGN_MAP FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame
		max_active_particles = maxi(max_active_particles, _global_particle_count())


func _global_particle_count() -> int:
	var pool := get_root().get_node_or_null("Spark/SaltmireSparkPool")
	if not is_instance_valid(pool):
		return 0
	var total := 0
	for emitter in pool.get_children():
		var parts: Variant = emitter.get("_parts")
		if parts is Array:
			for particle in parts:
				if particle is Dictionary and float(particle.get("age", 0.0)) < float(particle.get("life", 0.0)):
					total += 1
	return total


func _settle(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout


func _set_viewport_size(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_root().size = size
	get_root().get_window().content_scale_size = size
	DisplayServer.window_set_size(size)
	await _frames(6)
	_check("real project viewport matches %dx%d" % [size.x, size.y], get_root().get_viewport().get_visible_rect().size == Vector2(size))


func _capture(label: String, size: Vector2i) -> void:
	await _frames(2)
	if DisplayServer.get_name() == "headless":
		return
	var image := get_root().get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE_DIR, label]
	var saved := not image.is_empty() and image.save_png(ProjectSettings.globalize_path(path)) == OK
	_check("real GL framebuffer saved: %s" % label, saved)
	captures.append({"label": label, "path": path, "image_width": image.get_width(), "image_height": image.get_height(), "renderer": "running_project_viewport"})
	_check("capture dimensions are %dx%d" % [size.x, size.y], image.get_width() == size.x and image.get_height() == size.y)


func _seed_through_level_99() -> Dictionary:
	var islands := {ISLAND_ID: {"highest_unlocked_level": 100, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}}
	var completed: Dictionary = islands[ISLAND_ID]["completed_levels"]
	for level_id in range(1, 100):
		completed[str(level_id)] = {"completed": true, "stars": 1, "best_score": 100 + level_id}
	return {"schema_version": 2, "unlocked_islands": [ISLAND_ID], "islands": islands, "legacy_best_score": 0, "boosters": {}, "coins": 0, "reward_ledger": []}


func _last_trace(bridge, kind: String) -> Dictionary:
	var traces: Array[Dictionary] = bridge.get_visual_diagnostic_trace()
	for index in range(traces.size() - 1, -1, -1):
		if str(traces[index].get("kind", "")) == kind:
			return traces[index]
	return {}


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	await _set_viewport_size(Vector2i(720, 1280))
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign data validates", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	var manager := CAMPAIGN_SCRIPT.new()
	var seed_state := _seed_through_level_99()
	_check("explicit fixture save configures with only Sunny Cove unlocked", manager.configure(database, seed_state) and manager.is_island_unlocked(ISLAND_ID) and not manager.is_island_unlocked(NEXT_ISLAND_ID))
	var navigation = NAVIGATION_SCENE.instantiate()
	_check("production navigation accepts campaign fixture", navigation.configure_campaign(database, manager))
	get_root().add_child(navigation)
	await _frames(6)
	_check("production Island Map opens", navigation.show_island_map(ISLAND_ID))
	await _frames(5)
	var island_map = navigation.get_island_map()
	var world_map = navigation.get_world_map()
	var bridge: PresentationFeedbackBridge = world_map._presentation_bridge
	bridge.set_visual_diagnostics_enabled(true)
	island_map._presentation_bridge.set_visual_diagnostics_enabled(true)
	_check("M26-002 source route is explicitly fixture-seeded at level 100", manager.get_frontier_level_id(ISLAND_ID) == 100 and manager.is_level_completed(ISLAND_ID, 99))
	_check("locked islands remain non-selectable before completion", world_map.get_entry_state(NEXT_ISLAND_ID) == "LOCKED" and not world_map.is_entry_selectable(NEXT_ISLAND_ID))
	var next_entry: Control = world_map.get_entry(NEXT_ISLAND_ID)
	var entry_rect_before: Rect2 = next_entry.get_global_rect()
	var art_rect_before: Rect2 = next_entry.get_node("IslandArt").get_global_rect()
	_check("production level 100 is open", island_map.get_level_state(100) in ["OPEN", "CURRENT"])
	_check("selecting level 100 enters production gameplay", island_map.select_level(100) and navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1)
	var session = navigation._session_bridge
	_check("bridge starts the configured final-level session", session.active_island_id == ISLAND_ID and session.active_level_id == 100 and session.is_session_active())
	var objective_state: Dictionary = session.get_objective_state()
	var remaining: Dictionary = objective_state.get("normal_remaining", {})
	for level_value in remaining.keys():
		var count := int(remaining[level_value])
		if count > 0:
			session.record_to_go_delivery(int(level_value), count, "m26-002-fixture-%s" % str(level_value), 1500)
	var terminal: Dictionary = session.get_terminal_result()
	var progression: Dictionary = terminal.get("progression", {})
	_check("final-level terminal result records the first authoritative island-completion transition", terminal.get("outcome", "") == "WIN" and bool(progression.get("island_completion_transition", false)) and manager.is_island_complete(ISLAND_ID))
	_check("CampaignManager reports Tiki as newly unlocked from completion", progression.get("newly_unlocked_islands", []).has(NEXT_ISLAND_ID) and manager.is_island_unlocked(NEXT_ISLAND_ID))
	_check("terminal transition includes a stable event token", not str(progression.get("transition_token", "")).is_empty())
	await _frames(6)
	_check("normal result remains visible before map navigation", is_instance_valid(navigation.get_result_feedback_overlay()) and navigation.get_result_feedback_overlay().visible)
	_check("return action opens Island Map without changing completion or unlock truth", navigation.return_to_island_map() and manager.is_island_complete(ISLAND_ID) and manager.is_island_unlocked(NEXT_ISLAND_ID))
	await _frames(8)
	var island_trace := _last_trace(island_map._presentation_bridge, "island_complete")
	_check("Island Map completion cue dispatches through the existing bridge exactly once", not island_trace.is_empty() and int(island_map._feedback_service.semantic_counts.get("island_complete", 0)) == 1)
	var completion_plan: Dictionary = island_trace.get("plan", {})
	_check("completion particles stay within 40 and 1.10 seconds", int(completion_plan.get("spark_overrides", {}).get("amount", 0)) <= 40 and float(completion_plan.get("spark_overrides", {}).get("lifetime", 9.0)) <= 1.10)
	_check("completion effect targets only visible island title visual", str(island_trace.get("target", {}).get("path", "")).ends_with("/IslandName"))
	await _capture("full_island_complete_720x1280", Vector2i(720, 1280))
	await _settle(1.12)
	_check("Island Map presentation restored exact title color", not island_map._presentation_bridge.get_color_lifecycle_diagnostics().is_empty() and bool(island_map._presentation_bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))
	var complete_button_rect: Rect2 = world_map.get_entry(NEXT_ISLAND_ID).get_global_rect()
	_check("World Map displays the genuine newly unlocked island", navigation.show_world_map() and world_map.get_entry_state(NEXT_ISLAND_ID) == "OPEN" and world_map.is_entry_selectable(NEXT_ISLAND_ID))
	var unlock_trace: Dictionary = {}
	for _frame in range(100):
		await process_frame
		unlock_trace = _last_trace(bridge, "island_unlock")
		if not unlock_trace.is_empty():
			break
	_check("World Map unlock cue dispatches exactly once", not unlock_trace.is_empty() and int(world_map._feedback_service.semantic_counts.get("island_unlock", 0)) == 1)
	var unlock_plan: Dictionary = unlock_trace.get("plan", {})
	_check("unlock particles stay within 48 and 1.60 seconds", int(unlock_plan.get("spark_overrides", {}).get("amount", 0)) <= 48 and float(unlock_plan.get("spark_overrides", {}).get("lifetime", 9.0)) <= 1.60)
	_check("island art remains the visual feedback target and geometry is unchanged", str(unlock_trace.get("target", {}).get("path", "")).ends_with("/IslandArt") and world_map.get_entry(NEXT_ISLAND_ID).get_global_rect() == complete_button_rect and world_map.get_entry(NEXT_ISLAND_ID).get_node("IslandArt").get_global_rect() == art_rect_before and entry_rect_before == complete_button_rect)
	_check("selection center remains on the visible island art", world_map.get_marker_position(NEXT_ISLAND_ID) == art_rect_before.get_center())
	await _set_viewport_size(Vector2i(720, 1440))
	await _capture("full_island_unlock_720x1440", Vector2i(720, 1440))
	await _settle(1.62)
	_check("World Map unlock presentation restores exact art color", not bridge.get_color_lifecycle_diagnostics().is_empty() and bool(bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))
	var counts_before_refresh: Dictionary = world_map._feedback_service.semantic_counts.duplicate(true)
	world_map.refresh()
	navigation.show_world_map()
	await _frames(10)
	_check("refresh and navigation re-entry do not replay completion or unlock cues", world_map._feedback_service.semantic_counts == counts_before_refresh and int(island_map._feedback_service.semantic_counts.get("island_complete", 0)) == 1)
	_check("map actions, campaign selection, completion, and unlocked records are unchanged", manager.current_island_id == ISLAND_ID and manager.is_island_complete(ISLAND_ID) and manager.is_island_unlocked(NEXT_ISLAND_ID) and not manager.get_progression_state().get("unlocked_islands", []).is_empty())

	bridge.set_presentation_mode("REDUCED")
	await _set_viewport_size(Vector2i(720, 1280))
	var reduced_target = world_map.get_entry(NEXT_ISLAND_ID).get_node("IslandArt")
	world_map._feedback_service.request_semantic("island_unlock", {"island_id": NEXT_ISLAND_ID, "new_transition": true, "presentation_target": reduced_target}, "fixture-reduced-island-unlock", {"source": "m26-002-explicit-reduced-fixture"})
	await _frames(5)
	var reduced_trace := _last_trace(bridge, "island_unlock")
	var reduced_plan: Dictionary = reduced_trace.get("plan", {})
	_check("REDUCED unlock uses at most ten gentle particles", str(reduced_plan.get("mode", "")) == "REDUCED" and int(reduced_plan.get("spark_overrides", {}).get("amount", 99)) <= 10 and float(reduced_plan.get("spark_overrides", {}).get("speed", 999.0)) <= 35.0 and not reduced_plan.get("spark_overrides", {}).get("presets", []).has("confetti"))
	await _capture("reduced_island_unlock_720x1280", Vector2i(720, 1280))
	await _set_viewport_size(Vector2i(720, 1440))
	await _capture("reduced_island_unlock_720x1440", Vector2i(720, 1440))
	await _settle(0.52)
	_check("REDUCED unlock color restores exactly", not bridge.get_color_lifecycle_diagnostics().is_empty() and bool(bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))
	max_active_particles = maxi(max_active_particles, bridge._active_spark_particle_count())
	_check("all observed active Spark particles stay under global 48", max_active_particles <= 48)
	bridge.set_production_dispatch_enabled(false)
	var plugin_off_dispatch_count := bridge.dispatch_count
	var plugin_off_no_op_count := bridge.no_op_count
	var plugin_off_lifecycle_count := bridge.get_color_lifecycle_diagnostics().size()
	var locked_selection_before: String = world_map.selected_island_id
	_check("plugin-off keeps locked island navigation blocked", not world_map.is_entry_selectable("final_island") and not world_map.select_island("final_island") and world_map.selected_island_id == locked_selection_before)
	world_map._feedback_service.request_semantic("island_unlock", {
		"island_id": NEXT_ISLAND_ID,
		"new_transition": true,
		"presentation_target": world_map.get_entry(NEXT_ISLAND_ID).get_node("IslandArt"),
	}, "fixture-plugin-off-island-unlock", {"source": "m26-002-plugin-off-fallback"})
	await _frames(3)
	var plugin_off_trace := _last_trace(bridge, "island_unlock")
	_check("plugin-off semantic request safely no-ops without changing campaign navigation", bridge.dispatch_count == plugin_off_dispatch_count and bridge.no_op_count == plugin_off_no_op_count and bridge.get_color_lifecycle_diagnostics().size() == plugin_off_lifecycle_count and str(plugin_off_trace.get("dispatch_gate", "")) == "production_dispatch_disabled" and navigation.get_current_view() == navigation.VIEW_WORLD_MAP and manager.is_island_unlocked(NEXT_ISLAND_ID))
	var debug_transition_state := {
		"navigation_pending": navigation._pending_campaign_transition.duplicate(true),
		"island_completion_service_counts": island_map._feedback_service.semantic_counts.duplicate(true),
		"island_completion_trace": island_trace,
		"world_pending": world_map._pending_campaign_transition.duplicate(true),
		"world_entry_count": world_map.get_entry_count(),
		"world_unlock_service_counts": world_map._feedback_service.semantic_counts.duplicate(true),
		"world_unlock_trace": unlock_trace,
	}

	var persisted_state: Dictionary = manager.get_progression_state()
	navigation.queue_free()
	await _frames(5)
	var restarted_manager := CAMPAIGN_SCRIPT.new()
	_check("persisted campaign fixture reloads", restarted_manager.configure(database, persisted_state))
	var restarted_navigation = NAVIGATION_SCENE.instantiate()
	restarted_navigation.configure_campaign(database, restarted_manager)
	get_root().add_child(restarted_navigation)
	await _frames(6)
	_check("restart renders already-unlocked island without replay", restarted_navigation.show_world_map())
	await _frames(6)
	var restarted_world_map = restarted_navigation.get_world_map()
	_check("restart has no synthetic unlock request", restarted_world_map._feedback_service.semantic_counts.is_empty() and restarted_world_map._presentation_bridge.dispatch_count == 0 and restarted_world_map.get_entry_state(NEXT_ISLAND_ID) == "OPEN")
	restarted_navigation.queue_free()
	await _frames(4)
	var report := {
		"work_item": "BCM-M26-002",
		"route": "explicitly fixture-seeded campaign save through production gameplay session terminal bridge",
		"renderer": "running Godot project viewport with GL Compatibility",
		"requested_sizes": [[720, 1280], [720, 1440]],
		"captures": captures,
		"failures": failures,
		"max_observed_active_spark_particles": max_active_particles,
		"debug_transition_state": debug_transition_state,
		"owner_visual_acceptance": "PENDING_OWNER_REVIEW",
		"human_played_full_campaign": false,
	}
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		failures.append("evidence report could not be written")
	else:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	print("M26_002_CAMPAIGN_MAP_RESULT=%s captures=%d failures=%d max_particles=%d" % ["PASS" if failures.is_empty() else "FAIL", captures.size(), failures.size(), max_active_particles])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)

