extends SceneTree

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-002/M26-reward-primary"
const REPORT_PATH := EVIDENCE_DIR + "/m26_003_reward_primary_feedback.json"

var failures: Array[String] = []
var captures: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M26_003_REWARD_CTA PASS: %s" % label)
	else:
		failures.append(label)
		print("M26_003_REWARD_CTA FAIL: %s" % label)


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
	_check("real project viewport is %dx%d" % [size.x, size.y], get_root().get_viewport().get_visible_rect().size == Vector2(size))


func _capture(label: String, size: Vector2i) -> void:
	await _frames(2)
	if DisplayServer.get_name() == "headless":
		return
	var image := get_root().get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE_DIR, label]
	var saved := not image.is_empty() and image.save_png(ProjectSettings.globalize_path(path)) == OK
	_check("real GL framebuffer saved: %s" % label, saved)
	captures.append({"label": label, "path": path, "width": image.get_width(), "height": image.get_height(), "renderer": "running_project_viewport"})
	_check("capture is %dx%d" % [size.x, size.y], image.get_width() == size.x and image.get_height() == size.y)


func _start_session_and_win(navigation) -> Dictionary:
	var map = navigation.get_island_map()
	if not is_instance_valid(map):
		navigation.show_island_map("sunny_cove")
		await _frames(4)
		map = navigation.get_island_map()
	map.select_level(1)
	await _frames(4)
	var session = navigation._session_bridge
	session.mark_gameplay_ready()
	var remaining: Dictionary = session.get_objective_state().get("normal_remaining", {})
	for level_value in remaining.keys():
		var quantity := int(remaining[level_value])
		if quantity > 0:
			session.record_to_go_delivery(int(level_value), quantity, "m26-003-fixture-%s" % str(level_value), 800)
	await _frames(7)
	return session.get_terminal_result()


func _last_trace(bridge, kind: String) -> Dictionary:
	var traces: Array[Dictionary] = bridge.get_visual_diagnostic_trace()
	for index in range(traces.size() - 1, -1, -1):
		if str(traces[index].get("kind", "")) == kind:
			return traces[index]
	return {}


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	await _set_viewport_size(Vector2i(720, 1280))
	var shell = SHELL_SCENE.instantiate()
	get_root().add_child(shell)
	await _frames(5)
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	# Isolate this probe from settings left by earlier runs in the sandbox profile.
	shell.set_setting("reduced_motion", false)
	var navigation = shell.get_campaign_navigation()
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign data loads", database.load_canonical())
	var manager := CAMPAIGN_SCRIPT.new()
	var state := {"schema_version": 2, "unlocked_islands": ["sunny_cove"], "islands": {"sunny_cove": {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}}, "coins": 0, "boosters": {}, "reward_ledger": []}
	_check("explicit test fixture configures through production navigation", manager.configure(database, state) and navigation.configure_campaign(database, manager))
	var menu_controls: Dictionary = shell.get_menu_controls()
	var play_button: TextureButton = menu_controls.get("play")
	var settings_button: TextureButton = menu_controls.get("settings")
	var navigation_starts: Array[Dictionary] = []
	navigation.gameplay_session_started.connect(func(configuration: Dictionary) -> void: navigation_starts.append(configuration))
	_check("Home PLAY is the only whitelisted main-menu CTA target", play_button.is_in_group("presentation_effect_target") and not settings_button.is_in_group("presentation_effect_target"))
	var world_service: FeedbackService = navigation.get_world_map()._feedback_service
	var world_bridge: PresentationFeedbackBridge = navigation.get_world_map()._presentation_bridge
	var dispatch_before_negative := world_bridge.dispatch_count
	_check("generic SETTINGS action is rejected before semantic dispatch", not navigation.emit_primary_ui_feedback("SETTINGS", settings_button) and world_bridge.dispatch_count == dispatch_before_negative)
	_check("PLAY starts one production gameplay session", shell.press_play_continue() and navigation_starts.size() == 1 and navigation.get_gameplay_instance_count() == 1)
	await _frames(5)
	var play_trace := _last_trace(world_bridge, "ui_primary")
	_check("PLAY visual cue uses GameFeelFlow through the whitelist bridge", not play_trace.is_empty() and str(play_trace.get("payload", {}).get("action", "")) == "PLAY" and str(play_trace.get("gff_call", {}).get("effect", "")) == "color")
	var play_plan: Dictionary = play_trace.get("plan", {})
	_check("PLAY cue lasts at most 0.10 seconds and requests no particles", float(play_plan.get("gff_params", {}).get("duration", 1.0)) <= 0.10 and not play_plan.has("spark_preset"))
	var play_taps := int(world_service.semantic_counts.get("ui_primary", 0))
	_check("generic settings and map controls do not create tap-particle cues", not navigation.emit_primary_ui_feedback("PLAY", settings_button) and int(world_service.semantic_counts.get("ui_primary", 0)) == play_taps)
	await _capture("full_play_cta_720x1280", Vector2i(720, 1280))
	await _settle(0.16)
	_check("PLAY color restores exactly", not world_bridge.get_color_lifecycle_diagnostics().is_empty() and bool(world_bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))

	var terminal := await _start_session_and_win(navigation)
	_check("fixture WIN uses the production session terminal path", terminal.get("outcome", "") == "WIN" and terminal.get("island_id", "") == "sunny_cove")
	await _frames(8)
	var overlay = navigation.get_result_feedback_overlay()
	_check("Results shows NEXT LEVEL from authoritative next-level availability", overlay.visible and overlay.get_visible_actions().has("NEXT_LEVEL"))
	var reward_trace := _last_trace(world_bridge, "reward_granted")
	_check("new ledger grant dispatches one reward notification", not reward_trace.is_empty() and int(world_service.semantic_counts.get("reward_granted", 0)) == 1 and bool(reward_trace.get("payload", {}).get("newly_granted", false)))
	var reward_plan: Dictionary = reward_trace.get("plan", {})
	_check("FULL reward emphasis stays within five gentle particles", int(reward_plan.get("spark_overrides", {}).get("amount", 0)) <= 5 and float(reward_plan.get("spark_overrides", {}).get("speed", 999.0)) <= 35.0 and float(reward_plan.get("spark_overrides", {}).get("lifetime", 9.0)) <= 0.30)
	var grant_duplicate_before := int(world_service.semantic_counts.get("reward_granted", 0))
	navigation._emit_new_reward_feedback(terminal)
	_check("the same reward ledger ID is suppressed on duplicate terminal presentation", int(world_service.semantic_counts.get("reward_granted", 0)) == grant_duplicate_before)
	await _set_viewport_size(Vector2i(720, 1440))
	await _capture("full_reward_results_720x1440", Vector2i(720, 1440))
	var next_target: CanvasItem = overlay.get_action_presentation_target("NEXT_LEVEL")
	_check("only NEXT LEVEL and RETRY result buttons are eligible CTA targets", is_instance_valid(next_target) and next_target.is_in_group("presentation_effect_target") and not overlay.get_action_presentation_target("ISLAND_MAP"))
	var next_before := navigation_starts.size()
	var next_action_accepted: bool = overlay.trigger_action("NEXT_LEVEL")
	await _frames(5)
	_check("NEXT action transitions exactly once", next_action_accepted and navigation_starts.size() == next_before + 1 and navigation.get_current_view() == navigation.VIEW_GAMEPLAY)
	_check("NEXT event is recorded once and has no particles", int(world_service.semantic_counts.get("ui_primary", 0)) == play_taps + 1 and not _last_trace(world_bridge, "ui_primary").get("plan", {}).has("spark_preset"))
	_check("a second NEXT action cannot invoke navigation", not overlay.trigger_action("NEXT_LEVEL") and navigation_starts.size() == next_before + 1)

	var session = navigation._session_bridge
	session.resolve_lose("M26_003_FIXTURE_LOSE")
	await _frames(8)
	overlay = navigation.get_result_feedback_overlay()
	_check("LOSE exposes the explicit RETRY action", overlay.visible and overlay.get_visible_actions().has("RETRY"))
	var retry_target: CanvasItem = overlay.get_action_presentation_target("RETRY")
	_check("RETRY button is an approved visual target", is_instance_valid(retry_target) and retry_target.is_in_group("presentation_effect_target"))
	var retry_start_count := navigation_starts.size()
	var retry_action_accepted: bool = overlay.trigger_action("RETRY")
	await _frames(5)
	_check("RETRY action restarts the same session exactly once", retry_action_accepted and navigation_starts.size() == retry_start_count + 1 and navigation._session_bridge.active_level_id == 2)
	_check("RETRY cue does not emit particles or duplicate navigation", int(world_service.semantic_counts.get("ui_primary", 0)) == play_taps + 2 and not _last_trace(world_bridge, "ui_primary").get("plan", {}).has("spark_preset") and not overlay.trigger_action("RETRY"))
	await _set_viewport_size(Vector2i(720, 1280))
	await _capture("full_retry_cta_720x1280", Vector2i(720, 1280))

	var plugin_off_session = navigation._session_bridge
	plugin_off_session.resolve_lose("M26_003_PLUGIN_OFF_FIXTURE")
	await _frames(7)
	overlay = navigation.get_result_feedback_overlay()
	var plugin_off_starts := navigation_starts.size()
	world_bridge.set_production_dispatch_enabled(false)
	var plugin_off_retry_accepted: bool = overlay.trigger_action("RETRY")
	await _frames(5)
	_check("plugin-off RETRY preserves navigation and save authority", plugin_off_retry_accepted and navigation_starts.size() == plugin_off_starts + 1 and navigation._session_bridge.active_level_id == 2)
	_check("plugin-off RETRY remains safe without presentation output", world_bridge.dispatch_count == dispatch_before_negative + 4)
	world_bridge.set_production_dispatch_enabled(true)

	shell.set_setting("reduced_motion", true)
	_check("REDUCED mode flows through the production navigation settings boundary", world_bridge._presentation_mode == "REDUCED")
	navigation._session_bridge.resolve_lose("M26_003_REDUCED_REWARD_FIXTURE")
	await _frames(7)
	overlay = navigation.get_result_feedback_overlay()
	_check("REDUCED Results keeps its explicit RETRY action available", overlay.visible and overlay.get_visible_actions().has("RETRY"))
	var reduced_retry_accepted: bool = overlay.trigger_action("RETRY")
	await _frames(5)
	_check("REDUCED RETRY still invokes navigation once without particle cues", reduced_retry_accepted and navigation._session_bridge.active_level_id == 2 and not _last_trace(world_bridge, "ui_primary").get("plan", {}).has("spark_preset"))
	navigation._session_bridge.resolve_lose("M26_003_REDUCED_REWARD_NOTIFICATION_FIXTURE")
	await _frames(7)
	overlay = navigation.get_result_feedback_overlay()
	var reduced_reward: Dictionary = navigation.economy.grant_reward("fixture:reduced-reward", {"coins": 1})
	world_service.request_semantic("reward_granted", {"reward_id": "fixture:reduced-reward", "newly_granted": bool(reduced_reward.get("granted", false)), "presentation_target": overlay.get_reward_presentation_target()}, "reward-granted:fixture:reduced-reward", {"source": "m26-003-explicit-reduced-fixture"})
	await _frames(5)
	var reduced_trace := _last_trace(world_bridge, "reward_granted")
	_check("REDUCED reward is immediate, calm, and particle-free", bool(reduced_reward.get("granted", false)) and str(reduced_trace.get("plan", {}).get("mode", "")) == "REDUCED" and float(reduced_trace.get("plan", {}).get("gff_params", {}).get("duration", 1.0)) <= 0.10 and not reduced_trace.get("plan", {}).has("spark_preset"))
	await _capture("reduced_reward_cta_720x1280", Vector2i(720, 1280))
	await _set_viewport_size(Vector2i(720, 1440))
	await _capture("reduced_reward_cta_720x1440", Vector2i(720, 1440))
	await _settle(0.30)
	_check("REDUCED reward color restores exactly", not world_bridge.get_color_lifecycle_diagnostics().is_empty() and bool(world_bridge.get_color_lifecycle_diagnostics().back().get("restored_exactly", false)))

	var final_semantic_counts: Dictionary = world_service.semantic_counts.duplicate(true)
	shell.queue_free()
	await _frames(5)
	var report := {"work_item": "BCM-M26-003", "route": "production ApplicationShell, CampaignNavigationController, CampaignFeedbackOverlay, CampaignManager and GameEconomy with explicitly fixture-driven session", "renderer": "running Godot project viewport with GL Compatibility", "requested_sizes": [[720, 1280], [720, 1440]], "captures": captures, "play_next_retry_invocations": navigation_starts.size(), "semantic_counts": final_semantic_counts, "reduced_reward_grant": reduced_reward, "reduced_reward_trace": reduced_trace, "failures": failures, "human_played_campaign": false}
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		failures.append("evidence report could not be written")
	else:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	print("M26_003_REWARD_CTA_RESULT=%s captures=%d failures=%d" % ["PASS" if failures.is_empty() else "FAIL", captures.size(), failures.size()])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)

