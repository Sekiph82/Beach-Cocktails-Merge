extends SceneTree

## BCM-M33-004 uncensored sample trial.
##
## Plays one campaign level with the production GameManager, ShotController
## input path and Godot 2D physics until a real terminal state: WIN, table
## danger, or the normal 4T move budget is exhausted. No wall-clock cutoff is
## applied inside the trial (the runner owns a generous process timeout), so a
## result is never censored by host speed. Run with `--headless --fixed-fps 60`:
## every frame still advances physics by exactly 1/60 s, only faster than real
## time.
##
## Usage: godot --headless --fixed-fps 60 --path . --script <this> --
##   --t-island=<id> --t-level=<n> --t-seed=<n> --t-output=<json path>

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const POLICY := "R21_SPATIAL_LANE_V01"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := {}
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--t-") and argument.contains("="):
			var pair := argument.trim_prefix("--t-").split("=", false, 1)
			args[pair[0]] = pair[1]
	var island_id := str(args.get("island", ""))
	var level_id := int(args.get("level", 0))
	var seed_value := int(args.get("seed", 0))
	var output_path := str(args.get("output", ""))
	if island_id.is_empty() or level_id <= 0 or seed_value <= 0 or output_path.is_empty():
		push_error("requires --t-island --t-level --t-seed --t-output")
		quit(2)
		return

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		_write(output_path, {"classification": "ERROR", "reason": "CAMPAIGN_LOAD_FAILED", "detail": database.get_last_error()})
		quit(1)
		return
	var definition: Dictionary = database.get_level(island_id, level_id)
	var theoretical_t := int(definition.get("theoretical_shots_to_go", 0))
	if definition.is_empty() or theoretical_t <= 0:
		_write(output_path, {"classification": "ERROR", "reason": "LEVEL_OR_T_INVALID"})
		quit(1)
		return
	var cap := theoretical_t * 4

	var harness = HARNESS_SCRIPT.new(root)
	var started := Time.get_ticks_msec()
	var result: Dictionary = await harness.run_trial(
		database, island_id, level_id, seed_value, [], POLICY, cap,
		true, true, 0.0, "", true, true, false, 0,
		HARNESS_SCRIPT.DETERMINISM_TRACE_INTERVAL_FRAMES, "", {}, true, {}
	)
	var wall_ms := Time.get_ticks_msec() - started

	var outcome := str(result.get("outcome", ""))
	var reason := str(result.get("terminal_reason", ""))
	var shots := int(result.get("shot_count", 0))
	var moves := int(result.get("moves_used", 0))
	var classification := "ERROR"
	if outcome == HARNESS_SCRIPT.OUTCOME_COMPLETED and bool(result.get("normal_objective_complete", false)):
		classification = "WIN_OBSERVED"
	elif reason in ["MOVES_EXHAUSTED", "MOVE_BUDGET_EXHAUSTED", "PER_LEVEL_SHOT_BUDGET"]:
		classification = "LOSS_OUT_OF_MOVES"
	elif outcome in [HARNESS_SCRIPT.OUTCOME_DANGER, HARNESS_SCRIPT.OUTCOME_TIMEOUT]:
		classification = "LOSS_DANGER"
	if shots > cap or moves > cap:
		classification = "ERROR"
		reason = "4T_CAP_VIOLATED"

	var curve: Array = result.get("progress_curve", [])
	var t_start := int(curve[0].get("normal_T_start", 0)) if not curve.is_empty() else 0
	var t_progress := 0
	for point in curve:
		t_progress = maxi(t_progress, int(point.get("normal_T_progressed", 0)))
	var actions: Array = []
	for action in result.get("action_log", []):
		actions.append([int(action.get("spawn_level", 0)), snappedf(float(action.get("x_position", 0.0)), 0.1), int(action.get("merges_delta", 0)), int(action.get("normal_objective_progress_delta", 0))])

	var record := {
		"schema_version": 1,
		"work_item": "BCM-M33-004",
		"protocol": "UNCENSORED_FIXED_FPS_V01",
		"island_id": island_id,
		"level_id": level_id,
		"seed": seed_value,
		"policy": POLICY,
		"classification": classification,
		"outcome": outcome,
		"terminal_reason": reason,
		"normal_theoretical_shots_T": theoretical_t,
		"normal_4t_shot_cap": cap,
		"shots_used": shots,
		"production_moves_used": moves,
		"objective_T_start": t_start,
		"objective_T_progressed": t_progress,
		"normal_orders": definition.get("orders", []).duplicate(true),
		"normal_orders_remaining": result.get("normal_orders_remaining", {}).duplicate(true),
		"vip_enabled": bool(definition.get("vip", {}).get("enabled", false)) if definition.get("vip", {}) is Dictionary else false,
		"vip_complete": bool(result.get("vip_complete", false)),
		"stars": int(result.get("stars", 0)),
		"merge_count": int(result.get("merge_count", 0)),
		"contact_count": int(result.get("contact_count", 0)),
		"peak_live_drinks": int(result.get("peak_live_drinks", 0)),
		"danger_line_exposure_sec": snappedf(float(result.get("danger_line_exposure_sec", 0.0)), 0.01),
		"simulated_seconds": snappedf(float(result.get("elapsed_sec", 0.0)), 0.01),
		"physics_ticks_per_second": int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)),
		"fixed_fps_arg": OS.get_cmdline_args().has("--fixed-fps"),
		"wall_ms": wall_ms,
		"actions_compact_fields": ["spawn_level", "x", "merges_delta", "objective_T_delta"],
		"actions": actions,
	}
	_write(output_path, record)
	print("M33_004_TRIAL %s %s/L%d shots=%d/%d T=%d/%d wall_ms=%d" % [classification, island_id, level_id, shots, cap, t_progress, t_start, wall_ms])
	quit(0 if classification != "ERROR" else 1)


func _write(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(value) + "\n")
		file.close()
