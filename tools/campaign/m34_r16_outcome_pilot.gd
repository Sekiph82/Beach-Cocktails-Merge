extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const INTERNAL_WALL_LIMIT_SEC := 23.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_path := ""
	var progress_path := ""
	var island_id := ""
	var level_id := 0
	var seed_value := 0
	var policy_name := ""
	var replay_input_path := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--r16-output="):
			output_path = argument.trim_prefix("--r16-output=")
		elif argument.begins_with("--r16-progress="):
			progress_path = argument.trim_prefix("--r16-progress=")
		elif argument.begins_with("--r16-island="):
			island_id = argument.trim_prefix("--r16-island=")
		elif argument.begins_with("--r16-level="):
			level_id = int(argument.trim_prefix("--r16-level="))
		elif argument.begins_with("--r16-seed="):
			seed_value = int(argument.trim_prefix("--r16-seed="))
		elif argument.begins_with("--r16-policy="):
			policy_name = argument.trim_prefix("--r16-policy=")
		elif argument.begins_with("--r16-replay-input="):
			replay_input_path = argument.trim_prefix("--r16-replay-input=")
	if output_path.is_empty() or progress_path.is_empty() or island_id.is_empty() or level_id <= 0 or seed_value <= 0 or not [HARNESS_SCRIPT.POLICY_WEAK_V02, HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01].has(policy_name):
		push_error("R16 pilot requires output, progress, island, level, seed, and an approved policy")
		quit(2)
		return

	var action_log_override: Array = []
	if not replay_input_path.is_empty():
		var replay_file := FileAccess.open(replay_input_path, FileAccess.READ)
		if replay_file == null:
			_write_json(output_path, {"schema_version": 1, "status": "ERROR", "classification": "ERROR", "reason": "REPLAY_INPUT_OPEN_FAILED"})
			quit(1)
			return
		var replay_parse := JSON.new()
		if replay_parse.parse(replay_file.get_as_text()) != OK or not replay_parse.data is Dictionary:
			_write_json(output_path, {"schema_version": 1, "status": "ERROR", "classification": "ERROR", "reason": "REPLAY_INPUT_INVALID_JSON"})
			quit(1)
			return
		var replay_data: Dictionary = replay_parse.data
		var replay_actions: Variant = replay_data.get("action_log", [])
		if not replay_actions is Array or replay_actions.is_empty():
			_write_json(output_path, {"schema_version": 1, "status": "ERROR", "classification": "ERROR", "reason": "REPLAY_ACTION_LOG_MISSING"})
			quit(1)
			return
		action_log_override = replay_actions.duplicate(true)

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		_write_json(output_path, {"schema_version": 1, "status": "ERROR", "classification": "ERROR", "reason": "CAMPAIGN_LOAD_FAILED", "detail": database.get_last_error()})
		quit(1)
		return
	var definition: Dictionary = database.get_level(island_id, level_id)
	if definition.is_empty():
		_write_json(output_path, {"schema_version": 1, "status": "ERROR", "classification": "ERROR", "reason": "LEVEL_DEFINITION_MISSING"})
		quit(1)
		return

	var normal_shots_to_go := int(definition.get("theoretical_shots_to_go", 0))
	var normal_4t_cap := normal_shots_to_go * 4
	if normal_shots_to_go <= 0 or normal_4t_cap <= 0:
		_write_json(output_path, {"schema_version": 1, "status": "ERROR", "classification": "ERROR", "reason": "INVALID_NORMAL_4T_CAP"})
		quit(1)
		return
	var vip: Variant = definition.get("vip", null)
	var vip_enabled := vip is Dictionary and bool(vip.get("enabled", true))
	var normal_cost := MODEL_SCRIPT.normal_objective_cost(definition)
	var initial := {
		"schema_version": 1,
		"work_item": "BCM-M34-R16",
		"status": "CASE_RUNNING",
		"classification": "BUDGET_UNKNOWN",
		"case": {"island_id": island_id, "level_id": level_id, "seed": seed_value, "policy": policy_name, "replay": not action_log_override.is_empty()},
		"physics_mode": "standard_fps_production_physics",
		"fixed_fps": false,
		"time_scale": 1.0,
		"internal_wall_limit_sec": INTERNAL_WALL_LIMIT_SEC,
		"normal_objective_cost": normal_cost,
		"static_validation_record_count": database._levels_by_key.size(),
		"normal_theoretical_shots_T": normal_shots_to_go,
		"normal_4T_shot_cap": normal_4t_cap,
		"optional_vip_enabled": vip_enabled,
		"terminal_reason": "CASE_STARTED_NO_RESULT_YET",
		"action_log": [],
		"progress_curve": [],
	}
	_write_json(progress_path, initial)

	var harness = HARNESS_SCRIPT.new(get_root())
	harness.set_time_scale(1.0)
	var started_usec := Time.get_ticks_usec()
	var result: Dictionary = await harness.run_trial(
		database,
		island_id,
		level_id,
		seed_value,
		action_log_override,
		policy_name,
		normal_4t_cap,
		true,
		true,
		INTERNAL_WALL_LIMIT_SEC,
		"",
		true,
		true,
		false,
		0,
		HARNESS_SCRIPT.DETERMINISM_TRACE_INTERVAL_FRAMES,
		progress_path,
		{
			"static_validation_record_count": database._levels_by_key.size(),
			"physics_mode": "standard_fps_production_physics",
			"fixed_fps": false,
			"normal_theoretical_shots_T": normal_shots_to_go,
			"normal_4t_shot_cap": normal_4t_cap,
			"internal_wall_limit_sec": INTERNAL_WALL_LIMIT_SEC,
		}
	)
	var elapsed_usec := Time.get_ticks_usec() - started_usec
	var terminal_outcome := str(result.get("outcome", ""))
	var terminal_reason := str(result.get("terminal_reason", ""))
	var normal_complete := bool(result.get("normal_objective_complete", false))
	var shots_used := int(result.get("moves_used", result.get("shot_count", 0)))
	var shots_legal := shots_used <= normal_4t_cap and int(result.get("shot_count", 0)) <= normal_4t_cap
	var classification := "ERROR"
	if terminal_outcome == HARNESS_SCRIPT.OUTCOME_COMPLETED and normal_complete and shots_legal:
		classification = "WIN_OBSERVED"
	elif terminal_outcome in [HARNESS_SCRIPT.OUTCOME_DANGER, HARNESS_SCRIPT.OUTCOME_TIMEOUT]:
		classification = "LOSS_OBSERVED"
	elif terminal_outcome == HARNESS_SCRIPT.OUTCOME_HARNESS_ABORT and terminal_reason in ["PER_LEVEL_SHOT_BUDGET", "MOVE_BUDGET_EXHAUSTED", "PER_LEVEL_WALL_BUDGET", "PHYSICS_FRAME_BUDGET", "ACTION_BUDGET", "STOP_SIGNAL"]:
		classification = "BUDGET_UNKNOWN"

	var actions: Array = result.get("action_log", [])
	var record := {
		"schema_version": 1,
		"work_item": "BCM-M34-R16",
		"status": "CASE_COMPLETE",
		"classification": classification if shots_legal else "ERROR",
		"case": {"island_id": island_id, "level_id": level_id, "seed": seed_value, "policy": policy_name, "replay": not action_log_override.is_empty()},
		"physics": {
			"mode": "standard_fps_production_physics",
			"fixed_fps": false,
			"time_scale": 1.0,
			"physics_ticks_per_second": int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)),
			"run_on_separate_thread": bool(ProjectSettings.get_setting("physics/2d/run_on_separate_thread", false)),
			"shot_speed_px_per_sec": 700.0,
		},
		"normal_objective_cost": normal_cost,
		"static_validation_record_count": database._levels_by_key.size(),
		"normal_theoretical_shots_T": normal_shots_to_go,
		"normal_4T_shot_cap": normal_4t_cap,
		"optional_vip_enabled": vip_enabled,
		"shots_used": int(result.get("shot_count", 0)),
		"production_moves_used": shots_used,
		"shots_legal_within_normal_4T": shots_legal,
		"star_cap_outcome": int(result.get("stars", 0)),
		"normal_objective_complete": normal_complete,
		"outcome": terminal_outcome,
		"terminal_reason": terminal_reason,
		"elapsed_wall_usec": elapsed_usec,
		"physics_frames_observed": int(result.get("profile", {}).get("frame_count", 0)),
		"simulated_seconds": float(result.get("elapsed_sec", 0.0)),
		"merge_count": int(result.get("merge_count", 0)),
		"merge_events": result.get("merge_events", []).duplicate(true),
		"contact_count": int(result.get("contact_count", 0)),
		"moves_used": shots_used,
		"move_limit_including_optional_vip": int(result.get("move_limit", 0)),
		"normal_orders_completed": result.get("normal_orders_completed", {}).duplicate(true),
		"normal_orders_remaining": result.get("normal_orders_remaining", {}).duplicate(true),
		"vip_state": result.get("vip_state", {}).duplicate(true),
		"progress_curve": result.get("progress_curve", []).duplicate(true),
		"action_count": actions.size(),
		"action_log_sha256": _sha256(JSON.stringify(actions)),
		"action_log": actions.duplicate(true),
		"profile": result.get("profile", {}).duplicate(true),
		"human_fairness_ux": "NOT_ASSESSED",
	}
	_write_json(output_path, record)
	_write_json(progress_path, record)
	print("M34_R16_TRIAL classification=%s case=%s/%d seed=%d policy=%s shots=%d/%d merges=%d wall_ms=%d" % [
		str(record["classification"]), island_id, level_id, seed_value, policy_name,
		int(record["shots_used"]), normal_4t_cap, int(record["merge_count"]), int(elapsed_usec / 1000),
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
