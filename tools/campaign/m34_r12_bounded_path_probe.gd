extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const MODEL_SCRIPT = preload("res://scripts/campaign/m17_difficulty_model.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const OUTPUT_PATH := "res://coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R12/bounded_path_probe.json"
const TOTAL_WALL_LIMIT_SEC := 300.0
const PER_TRIAL_WALL_LIMIT_SEC := 45.0
const CASES := [
	{"island_id": "sunny_cove", "level_id": 50},
	{"island_id": "tiki_island", "level_id": 100},
	{"island_id": "azure_bay", "level_id": 1},
	{"island_id": "coconut_beach", "level_id": 50},
	{"island_id": "sunset_island", "level_id": 100},
	{"island_id": "party_beach", "level_id": 1},
	{"island_id": "frozen_paradise", "level_id": 50},
	{"island_id": "volcano_bay", "level_id": 100},
	{"island_id": "billionaire_island", "level_id": 1},
	{"island_id": "final_island", "level_id": 50},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(
		DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
		DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS,
		DATABASE_SCRIPT.ValidationMode.FULL
	):
		push_error("R12 campaign load failed: %s" % database.get_last_error())
		quit(1)
		return
	var island_order: Array[String] = database.get_island_ids_in_order()
	var harness = HARNESS_SCRIPT.new(get_root())
	harness.set_time_scale(1.0)
	var started_usec := Time.get_ticks_usec()
	var records: Array[Dictionary] = []
	var stop_reason := "ALL_SELECTED_CASES_RUN"
	for case_index in range(CASES.size()):
		if float(Time.get_ticks_usec() - started_usec) / 1_000_000.0 >= TOTAL_WALL_LIMIT_SEC:
			stop_reason = "AGGREGATE_WALL_BUDGET"
			break
		var case: Dictionary = CASES[case_index]
		var island_id := str(case["island_id"])
		var level_id := int(case["level_id"])
		var definition: Dictionary = database.get_level(island_id, level_id)
		if definition.is_empty():
			records.append({"case": case, "classification": "NOT_RUN", "reason": "LEVEL_DEFINITION_MISSING"})
			continue
		var normal_t := int(ceil(float(MODEL_SCRIPT.normal_objective_cost(definition)) / 4.0))
		var legal_moves := 4 * normal_t
		var island_index := island_order.find(island_id)
		var seed_value := 34120000 + island_index * 1000 + level_id
		var trial_started := Time.get_ticks_usec()
		var result: Dictionary = await harness.run_trial(
			database,
			island_id,
			level_id,
			seed_value,
			[],
			HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
			legal_moves,
			true,
			true,
			PER_TRIAL_WALL_LIMIT_SEC,
			"",
			true,
			true,
			false
		)
		var trial_wall_usec := Time.get_ticks_usec() - trial_started
		var action_log: Array = result.get("action_log", [])
		var action_hash := _sha256(JSON.stringify(action_log))
		var vip_definition = definition.get("vip")
		var vip_enabled := vip_definition is Dictionary and bool(vip_definition.get("enabled", false))
		var record := {
			"island_id": island_id,
			"level_id": level_id,
			"global_level_id": int(definition.get("global_level_id", -1)),
			"stratum": "EARLY" if level_id <= 10 else ("MIDDLE" if level_id <= 90 else "LATE"),
			"seed": seed_value,
			"policy": HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
			"normal_T": normal_t,
			"legal_move_limit_4T": legal_moves,
			"shots_used": int(result.get("shot_count", 0)),
			"moves_used": int(result.get("moves_used", 0)),
			"moves_remaining": int(result.get("moves_remaining", legal_moves)),
			"moves_legal": int(result.get("moves_used", 0)) <= legal_moves,
			"normal_objective_complete": bool(result.get("normal_objective_complete", false)),
			"vip_enabled_optional": vip_enabled,
			"vip_complete": bool(result.get("vip_complete", false)),
			"merge_count": int(result.get("merge_count", 0)),
			"outcome": str(result.get("outcome", "")),
			"terminal_reason": str(result.get("terminal_reason", "")),
			"classification": "BUDGET_UNKNOWN",
			"trial_wall_usec": trial_wall_usec,
			"profile": result.get("profile", {}).duplicate(true),
			"action_count": action_log.size(),
			"action_log_sha256": action_hash,
		}
		if bool(record["normal_objective_complete"]) and str(record["outcome"]) == HARNESS_SCRIPT.OUTCOME_COMPLETED and bool(record["moves_legal"]):
			var replay_started := Time.get_ticks_usec()
			var replay: Dictionary = await harness.run_trial(
				database,
				island_id,
				level_id,
				seed_value,
				action_log,
				HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
				legal_moves,
				true,
				true,
				PER_TRIAL_WALL_LIMIT_SEC,
				"",
				true,
				true,
				false
			)
			var replay_log: Array = replay.get("action_log", [])
			var replay_ok := str(replay.get("outcome", "")) == HARNESS_SCRIPT.OUTCOME_COMPLETED and bool(replay.get("normal_objective_complete", false)) and replay_log == action_log
			record["replay_wall_usec"] = Time.get_ticks_usec() - replay_started
			record["replay_outcome"] = str(replay.get("outcome", ""))
			record["replay_terminal_reason"] = str(replay.get("terminal_reason", ""))
			record["replay_action_log_sha256"] = _sha256(JSON.stringify(replay_log))
			record["replay_identical"] = replay_ok
			record["classification"] = "PROVED_PATH_WIN" if replay_ok else "BUDGET_UNKNOWN"
			if replay_ok:
				record["winning_action_log"] = action_log
		else:
			record["candidate_path"] = "WIN_NOT_REPLAYED_OR_NOT_IDENTICAL"
		records.append(record)
		print("M34_R12_PATH_SAMPLE %s/%d classification=%s moves=%d/%d merges=%d wall=%.3f" % [
			island_id,
			level_id,
			str(record["classification"]),
			int(record["moves_used"]),
			legal_moves,
			int(record["merge_count"]),
			float(trial_wall_usec) / 1_000_000.0,
		])
	var report := {
		"schema_version": 1,
		"work_item": "BCM-M34-R12-003",
		"execution_mode": "Godot --fixed-fps 60; Engine.time_scale=1.0; physics_ticks_per_second=60",
		"policy": HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01,
		"total_wall_limit_sec": TOTAL_WALL_LIMIT_SEC,
		"per_trial_wall_limit_sec": PER_TRIAL_WALL_LIMIT_SEC,
		"maximum_move_limit_rule": "exact 4T; every trial is bounded by its production move budget",
		"cases_selected": CASES,
		"records": records,
		"stop_reason": stop_reason,
		"elapsed_wall_usec": Time.get_ticks_usec() - started_usec,
		"proved_path_wins": records.filter(func(row: Dictionary) -> bool: return str(row.get("classification", "")) == "PROVED_PATH_WIN").size(),
		"proved_impossible": 0,
		"unknown_count": records.filter(func(row: Dictionary) -> bool: return str(row.get("classification", "")) == "BUDGET_UNKNOWN").size(),
	}
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write R12 bounded path output: %s" % OUTPUT_PATH)
		quit(1)
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("M34_R12_BOUNDED_PATH_RESULT=PASS selected=%d records=%d wins=%d unknown=%d stop=%s" % [
		CASES.size(), records.size(), int(report["proved_path_wins"]), int(report["unknown_count"]), stop_reason,
	])
	quit(0)


func _sha256(value: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(value.to_utf8_buffer())
	return context.finish().hex_encode()
