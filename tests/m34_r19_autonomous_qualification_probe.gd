extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const STUDIO_SCRIPT = preload("res://scripts/debug/level_qualification_studio.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_R19_PROBE PASS: %s" % label)
	else:
		_failures.append(label)
		print("M34_R19_PROBE FAIL: %s" % label)


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("canonical campaign validates all 1,000 island-level records", loaded and database._levels_by_key.size() == 1000)
	if not loaded:
		_finish()
		return
	var island_ids: Array = database.get_island_ids()
	var geometry_hashes: Dictionary = {}
	var geometry_pairs_valid := island_ids.size() == 10
	for island_id in island_ids:
		var island: Dictionary = database.get_island(str(island_id))
		var theme: Dictionary = island.get("theme", {})
		var surface_path := str(theme.get("gameplay_surface", ""))
		var profile_path := str(theme.get("playable_geometry_profile", ""))
		var surface_bytes := FileAccess.get_file_as_bytes(surface_path)
		var profile_text := FileAccess.get_file_as_string(profile_path)
		var profile: Variant = JSON.parse_string(profile_text)
		var surface_hash := _sha256_bytes(surface_bytes)
		if surface_bytes.is_empty() or not profile is Dictionary or str(profile.get("surface_sha256", "")) != surface_hash or str(profile.get("island_id", "")) != str(island_id):
			geometry_pairs_valid = false
		geometry_hashes[surface_hash] = true
	_check("each island resolves its own R04 gameplay surface and SHA-bound geometry profile", geometry_pairs_valid and geometry_hashes.size() == 10)

	var rects := [
		Rect2(Vector2.ZERO, Vector2(720.0, 1280.0)),
		Rect2(Vector2(16.0, 18.0), Vector2(405.0, 720.0)),
		Rect2(Vector2(485.0, 24.0), Vector2(720.0, 1280.0)),
		Rect2(Vector2(37.0, 41.0), Vector2(800.0, 1422.0)),
	]
	var mapping_valid := true
	var sample_points := [Vector2(0.0, 0.0), Vector2(360.0, 568.0), Vector2(719.0, 1279.0), Vector2(150.0, 1136.0)]
	for game_rect in rects:
		for game_point in sample_points:
			var outer := STUDIO_SCRIPT.game_viewport_to_outer_input(game_point, game_rect)
			var mapped := STUDIO_SCRIPT.outer_input_to_game_viewport(outer, game_rect)
			if mapped.distance_to(game_point) > 0.001:
				mapping_valid = false
	_check("desktop, canonical, and window-scaled pointer coordinates round-trip to the same 720x1280 production input points", mapping_valid)

	var harness = HARNESS_SCRIPT.new(root)
	var legal_lanes: Array[float] = [150.0, 220.0, 290.0, 360.0, 430.0, 500.0, 570.0]
	var observations: Array[Dictionary] = [
		{"level": 1, "x": 360.0, "y": 950.0, "instance_id": 1},
		{"level": 1, "x": 500.0, "y": 900.0, "instance_id": 2},
	]
	var baseline: Dictionary = harness.choose_r19_action_from_observations(1, observations, 2, legal_lanes, {})
	var repeated: Dictionary = harness.choose_r19_action_from_observations(1, observations, 2, legal_lanes, {})
	var cooled_feedback := {"360000": {"trials": 3, "objective_gain": 0, "merge_gain": 0, "contact_gain": 1, "no_progress": 3}}
	var adapted: Dictionary = harness.choose_r19_action_from_observations(1, observations, 2, legal_lanes, cooled_feedback)
	_check("feedback-guided bot is deterministic and avoids a repeatedly unproductive lane", baseline == repeated and float(adapted.get("x_position", 360.0)) != float(baseline.get("x_position", 360.0)) and str(adapted.get("decision_reason", "")).begins_with("feedback_"))

	var short_run: Dictionary = await harness.run_trial(
		database,
		"sunny_cove",
		1,
		34116001,
		[],
		HARNESS_SCRIPT.POLICY_R19_FEEDBACK_AWARE_V01,
		1,
		true,
		true,
		8.0,
		"",
		true,
		true,
		false,
		0,
		HARNESS_SCRIPT.DETERMINISM_TRACE_INTERVAL_FRAMES,
		"",
		{"work_item": "BCM-M34-R19_INPUT_CONTRACT"},
		true
	)
	var actions: Array = short_run.get("action_log", [])
	var actual_input_action: Dictionary = actions[0] if actions.size() == 1 else {}
	_check("bounded shot passes press/release through production ShotController input and records its projected launch point", actions.size() == 1 and str(actual_input_action.get("input_path", "")) == "ShotController._unhandled_input" and is_equal_approx(float(actual_input_action.get("requested_viewport_x", -1.0)), float(actual_input_action.get("fired_position", [])[0]) if actual_input_action.get("fired_position", []).size() == 2 else -2.0) and int(short_run.get("profile", {}).get("frame_count", 0)) > 0)
	_check("short production shot remains standard-FPS, time-scale 1, and within normal 4T", short_run.get("physics_mode", "") == "standard_fps_production_physics" and not bool(short_run.get("fixed_fps", true)) and is_equal_approx(float(short_run.get("time_scale", 0.0)), 1.0) and int(short_run.get("shot_count", 0)) <= int(short_run.get("normal_theoretical_shots_T", 0)) * 4)
	_finish()


func _sha256_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _finish() -> void:
	if _failures.is_empty():
		print("M34_R19_PROBE_RESULT=PASS")
		quit(0)
	else:
		print("M34_R19_PROBE_RESULT=FAIL failures=%d details=%s" % [_failures.size(), ";".join(_failures)])
		quit(1)
