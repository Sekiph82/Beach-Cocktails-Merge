extends SceneTree

## Focused M17 model, schema, replay, and immutability probe.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const CANONICAL_LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M17_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M17_PROBE FAIL: %s" % label)


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode()


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove loads in FULL validation mode", database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL))
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	_check("canonical Sunny Cove has 100 levels", levels.size() == 100)
	if levels.size() < 100:
		print("M17_DIFFICULTY_VALIDATION_RESULT=FAIL failures=%s" % str(failures))
		quit(1)
		return
	_check("L1 objective cost is 16", MODEL_SCRIPT.normal_objective_cost(levels[0]) == 16)
	_check("L100 objective cost is 240", MODEL_SCRIPT.normal_objective_cost(levels[99]) == 240)
	_check("VIP cost is separate", MODEL_SCRIPT.vip_objective_cost(levels[3]) == 16 and MODEL_SCRIPT.normal_objective_cost(levels[3]) == 32)
	_check("expected L1-equivalent spawn value is 7/3", is_equal_approx(MODEL_SCRIPT.EXPECTED_SPAWN_VALUE_L1_EQUIVALENT, 7.0 / 3.0))
	var default_timer := MODEL_SCRIPT.timer_calculation(levels[0])
	var override_timer := MODEL_SCRIPT.timer_calculation(levels[0], 2.0)
	_check("timer exposes named calibration", is_equal_approx(float(default_timer["seconds_per_launch_calibration"]), MODEL_SCRIPT.DEFAULT_SECONDS_PER_LAUNCH))
	_check("timer calibration override changes raw and target time", not is_equal_approx(float(default_timer["raw_calculated_production_time_sec"]), float(override_timer["raw_calculated_production_time_sec"])) and not is_equal_approx(float(default_timer["planning_target_time_sec"]), float(override_timer["planning_target_time_sec"])))
	_check("percentile uses deterministic R7 interpolation", is_equal_approx(MODEL_SCRIPT.percentile([1, 2, 3, 4], 0.75), 3.25))

	var before_hash := _sha256(CANONICAL_LEVELS_PATH)
	var harness = HARNESS_SCRIPT.new(root)
	var schema_record: Dictionary = harness.new_telemetry("sunny_cove", 1, 17017001)
	_check("telemetry schema is complete", harness.validate_telemetry(schema_record).is_empty())
	var first: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017001)
	var second: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017001)
	_check("same seed produces the same action log", first["action_log"] == second["action_log"])
	_check("same seed preserves logical outcome", first["outcome"] == second["outcome"])
	var replay: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017001, first["action_log"])
	_check("exact action-log replay preserves logical result", replay["outcome"] == first["outcome"] and replay["merge_count"] == first["merge_count"])
	var different: Dictionary = await harness.run_trial(database, "sunny_cove", 1, 17017002)
	_check("different seed changes the seeded action sequence", different["action_log"] != first["action_log"])
	_check("focused trial telemetry validates", harness.validate_telemetry(first).is_empty())
	_check("canonical Sunny Cove JSON is byte-for-byte unchanged", _sha256(CANONICAL_LEVELS_PATH) == before_hash)

	if failures.is_empty():
		print("M17_DIFFICULTY_VALIDATION_RESULT=PASS")
		quit(0)
		return
	print("M17_DIFFICULTY_VALIDATION_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
