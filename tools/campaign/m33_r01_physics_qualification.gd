extends SceneTree

## Bounded, resumable R01 production-physics qualification runner.
## Uses the current production session, GameManager, ShotController, Drink,
## merge queue and delivery path through the M17 physical harness.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const MANIFEST_PATH := "res://data/campaign/content_manifest_m33.json"
const RUNNER_VERSION := "BCM-M33-R01-QUALIFICATION-1.1.0"
const POLICY := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const LEVEL_FIRST := 101
const LEVEL_LAST := 1000

var _started_msec := 0
var _stop_reason := ""


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_started_msec = Time.get_ticks_msec()
	var options := _parse_options(OS.get_cmdline_user_args())
	var start_level := clampi(int(options.get("start", 101)), LEVEL_FIRST, LEVEL_LAST)
	var end_level := clampi(int(options.get("end", LEVEL_LAST)), start_level, LEVEL_LAST)
	var level_ids := _resolve_level_ids(options, start_level, end_level)
	var trial_count := clampi(int(options.get("trials", 3)), 1, 8)
	var seed_base := int(options.get("seed-base", 33040100))
	var max_shots := clampi(int(options.get("max-shots", 60)), 12, 400)
	var per_trial_wall_sec := clampf(float(options.get("per-trial-wall-sec", 30.0)), 5.0, 300.0)
	var global_budget_sec := clampf(float(options.get("global-budget-sec", 240.0)), 15.0, 3600.0)
	var output_path := str(options.get("output", "user://m33_r01/physics_trials.jsonl"))
	var trace_path := str(options.get("traces", "user://m33_r01/representative_traces.jsonl"))
	var output_absolute := ProjectSettings.globalize_path(output_path)
	var trace_absolute := ProjectSettings.globalize_path(trace_path)
	DirAccess.make_dir_recursive_absolute(output_absolute.get_base_dir())
	DirAccess.make_dir_recursive_absolute(trace_absolute.get_base_dir())

	var manifest_sha := _sha256(MANIFEST_PATH)
	if manifest_sha.is_empty():
		push_error("M33_R01 manifest SHA could not be read")
		quit(2)
		return
	var processed := _load_processed(output_absolute)
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M33_R01 canonical database load failed: %s" % database.get_last_error())
		quit(2)
		return
	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(1.0)
	var output := _open_append_preserving(output_path)
	if output == null:
		push_error("M33_R01 cannot open JSONL checkpoint: %s" % error_string(FileAccess.get_open_error()))
		quit(2)
		return
	output.seek_end()
	var traces := _open_append_preserving(trace_path)
	if traces != null:
		traces.seek_end()

	var identity := {
		"runner_version": RUNNER_VERSION,
		"content_version": str(JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH)).get("content_version", "UNKNOWN")),
		"manifest_sha256": manifest_sha,
		"godot_version": Engine.get_version_info().string,
		"physics_scale": harness.get_time_scale(),
		"project_name": str(ProjectSettings.get_setting("application/config/name", "")),
		"isolated_user_data": true,
		"policy": POLICY,
		"seed_formula": "seed_base + global_level_id * 100 + trial_index",
		"seed_base": seed_base,
		"max_shots_per_trial": max_shots,
		"per_trial_wall_budget_sec": per_trial_wall_sec,
		"global_wall_budget_sec": global_budget_sec,
		"requested_level_ids": level_ids,
		"requested_trials_per_level": trial_count,
	}
	var metadata_path := output_path.get_base_dir().path_join("run_metadata.json")
	var metadata_file := FileAccess.open(metadata_path, FileAccess.WRITE)
	if metadata_file != null:
		metadata_file.store_string(JSON.stringify(identity, "\t") + "\n")
		metadata_file.flush()
		metadata_file.close()
	print("M33_R01_RUN_IDENTITY=%s" % JSON.stringify(identity))
	print("M33_R01_USER_DATA_PATH=%s" % ProjectSettings.globalize_path("user://"))
	print("M33_R01_CHECKPOINT_RESUME_KEYS=%d" % processed.size())

	var trace_island_written := _load_trace_islands(trace_absolute)
	var done_count := 0
	for global_level in level_ids:
		if _budget_exhausted(global_budget_sec):
			_stop_reason = "GLOBAL_WALL_BUDGET"
			break
		var mapping := _map_global_level(global_level)
		var definition: Dictionary = database.get_level(str(mapping["island_id"]), int(mapping["local_level_id"]))
		if definition.is_empty():
			var invalid_row := _base_row(global_level, mapping, -1, 0, manifest_sha, max_shots, per_trial_wall_sec, global_budget_sec)
			invalid_row["trial_outcome"] = "error"
			invalid_row["qualification_status"] = "VERIFIED_DATA_INVALID"
			invalid_row["data_valid"] = false
			invalid_row["error"] = "canonical database did not return the expected level"
			_write_row(output, invalid_row)
			continue
		var difficulty_band := str(definition.get("difficulty_band", definition.get("difficulty_tier", "UNSPECIFIED")))
		for trial_index in range(trial_count):
			if _budget_exhausted(global_budget_sec):
				_stop_reason = "GLOBAL_WALL_BUDGET"
				break
			var seed_value := seed_base + global_level * 100 + trial_index
			var checkpoint_key := _checkpoint_key(global_level, seed_value, max_shots, per_trial_wall_sec, manifest_sha)
			if processed.has(checkpoint_key):
				continue
			var trial_started := Time.get_ticks_msec()
			print("M33_R01_TRIAL global=%d island=%s local=%d seed=%d trial=%d/%d" % [global_level, mapping["island_id"], mapping["local_level_id"], seed_value, trial_index + 1, trial_count])
			var trial: Dictionary = await harness.run_trial(
				database,
				str(mapping["island_id"]),
				int(mapping["local_level_id"]),
				seed_value,
				[],
				POLICY,
				max_shots,
				true,
				true,
				per_trial_wall_sec
			)
			var wall_ms := Time.get_ticks_msec() - trial_started
			var row := _base_row(global_level, mapping, trial_index, seed_value, manifest_sha, max_shots, per_trial_wall_sec, global_budget_sec)
			row["difficulty_band"] = difficulty_band
			row["trial_outcome"] = _trial_outcome(trial)
			row["qualification_status"] = "PROVEN_REACHABLE_IN_BOUNDED_TRIAL" if row["trial_outcome"] == "completed" else "NOT_COMPLETED_WITHIN_BUDGET" if row["trial_outcome"] == "exhausted-budget" else "NOT_RUN/ERROR"
			row["seed_count"] = 1
			row["shot_count"] = int(trial.get("shot_count", 0))
			row["simulated_seconds"] = float(trial.get("elapsed_sec", 0.0))
			row["wall_milliseconds"] = wall_ms
			row["physics_scale"] = harness.get_time_scale()
			row["normal_objective_complete"] = bool(trial.get("normal_objective_complete", false))
			row["to_go_completed"] = trial.get("normal_orders_completed", {})
			row["to_go_remaining"] = trial.get("normal_orders_remaining", {})
			row["vip_optional"] = trial.get("vip_state", {})
			row["moves_used"] = int(trial.get("moves_used", 0))
			row["moves_remaining"] = int(trial.get("moves_remaining", 0))
			row["move_limit"] = int(trial.get("move_limit", 0))
			row["star_result"] = int(trial.get("stars", 0))
			row["theoretical_shots_to_go"] = int(definition.get("theoretical_shots_to_go", 0))
			row["move_limit_expected"] = int(definition.get("move_limit", 0))
			row["terminal_reason"] = str(trial.get("terminal_reason", ""))
			row["merge_count"] = int(trial.get("merge_count", 0))
			row["peak_live_drinks"] = int(trial.get("peak_live_drinks", 0))
			row["policy_name"] = str(trial.get("policy_name", POLICY))
			row["action_log_sha256"] = _sha256_text(JSON.stringify(trial.get("action_log", [])))
			row["telemetry_valid"] = harness.validate_telemetry(trial).is_empty()
			row["known_impossible"] = false
			row["data_valid"] = true
			if row["trial_outcome"] == "completed" and not bool(row["telemetry_valid"]):
				row["qualification_status"] = "NOT_RUN/ERROR"
			if row["trial_outcome"] == "error":
				row["error"] = row["terminal_reason"]
			_write_row(output, row)
			processed[checkpoint_key] = true
			done_count += 1
			print("M33_R01_RESULT global=%d seed=%d outcome=%s shots=%d wall_ms=%d moves=%d/%d stars=%d" % [global_level, seed_value, row["trial_outcome"], row["shot_count"], wall_ms, row["moves_used"], row["move_limit"], row["star_result"]])
			if traces != null and not trace_island_written.has(str(mapping["island_id"])):
				var trace_row := {
					"global_level_id": global_level,
					"island_id": mapping["island_id"],
					"local_level_id": mapping["local_level_id"],
					"seed": seed_value,
					"policy": POLICY,
					"trial_outcome": row["trial_outcome"],
					"action_log": trial.get("action_log", []),
				}
				traces.store_line(JSON.stringify(trace_row))
				traces.flush()
				trace_island_written[str(mapping["island_id"])] = true
			if not bool(row["telemetry_valid"]):
				push_error("M33_R01 telemetry schema failed at global level %d seed %d" % [global_level, seed_value])
			if _trial_outcome(trial) == "error":
				print("M33_R01_ERROR global=%d seed=%d reason=%s" % [global_level, seed_value, row["terminal_reason"]])
			if _budget_exhausted(global_budget_sec):
				_stop_reason = "GLOBAL_WALL_BUDGET"
				break
		if not _stop_reason.is_empty():
			break
	output.flush()
	output.close()
	if traces != null:
		traces.flush()
		traces.close()
	var elapsed_sec := float(Time.get_ticks_msec() - _started_msec) / 1000.0
	print("M33_R01_BATCH_EXECUTION=COMPLETE requested=%s new_trials=%d resumed_keys=%d elapsed_sec=%.2f stop_reason=%s" % [str(level_ids), done_count, processed.size() - done_count, elapsed_sec, _stop_reason if not _stop_reason.is_empty() else "RANGE_COMPLETE"])
	quit(0)


func _parse_options(arguments: PackedStringArray) -> Dictionary:
	var parsed := {}
	for argument in arguments:
		if not argument.begins_with("--") or not argument.contains("="):
			continue
		var split := argument.trim_prefix("--").split("=", false, 1)
		if split.size() == 2:
			parsed[split[0]] = split[1]
	return parsed


func _resolve_level_ids(options: Dictionary, start_level: int, end_level: int) -> Array[int]:
	var result: Array[int] = []
	if options.has("level-list"):
		for raw_level in str(options["level-list"]).split(",", false):
			var parsed := str(raw_level).to_int()
			if parsed >= LEVEL_FIRST and parsed <= LEVEL_LAST and not result.has(parsed):
				result.append(parsed)
		return result
	for level_id in range(start_level, end_level + 1):
		result.append(level_id)
	return result


func _map_global_level(global_level: int) -> Dictionary:
	var islands := ["sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island"]
	var index := clampi(int(floor(float(global_level - 1) / 100.0)), 0, islands.size() - 1)
	return {"island_id": islands[index], "local_level_id": ((global_level - 1) % 100) + 1}


func _base_row(global_level: int, mapping: Dictionary, trial_index: int, seed_value: int, manifest_sha: String, max_shots: int, per_trial_wall_sec: float, global_budget_sec: float) -> Dictionary:
	return {
		"schema_version": 1,
		"runner_version": RUNNER_VERSION,
		"global_level_id": global_level,
		"island_id": str(mapping.get("island_id", "")),
		"local_level_id": int(mapping.get("local_level_id", 0)),
		"trial_index": trial_index,
		"seed": seed_value,
		"seed_formula": "seed_base + global_level_id * 100 + trial_index",
		"manifest_sha256": manifest_sha,
		"max_shots": max_shots,
		"per_trial_wall_budget_sec": per_trial_wall_sec,
		"global_wall_budget_sec": global_budget_sec,
		"known_impossible": false,
		"data_valid": true,
	}


func _trial_outcome(trial: Dictionary) -> String:
	if bool(trial.get("normal_objective_complete", false)) and str(trial.get("outcome", "")) == "completed":
		return "completed"
	var reason := str(trial.get("terminal_reason", ""))
	if reason in ["PER_LEVEL_SHOT_BUDGET", "PER_LEVEL_WALL_BUDGET", "MOVE_BUDGET_EXHAUSTED", "ACTION_BUDGET"]:
		return "exhausted-budget"
	if str(trial.get("outcome", "")) in ["danger", "timeout"]:
		return "exhausted-budget"
	return "error"


func _checkpoint_key(global_level: int, seed_value: int, max_shots: int, per_trial_wall_sec: float, manifest_sha: String) -> String:
	return "%s|%s|%d|%d|%.3f|%s|%s" % [RUNNER_VERSION, global_level, seed_value, max_shots, per_trial_wall_sec, manifest_sha, POLICY]


func _load_processed(path: String) -> Dictionary:
	var result := {}
	if not FileAccess.file_exists(path):
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result
	while not file.eof_reached():
		var line := file.get_line()
		if line.strip_edges().is_empty():
			continue
		var parsed = JSON.parse_string(line)
		if parsed is Dictionary:
			result[_checkpoint_key(int(parsed.get("global_level_id", 0)), int(parsed.get("seed", 0)), int(parsed.get("max_shots", 0)), float(parsed.get("per_trial_wall_budget_sec", 0.0)), str(parsed.get("manifest_sha256", "")))] = true
	file.close()
	return result


func _load_trace_islands(path: String) -> Dictionary:
	var result := {}
	if not FileAccess.file_exists(path):
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result
	while not file.eof_reached():
		var line := file.get_line()
		if line.strip_edges().is_empty():
			continue
		var parsed = JSON.parse_string(line)
		if parsed is Dictionary and parsed.has("island_id"):
			result[str(parsed["island_id"])] = true
	file.close()
	return result


func _write_row(file: FileAccess, row: Dictionary) -> void:
	file.store_line(JSON.stringify(row))
	file.flush()


func _open_append_preserving(path: String) -> FileAccess:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null and FileAccess.get_open_error() == ERR_FILE_NOT_FOUND:
		var create := FileAccess.open(path, FileAccess.WRITE)
		if create == null:
			return null
		create.close()
		file = FileAccess.open(path, FileAccess.READ_WRITE)
	return file


func _budget_exhausted(global_budget_sec: float) -> bool:
	return float(Time.get_ticks_msec() - _started_msec) / 1000.0 >= global_budget_sec


func _sha256(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	context.update(bytes)
	return context.finish().hex_encode().to_upper()


func _sha256_text(value: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(value.to_utf8_buffer())
	return context.finish().hex_encode().to_upper()
