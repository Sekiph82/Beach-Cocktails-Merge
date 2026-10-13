extends SceneTree

## Small sequential R02 production-physics calibration pilot.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const RUNNER_VERSION := "BCM-M33-R02-CALIBRATION-1.0.2"
const POLICY := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const GLOBAL_BUDGET_HARD_CAP_SEC := 900.0
const GLOBAL_STOP_GRACE_SEC := 2.0
const SEED_BASE := 33050100
const REFERENCE_WALL_SEC_PER_SHOT := 1.07
const WALL_HEADROOM_FACTOR := 1.12
const PILOT_LEVELS := [101, 202, 304, 479]
const ISLANDS := ["sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island"]
const LEVEL_PATHS := [
	"res://data/campaign/levels/sunny_cove.json",
	"res://data/campaign/levels/tiki_island_full.json",
	"res://data/campaign/levels/azure_bay.json",
	"res://data/campaign/levels/coconut_beach.json",
	"res://data/campaign/levels/sunset_island.json",
	"res://data/campaign/levels/party_beach.json",
	"res://data/campaign/levels/frozen_paradise.json",
	"res://data/campaign/levels/volcano_bay.json",
	"res://data/campaign/levels/billionaire_island.json",
	"res://data/campaign/levels/final_island.json",
]
const MANIFEST_PATH := "res://data/campaign/content_manifest_m33.json"

var _started_msec := 0
var _stop_reason := ""


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_started_msec = Time.get_ticks_msec()
	var options := _parse_options(OS.get_cmdline_user_args())
	var total_budget_sec := clampf(float(options.get("global-budget-sec", GLOBAL_BUDGET_HARD_CAP_SEC)), 1.0, GLOBAL_BUDGET_HARD_CAP_SEC)
	var output_path := str(options.get("output", "res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R02/calibration_trials.jsonl"))
	var output_absolute := ProjectSettings.globalize_path(output_path)
	DirAccess.make_dir_recursive_absolute(output_absolute.get_base_dir())
	var output := _open_append_preserving(output_path)
	if output == null:
		push_error("M33_R02 cannot open checkpoint: %s" % error_string(FileAccess.get_open_error()))
		quit(2)
		return
	output.seek_end()

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M33_R02 canonical database load failed: %s" % database.get_last_error())
		output.close()
		quit(2)
		return
	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(1.0)
	var source_hashes := _source_hashes()
	var source_hash_digest := _sha256_text(JSON.stringify(source_hashes))
	var identity := {
		"runner_version": RUNNER_VERSION,
		"godot_version": Engine.get_version_info().string,
		"project_name": str(ProjectSettings.get_setting("application/config/name", "")),
		"isolated_user_data": true,
		"user_data_path": ProjectSettings.globalize_path("user://"),
		"physics_scale": harness.get_time_scale(),
		"policy": POLICY,
		"seed_formula": "global 101 known Tiki seed 33050200; candidates use SEED_BASE + global_level_id * 100; seed_base=%d" % SEED_BASE,
		"theoretical_T_units": "sum(2^(target_level-3) * quantity) for normal To-Go orders; VIP T is reported separately",
		"relative_shot_budget_formula": "ceil(normal_order_L1_equivalent_cost * 3 / 7) = ceil(12*T/7); global 101 control floor 12 from prior observed 11-shot success",
		"wall_budget_formula": "min(remaining global seconds minus 2s flush reserve, shot_budget * 1.12); known global 101 control gets a 20s minimum; baseline planning rate 1.07 wall seconds/shot measured in R01 aggregate",
		"global_wall_budget_sec": total_budget_sec,
		"global_wall_budget_hard_cap_sec": GLOBAL_BUDGET_HARD_CAP_SEC,
		"reserved_shutdown_and_flush_sec": GLOBAL_STOP_GRACE_SEC,
		"max_concurrent_trials": 1,
		"pilot_global_levels": _resolve_level_ids(options),
		"source_sha256": source_hashes,
		"source_hash_digest_sha256": source_hash_digest,
	}
	var metadata_path := output_path.get_base_dir().path_join("run_metadata_%s.json" % output_path.get_file().get_basename())
	var metadata := FileAccess.open(metadata_path, FileAccess.WRITE)
	if metadata != null:
		metadata.store_string(JSON.stringify(identity, "\t") + "\n")
		metadata.flush()
		metadata.close()
	print("M33_R02_RUN_IDENTITY=%s" % JSON.stringify(identity))

	var processed := _load_processed(output_absolute)
	var trial_rows: Array[Dictionary] = []
	for global_id in _resolve_level_ids(options):
		var mapping := _map_global_level(global_id)
		var definition: Dictionary = database.get_level(str(mapping["island_id"]), int(mapping["local_level_id"]))
		if definition.is_empty():
			var invalid := _base_row(global_id, mapping, -1, 0, 0)
			invalid["trial_outcome"] = "error"
			invalid["qualification_status"] = "VERIFIED_DATA_INVALID"
			invalid["error"] = "canonical runtime database did not return the expected record"
			_write_row(output, invalid)
			trial_rows.append(invalid)
			continue
		var normal_cost := MODEL_SCRIPT.normal_objective_cost(definition)
		var normal_t := int(ceil(float(normal_cost) / 4.0))
		var shot_budget := int(ceil(float(normal_cost) * 3.0 / 7.0))
		if global_id == 101:
			shot_budget = maxi(12, shot_budget)
		var seed_value: int = 33050200 if global_id == 101 else SEED_BASE + global_id * 100
		var checkpoint_key := _checkpoint_key(global_id, seed_value, shot_budget, source_hash_digest)
		if processed.has(checkpoint_key):
			continue
		var remaining_global_sec := total_budget_sec - float(Time.get_ticks_msec() - _started_msec) / 1000.0
		if remaining_global_sec <= GLOBAL_STOP_GRACE_SEC:
			_stop_reason = "GLOBAL_WALL_BUDGET_BEFORE_TRIAL"
			var skipped := _base_row(global_id, mapping, seed_value, shot_budget, 0)
			skipped["trial_outcome"] = "not_run"
			skipped["qualification_status"] = "NOT_RUN/ERROR"
			skipped["terminal_reason"] = _stop_reason
			_write_row(output, skipped)
			trial_rows.append(skipped)
			continue
		var target_wall_sec := float(shot_budget) * WALL_HEADROOM_FACTOR
		if global_id == 101:
			target_wall_sec = maxf(20.0, target_wall_sec)
		var requested_trial_wall_sec := minf(remaining_global_sec - GLOBAL_STOP_GRACE_SEC, target_wall_sec)
		print("M33_R02_TRIAL global=%d island=%s local=%d T=%d shot_budget=%d wall_budget_sec=%.2f seed=%d" % [global_id, mapping["island_id"], mapping["local_level_id"], normal_t, shot_budget, requested_trial_wall_sec, seed_value])
		var trial_started := Time.get_ticks_msec()
		var trial: Dictionary = await harness.run_trial(
			database,
			str(mapping["island_id"]),
			int(mapping["local_level_id"]),
			seed_value,
			[],
			POLICY,
			shot_budget,
			true,
			true,
			requested_trial_wall_sec
		)
		var wall_ms := Time.get_ticks_msec() - trial_started
		var row := _base_row(global_id, mapping, seed_value, shot_budget, wall_ms)
		row["manifest_sha256"] = str(source_hashes[MANIFEST_PATH])
		row["source_hash_digest_sha256"] = source_hash_digest
		row["difficulty_band"] = str(definition.get("difficulty_band", definition.get("difficulty_tier", "UNSPECIFIED")))
		row["normal_T"] = normal_t
		row["normal_order_L1_equivalent_cost"] = normal_cost
		row["vip_T_optional_separate"] = int(MODEL_SCRIPT.vip_objective_cost(definition) / 4)
		row["theoretical_T_total_for_move_limit"] = int(definition.get("theoretical_shots_total", 0))
		row["canonical_move_limit_4T"] = int(definition.get("move_limit", 0))
		row["canonical_time_limit_sec"] = float(definition.get("time_limit_sec", 0.0))
		row["trial_outcome"] = _trial_outcome(trial)
		row["telemetry_valid"] = HARNESS_SCRIPT.new(root).validate_telemetry(trial).is_empty()
		row["qualification_status"] = "PROVEN_REACHABLE_IN_BOUNDED_TRIAL" if row["trial_outcome"] == "completed" and bool(row["telemetry_valid"]) else "NOT_COMPLETED_WITHIN_BUDGET" if row["trial_outcome"] == "exhausted-budget" else "NOT_RUN/ERROR"
		row["shot_count"] = int(trial.get("shot_count", 0))
		row["simulated_seconds"] = float(trial.get("elapsed_sec", 0.0))
		row["requested_trial_wall_budget_sec"] = requested_trial_wall_sec
		row["moves_used"] = int(trial.get("moves_used", 0))
		row["moves_remaining"] = int(trial.get("moves_remaining", 0))
		row["normal_objective_complete"] = bool(trial.get("normal_objective_complete", false))
		row["normal_orders_completed"] = trial.get("normal_orders_completed", {})
		row["normal_orders_remaining"] = trial.get("normal_orders_remaining", {})
		row["vip_optional_status"] = trial.get("vip_state", {})
		row["star_result"] = int(trial.get("stars", 0))
		row["merge_count"] = int(trial.get("merge_count", 0))
		row["failed_merge_approach_count"] = int(trial.get("failed_merge_approach_count", 0))
		row["danger_line_exposure_sec"] = float(trial.get("danger_line_exposure_sec", 0.0))
		row["peak_live_drinks"] = int(trial.get("peak_live_drinks", 0))
		row["progress_curve"] = trial.get("progress_curve", [])
		row["action_log_sha256"] = _sha256_text(JSON.stringify(trial.get("action_log", [])))
		row["progress_curve_sha256"] = _sha256_text(JSON.stringify(row["progress_curve"]))
		row["terminal_reason"] = str(trial.get("terminal_reason", ""))
		row["policy_name"] = POLICY
		row["seed_count"] = 1
		row["known_impossible"] = false
		_write_row(output, row)
		trial_rows.append(row)
		processed[checkpoint_key] = true
		print("M33_R02_RESULT global=%d status=%s shots=%d/%d T_progress=%d/%d moves=%d wall_ms=%d sim_sec=%.2f merges=%d" % [global_id, row["qualification_status"], row["shot_count"], shot_budget, int(row["progress_curve"].back().get("normal_T_progressed", 0)) if not row["progress_curve"].is_empty() else 0, normal_t, row["moves_used"], wall_ms, row["simulated_seconds"], row["merge_count"]])
		if float(Time.get_ticks_msec() - _started_msec) / 1000.0 >= total_budget_sec:
			_stop_reason = "GLOBAL_WALL_BUDGET"

	output.flush()
	output.close()
	print("M33_R02_BATCH_EXECUTION=COMPLETE trials=%d global_elapsed_sec=%.3f stop_reason=%s" % [trial_rows.size(), float(Time.get_ticks_msec() - _started_msec) / 1000.0, _stop_reason if not _stop_reason.is_empty() else "PILOT_COMPLETE_OR_CHECKPOINT_RESUME"])
	quit(0)


func _parse_options(arguments: PackedStringArray) -> Dictionary:
	var result := {}
	for argument in arguments:
		if argument.begins_with("--") and argument.contains("="):
			var pieces := argument.trim_prefix("--").split("=", false, 1)
			if pieces.size() == 2:
				result[pieces[0]] = pieces[1]
	return result


func _map_global_level(global_id: int) -> Dictionary:
	var index := clampi(int(floor(float(global_id - 1) / 100.0)), 0, ISLANDS.size() - 1)
	return {"island_id": ISLANDS[index], "local_level_id": ((global_id - 1) % 100) + 1}


func _resolve_level_ids(options: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if options.has("level-list"):
		for raw in str(options["level-list"]).split(",", false):
			var global_id := str(raw).to_int()
			if global_id >= 101 and global_id <= 1000 and not result.has(global_id):
				result.append(global_id)
		return result
	for global_id in PILOT_LEVELS:
		result.append(global_id)
	return result


func _base_row(global_id: int, mapping: Dictionary, seed_value: int, shot_budget: int, wall_ms: int) -> Dictionary:
	return {
		"schema_version": 1,
		"runner_version": RUNNER_VERSION,
		"global_level_id": global_id,
		"island_id": str(mapping.get("island_id", "")),
		"local_level_id": int(mapping.get("local_level_id", 0)),
		"seed": seed_value,
		"seed_formula": "known successful R01 Tiki control seed 33050200" if global_id == 101 else "SEED_BASE + global_level_id * 100; seed_base=%d" % SEED_BASE,
		"shot_budget": shot_budget,
		"wall_milliseconds": wall_ms,
	}


func _trial_outcome(trial: Dictionary) -> String:
	if bool(trial.get("normal_objective_complete", false)) and str(trial.get("outcome", "")) == "completed":
		return "completed"
	if str(trial.get("terminal_reason", "")) in ["PER_LEVEL_SHOT_BUDGET", "PER_LEVEL_WALL_BUDGET", "MOVE_BUDGET_EXHAUSTED", "ACTION_BUDGET"] or str(trial.get("outcome", "")) in ["danger", "timeout"]:
		return "exhausted-budget"
	return "error"


func _source_hashes() -> Dictionary:
	var paths := [
		"res://tools/campaign/m33_r02_calibration_pilot.gd",
		"res://tools/campaign/m33_r02_static_diagnosis.gd",
		"res://tools/generate_m33_campaign_content.py",
		"res://tools/validate_m33_campaign_content.py",
		"res://scripts/campaign/m17_seeded_validation_harness.gd",
		"res://scripts/campaign/level_database.gd",
		"res://scripts/campaign/m17_difficulty_model.gd",
		"res://scripts/campaign/m17_canonical_screening_model.gd",
		"res://scripts/campaign/m17_vip_optionality_model.gd",
		"res://scripts/game_manager.gd",
		"res://scripts/shot_controller.gd",
		"res://scripts/drink.gd",
		"res://scripts/merge_queue.gd",
		"res://scripts/campaign/gameplay_session_bridge.gd",
		"res://tests/m33_tiki_compatibility_probe.gd",
		"res://tests/m17_vip_optionality_probe.gd",
		"res://data/campaign/content_generation_profiles_m33.json",
		"res://data/campaign/islands.json",
		MANIFEST_PATH,
	]
	for level_path in LEVEL_PATHS:
		paths.append(level_path)
	var hashes := {}
	for path in paths:
		hashes[path] = _sha256(path)
	return hashes


func _checkpoint_key(global_id: int, seed_value: int, shot_budget: int, source_hash_digest: String) -> String:
	return "%s|%d|%d|%d|%s|%s" % [RUNNER_VERSION, global_id, seed_value, shot_budget, source_hash_digest, POLICY]


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
		var value = JSON.parse_string(line)
		if value is Dictionary:
			result[_checkpoint_key(int(value.get("global_level_id", 0)), int(value.get("seed", 0)), int(value.get("shot_budget", 0)), str(value.get("source_hash_digest_sha256", "")))] = true
	file.close()
	return result


func _open_append_preserving(path: String) -> FileAccess:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null and FileAccess.get_open_error() == ERR_FILE_NOT_FOUND:
		var create := FileAccess.open(path, FileAccess.WRITE)
		if create == null:
			return null
		create.close()
		file = FileAccess.open(path, FileAccess.READ_WRITE)
	return file


func _write_row(file: FileAccess, row: Dictionary) -> void:
	file.store_line(JSON.stringify(row))
	file.flush()


func _sha256(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode().to_upper()


func _sha256_text(value: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(value.to_utf8_buffer())
	return context.finish().hex_encode().to_upper()
