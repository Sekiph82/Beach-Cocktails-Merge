extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const INTERNAL_WALL_LIMIT_SEC := 8.0
const BACKTRACKING_ATTEMPT_CAP := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_path := ""
	var progress_path := ""
	var island_id := ""
	var level_id := 0
	var seed_value := 0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--r14-output="):
			output_path = argument.trim_prefix("--r14-output=")
		elif argument.begins_with("--r14-progress="):
			progress_path = argument.trim_prefix("--r14-progress=")
		elif argument.begins_with("--r14-island="):
			island_id = argument.trim_prefix("--r14-island=")
		elif argument.begins_with("--r14-level="):
			level_id = int(argument.trim_prefix("--r14-level="))
		elif argument.begins_with("--r14-seed="):
			seed_value = int(argument.trim_prefix("--r14-seed="))
	if output_path.is_empty() or progress_path.is_empty() or island_id.is_empty() or level_id <= 0 or seed_value <= 0:
		push_error("R14 probe requires output, progress, island, level, and seed arguments")
		quit(2)
		return

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(
		DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
		DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS,
		DATABASE_SCRIPT.ValidationMode.FULL
	):
		_write_json(output_path, {"status": "ERROR", "reason": "CAMPAIGN_LOAD_FAILED", "detail": database.get_last_error()})
		quit(1)
		return
	var definition: Dictionary = database.get_level(island_id, level_id)
	if definition.is_empty():
		_write_json(output_path, {"status": "ERROR", "reason": "LEVEL_DEFINITION_MISSING"})
		quit(1)
		return

	var normal_t := int(ceil(float(MODEL_SCRIPT.normal_objective_cost(definition)) / 4.0))
	var legal_shot_ceiling := 4 * normal_t
	var physics_frame_ceiling := legal_shot_ceiling * 60 + 90
	var initial := {
		"schema_version": 1,
		"work_item": "BCM-M34-R14-003",
		"status": "CASE_RUNNING",
		"classification": "UNKNOWN_TIMEOUT",
		"case": {"island_id": island_id, "level_id": level_id, "seed": seed_value},
		"normal_T": normal_t,
		"legal_shot_ceiling_4T": legal_shot_ceiling,
		"physics_frame_ceiling": physics_frame_ceiling,
		"internal_wall_limit_sec": INTERNAL_WALL_LIMIT_SEC,
		"backtracking_attempt_cap": BACKTRACKING_ATTEMPT_CAP,
		"backtracking_attempts_used": 0,
		"candidate_strategy": "single deterministic MERGE_AWARE_V01 candidate; no backtracking implemented",
		"partial_reason": "CASE_STARTED_NO_RESULT_YET"
	}
	if not _write_json(progress_path, initial):
		push_error("Unable to write initial durable R14 progress")
		quit(1)
		return

	var harness = HARNESS_SCRIPT.new(get_root())
	harness.set_time_scale(1.0)
	var started_usec := Time.get_ticks_usec()
	var result: Dictionary = await harness.run_trial(
		database,
		island_id,
		level_id,
		seed_value,
		[],
		HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
		legal_shot_ceiling,
		true,
		true,
		INTERNAL_WALL_LIMIT_SEC,
		"",
		true,
		true,
		true,
		physics_frame_ceiling
	)
	var elapsed_usec := Time.get_ticks_usec() - started_usec
	var actions: Array = result.get("action_log", [])
	var legal_shots := int(result.get("shot_count", 0)) <= legal_shot_ceiling
	var win_candidate := bool(result.get("normal_objective_complete", false)) and str(result.get("outcome", "")) == HARNESS_SCRIPT.OUTCOME_COMPLETED and legal_shots
	var vip_definition = definition.get("vip")
	var vip_enabled := vip_definition is Dictionary and bool(vip_definition.get("enabled", false))
	var record := {
		"schema_version": 1,
		"work_item": "BCM-M34-R14-003",
		"status": "CASE_COMPLETE",
		"classification": "LEGAL_PATH_NOT_FOUND_WITHIN_BUDGET",
		"island_id": island_id,
		"level_id": level_id,
		"seed": seed_value,
		"policy": HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
		"normal_T": normal_t,
		"expected_spawn_count_estimate": MODEL_SCRIPT.expected_spawn_count(MODEL_SCRIPT.normal_objective_cost(definition)),
		"legal_shot_ceiling_4T": legal_shot_ceiling,
		"shots_used": int(result.get("shot_count", 0)),
		"shots_legal": legal_shots,
		"physics_frame_ceiling": physics_frame_ceiling,
		"physics_frames_observed": int(result.get("profile", {}).get("frame_count", 0)),
		"internal_wall_limit_sec": INTERNAL_WALL_LIMIT_SEC,
		"elapsed_wall_usec": elapsed_usec,
		"normal_objective_complete": bool(result.get("normal_objective_complete", false)),
		"vip_enabled_optional": vip_enabled,
		"vip_complete": bool(result.get("vip_complete", false)),
		"outcome": str(result.get("outcome", "")),
		"terminal_reason": str(result.get("terminal_reason", "")),
		"merge_count": int(result.get("merge_count", 0)),
		"contact_count": int(result.get("contact_count", 0)),
		"peak_live_drinks": int(result.get("peak_live_drinks", 0)),
		"peak_board_occupancy": float(result.get("peak_board_occupancy", 0.0)),
		"action_count": actions.size(),
		"action_log_sha256": _sha256(JSON.stringify(actions)),
		"action_log": actions,
		"path_provenance": "production ShotController and full Godot physics; deterministic seed and policy; candidate action log is not a proof until exact replay matches",
		"backtracking_attempt_cap": BACKTRACKING_ATTEMPT_CAP,
		"backtracking_attempts_used": 0,
		"profile": result.get("profile", {}).duplicate(true),
	}
	if win_candidate:
		var replay_started_usec := Time.get_ticks_usec()
		var replay: Dictionary = await harness.run_trial(
			database,
			island_id,
			level_id,
			seed_value,
			actions,
			HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
			legal_shot_ceiling,
			true,
			true,
			INTERNAL_WALL_LIMIT_SEC,
			"",
			true,
			true,
			true,
			physics_frame_ceiling
		)
		var replay_actions: Array = replay.get("action_log", [])
		var replay_ok := str(replay.get("outcome", "")) == HARNESS_SCRIPT.OUTCOME_COMPLETED and bool(replay.get("normal_objective_complete", false)) and replay_actions == actions and int(replay.get("shot_count", 0)) <= legal_shot_ceiling
		record["replay_wall_usec"] = Time.get_ticks_usec() - replay_started_usec
		record["replay_outcome"] = str(replay.get("outcome", ""))
		record["replay_terminal_reason"] = str(replay.get("terminal_reason", ""))
		record["replay_action_log_sha256"] = _sha256(JSON.stringify(replay_actions))
		record["replay_identical"] = replay_ok
		record["classification"] = "WIN_PROVEN" if replay_ok else "ERROR"
		record["terminal_reason"] = "EXACT_ACTION_REPLAY_CONFIRMED" if replay_ok else "WIN_CANDIDATE_REPLAY_MISMATCH"
	if not legal_shots:
		record["classification"] = "ERROR"
		record["terminal_reason"] = "LEGAL_SHOT_CEILING_EXCEEDED"
	elif not ["", "MOVE_BUDGET_EXHAUSTED", "PER_LEVEL_SHOT_BUDGET", "PHYSICS_FRAME_BUDGET", "PER_LEVEL_WALL_BUDGET", "TABLE_DANGER", "DANGER_LINE", "TIME_LIMIT"].has(str(result.get("terminal_reason", ""))):
		record["classification"] = "ERROR"
		record["terminal_reason"] = "UNEXPECTED_TERMINAL_REASON:%s" % str(result.get("terminal_reason", ""))

	_write_json(output_path, record)
	_write_json(progress_path, record)
	print("M34_R14_CASE_RESULT island=%s level=%d classification=%s shots=%d/%d frames=%d/%d merges=%d" % [
		island_id, level_id, str(record["classification"]), int(record["shots_used"]), legal_shot_ceiling,
		int(record["physics_frames_observed"]), physics_frame_ceiling, int(record["merge_count"]),
	])
	quit(0 if str(record["classification"]) != "ERROR" else 1)


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "\t") + "\n")
	file.flush()
	file.close()
	return true


func _sha256(value: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(value.to_utf8_buffer())
	return context.finish().hex_encode()
