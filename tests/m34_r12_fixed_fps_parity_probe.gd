extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_path := ""
	var mode := "normal"
	var policy_name := HARNESS_SCRIPT.POLICY_CHEAP_MERGE_CENTER_V01
	var island_id := "azure_bay"
	var level_id := 1
	var seed_value := 34112001
	var action_cap := 6
	var trace_interval_frames := 15
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--r12-output="):
			output_path = argument.trim_prefix("--r12-output=")
		elif argument.begins_with("--r12-mode="):
			mode = argument.trim_prefix("--r12-mode=")
		elif argument.begins_with("--r12-policy="):
			policy_name = argument.trim_prefix("--r12-policy=")
		elif argument.begins_with("--r14-island="):
			island_id = argument.trim_prefix("--r14-island=")
		elif argument.begins_with("--r14-level="):
			level_id = int(argument.trim_prefix("--r14-level="))
		elif argument.begins_with("--r14-seed="):
			seed_value = int(argument.trim_prefix("--r14-seed="))
		elif argument.begins_with("--r14-action-cap="):
			action_cap = int(argument.trim_prefix("--r14-action-cap="))
		elif argument.begins_with("--r14-policy="):
			policy_name = argument.trim_prefix("--r14-policy=")
		elif argument.begins_with("--r15-trace-interval="):
			trace_interval_frames = maxi(1, int(argument.trim_prefix("--r15-trace-interval=")))
	if output_path.is_empty():
		push_error("R12 probe requires --r12-output=<absolute path>")
		quit(2)
		return

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(
		DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
		DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS,
		DATABASE_SCRIPT.ValidationMode.FULL
	):
		push_error("R12 probe campaign load failed: %s" % database.get_last_error())
		quit(1)
		return

	var harness = HARNESS_SCRIPT.new(get_root())
	harness.set_time_scale(1.0)
	var started_usec := Time.get_ticks_usec()
	var trial: Dictionary = await harness.run_trial(
		database,
		island_id,
		level_id,
		seed_value,
		[],
		policy_name,
		action_cap,
		true,
		true,
		0.0,
		"",
		true,
		true,
		true,
		maxi(action_cap * 60 + 90, 90),
		trace_interval_frames
	)
	var wall_usec := Time.get_ticks_usec() - started_usec
	var report := {
		"probe": "M34-R12 production physics fixed-FPS parity",
		"mode": mode,
		"island_id": island_id,
		"level_id": level_id,
		"seed": seed_value,
		"policy": policy_name,
		"action_cap": action_cap,
		"physics_frame_ceiling": maxi(action_cap * 60 + 90, 90),
		"engine_time_scale": Engine.time_scale,
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
		"max_fps": Engine.max_fps,
		"processor_count": OS.get_processor_count(),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"physics_engine_setting": ProjectSettings.get_setting("physics/2d/physics_engine", "DEFAULT"),
		"physics_separate_thread": ProjectSettings.get_setting("physics/2d/run_on_separate_thread", false),
		"physics_solver_iterations": ProjectSettings.get_setting("physics/2d/solver/solver_iterations", 8),
		"max_physics_steps_per_frame": ProjectSettings.get_setting("physics/common/max_physics_steps_per_frame", 8),
		"trace_interval_frames": trace_interval_frames,
		"wall_usec": wall_usec,
		"telemetry": trial,
	}
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write R12 probe output: %s" % output_path)
		quit(1)
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("M34_R12_PARITY_PROBE_RESULT=PASS mode=%s frames=%d actions=%d merges=%d wall_usec=%d" % [
		mode,
		int(trial.get("profile", {}).get("frame_count", 0)),
		int(trial.get("shot_count", 0)),
		int(trial.get("merge_count", 0)),
		wall_usec,
	])
	quit(0)
