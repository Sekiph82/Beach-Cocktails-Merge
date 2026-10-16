extends SceneTree

const STUDIO_SCENE := preload("res://scenes/debug/LevelQualificationStudio.tscn")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_R18_STUDIO PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_R18_STUDIO FAIL: %s" % label)


func _run() -> void:
	var studio := STUDIO_SCENE.instantiate()
	root.add_child(studio)
	await process_frame
	await process_frame
	_check("dedicated debug entrypoint loads under the isolated R18 profile", studio._isolation_error.is_empty())
	if not studio._isolation_error.is_empty():
		_finish()
		return
	var desktop_layout: Dictionary = studio.debug_layout_snapshot(Vector2(1440, 960))
	var desktop_game: Rect2 = desktop_layout.get("game_rect", Rect2())
	var desktop_panel: Rect2 = desktop_layout.get("panel_rect", Rect2())
	_check("desktop layout keeps an aspect-correct portrait preview beside a full-height inspector", desktop_layout.get("mode", "") == "DESKTOP_SIDEBAR" and is_equal_approx(desktop_game.size.x / desktop_game.size.y, 720.0 / 1280.0) and desktop_panel.position.x >= desktop_game.end.x and is_equal_approx(desktop_panel.position.y, desktop_game.position.y) and is_equal_approx(desktop_panel.size.y, desktop_game.size.y) and desktop_panel.end.y <= 960.0)
	var portrait_layout: Dictionary = studio.debug_layout_snapshot(Vector2(720, 1280))
	var portrait_panel: Rect2 = portrait_layout.get("panel_rect", Rect2())
	_check("portrait fallback wraps controls in a vertical-only scroll panel with no horizontal overflow", portrait_layout.get("mode", "") == "PORTRAIT_SCROLL_OVERLAY" and bool(portrait_layout.get("panel_vertical_scroll_enabled", false)) and bool(portrait_layout.get("panel_horizontal_scroll_disabled", false)) and bool(portrait_layout.get("selector_wrap_enabled", false)) and bool(portrait_layout.get("preset_wrap_enabled", false)) and bool(portrait_layout.get("action_wrap_enabled", false)) and portrait_panel.position.x >= 0.0 and portrait_panel.end.x <= 720.0 and portrait_panel.end.y <= 1280.0)
	_check("studio overlay draws above production UI while the preview remains a pointer target", int(portrait_layout.get("overlay_layer", -1)) > 0 and bool(portrait_layout.get("game_input_enabled", false)))
	studio._layout_for_size(studio.get_viewport_rect().size)
	_check("Studio starts UNTESTED without asserting a level result", studio.debug_get_snapshot().get("status", "") == "UNTESTED")
	_check("canonical selector exposes all ten islands and one hundred levels each", studio._island_ids.size() == 10 and studio._database.get_levels_for_island("tiki_island").size() == 100)
	var selection_count := 0
	for island_id in studio._island_ids:
		for level_id in range(1, 101):
			if studio.debug_select_case(island_id, level_id, 777):
				selection_count += 1
	_check("all 10 × 100 canonical island/level combinations are selectable", selection_count == 1000)
	_check("Studio-only controls stay outside the production campaign navigation tree", studio._navigation.find_child("QualificationStudioDock", true, false) == null and studio.find_child("QualificationStudioDock", true, false) == studio._dock)
	studio.debug_select_case("tiki_island", 10, 34116110)
	var world_map = studio._navigation.get_world_map()
	var sunny_entry: Control = world_map.get_entry("sunny_cove") as Control
	_check("Sunny Cove map target is visible and selectable for real mouse routing", is_instance_valid(sunny_entry) and world_map.is_entry_selectable("sunny_cove"))
	if is_instance_valid(sunny_entry):
		studio._dock.hide()
		_route_preview_click(studio, sunny_entry.get_global_rect().get_center())
		await process_frame
		_check("real mouse input routed through the portrait preview opens Sunny Cove map", studio._navigation.get_current_view() == CampaignNavigationController.VIEW_ISLAND_MAP and studio._navigation.get_active_island_id() == "sunny_cove")
		studio._navigation.show_world_map()
		studio._dock.show()
		await process_frame
	_check("Tiki L10 selection binds canonical T=24 and exact normal 4T cap=96", studio.debug_select_case("tiki_island", 10, 34116110) and int(studio.debug_get_snapshot().get("normal_theoretical_shots_T", 0)) == 24 and int(studio.debug_get_snapshot().get("normal_4t_cap", 0)) == 96 and int(studio.debug_get_snapshot().get("stored_move_limit", 0)) == 96)
	_check("Tiki L30 diagnostic preset binds canonical T=32 and exact normal 4T cap=128", studio.debug_select_case("tiki_island", 30, 34116130) and int(studio.debug_get_snapshot().get("normal_theoretical_shots_T", 0)) == 32 and int(studio.debug_get_snapshot().get("normal_4t_cap", 0)) == 128 and int(studio.debug_get_snapshot().get("stored_move_limit", 0)) == 128)
	studio.debug_select_case("tiki_island", 10, 34116110)
	var save_path := SAVE_SCRIPT.DEFAULT_SAVE_PATH
	var backup_path := SAVE_SCRIPT.DEFAULT_BACKUP_PATH
	var legacy_path := SAVE_SCRIPT.DEFAULT_LEGACY_PATH
	var save_existed_before := FileAccess.file_exists(save_path) or FileAccess.file_exists(backup_path) or FileAccess.file_exists(legacy_path)
	_check("save and energy persistence are detached before session start", not studio._navigation._persistence_enabled and studio._navigation.economy == null and studio._navigation.campaign_manager.economy == null and studio._navigation.get_session_bridge().economy == null)
	_check("production Tiki L10 session starts through CampaignNavigationController with its diagnostic seed injected", studio.debug_start_selected() and Engine.has_meta("bcm_m34_r18_seed") and int(Engine.get_meta("bcm_m34_r18_seed")) == 34116110)
	await process_frame
	await process_frame
	var gameplay: GameManager = studio._active_gameplay
	_check("session uses the production Main scene, GameManager, and ShotController", is_instance_valid(gameplay) and is_instance_valid(gameplay.shot_controller) and studio._navigation.get_current_view() == CampaignNavigationController.VIEW_GAMEPLAY)
	if is_instance_valid(gameplay):
		var held: Drink = gameplay.shot_controller.get("_current_drink")
		if is_instance_valid(held):
			_route_preview_click(studio, held.global_position)
		await process_frame
		await process_frame
	var snapshot: Dictionary = studio.debug_get_snapshot()
	_check("actual ShotController action is captured with a stable action ID and seed", snapshot.get("shots", []).size() == 1 and str(snapshot.get("shots", [])[0].get("action_id", "")).begins_with("SHOT-") and int(snapshot.get("shots", [])[0].get("seed", 0)) == 34116110 and _has_event(snapshot.get("timeline", []), "SHOT_FIRED"))
	studio.debug_pause()
	await process_frame
	var frame_before_step := Engine.get_physics_frames()
	await studio.debug_step_once()
	var stepped_frames := Engine.get_physics_frames() - frame_before_step
	_check("pause and single-physics-step controls operate while the dock remains responsive", paused and stepped_frames == 1)
	studio.debug_resume()
	_check("resume restores production physics", not paused)
	var exported_first: Dictionary = await studio.debug_export_attempt(false)
	var first_report_path := str(exported_first.get("report_path", ""))
	var first_hash := _sha256(FileAccess.get_file_as_bytes(first_report_path)) if not first_report_path.is_empty() else ""
	var exported_second: Dictionary = await studio.debug_export_attempt(false)
	var manifest_lines := FileAccess.get_file_as_string(str(exported_second.get("manifest_path", ""))).strip_edges().split("\n", false)
	var first_new_manifest: Dictionary = JSON.parse_string(manifest_lines[manifest_lines.size() - 2]) if manifest_lines.size() >= 2 else {}
	var second_new_manifest: Dictionary = JSON.parse_string(manifest_lines[manifest_lines.size() - 1]) if not manifest_lines.is_empty() else {}
	_check("JSON export appends unique create-new packages and leaves earlier report bytes unchanged", bool(exported_first.get("ok", false)) and bool(exported_second.get("ok", false)) and str(exported_first.get("export_id", "")) != str(exported_second.get("export_id", "")) and first_hash == _sha256(FileAccess.get_file_as_bytes(first_report_path)) and manifest_lines.size() >= 2 and str(first_new_manifest.get("export_id", "")) == str(exported_first.get("export_id", "")) and str(second_new_manifest.get("export_id", "")) == str(exported_second.get("export_id", "")) and str(first_new_manifest.get("report_sha256", "")) == first_hash)
	var exported_json: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(first_report_path))
	_check("export includes R17 immutable references and honest normal 4T definition", exported_json.get("r17_immutable_evidence_refs", []).size() >= 5 and int(exported_json.get("normal_4t_legal_move_cap", 0)) == 96 and str(exported_json.get("status", "")) == "IN_PROGRESS")
	var old_attempt_id := str(snapshot.get("attempt_id", ""))
	_check("seed reset starts a distinct attempt with the same selected seed", studio.debug_start_selected() and str(studio.debug_get_snapshot().get("attempt_id", "")) != old_attempt_id and int(studio.debug_get_snapshot().get("seed", 0)) == 34116110)
	var save_still_absent := not FileAccess.file_exists(save_path) and not FileAccess.file_exists(backup_path) and not FileAccess.file_exists(legacy_path)
	_check("debug run and reset do not create campaign save, backup, or legacy save files", not save_existed_before and save_still_absent)
	paused = false
	studio.queue_free()
	await process_frame
	_finish()



func _route_preview_click(studio: Node, subviewport_position: Vector2) -> void:
	var container: Control = studio._game_container
	var viewport_size := Vector2(720.0, 1280.0)
	var outer_position := container.position + Vector2(subviewport_position.x * container.size.x / viewport_size.x, subviewport_position.y * container.size.y / viewport_size.y)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = outer_position
	studio.get_viewport().push_input(press, true)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = outer_position
	studio.get_viewport().push_input(release, true)
	await process_frame


func _has_event(events: Array, name: String) -> bool:
	for event in events:
		if str(event.get("kind", "")) == name:
			return true
	return false


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _finish() -> void:
	if failures.is_empty():
		print("M34_R18_STUDIO_RESULT=PASS")
		quit(0)
	else:
		print("M34_R18_STUDIO_RESULT=FAIL failures=%d details=%s" % [failures.size(), ";".join(failures)])
		quit(1)
