extends SceneTree

## Bounded, resumable R11 mechanical path sampling. Every candidate action is
## committed through production ShotController and resolved by production
## Drink/GameManager physics. This runner cannot prove impossibility.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")
const R10_REPORT_PATH := "res://coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R10/offline_gameplay_quality.json"
const OUTPUT_DIR := "res://coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R11"
const SUMMARY_PATH := OUTPUT_DIR + "/mechanical_coverage_summary.json"
const CSV_PATH := OUTPUT_DIR + "/mechanical_coverage_static_1000.csv"
const CHECKPOINT_A_PATH := OUTPUT_DIR + "/checkpoint_a.json"
const CHECKPOINT_B_PATH := OUTPUT_DIR + "/checkpoint_b.json"
const STOP_FLAG_PATH := OUTPUT_DIR + "/STOP"
const POLICY_CHEAP := HARNESS_SCRIPT.POLICY_CHEAP_MERGE_CENTER_V01
const POLICY_MERGE_AWARE := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const PROFILE_WALL_LIMIT_SEC := 0.65
const TRIAL_WALL_LIMIT_SEC := 5.0
const TOTAL_WALL_LIMIT_SEC := 480.0
const SEED_BASE := 34110000
const MID_LEVEL_ID := 50

const PROFILE_VARIANTS := [
	{"id": "MERGE_AWARE_UNCACHED", "policy": POLICY_MERGE_AWARE, "cache": false},
	{"id": "MERGE_AWARE_CACHED", "policy": POLICY_MERGE_AWARE, "cache": true},
	{"id": "CHEAP_MERGE_CENTER_CACHED", "policy": POLICY_CHEAP, "cache": true},
]
const COVERAGE_VARIANTS := [
	{"id": "CHEAP_MERGE_CENTER_CACHED", "policy": POLICY_CHEAP, "cache": true},
	{"id": "MERGE_AWARE_CACHED", "policy": POLICY_MERGE_AWARE, "cache": true},
]

var _checkpoint: Dictionary = {}
var _checkpoint_slot := ""
var _sequence := 0
var _session_started_unix := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _ensure_output_dir():
		quit(1)
		return
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(
		DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
		DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS,
		DATABASE_SCRIPT.ValidationMode.FULL
	):
		push_error("M34-R11 full campaign load failed: %s" % database.get_last_error())
		quit(1)
		return
	var config := _configuration(database)
	if not _load_or_create_checkpoint(config):
		quit(1)
		return
	var static_scan := _scan_all_levels(database)
	_checkpoint["static_summary"] = static_scan.get("summary", {})
	_checkpoint["static_errors"] = static_scan.get("errors", [])
	if not bool(static_scan.get("ok", false)):
		_checkpoint["status"] = "STATIC_VALIDATION_FAILED"
		_save_checkpoint()
		_write_csv(static_scan.get("rows", []))
		_write_summary()
		push_error("R11 static validation failed: %s" % _checkpoint["static_errors"])
		quit(1)
		return
	_write_csv(static_scan["rows"])
	if not _checkpoint["profile_complete"]:
		await _run_profiles(database)
	if not _checkpoint["coverage_complete"]:
		await _run_coverage(database)
	if bool(_checkpoint.get("stop_requested", false)):
		_checkpoint["status"] = "STOPPED_BY_FLAG"
	elif _elapsed_session_sec() >= TOTAL_WALL_LIMIT_SEC:
		_checkpoint["status"] = "STOPPED_AT_GLOBAL_WALL_BUDGET"
	elif bool(_checkpoint.get("profile_complete", false)) and bool(_checkpoint.get("coverage_complete", false)):
		_checkpoint["status"] = "COMPLETE_BOUNDED_SAMPLE"
	else:
		_checkpoint["status"] = "PARTIAL_BOUNDED_SAMPLE"
	_checkpoint["session_elapsed_wall_sec"] = snappedf(_elapsed_session_sec(), 0.01)
	_sanitize_profile_records()
	_save_checkpoint()
	_write_summary()
	_print_aggregate()
	quit(0)


func _configuration(database) -> Dictionary:
	var ordered_islands: Array[String] = database.get_island_ids_in_order()
	var r10_data := _read_json(R10_REPORT_PATH)
	var r10_unknowns: Array[Dictionary] = []
	for trial in r10_data.get("trials", []):
		if str(trial.get("classification", "")).begins_with("UNVERIFIED"):
			r10_unknowns.append({
				"island_id": str(trial.get("island_id", "")),
				"level_id": int(trial.get("level_id", 0)),
			})
	r10_unknowns.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ai := ordered_islands.find(str(a["island_id"]))
		var bi := ordered_islands.find(str(b["island_id"]))
		return ai < bi if ai != bi else int(a["level_id"]) < int(b["level_id"])
	)
	var profile_variants: Array[Dictionary] = []
	for variant in PROFILE_VARIANTS:
		profile_variants.append(variant.duplicate(true))
	var coverage_variants: Array[Dictionary] = []
	for variant in COVERAGE_VARIANTS:
		coverage_variants.append(variant.duplicate(true))
	return {
		"schema_version": 1,
		"work_item": "BCM-M34-R11-001..005",
		"island_ids_in_order": ordered_islands,
		"r10_unverified_cases": r10_unknowns,
		"mid_level_id": MID_LEVEL_ID,
		"profile_variants": profile_variants,
		"coverage_variants": coverage_variants,
		"profile_per_trial_wall_sec": PROFILE_WALL_LIMIT_SEC,
		"coverage_per_trial_wall_sec": TRIAL_WALL_LIMIT_SEC,
		"aggregate_wall_budget_sec": TOTAL_WALL_LIMIT_SEC,
		"time_scale": 1.0,
		"timer_disabled": true,
		"production_shot_controller": true,
		"legal_launch_geometry_cache": "per trial, keyed by spawn drink level; each lane derives from production footprint and boundary tests",
		"seed_formula": "34110000 + canonical_island_order_index*1000 + level_id; identical seed across policies for paired comparison",
		"trial_classifications": ["PROVED_PATH_WIN", "BUDGET_UNKNOWN", "NOT_RUN"],
		"impossibility_claim_policy": "PROVED_IMPOSSIBLE is never emitted; the finite deterministic candidates do not constitute exhaustive proof",
		"stop_flag_path": STOP_FLAG_PATH,
		"resume_policy": "two-slot sequence checkpoint; matching config resumes and preserves unique completed trial IDs",
	}


func _load_or_create_checkpoint(config: Dictionary) -> bool:
	var config_json := JSON.stringify(config)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(config_json.to_utf8_buffer())
	var config_hash := context.finish().hex_encode()
	var candidates: Array[Dictionary] = []
	for path in [CHECKPOINT_A_PATH, CHECKPOINT_B_PATH]:
		var candidate := _read_json(path)
		if not candidate.is_empty() and str(candidate.get("config_hash", "")) == config_hash:
			candidates.append(candidate)
		elif FileAccess.file_exists(path):
			push_error("R11 checkpoint exists but has a different configuration: %s" % path)
			return false
	if not candidates.is_empty():
		candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("sequence", 0)) > int(b.get("sequence", 0))
		)
		_checkpoint = candidates[0]
		_checkpoint_slot = str(_checkpoint.get("checkpoint_slot", ""))
		_sequence = int(_checkpoint.get("sequence", 0))
		_session_started_unix = int(_checkpoint.get("session_started_unix", Time.get_unix_time_from_system()))
		print("M34_R11_RESUME sequence=%d profile_trials=%d coverage_levels=%d elapsed=%.1fs" % [
			_sequence,
			_checkpoint.get("profile_trials", []).size(),
			_checkpoint.get("coverage_levels", {}).size(),
			_elapsed_session_sec(),
		])
		return true
	_session_started_unix = int(Time.get_unix_time_from_system())
	_checkpoint = {
		"schema_version": 1,
		"config_hash": config_hash,
		"configuration": config,
		"sequence": 0,
		"checkpoint_slot": "",
		"session_started_unix": _session_started_unix,
		"profile_trials": [],
		"coverage_levels": {},
		"profile_complete": false,
		"coverage_complete": false,
		"stop_requested": false,
		"status": "RUNNING",
	}
	_save_checkpoint()
	return true


func _scan_all_levels(database) -> Dictionary:
	var errors: Array[String] = []
	var rows: Array[Dictionary] = []
	var seen_save_ids: Dictionary = {}
	var static_summary := {
		"island_count": 0,
		"level_count": 0,
		"normal_order_rows": 0,
		"vip_enabled_levels": 0,
		"timed_records": 0,
		"move_cap_4t_failures": 0,
		"star_contract_failures": 0,
		"save_identifier_failures": 0,
		"dynamic_resource_failures": 0,
		"normal_T_min": 0,
		"normal_T_max": 0,
		"total_T_min": 0,
		"total_T_max": 0,
	}
	var all_normal_t: Array[int] = []
	var all_total_t: Array[int] = []
	var bridge = BRIDGE_SCRIPT.new()
	var island_ids: Array[String] = database.get_island_ids_in_order()
	static_summary["island_count"] = island_ids.size()
	for island_index in range(island_ids.size()):
		var island_id := island_ids[island_index]
		var island: Dictionary = database.get_island(island_id)
		var theme: Dictionary = island.get("theme", {})
		var island_resources_ok := _resource_exists(str(theme.get("gameplay_surface", ""))) and _resource_exists(str(theme.get("playable_geometry_profile", ""))) and _resource_exists(str(theme.get("island_map_background", "")))
		for level_id in range(1, 101):
			var level: Dictionary = database.get_level(island_id, level_id)
			if level.is_empty():
				errors.append("missing level %s/%d" % [island_id, level_id])
				continue
			var stable_id := island_index * 100 + level_id
			var stored_id := int(level.get("global_level_id", stable_id))
			var save_id_ok := stored_id == stable_id and not seen_save_ids.has(stable_id)
			if not save_id_ok:
				static_summary["save_identifier_failures"] = int(static_summary["save_identifier_failures"]) + 1
				errors.append("global save ID mismatch/duplicate %s/%d stored=%d expected=%d" % [island_id, level_id, stored_id, stable_id])
			seen_save_ids[stable_id] = true
			var normal_t := 0
			var normal_rows: Array = level.get("orders", [])
			var resources_ok := island_resources_ok
			for order in normal_rows:
				var cocktail_level := int(order.get("cocktail_level", 0))
				var quantity := int(order.get("quantity", 0))
				normal_t += _ideal_shots(cocktail_level, quantity)
				static_summary["normal_order_rows"] = int(static_summary["normal_order_rows"]) + 1
				resources_ok = resources_ok and _cocktail_resource_exists(cocktail_level)
			var vip_t := 0
			var vip_enabled := false
			var vip: Variant = level.get("vip", null)
			if vip is Dictionary and bool(vip.get("enabled", true)):
				vip_enabled = true
				vip_t = _ideal_shots(int(vip.get("cocktail_level", 0)), int(vip.get("quantity", 0)))
				resources_ok = resources_ok and _cocktail_resource_exists(int(vip.get("cocktail_level", 0)))
				static_summary["vip_enabled_levels"] = int(static_summary["vip_enabled_levels"]) + 1
			for starter in level.get("initial_tabletop_drinks", []):
				resources_ok = resources_ok and _cocktail_resource_exists(int(starter.get("cocktail_level", 0)))
			var total_t := normal_t + vip_t
			var move_limit := int(level.get("move_limit", -1))
			var cap_ok := total_t > 0 and move_limit == 4 * total_t and int(level.get("theoretical_shots_to_go", -1)) == normal_t and int(level.get("theoretical_shots_vip", -1)) == vip_t and int(level.get("theoretical_shots_total", -1)) == total_t
			if not cap_ok:
				static_summary["move_cap_4t_failures"] = int(static_summary["move_cap_4t_failures"]) + 1
				errors.append("4T/derived objective mismatch %s/%d" % [island_id, level_id])
			var no_timer := float(level.get("time_limit_sec", -1.0)) == 0.0 and not bool(level.get("feature_flags", {}).get("timed", false))
			if not no_timer:
				static_summary["timed_records"] = int(static_summary["timed_records"]) + 1
				errors.append("timer flag or limit present %s/%d" % [island_id, level_id])
			var stars_ok := _star_contract_ok(bridge, total_t)
			if not stars_ok:
				static_summary["star_contract_failures"] = int(static_summary["star_contract_failures"]) + 1
				errors.append("move-star boundary mismatch %s/%d" % [island_id, level_id])
			if not resources_ok:
				static_summary["dynamic_resource_failures"] = int(static_summary["dynamic_resource_failures"]) + 1
				errors.append("dynamic campaign resource missing %s/%d" % [island_id, level_id])
			all_normal_t.append(normal_t)
			all_total_t.append(total_t)
			rows.append({
				"island_id": island_id,
				"level_id": level_id,
				"global_level_id": stable_id,
				"save_identifier_ok": save_id_ok,
				"stratum": "EARLY" if level_id <= 10 else ("MID" if level_id >= 45 and level_id <= 55 else ("LATE" if level_id >= 90 else "OTHER")),
				"normal_order_rows": normal_rows.size(),
				"normal_T": normal_t,
				"vip_enabled_optional": vip_enabled,
				"vip_T_in_denominator": vip_t,
				"total_T": total_t,
				"move_limit": move_limit,
				"move_limit_equals_4T": cap_ok,
				"stars_3_before_2T": _stars_at(bridge, total_t, 2 * total_t - 1) == 3,
				"stars_2_before_3T": _stars_at(bridge, total_t, 3 * total_t - 1) == 2,
				"stars_1_at_4T": _stars_at(bridge, total_t, 4 * total_t) == 1,
				"untimed": no_timer,
				"dynamic_resources_resolve": resources_ok,
				"static_status": "PASS" if cap_ok and no_timer and stars_ok and resources_ok and save_id_ok else "FAIL",
			})
	static_summary["level_count"] = rows.size()
	static_summary["normal_T_min"] = _min_int(all_normal_t)
	static_summary["normal_T_max"] = _max_int(all_normal_t)
	static_summary["total_T_min"] = _min_int(all_total_t)
	static_summary["total_T_max"] = _max_int(all_total_t)
	if island_ids.size() != 10 or rows.size() != 1000 or seen_save_ids.size() != 1000:
		errors.append("canonical coverage count mismatch islands=%d records=%d save_ids=%d" % [island_ids.size(), rows.size(), seen_save_ids.size()])
	return {"ok": errors.is_empty(), "summary": static_summary, "errors": errors, "rows": rows}


func _star_contract_ok(bridge, theoretical_shots: int) -> bool:
	if theoretical_shots <= 0:
		return false
	return (
		_stars_at(bridge, theoretical_shots, 0) == 3
		and _stars_at(bridge, theoretical_shots, 2 * theoretical_shots - 1) == 3
		and _stars_at(bridge, theoretical_shots, 2 * theoretical_shots) == 2
		and _stars_at(bridge, theoretical_shots, 3 * theoretical_shots - 1) == 2
		and _stars_at(bridge, theoretical_shots, 3 * theoretical_shots) == 1
		and _stars_at(bridge, theoretical_shots, 4 * theoretical_shots) == 1
		and _stars_at(bridge, theoretical_shots, 4 * theoretical_shots + 1) == 0
		and bridge.calculate_stars(false, 0, theoretical_shots) == 0
	)


func _stars_at(bridge, theoretical_shots: int, moves_used: int) -> int:
	return int(bridge.calculate_stars(true, moves_used, theoretical_shots))


func _ideal_shots(cocktail_level: int, quantity: int) -> int:
	if cocktail_level < 3 or cocktail_level > 12 or quantity <= 0:
		return 0
	return (1 << (cocktail_level - 3)) * quantity


func _cocktail_resource_exists(cocktail_level: int) -> bool:
	if cocktail_level < 1 or cocktail_level > 12:
		return false
	return FileAccess.file_exists("res://assets/cocktails/L%02d.png" % cocktail_level)


func _resource_exists(resource_path: String) -> bool:
	return not resource_path.is_empty() and FileAccess.file_exists(resource_path)


func _run_profiles(database) -> void:
	var unknowns: Array[Dictionary] = _checkpoint["configuration"]["r10_unverified_cases"]
	var profile_ids := _recorded_trial_ids(_checkpoint.get("profile_trials", []))
	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(1.0)
	for sample in unknowns:
		for variant in PROFILE_VARIANTS:
			if _stop_or_budget_exhausted():
				_checkpoint["profile_complete"] = false
				return
			var island_id := str(sample["island_id"])
			var level_id := int(sample["level_id"])
			var seed_value := _trial_seed(_checkpoint["configuration"]["island_ids_in_order"], island_id, level_id)
			var trial_id := "profile|%s|%d|%s|%d" % [island_id, level_id, str(variant["id"]), seed_value]
			if profile_ids.has(trial_id):
				continue
			var definition: Dictionary = database.get_level(island_id, level_id)
			if definition.is_empty():
				continue
			var started := Time.get_ticks_usec()
			var result: Dictionary = await harness.run_trial(
				database, island_id, level_id, seed_value, [], str(variant["policy"]), 0, true, true,
				PROFILE_WALL_LIMIT_SEC, STOP_FLAG_PATH, true, bool(variant["cache"])
			)
			var summary := _trial_summary(trial_id, "PROFILE", island_id, level_id, seed_value, str(variant["policy"]), bool(variant["cache"]), definition, result, Time.get_ticks_usec() - started)
			_checkpoint["profile_trials"].append(summary)
			profile_ids[trial_id] = true
			_save_checkpoint()
			print("M34_R11_PROFILE %s/%d variant=%s class=%s frames=%d wall=%.3f" % [island_id, level_id, str(variant["id"]), str(summary["classification"]), int(summary["profile"].get("frame_count", 0)), float(summary["wall_sec"])])
			if str(result.get("terminal_reason", "")) == "STOP_SIGNAL":
				_checkpoint["stop_requested"] = true
				return
	_checkpoint["profile_complete"] = true
	_save_checkpoint()


func _run_coverage(database) -> void:
	var ordered_islands: Array[String] = []
	for island_id in _checkpoint["configuration"]["island_ids_in_order"]:
		ordered_islands.append(str(island_id))
	_seed_prior_path_wins()
	var cases: Array[Dictionary] = []
	for case in _checkpoint["configuration"]["r10_unverified_cases"]:
		cases.append({"island_id": case["island_id"], "level_id": int(case["level_id"]), "source": "R10_UNVERIFIED"})
	for island_id in ordered_islands:
		cases.append({"island_id": island_id, "level_id": MID_LEVEL_ID, "source": "R11_MID_STRATUM"})
	cases.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if str(a["source"]) != str(b["source"]):
			return str(a["source"]) == "R10_UNVERIFIED"
		var ai := ordered_islands.find(str(a["island_id"]))
		var bi := ordered_islands.find(str(b["island_id"]))
		if ai == bi:
			return int(a["level_id"]) < int(b["level_id"])
		return ai < bi
	)
	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(1.0)
	for sample in cases:
		var island_id := str(sample["island_id"])
		var level_id := int(sample["level_id"])
		var level_key := "%s/%d" % [island_id, level_id]
		if not _checkpoint["coverage_levels"].has(level_key):
			_checkpoint["coverage_levels"][level_key] = {
				"island_id": island_id,
				"level_id": level_id,
				"stratum": _stratum(level_id),
				"source": sample["source"],
				"trials": [],
				"status": "NOT_RUN",
				"unrun_policy_ids": [],
			}
	_save_checkpoint()
	for sample in cases:
		var island_id := str(sample["island_id"])
		var level_id := int(sample["level_id"])
		var level_key := "%s/%d" % [island_id, level_id]
		var level_results: Dictionary = _checkpoint["coverage_levels"].get(level_key, {
			"island_id": island_id,
			"level_id": level_id,
			"stratum": _stratum(level_id),
			"source": sample["source"],
			"trials": [],
			"status": "BUDGET_UNKNOWN",
			"unrun_policy_ids": [],
		})
		if str(level_results.get("status", "")) == "PROVED_PATH_WIN":
			continue
		var definition: Dictionary = database.get_level(island_id, level_id)
		if definition.is_empty():
			level_results["status"] = "NOT_RUN"
			level_results["not_run_reason"] = "LEVEL_DEFINITION_MISSING"
			_checkpoint["coverage_levels"][level_key] = level_results
			_save_checkpoint()
			continue
		for variant in COVERAGE_VARIANTS:
			if _stop_or_budget_exhausted():
				level_results["status"] = "NOT_RUN" if level_results["trials"].is_empty() else "BUDGET_UNKNOWN"
				level_results["unrun_policy_ids"].append(str(variant["id"]))
				_checkpoint["coverage_levels"][level_key] = level_results
				_save_checkpoint()
				return
			var seed_value := _trial_seed(ordered_islands, island_id, level_id)
			var trial_id := "coverage|%s|%d|%s|%d" % [island_id, level_id, str(variant["id"]), seed_value]
			if _recorded_trial_ids(level_results["trials"]).has(trial_id):
				continue
			var session_remaining := TOTAL_WALL_LIMIT_SEC - _elapsed_session_sec()
			var trial_wall_limit := minf(TRIAL_WALL_LIMIT_SEC, session_remaining)
			if trial_wall_limit <= 0.0:
				level_results["unrun_policy_ids"].append(str(variant["id"]))
				level_results["status"] = "NOT_RUN" if level_results["trials"].is_empty() else "BUDGET_UNKNOWN"
				_checkpoint["coverage_levels"][level_key] = level_results
				_save_checkpoint()
				return
			var started := Time.get_ticks_usec()
			var result: Dictionary = await harness.run_trial(
				database, island_id, level_id, seed_value, [], str(variant["policy"]), 0, true, true,
				trial_wall_limit, STOP_FLAG_PATH, true, bool(variant["cache"])
			)
			var summary := _trial_summary(trial_id, str(sample["source"]), island_id, level_id, seed_value, str(variant["policy"]), bool(variant["cache"]), definition, result, Time.get_ticks_usec() - started)
			level_results["trials"].append(summary)
			if str(summary["classification"]) == "PROVED_PATH_WIN":
				level_results["status"] = "PROVED_PATH_WIN"
				level_results["path_win_policy"] = str(variant["id"])
				level_results["path_win_trial_id"] = trial_id
				for remaining_variant in COVERAGE_VARIANTS:
					if str(remaining_variant["id"]) == str(variant["id"]):
						continue
					if not _recorded_trial_ids(level_results["trials"]).has("coverage|%s|%d|%s|%d" % [island_id, level_id, str(remaining_variant["id"]), seed_value]):
						level_results["unrun_policy_ids"].append(str(remaining_variant["id"]))
			else:
				level_results["status"] = "BUDGET_UNKNOWN"
				if str(result.get("terminal_reason", "")) == "STOP_SIGNAL":
					_checkpoint["stop_requested"] = true
			_checkpoint["coverage_levels"][level_key] = level_results
			_save_checkpoint()
			print("M34_R11_COVERAGE %s/%d class=%s trials=%d policy=%s moves=%d/%d wall=%.3f" % [island_id, level_id, str(summary["classification"]), level_results["trials"].size(), str(summary["policy"]), int(summary["moves_used"]), int(summary["move_limit_4T"]), float(summary["wall_sec"])])
			if str(summary["classification"]) == "PROVED_PATH_WIN" or _checkpoint["stop_requested"]:
				for remaining_variant in COVERAGE_VARIANTS:
					if not _recorded_trial_ids(level_results["trials"]).has("coverage|%s|%d|%s|%d" % [island_id, level_id, str(remaining_variant["id"]), seed_value]) and not level_results["unrun_policy_ids"].has(str(remaining_variant["id"])):
						level_results["unrun_policy_ids"].append(str(remaining_variant["id"]))
				_checkpoint["coverage_levels"][level_key] = level_results
			_save_checkpoint()
			if _checkpoint["stop_requested"]:
				return
			if str(summary["classification"]) == "PROVED_PATH_WIN":
				break
		_checkpoint["coverage_levels"][level_key] = level_results
		_save_checkpoint()
	_checkpoint["coverage_complete"] = true
	_save_checkpoint()


func _seed_prior_path_wins() -> void:
	if not _checkpoint["coverage_levels"].is_empty():
		return
	var report := _read_json(R10_REPORT_PATH)
	for trial in report.get("trials", []):
		if str(trial.get("classification", "")) != "MECHANICAL_WIN_ONE_POLICY_ONE_SEED":
			continue
		var island_id := str(trial.get("island_id", ""))
		var level_id := int(trial.get("level_id", 0))
		var level_key := "%s/%d" % [island_id, level_id]
		_checkpoint["coverage_levels"][level_key] = {
			"island_id": island_id,
			"level_id": level_id,
			"stratum": _stratum(level_id),
			"source": "R10_PRIOR_PATH_EVIDENCE",
			"trials": [],
			"status": "PROVED_PATH_WIN",
			"prior_evidence": {
				"classification": "PROVED_PATH_WIN",
				"policy": str(trial.get("policy", "MERGE_AWARE_V01")),
				"seed": int(trial.get("seed", 0)),
				"moves_used": int(trial.get("moves_used", 0)),
				"move_limit": int(trial.get("move_limit", 0)),
				"normal_complete": bool(trial.get("normal_complete", false)),
				"vip_complete": bool(trial.get("vip_complete", false)),
				"source_file": "evidence/M34-R10/offline_gameplay_quality.json",
			},
		}
	_save_checkpoint()


func _trial_summary(trial_id: String, source: String, island_id: String, level_id: int, seed_value: int, policy: String, cache_enabled: bool, definition: Dictionary, result: Dictionary, measured_wall_usec: int) -> Dictionary:
	var normal_t := 0
	for order in definition.get("orders", []):
		normal_t += _ideal_shots(int(order.get("cocktail_level", 0)), int(order.get("quantity", 0)))
	var vip_t := int(definition.get("theoretical_shots_vip", 0))
	var total_t := normal_t + vip_t
	var won := bool(result.get("normal_objective_complete", false)) and str(result.get("outcome", "")) == "completed"
	return {
		"trial_id": trial_id,
		"source": source,
		"island_id": island_id,
		"level_id": level_id,
		"stratum": _stratum(level_id),
		"global_level_id": int(definition.get("global_level_id", _fallback_global_id(island_id, level_id))),
		"policy": policy,
		"legal_geometry_cache": cache_enabled,
		"seed": seed_value,
		"normal_order_rows": definition.get("orders", []).size(),
		"normal_objective_T": normal_t,
		"vip_enabled_optional": _vip_enabled(definition),
		"vip_T_in_4T_denominator": vip_t,
		"theoretical_T": total_t,
		"move_limit_4T": 4 * total_t,
		"moves_used": int(result.get("moves_used", 0)),
		"moves_remaining": int(result.get("moves_remaining", 0)),
		"moves_legal": int(result.get("moves_used", 0)) <= 4 * total_t,
		"normal_complete": bool(result.get("normal_objective_complete", false)),
		"vip_complete": bool(result.get("vip_complete", false)),
		"classification": "PROVED_PATH_WIN" if won else "BUDGET_UNKNOWN",
		"policy_outcome": str(result.get("outcome", "")),
		"terminal_reason": str(result.get("terminal_reason", "")),
		"shots": int(result.get("shot_count", 0)),
		"merge_count": int(result.get("merge_count", 0)),
		"peak_live_drinks": int(result.get("peak_live_drinks", 0)),
		"elapsed_simulated_sec": snappedf(float(result.get("elapsed_sec", 0.0)), 0.01),
		"wall_sec": snappedf(float(measured_wall_usec) / 1000000.0, 0.001),
		"profile": result.get("profile", {}),
		"score_stars_at_result": int(result.get("stars", 0)),
	}


func _write_csv(rows: Array) -> void:
	var lines := PackedStringArray(["island_id,level_id,global_level_id,save_identifier_ok,stratum,normal_order_rows,normal_T,vip_enabled_optional,vip_T_in_denominator,total_T,move_limit_4T,move_limit_equals_4T,stars_3_before_2T,stars_2_before_3T,stars_1_at_4T,untimed,dynamic_resources_resolve,static_status"])
	for row in rows:
		lines.append("%s,%d,%d,%s,%s,%d,%d,%s,%d,%d,%d,%s,%s,%s,%s,%s,%s,%s" % [
			str(row["island_id"]), int(row["level_id"]), int(row["global_level_id"]), str(row["save_identifier_ok"]), str(row["stratum"]), int(row["normal_order_rows"]), int(row["normal_T"]), str(row["vip_enabled_optional"]), int(row["vip_T_in_denominator"]), int(row["total_T"]), int(row["move_limit"]), str(row["move_limit_equals_4T"]), str(row["stars_3_before_2T"]), str(row["stars_2_before_3T"]), str(row["stars_1_at_4T"]), str(row["untimed"]), str(row["dynamic_resources_resolve"]), str(row["static_status"]),
		])
	var file := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write static CSV: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string("\n".join(lines) + "\n")
	file.close()


func _write_summary() -> void:
	var payload := _checkpoint.duplicate(true)
	payload["session_elapsed_wall_sec"] = snappedf(_elapsed_session_sec(), 0.01)
	payload["coverage_aggregate"] = _coverage_aggregate()
	var file := FileAccess.open(SUMMARY_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write R11 summary: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(payload, "\t") + "\n")
	file.close()


func _save_checkpoint() -> void:
	_sequence += 1
	var next_slot := "A" if _checkpoint_slot != "A" else "B"
	var destination := CHECKPOINT_A_PATH if next_slot == "A" else CHECKPOINT_B_PATH
	var temporary := destination + ".tmp"
	_checkpoint["sequence"] = _sequence
	_checkpoint["checkpoint_slot"] = next_slot
	_checkpoint["session_elapsed_wall_sec"] = snappedf(_elapsed_session_sec(), 0.01)
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write R11 checkpoint temp: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(_checkpoint, "\t") + "\n")
	file.flush()
	file.close()
	var absolute_destination := ProjectSettings.globalize_path(destination)
	if FileAccess.file_exists(destination):
		DirAccess.remove_absolute(absolute_destination)
	var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), absolute_destination)
	if err != OK:
		push_error("Unable to rotate R11 checkpoint slot: %s" % error_string(err))
		return
	_checkpoint_slot = next_slot


func _ensure_output_dir() -> bool:
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	return err == OK or err == ERR_ALREADY_EXISTS


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed := JSON.new()
	var err := parsed.parse(FileAccess.get_file_as_string(path))
	if err != OK or not parsed.data is Dictionary:
		return {}
	return parsed.data


func _recorded_trial_ids(records: Array) -> Dictionary:
	var ids: Dictionary = {}
	for record in records:
		var trial_id := str(record.get("trial_id", ""))
		if not trial_id.is_empty():
			ids[trial_id] = true
	return ids


func _trial_seed(ordered_islands: Array, island_id: String, level_id: int) -> int:
	return SEED_BASE + ordered_islands.find(island_id) * 1000 + level_id


func _fallback_global_id(island_id: String, level_id: int) -> int:
	var ordered: Array[String] = []
	for candidate in _checkpoint["configuration"]["island_ids_in_order"]:
		ordered.append(str(candidate))
	return ordered.find(island_id) * 100 + level_id


func _vip_enabled(definition: Dictionary) -> bool:
	var vip: Variant = definition.get("vip", null)
	return vip is Dictionary and bool(vip.get("enabled", true))


func _stratum(level_id: int) -> String:
	if level_id <= 10:
		return "EARLY"
	if level_id >= 45 and level_id <= 55:
		return "MID"
	if level_id >= 90:
		return "LATE"
	return "OTHER"


func _stop_or_budget_exhausted() -> bool:
	if FileAccess.file_exists(STOP_FLAG_PATH):
		_checkpoint["stop_requested"] = true
		return true
	return _elapsed_session_sec() >= TOTAL_WALL_LIMIT_SEC


func _elapsed_session_sec() -> float:
	if _session_started_unix <= 0:
		return 0.0
	return maxf(0.0, float(Time.get_unix_time_from_system() - _session_started_unix))


func _coverage_aggregate() -> Dictionary:
	var levels: Dictionary = _checkpoint.get("coverage_levels", {})
	var result := {"total_result_level_count": levels.size(), "selected_level_count": 0, "prior_path_evidence_count": 0, "proved_path_wins": 0, "budget_unknown": 0, "not_run": 0, "profile_trial_count": _checkpoint.get("profile_trials", []).size()}
	var expected_level_count: int = _checkpoint.get("configuration", {}).get("r10_unverified_cases", []).size() + _checkpoint.get("configuration", {}).get("island_ids_in_order", []).size()
	var selected_status_counts := {"PROVED_PATH_WIN": 0, "BUDGET_UNKNOWN": 0, "NOT_RUN": 0}
	var by_island: Dictionary = {}
	for level_result in levels.values():
		var status := str(level_result.get("status", "NOT_RUN"))
		if str(level_result.get("source", "")) == "R10_PRIOR_PATH_EVIDENCE":
			result["prior_path_evidence_count"] = int(result["prior_path_evidence_count"]) + 1
		else:
			result["selected_level_count"] = int(result["selected_level_count"]) + 1
			selected_status_counts[status] = int(selected_status_counts.get(status, 0)) + 1
		if status == "PROVED_PATH_WIN":
			result["proved_path_wins"] = int(result["proved_path_wins"]) + 1
		elif status == "BUDGET_UNKNOWN":
			result["budget_unknown"] = int(result["budget_unknown"]) + 1
		else:
			result["not_run"] = int(result["not_run"]) + 1
		var island_id := str(level_result.get("island_id", ""))
		if not by_island.has(island_id):
			by_island[island_id] = {"PROVED_PATH_WIN": 0, "BUDGET_UNKNOWN": 0, "NOT_RUN": 0}
		by_island[island_id][status] = int(by_island[island_id].get(status, 0)) + 1
	result["by_island"] = by_island
	result["unverified_level_count"] = int(result["budget_unknown"]) + int(result["not_run"])
	result["expected_selected_level_count"] = expected_level_count
	result["selected_status_counts"] = selected_status_counts
	result["profile_aggregate"] = _profile_aggregate(_checkpoint.get("profile_trials", []))
	return result


func _sanitize_profile_records() -> void:
	for record in _checkpoint.get("profile_trials", []):
		var trial_parts: PackedStringArray = str(record.get("trial_id", "")).split("|")
		if trial_parts.size() >= 4:
			record["variant"] = trial_parts[3]
		var profile: Dictionary = record.get("profile", {})
		for stale_key in ["engine_physics_process_usec_max", "engine_physics_process_usec_per_frame", "engine_physics_process_usec_sum", "engine_process_usec_max", "engine_process_usec_per_frame", "engine_process_usec_sum"]:
			profile.erase(stale_key)
		profile["engine_performance_monitor"] = "excluded_from_analysis; resumed records may contain stale samples"
		if not profile.has("shot_commit_wall_usec"):
			profile["shot_commit_timing"] = "NOT_CAPTURED_IN_ORIGINAL_COMPLETED_PROFILES"
		record["profile"] = profile
	_checkpoint["profile_trials"] = _checkpoint.get("profile_trials", [])


func _profile_aggregate(profiles: Array) -> Dictionary:
	var grouped: Dictionary = {}
	for record in profiles:
		var variant := str(record.get("variant", "UNKNOWN"))
		if not grouped.has(variant):
			grouped[variant] = {"trial_count": 0, "total_wall_sec": 0.0, "total_frames": 0, "total_decisions": 0, "decision_wall_usec": 0, "physics_frame_wait_wall_usec": 0, "sample_wall_usec": 0, "geometry_cache_misses": 0, "merge_count": 0}
		var aggregate: Dictionary = grouped[variant]
		var profile: Dictionary = record.get("profile", {})
		aggregate["trial_count"] = int(aggregate["trial_count"]) + 1
		aggregate["total_wall_sec"] = float(aggregate["total_wall_sec"]) + float(record.get("wall_sec", 0.0))
		aggregate["total_frames"] = int(aggregate["total_frames"]) + int(profile.get("frame_count", 0))
		aggregate["total_decisions"] = int(aggregate["total_decisions"]) + int(profile.get("decision_count", 0))
		aggregate["merge_count"] = int(aggregate["merge_count"]) + int(record.get("merge_count", 0))
		for key in ["decision_wall_usec", "physics_frame_wait_wall_usec", "sample_wall_usec", "geometry_cache_misses"]:
			aggregate[key] = int(aggregate[key]) + int(profile.get(key, 0))
	for variant in grouped:
		var row: Dictionary = grouped[variant]
		var frames := maxi(1, int(row["total_frames"]))
		var decisions := maxi(1, int(row["total_decisions"]))
		row["mean_trial_wall_sec"] = snappedf(float(row["total_wall_sec"]) / float(maxi(1, int(row["trial_count"]))), 0.001)
		row["wall_usec_per_frame"] = snappedf(float(row["total_wall_sec"]) * 1000000.0 / float(frames), 0.1)
		row["physics_frame_wait_usec_per_frame"] = snappedf(float(row["physics_frame_wait_wall_usec"]) / float(frames), 0.1)
		row["sample_wall_usec_per_frame"] = snappedf(float(row["sample_wall_usec"]) / float(frames), 0.1)
		row["decision_wall_usec_per_decision"] = snappedf(float(row["decision_wall_usec"]) / float(decisions), 0.1)
	return grouped


func _print_aggregate() -> void:
	var aggregate: Dictionary = _coverage_aggregate()
	print("M34_R11_RESULT status=%s static=%d profiles=%d path_wins=%d budget_unknown=%d not_run=%d elapsed=%.1fs" % [
		str(_checkpoint.get("status", "")),
		int(_checkpoint.get("static_summary", {}).get("level_count", 0)),
		int(aggregate["profile_trial_count"]),
		int(aggregate["proved_path_wins"]),
		int(aggregate["budget_unknown"]),
		int(aggregate["not_run"]),
		_elapsed_session_sec(),
	])


func _min_int(values: Array[int]) -> int:
	if values.is_empty():
		return 0
	var result := values[0]
	for value in values:
		result = mini(result, value)
	return result


func _max_int(values: Array[int]) -> int:
	var result := 0
	for value in values:
		result = maxi(result, value)
	return result
