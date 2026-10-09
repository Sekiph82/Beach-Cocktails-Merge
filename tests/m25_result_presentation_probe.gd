extends SceneTree

const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const SERVICE_SCRIPT := preload("res://scripts/feedback_service.gd")
const OVERLAY_SCRIPT := preload("res://scripts/campaign/campaign_feedback_overlay.gd")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const REPORT_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MASTER-V01/m25_result_presentation_probe.json"
const RENDER_DIR := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MASTER-V01/rendered_synthetic"

var checks := 0
var failures: Array[String] = []
var captures: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	checks += 1
	if not condition:
		failures.append(label)
	print("M25_RESULT_PRESENTATION %s: %s" % ["PASS" if condition else "FAIL", label])


func _run() -> void:
	var planner := BRIDGE_SCRIPT.new()
	var win := planner._result_presentation_plan("game_success", "FULL", {"stars": 1})
	var mastery := planner._result_presentation_plan("game_success", "FULL", {"stars": 3})
	var first_clear := planner._result_presentation_plan("game_success", "FULL", {"stars": 3, "progression": {"first_clear": true}})
	var reward := planner._result_presentation_plan("game_success", "FULL", {"progression": {"first_clear": true}, "economy": {"grants": [{"granted": true, "reward_id": "new"}]}})
	var reduced_win := planner._result_presentation_plan("game_success", "REDUCED", {"stars": 3})
	var lose := planner._result_presentation_plan("game_fail", "FULL", {})
	var reduced_lose := planner._result_presentation_plan("game_fail", "REDUCED", {})
	_check("ordinary WIN uses a presentation-only color cue and bounded celebration", win.gff_effect == "color" and int(win.get("spark_overrides", {}).get("amount", 0)) == 30 and float(win.spark_overrides.lifetime) <= 1.20)
	_check("three-star MASTERY is the strongest non-meta tier and never exceeds 48", mastery.get("tier", "") == "MASTERY" and int(mastery.get("spark_overrides", {}).get("amount", 0)) == 48)
	_check("first-clear subsumes the ordinary mastery flourish", first_clear.get("tier", "") == "FIRST_CLEAR" and int(first_clear.get("spark_overrides", {}).get("amount", 0)) == 36)
	_check("new reward subsumes weaker celebration tiers", reward.get("tier", "") == "REWARD" and int(reward.get("spark_overrides", {}).get("amount", 0)) == 40)
	_check("REDUCED WIN is color-only with zero particles and <=0.12 seconds", reduced_win.gff_effect == "color" and not reduced_win.has("spark_preset") and float(reduced_win.gff_params.duration) <= 0.12)
	_check("LOSE has no Spark and stays within FULL/REDUCED time limits", not lose.has("spark_preset") and float(lose.gff_params.duration) <= 0.25 and float(reduced_lose.gff_params.duration) <= 0.10)
	_check("live result particle clamp accounts for any prior active particles", int(planner._result_presentation_plan("game_success", "FULL", {"stars": 3}).get("spark_overrides", {}).get("amount", 0)) <= 48)
	planner.free()
	var database = DATABASE_SCRIPT.new()
	var campaign = CAMPAIGN_SCRIPT.new()
	var database_loaded: bool = database.load_canonical()
	var campaign_ready: bool = database_loaded and campaign.configure(database, {})
	var first_clear_result: Dictionary = campaign.mark_level_completed("sunny_cove", 1, {"stars": 3, "score": 300}) if campaign_ready else {}
	var replay_result: Dictionary = campaign.mark_level_completed("sunny_cove", 1, {"stars": 3, "score": 300}) if campaign_ready else {}
	_check("progression classifies the initial completion as first-clear and replay as existing", bool(first_clear_result.get("first_clear", false)) and not bool(replay_result.get("first_clear", true)))
	campaign = null
	database = null

	var service := SERVICE_SCRIPT.new()
	var overlay := OVERLAY_SCRIPT.new()
	var bridge := BRIDGE_SCRIPT.new()
	service.name = "M25FeedbackService"
	root.add_child(overlay)
	root.add_child(service)
	service.add_child(bridge)
	bridge.configure(service, root)
	bridge.set_visual_diagnostics_enabled(true)
	bridge.set_production_dispatch_enabled(true)
	await process_frame
	if DisplayServer.get_name() != "headless":
		_capture("full_before")
	var original := {"session_serial": 77, "outcome": "WIN", "level_id": 1, "score": 300, "stars": 3, "progression": {"first_clear": true}, "economy": {"grants": []}}
	var requests: Array[Dictionary] = []
	service.semantic_requested.connect(func(request: Dictionary) -> void: requests.append(request.duplicate(true)))
	overlay.show_result(original)
	overlay.play_result_entrance(0.24)
	if DisplayServer.get_name() != "headless":
		_capture("full_event")
	_check("first terminal presentation semantic is accepted", service.emit_result_presentation(original, overlay.get_result_presentation_target()))
	await _settle_seconds(0.30)
	if DisplayServer.get_name() != "headless":
		_capture("full_settled")
	print("M25_RESULT_ALPHA_AFTER_FULL_FADE=%.4f" % overlay.modulate.a)
	print("M25_RESULT_ENTRANCE_DEBUG inside_tree=%s tween=%s elapsed=%.3f visible=%s" % [str(overlay.is_inside_tree()), str(overlay._result_entrance_tween.is_running() if overlay._result_entrance_tween != null else false), overlay._result_entrance_tween.get_total_elapsed_time() if overlay._result_entrance_tween != null else -1.0, str(overlay.visible)])
	_check("FULL WIN fade settles to a visible, fully opaque result", overlay.modulate.a >= 0.95)
	_check("production bridge invokes GFF and one bounded WIN Spark burst", bridge.dispatch_count == 1 and bridge._active_spark_particle_count() <= 48 and bridge._active_spark_particle_count() > 0)
	var duplicate_suppressed := not service.emit_result_presentation(original, overlay) and requests.size() == 1
	_check("duplicate terminal presentation semantic is suppressed", duplicate_suppressed)
	_check("presentation request preserves immutable result values and does not mutate source", int(requests[0].payload.score) == 300 and int(original.score) == 300 and not original.has("presentation_target"))
	var win_copy := original.duplicate(true)
	overlay.show_result(win_copy)
	_check("WIN copy, score, stars, reward text, and actions remain visible", overlay.visible and overlay.get_title_text() == "LEVEL COMPLETE" and overlay.get_body_text().contains("SCORE 300") and overlay.get_body_text().contains("★★★") and overlay.get_visible_actions().has("ISLAND_MAP"))
	_check("overlay result surface and visual children expose local allowlisted targets", overlay.get_result_presentation_targets().size() == 3)
	bridge.set_presentation_mode("REDUCED")
	var reduced_result := {"session_serial": 78, "outcome": "WIN", "score": 300, "stars": 3}
	overlay.show_result(reduced_result)
	overlay.play_result_entrance(0.10)
	_check("REDUCED semantic dispatch remains GFF-only", service.emit_result_presentation(reduced_result, overlay.get_result_presentation_target()))
	await _settle_seconds(0.20)
	if DisplayServer.get_name() != "headless":
		_capture("reduced_settled")
	_check("REDUCED dispatch leaves Spark pool empty", bridge.dispatch_count == 2 and get_root().get_node("Spark/SaltmireSparkPool").get_child_count() == 0)
	var lose_result := {"session_serial": 79, "outcome": "LOSE", "score": 10, "stars": 0, "level_id": 2}
	overlay.show_result(lose_result)
	_check("LOSE semantic dispatch is accepted", service.emit_result_presentation(lose_result, overlay.get_result_presentation_target()))
	await _settle_seconds(0.20)
	if DisplayServer.get_name() != "headless":
		_capture("lose_settled")
	_check("LOSE dispatch is subdued and adds no Spark emitter", bridge.dispatch_count == 3 and get_root().get_node("Spark/SaltmireSparkPool").get_child_count() == 0)
	overlay.hide_feedback()
	overlay.show_result(lose_result)
	_check("LOSE retains retry/map actions and unchanged result wording", overlay.visible and overlay.get_title_text() == "LEVEL FAILED" and overlay.get_visible_actions() == ["RETRY", "ISLAND_MAP"])
	var action_calls := [0]
	overlay.action_requested.connect(func(_action: String) -> void: action_calls[0] += 1)
	await process_frame
	var retry_button := overlay._actions.get_child(0) as Button
	var retry_rect_before := retry_button.get_global_rect()
	_check("Retry remains activatable while the failure result is presented", overlay.trigger_action("RETRY"))
	await process_frame
	_check("Retry action target stays sized and emits one action without hitbox movement", action_calls[0] == 1 and retry_button.get_global_rect() == retry_rect_before and retry_rect_before.size.x > 0.0 and retry_rect_before.size.y > 0.0)

	var report := {"checks": checks, "failures": failures, "production_semantic_duplicate_suppressed": duplicate_suppressed, "renderer": "Godot viewport when windowed; result is synthetic and not acceptance", "captures": captures}
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		failures.append("unable to write report")
	else:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	print("M25_RESULT_PRESENTATION_PROBE_RESULT=%s checks=%d failures=%d" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	bridge.set_production_dispatch_enabled(false)
	bridge.queue_free()
	service.queue_free()
	overlay.queue_free()
	get_root().get_node("Spark").clear()
	await process_frame
	await process_frame
	await _settle_seconds(1.30)
	quit(0 if failures.is_empty() else 1)


func _capture(label: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RENDER_DIR))
	var image := root.get_viewport().get_texture().get_image()
	if image == null:
		failures.append("viewport capture unavailable:%s" % label)
		return
	var path := "%s/%s.png" % [RENDER_DIR, label]
	var error := image.save_png(path)
	if error != OK:
		failures.append("viewport capture failed:%s:%s" % [label, error])
		return
	captures.append({"label": label, "path": path, "width": image.get_width(), "height": image.get_height(), "renderer": "running Godot project viewport", "synthetic_result_fixture": true})


func _settle_seconds(seconds: float) -> void:
	for _index in range(maxi(1, int(ceil(seconds * 60.0)))):
		await process_frame
