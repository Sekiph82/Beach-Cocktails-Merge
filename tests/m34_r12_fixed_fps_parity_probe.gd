extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const ISLAND_ID := "azure_bay"
const LEVEL_ID := 1
const SEED_VALUE := 34112001
const ACTION_CAP := 6


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_path := ""
	var mode := "normal"
	var policy_name := HARNESS_SCRIPT.POLICY_CHEAP_MERGE_CENTER_V01
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--r12-output="):
			output_path = argument.trim_prefix("--r12-output=")
		elif argument.begins_with("--r12-mode="):
			mode = argument.trim_prefix("--r12-mode=")
		elif argument.begins_with("--r12-policy="):
			policy_name = argument.trim_prefix("--r12-policy=")
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
		ISLAND_ID,
		LEVEL_ID,
		SEED_VALUE,
		[],
		policy_name,
		ACTION_CAP,
		true,
		true,
		0.0,
		"",
		true,
		true,
		true
	)
	var wall_usec := Time.get_ticks_usec() - started_usec
	var report := {
		"probe": "M34-R12 production physics fixed-FPS parity",
		"mode": mode,
		"island_id": ISLAND_ID,
		"level_id": LEVEL_ID,
		"seed": SEED_VALUE,
		"policy": policy_name,
		"action_cap": ACTION_CAP,
		"engine_time_scale": Engine.time_scale,
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
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
