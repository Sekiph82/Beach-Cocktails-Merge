extends SceneTree

const LEVEL_DB := preload("res://scripts/campaign/level_database.gd")
const HARNESS := preload("res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-100-STAR/runners/m25_move100_physics_harness.gd")
const CLASS_REPORT_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.json"

var output_dir := ""
var failures: Array[String] = []

func _initialize() -> void:
	print("CAL02_RUNNER_BOOT")
	output_dir = OS.get_environment("M25_CAL02_OUTPUT").strip_edges()
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-CAL02/runs")
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output_dir)
	var database = LEVEL_DB.new()
	if not database.load_canonical():
		_fail("canonical database load failed: %s" % database.get_last_error())
		quit(1)
		return
	var class_file := FileAccess.open(CLASS_REPORT_PATH, FileAccess.READ)
	if class_file == null:
		_fail("could not read M17 class report")
		quit(1)
		return
	var report: Variant = JSON.parse_string(class_file.get_as_text())
	class_file.close()
	if not report is Dictionary or int(report.get("challenge_class_count", 0)) != 45:
		_fail("expected canonical report with exactly 45 challenge classes")
		quit(1)
		return
	var classes: Array = report.get("challenge_classes", [])
	var seeds := _parse_ints(OS.get_environment("M25_CAL02_SEEDS"), [31001, 31002])
	var policies := _parse_strings(OS.get_environment("M25_CAL02_POLICIES"), ["WEAK_V02", "MERGE_AWARE_V01"])
	var class_filter := _parse_strings(OS.get_environment("M25_CAL02_CLASS_IDS"), [])
	var limit := int(OS.get_environment("M25_CAL02_TRIAL_LIMIT"))
	var trial_path := output_dir.path_join("trials.jsonl")
	var completed := _load_completed_keys(trial_path)
	var harness = HARNESS.new(root)
	harness.set_time_scale(1.0)
	var written := 0
	var total_skipped := 0
	for class_record in classes:
		if not class_record is Dictionary:
			continue
		var class_id := str(class_record.get("class_id", ""))
		if not class_filter.is_empty() and not class_filter.has(class_id):
			continue
		var level_id := int(class_record.get("representative", 0))
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		if class_id.is_empty() or definition.is_empty():
			_fail("invalid class mapping: %s/%d" % [class_id, level_id])
			continue
		for policy in policies:
			for seed_value in seeds:
				var key := _trial_key(class_id, policy, seed_value)
				if completed.has(key):
					total_skipped += 1
					continue
				var wall_start := Time.get_ticks_msec()
				var result: Dictionary = await harness.run_trial(database, "sunny_cove", level_id, seed_value, [], policy)
				var wall_ms := Time.get_ticks_msec() - wall_start
				var vip: Variant = definition.get("vip", null)
				var vip_enabled := vip is Dictionary and bool(vip.get("enabled", false))
				var trial := {
					"schema_version": 1,
					"class_id": class_id,
					"representative_level_id": level_id,
					"member_level_ids": class_record.get("member_level_ids", []),
					"seed": seed_value,
					"policy": policy,
					"outcome": result.get("outcome", ""),
					"terminal_reason": result.get("terminal_reason", ""),
					"moves": int(result.get("shot_count", 0)),
					"merge_count": int(result.get("merge_count", 0)),
					"simulated_elapsed_sec": float(result.get("elapsed_sec", 0.0)),
					"wall_ms": wall_ms,
					"normal_objective_complete": bool(result.get("normal_objective_complete", false)),
					"vip_enabled": vip_enabled,
					"vip_config": vip if vip_enabled else {},
					"vip_complete": bool(result.get("vip_complete", false)),
					"time_limit_sec": float(definition.get("time_limit_sec", 0.0)),
					"physics_hook": result.get("physics_hook", ""),
					"action_log": result.get("action_log", []),
				}
				if not _append_jsonl(trial_path, trial):
					_fail("could not checkpoint trial %s" % key)
					quit(1)
					return
				completed[key] = true
				written += 1
				_write_run_status(classes.size(), policies, seeds, written, total_skipped, completed.size())
				print("CAL02_TRIAL class=%s level=%d policy=%s seed=%d outcome=%s moves=%d wall_ms=%d vip=%s" % [class_id, level_id, policy, seed_value, trial.outcome, trial.moves, wall_ms, str(vip_enabled)])
				if limit > 0 and written >= limit:
					_write_run_status(classes.size(), policies, seeds, written, total_skipped, completed.size())
					print("CAL02_CHECKPOINT written=%d skipped=%d total_keys=%d" % [written, total_skipped, completed.size()])
					quit(0)
					return
	_write_run_status(classes.size(), policies, seeds, written, total_skipped, completed.size())
	print("CAL02_BATCH_RESULT %s written=%d skipped=%d total_keys=%d failures=%d" % ["PASS" if failures.is_empty() else "FAIL", written, total_skipped, completed.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func _trial_key(class_id: String, policy: String, seed_value: int) -> String:
	return "%s|%s|%d" % [class_id, policy, seed_value]

func _load_completed_keys(path: String) -> Dictionary:
	var keys := {}
	if not FileAccess.file_exists(path):
		return keys
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("could not read existing JSONL checkpoint")
		return keys
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var value: Variant = JSON.parse_string(line)
		if value is Dictionary and value.has_all(["class_id", "policy", "seed", "outcome"]):
			keys[_trial_key(str(value.class_id), str(value.policy), int(value.seed))] = true
	file.close()
	return keys

func _append_jsonl(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.READ_WRITE) if FileAccess.file_exists(path) else FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.seek_end()
	file.store_string(JSON.stringify(value) + "\n")
	file.flush()
	file.close()
	return true

func _write_run_status(class_count: int, policies: Array, seeds: Array, written: int, skipped: int, completed_count: int) -> void:
	var status := {
		"work_item": "BCM-M25-CAL02",
		"class_report": CLASS_REPORT_PATH,
		"expected_class_count": class_count,
		"policies": policies,
		"seeds": seeds,
		"requested_key_count": class_count * policies.size() * seeds.size(),
		"written_this_invocation": written,
		"skipped_existing_this_invocation": skipped,
		"unique_completed_keys": completed_count,
		"physics_time_scale": 1.0,
		"physics_frames_per_action": 60,
		"checkpoint_path": "trials.jsonl",
		"failures": failures,
	}
	var file := FileAccess.open(output_dir.path_join("run_status.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(status, "\t") + "\n")
		file.close()

func _parse_ints(raw: String, fallback: Array[int]) -> Array[int]:
	if raw.strip_edges().is_empty():
		return fallback
	var values: Array[int] = []
	for part in raw.split(",", false):
		var parsed := part.strip_edges().to_int()
		if parsed > 0 and not values.has(parsed):
			values.append(parsed)
	return values if not values.is_empty() else fallback

func _parse_strings(raw: String, fallback: Array[String]) -> Array[String]:
	if raw.strip_edges().is_empty():
		return fallback
	var values: Array[String] = []
	for part in raw.split(",", false):
		var parsed := part.strip_edges()
		if not parsed.is_empty() and not values.has(parsed):
			values.append(parsed)
	return values if not values.is_empty() else fallback

func _fail(reason: String) -> void:
	failures.append(reason)
	push_error(reason)
