extends SceneTree

## BCM-M17 V06 Child 02 analytical-map and post-V05 reserve probe.
## This probe is read-only and writes no V06 report or canonical data.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const V04_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.json"
const V05_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M17_V06_ANALYTICAL PASS: %s" % label)
	else:
		failures.append(label)
		print("M17_V06_ANALYTICAL FAIL: %s" % label)


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(FileAccess.get_file_as_bytes(path))
	return context.finish().hex_encode().to_upper()


func _load_json(path: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


func _run() -> void:
	var before_hash := _sha256(LEVELS_PATH)
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove loads in FULL mode", database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL))
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	var classes: Array[Dictionary] = MODEL_SCRIPT.build_challenge_classes(levels)
	_check("canonical dataset has exactly 100 levels", levels.size() == 100)
	_check("canonical dataset has exactly 45 challenge classes", classes.size() == 45)
	_check("all levels map once and class representatives are lowest IDs", _mapping_is_exact(classes, levels))
	var all_reachable := true
	for level in levels:
		all_reachable = all_reachable and bool(MODEL_SCRIPT.level_reachability(level, 12).get("valid", false))
	_check("all normal objectives are reachable with positive quantities and timers", all_reachable)
	var timer_scan := MODEL_SCRIPT.timer_scan(levels)
	_check("timer/cost scan covers all levels", timer_scan.get("levels", []).size() == 100)
	var no_fabricated_impossibility := true
	for record in timer_scan.get("levels", []):
		no_fabricated_impossibility = no_fabricated_impossibility and not bool(record.get("mathematically_unreachable_from_timer", false))
	_check("timer scan does not invent strict impossibility", no_fabricated_impossibility)
	var v04 := _load_json(V04_PATH)
	var v05 := _load_json(V05_PATH)
	_check("V04 historical report is present and distinct", not v04.is_empty() and _sha256(V04_PATH) != _sha256(V05_PATH))
	_check("V05 post-fix forced result is 0/25", int(v05.get("post_v05_forced_capture_count", -1)) == 0 and int(v05.get("post_v05_forced_capture_denominator", -1)) == 25)
	_check("V05 post-fix surplus result is 25/25", int(v05.get("post_v05_surplus_path_count", -1)) == 25 and int(v05.get("post_v05_surplus_path_denominator", -1)) == 25)
	_check("V05 reports no validation errors", (v05.get("validation_errors", []) as Array).is_empty())
	_check("canonical Sunny Cove JSON is byte-for-byte unchanged", _sha256(LEVELS_PATH) == before_hash)
	if failures.is_empty():
		print("M17_V06_ANALYTICAL_RESULT=PASS levels=%d classes=%d" % [levels.size(), classes.size()])
		quit(0)
		return
	print("M17_V06_ANALYTICAL_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _mapping_is_exact(classes: Array[Dictionary], levels: Array[Dictionary]) -> bool:
	var seen: Dictionary = {}
	for class_record in classes:
		var members: Array = class_record.get("member_level_ids", [])
		if members.is_empty() or int(class_record.get("representative", 0)) != int(members[0]):
			return false
		for level_id in members:
			if seen.has(int(level_id)):
				return false
			seen[int(level_id)] = true
	return seen.size() == levels.size()
