extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := _arguments()
	var output_path := str(args.get("output", ""))
	var live_progress_path := str(args.get("progress", ""))
	var island_id := str(args.get("island", ""))
	var level_id := int(args.get("level", 0))
	var seed_value := int(args.get("seed", 0))
	var wall_limit := float(args.get("wall-limit", 0.0))
	var policy_name := str(args.get("policy", HARNESS_SCRIPT.POLICY_R19_FEEDBACK_AWARE_V01))
	var inherited_feedback: Dictionary = {}
	var feedback_path := str(args.get("feedback", ""))
	if not feedback_path.is_empty():
		var feedback_file := FileAccess.open(feedback_path, FileAccess.READ)
		if feedback_file == null:
			push_error("R19 inherited feedback file could not be opened")
			quit(2)
			return
		var parsed_feedback: Variant = JSON.parse_string(feedback_file.get_as_text())
		if not parsed_feedback is Dictionary:
			push_error("R19 inherited feedback must be a JSON dictionary")
			quit(2)
		inherited_feedback = parsed_feedback.duplicate(true)
	if output_path.is_empty() or live_progress_path.is_empty() or island_id.is_empty() or level_id <= 0 or seed_value <= 0 or wall_limit <= 0.0 or wall_limit > 120.0:
		push_error("R19/R20 trial requires output, progress, island, level, positive seed, and wall limit <=120 seconds")
		quit(2)
		return
	if policy_name not in [HARNESS_SCRIPT.POLICY_R19_FEEDBACK_AWARE_V01, HARNESS_SCRIPT.POLICY_R20_OBJECTIVE_LOOKAHEAD_V01]:
		push_error("Unsupported R19/R20 trial policy: %s" % policy_name)
		quit(2)
		return

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		_write_json(output_path, {"schema_version": 1, "work_item": "BCM-M34-R19", "classification": "ERROR", "reason": "CAMPAIGN_LOAD_FAILED", "detail": database.get_last_error()})
		quit(1)
		return
	var definition: Dictionary = database.get_level(island_id, level_id)
	var island_definition: Dictionary = database.get_island(island_id)
	var global_level_id := ((int(island_definition.get("order_index", 0)) - 1) * 100) + level_id
	var theoretical_t := int(definition.get("theoretical_shots_to_go", 0))
	var normal_4t_cap := theoretical_t * 4
	if definition.is_empty() or theoretical_t <= 0 or normal_4t_cap <= 0:
		_write_json(output_path, {"schema_version": 1, "work_item": "BCM-M34-R19", "classification": "ERROR", "reason": "LEVEL_OR_NORMAL_4T_INVALID"})
		quit(1)
		return

	var initial_progress := {
		"schema_version": 1,
		"work_item": "BCM-M34-R19",
		"status": "CASE_RUNNING",
		"classification": "BUDGET_UNKNOWN",
		"case": {"island_id": island_id, "level_id": level_id, "global_level_id": global_level_id, "seed": seed_value, "policy": policy_name},
		"physics_mode": "standard_fps_production_physics",
		"fixed_fps": false,
		"time_scale": 1.0,
		"global_validated_level_count": database._levels_by_key.size(),
		"global_level_id": global_level_id,
		"normal_theoretical_shots_T": theoretical_t,
		"normal_4t_shot_cap": normal_4t_cap,
		"optional_vip_enabled": bool(definition.get("vip", {}).get("enabled", false)) if definition.get("vip", {}) is Dictionary else false,
		"terminal_reason": "CASE_STARTED_NO_RESULT_YET",
		"action_log": [],
		"progress_curve": [],
	}
	_write_json(live_progress_path, initial_progress)

	var harness = HARNESS_SCRIPT.new(root)
	var started_usec := Time.get_ticks_usec()
	var result: Dictionary = await harness.run_trial(
		database,
		island_id,
		level_id,
		seed_value,
		[],
		policy_name,
		normal_4t_cap,
		true,
		true,
		wall_limit,
		"",
		true,
		true,
		false,
		0,
		HARNESS_SCRIPT.DETERMINISM_TRACE_INTERVAL_FRAMES,
		live_progress_path,
		{
			"work_item": "BCM-M34-R19",
			"global_validated_level_count": database._levels_by_key.size(),
			"physics_mode": "standard_fps_production_physics",
			"fixed_fps": false,
			"normal_theoretical_shots_T": theoretical_t,
			"normal_4t_shot_cap": normal_4t_cap,
			"per_trial_wall_limit_sec": wall_limit,
		},
		true,
		inherited_feedback
	)
	var elapsed_usec := Time.get_ticks_usec() - started_usec
	var outcome := str(result.get("outcome", ""))
	var reason := str(result.get("terminal_reason", ""))
	var shots := int(result.get("shot_count", 0))
	var classification := "ERROR"
	if outcome == HARNESS_SCRIPT.OUTCOME_COMPLETED and bool(result.get("normal_objective_complete", false)) and shots <= normal_4t_cap and int(result.get("moves_used", 0)) <= normal_4t_cap:
		classification = "WIN_OBSERVED"
	elif outcome in [HARNESS_SCRIPT.OUTCOME_DANGER, HARNESS_SCRIPT.OUTCOME_TIMEOUT]:
		classification = "LOSS_OBSERVED"
	elif outcome == HARNESS_SCRIPT.OUTCOME_HARNESS_ABORT and reason in ["PER_LEVEL_SHOT_BUDGET", "MOVE_BUDGET_EXHAUSTED", "PER_LEVEL_WALL_BUDGET", "PHYSICS_FRAME_BUDGET", "ACTION_BUDGET", "STOP_SIGNAL"]:
		classification = "BUDGET_UNKNOWN"
	if shots > normal_4t_cap or int(result.get("moves_used", 0)) > normal_4t_cap:
		classification = "ERROR"

	var record := {
		"schema_version": 1,
		"work_item": "BCM-M34-R19",
		"status": "CASE_COMPLETE",
		"classification": classification,
		"case": {"island_id": island_id, "level_id": level_id, "global_level_id": global_level_id, "seed": seed_value, "policy": policy_name},
		"physics": {
			"mode": "standard_fps_production_physics",
			"fixed_fps": false,
			"time_scale": 1.0,
			"physics_ticks_per_second": int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)),
			"run_on_separate_thread": bool(ProjectSettings.get_setting("physics/2d/run_on_separate_thread", false)),
			"shot_speed_px_per_sec": 700.0,
			"input_path": "production ShotController._unhandled_input mouse press/release + footprint projection + _launch + Drink.launch_up + Godot 2D physics",
		},
		"global_validated_level_count": database._levels_by_key.size(),
		"global_level_id": global_level_id,
		"normal_theoretical_shots_T": theoretical_t,
		"normal_4t_shot_cap": normal_4t_cap,
		"optional_vip_enabled": bool(definition.get("vip", {}).get("enabled", false)) if definition.get("vip", {}) is Dictionary else false,
		"normal_4t_cap_verified": shots <= normal_4t_cap and int(result.get("moves_used", 0)) <= normal_4t_cap,
		"shots_used": shots,
		"production_moves_used": int(result.get("moves_used", 0)),
		"outcome": outcome,
		"terminal_reason": reason,
		"normal_objective_complete": bool(result.get("normal_objective_complete", false)),
		"normal_orders_completed": result.get("normal_orders_completed", {}).duplicate(true),
		"normal_orders_remaining": result.get("normal_orders_remaining", {}).duplicate(true),
		"vip_state": result.get("vip_state", {}).duplicate(true),
		"elapsed_wall_usec": elapsed_usec,
		"physics_frames_observed": int(result.get("profile", {}).get("frame_count", 0)),
		"simulated_seconds": float(result.get("elapsed_sec", 0.0)),
		"merge_count": int(result.get("merge_count", 0)),
		"merge_events": result.get("merge_events", []).duplicate(true),
		"contact_count": int(result.get("contact_count", 0)),
		"contact_events": result.get("contact_events", []).duplicate(true),
		"action_count": result.get("action_log", []).size(),
		"action_log": result.get("action_log", []).duplicate(true),
		"progress_curve": result.get("progress_curve", []).duplicate(true),
		"production_geometry_snapshot": result.get("production_geometry_snapshot", {}).duplicate(true),
		"lane_feedback": result.get("r19_lane_feedback", {}).duplicate(true),
		"inherited_lane_feedback": inherited_feedback.duplicate(true),
		"profile": result.get("profile", {}).duplicate(true),
		"human_fairness_ux": "NOT_ASSESSED",
	}
	record["action_progress_sha256"] = _sha256(JSON.stringify({"action_log": record.action_log, "progress_curve": record.progress_curve, "lane_feedback": record.lane_feedback}))
	_write_json(output_path, record)
	_write_json(live_progress_path, record)
	print("M34_R19_TRIAL classification=%s case=%s/%d seed=%d shots=%d/%d objective_progress=%d wall_ms=%d" % [
		classification,
		island_id,
		level_id,
		seed_value,
		shots,
		normal_4t_cap,
		_harness_objective_progress(record),
		int(elapsed_usec / 1000),
	])
	quit(0 if classification != "ERROR" else 1)


func _arguments() -> Dictionary:
	var result := {}
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--r19-") and argument.contains("="):
			var pair := argument.trim_prefix("--r19-").split("=", false, 1)
			if pair.size() == 2:
				result[pair[0]] = pair[1]
	return result


func _harness_objective_progress(record: Dictionary) -> int:
	var best := 0
	for point in record.get("progress_curve", []):
		best = maxi(best, int(point.get("normal_T_progressed", 0)))
	return best


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
