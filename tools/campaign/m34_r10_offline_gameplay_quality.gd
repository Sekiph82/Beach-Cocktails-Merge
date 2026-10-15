extends SceneTree

## Bounded offline screen for M33-004. Uses the existing M17 harness, real
## GameManager/Drink physics and the production move-commit path. A single
## deterministic policy trial is evidence about that run, never proof of
## universal solvability or human playability.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const HARNESS_SCRIPT = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")
const OUTPUT_PATH := "res://coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R10/offline_gameplay_quality.json"
const POLICY := HARNESS_SCRIPT.POLICY_MERGE_AWARE_V01
const SAMPLE_LEVELS: Array[int] = [1, 100]
const SEED_BASE := 34100000
const PER_TRIAL_WALL_LIMIT_SEC := 20.0
const TOTAL_WALL_LIMIT_SEC := 360.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(
		DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
		DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS,
		DATABASE_SCRIPT.ValidationMode.FULL
	):
		push_error("M34-R10 campaign load failed: %s" % database.get_last_error())
		quit(1)
		return

	var report := {
		"schema_version": 1,
		"work_item": "BCM-M34-R10-001",
		"method": "M17 merge-aware deterministic lane policy with production GameManager/Drink physics and ShotController move commits",
		"decision_grade_time_scale": 1.0,
		"timer_disabled_for_run": true,
		"vip_is_optional_for_normal_completion": true,
		"policy": POLICY,
		"seed_formula": "34100000 + island_order_index * 1000 + level_id",
		"sample_design": "early L1 and late L100 capstone from each of the ten islands, ordered round-robin by stratum; complete static census covers all complexity and VIP records",
		"per_trial_wall_limit_sec": PER_TRIAL_WALL_LIMIT_SEC,
		"total_wall_limit_sec": TOTAL_WALL_LIMIT_SEC,
		"campaign_static": {},
		"trials": [],
		"summary": {},
		"limitations": [
			"This deterministic lane policy is not an optimal solver or human-playability model.",
			"A successful run proves one production-physics trajectory for one seed; a failed run does not prove the level is unsolvable.",
			"No owner/human fairness playtest was performed; M33-004 remains open.",
		]
	}
	var static_result := _scan_campaign(database)
	if not bool(static_result.get("ok", false)):
		push_error("M34-R10 static campaign scan failed: %s" % static_result.get("errors", []))
		report["campaign_static"] = static_result
		_write_report(report)
		quit(1)
		return
	report["campaign_static"] = static_result

	var selected: Array[Dictionary] = []
	var ordered_ids: Array[String] = database.get_island_ids_in_order()
	for island_index in range(ordered_ids.size()):
		var island_id := ordered_ids[island_index]
		for level_id in SAMPLE_LEVELS:
			var definition: Dictionary = database.get_level(island_id, level_id)
			if definition.is_empty():
				push_error("M34-R10 selected level missing: %s/%d" % [island_id, level_id])
				quit(1)
				return
			selected.append({
				"island_index": island_index,
				"island_id": island_id,
				"level_id": level_id,
				"definition": definition,
				"stratum": "EARLY" if level_id == 1 else ("LATE_CAPSTONE" if level_id == 100 else "MID_THRESHOLD_50_51"),
			})
	selected.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["level_id"]) == int(b["level_id"]):
			return int(a["island_index"]) < int(b["island_index"])
		return int(a["level_id"]) < int(b["level_id"])
	)

	var harness = HARNESS_SCRIPT.new(root)
	harness.set_time_scale(1.0)
	var wall_start_msec := Time.get_ticks_msec()
	var wins := 0
	var terminal_failures := 0
	var bounded_out := 0
	var executed_count := 0
	for sample in selected:
		var elapsed_wall := float(Time.get_ticks_msec() - wall_start_msec) / 1000.0
		var island_id := str(sample["island_id"])
		var level_id := int(sample["level_id"])
		var seed_value := SEED_BASE + int(sample["island_index"]) * 1000 + level_id
		var record: Dictionary
		if elapsed_wall >= TOTAL_WALL_LIMIT_SEC:
			record = _not_run_record(sample, seed_value, "TOTAL_WALL_BUDGET")
			bounded_out += 1
		else:
			executed_count += 1
			var result: Dictionary = await harness.run_trial(
				database,
				island_id,
				level_id,
				seed_value,
				[],
				POLICY,
				0,
				true,
				true,
				PER_TRIAL_WALL_LIMIT_SEC
			)
			record = _summarize_trial(sample, seed_value, result)
			if str(record["classification"]) == "MECHANICAL_WIN_ONE_POLICY_ONE_SEED":
				wins += 1
			elif str(record["classification"]) == "MECHANICAL_TERMINAL_FAILURE_ONE_POLICY_ONE_SEED":
				terminal_failures += 1
			else:
				bounded_out += 1
			print("M34_R10_TRIAL %s/%d class=%s shots=%d/%d" % [
				island_id,
				level_id,
				str(record["classification"]),
				int(record["shots"]),
				int(record["move_limit"]),
			])
		report["trials"].append(record)
		_write_report(report)

	var not_run := selected.size() - executed_count
	var mechanically_observed := wins + terminal_failures
	report["summary"] = {
		"canonical_islands": ordered_ids.size(),
		"canonical_level_records": int(static_result["record_count"]),
		"selected_trials": selected.size(),
		"executed_trials": selected.size() - not_run,
		"mechanically_observed_terminal_trials": mechanically_observed,
		"one_policy_seed_wins": wins,
		"one_policy_seed_terminal_failures": terminal_failures,
		"wall_or_harness_bounded_or_not_run": bounded_out,
		"vip_present_in_mechanical_sample": _count_vip_samples(report["trials"]),
		"normal_wins_skipping_vip": _count_vip_skips(report["trials"]),
		"m33_004_status": "OPEN_HUMAN_FAIRNESS_AND_UNSAMPLED_LEVELS_REMAIN_UNVERIFIED",
		"total_wall_sec": snappedf(float(Time.get_ticks_msec() - wall_start_msec) / 1000.0, 0.01),
	}
	_write_report(report)
	print("M34_R10_OFFLINE_GAMEPLAY_RESULT=PASS_STATIC_%d_MECHANICAL_%d_WINS_%d_FAILURES_%d_BOUNDED_%d" % [
		int(static_result["record_count"]), mechanically_observed, wins, terminal_failures, bounded_out,
	])
	quit(0)


func _scan_campaign(database) -> Dictionary:
	var ids: Array[String] = database.get_island_ids_in_order()
	var record_count := 0
	var nonzero_timers := 0
	var timed_flags := 0
	var vip_count := 0
	var order_count := 0
	var normal_costs: Array[int] = []
	var tier_counts: Dictionary = {}
	var island_counts: Dictionary = {}
	var island_complexity: Dictionary = {}
	var errors: Array[String] = []
	for island_id in ids:
		var rows: Array[Dictionary] = database.get_levels_for_island(island_id)
		var local_costs: Array[int] = []
		island_counts[island_id] = rows.size()
		if rows.size() != 100:
			errors.append("%s has %d levels, expected 100" % [island_id, rows.size()])
		for expected_level in range(1, 101):
			var definition: Dictionary = database.get_level(island_id, expected_level)
			if definition.is_empty():
				errors.append("missing %s/%d" % [island_id, expected_level])
				continue
			record_count += 1
			if float(definition.get("time_limit_sec", 0.0)) != 0.0:
				nonzero_timers += 1
			var flags: Dictionary = definition.get("feature_flags", {})
			if bool(flags.get("timed", false)):
				timed_flags += 1
			var vip: Variant = definition.get("vip", null)
			if vip is Dictionary and bool(vip.get("enabled", true)):
				vip_count += 1
			var orders: Array = definition.get("orders", [])
			order_count += orders.size()
			var normal_cost := 0
			for order in orders:
				var target := int(order.get("cocktail_level", 0))
				var quantity := int(order.get("quantity", 0))
				if target < 3 or target > 12 or quantity <= 0:
					errors.append("invalid normal order %s/%d" % [island_id, expected_level])
				else:
					normal_cost += (1 << (target - 3)) * quantity
			normal_costs.append(normal_cost)
			local_costs.append(normal_cost)
			var tier := str(definition.get("difficulty_tier", "UNLABELLED"))
			tier_counts[tier] = int(tier_counts.get(tier, 0)) + 1
		island_complexity[island_id] = {
			"normal_objective_T_min": _min_int(local_costs),
			"normal_objective_T_median": _median_int(local_costs),
			"normal_objective_T_max": _max_int(local_costs),
			"l100_is_highest_normal_objective_T": not local_costs.is_empty() and _normal_cost(database.get_level(island_id, 100)) == _max_int(local_costs),
		}
	return {
		"ok": errors.is_empty() and ids.size() == 10 and record_count == 1000 and nonzero_timers == 0 and timed_flags == 0,
		"island_count": ids.size(),
		"island_level_counts": island_counts,
		"island_complexity": island_complexity,
		"record_count": record_count,
		"tier_counts": tier_counts,
		"vip_enabled_records": vip_count,
		"normal_order_rows": order_count,
		"time_limit_nonzero_records": nonzero_timers,
		"timed_feature_flag_records": timed_flags,
		"normal_objective_T_min": _min_int(normal_costs),
		"normal_objective_T_median": _median_int(normal_costs),
		"normal_objective_T_max": _max_int(normal_costs),
		"errors": errors,
	}


func _summarize_trial(sample: Dictionary, seed_value: int, result: Dictionary) -> Dictionary:
	var outcome := str(result.get("outcome", ""))
	var terminal_reason := str(result.get("terminal_reason", ""))
	var normal_complete := bool(result.get("normal_objective_complete", false))
	var classification := "UNVERIFIED_HARNESS_OR_WALL_LIMIT"
	if normal_complete:
		classification = "MECHANICAL_WIN_ONE_POLICY_ONE_SEED"
	elif outcome in ["danger", "timeout"] or terminal_reason == "MOVE_BUDGET_EXHAUSTED":
		classification = "MECHANICAL_TERMINAL_FAILURE_ONE_POLICY_ONE_SEED"
	return {
		"island_id": sample["island_id"],
		"level_id": sample["level_id"],
		"stratum": sample["stratum"],
		"normal_objective_T": _normal_cost(sample["definition"]),
		"vip_enabled_optional": _vip_enabled(sample["definition"]),
		"seed": seed_value,
		"policy": POLICY,
		"outcome": outcome,
		"terminal_reason": terminal_reason,
		"classification": classification,
		"shots": int(result.get("shot_count", 0)),
		"moves_used": int(result.get("moves_used", 0)),
		"move_limit": int(result.get("move_limit", 0)),
		"moves_remaining": int(result.get("moves_remaining", 0)),
		"normal_complete": normal_complete,
		"vip_complete": bool(result.get("vip_complete", false)),
		"peak_live_drinks": int(result.get("peak_live_drinks", 0)),
		"elapsed_simulated_sec": snappedf(float(result.get("elapsed_sec", 0.0)), 0.01),
	}


func _not_run_record(sample: Dictionary, seed_value: int, reason: String) -> Dictionary:
	return {
		"island_id": sample["island_id"],
		"level_id": sample["level_id"],
		"stratum": sample["stratum"],
		"normal_objective_T": _normal_cost(sample["definition"]),
		"vip_enabled_optional": _vip_enabled(sample["definition"]),
		"seed": seed_value,
		"policy": POLICY,
		"outcome": "not_run",
		"terminal_reason": reason,
		"classification": "UNVERIFIED_NOT_RUN",
		"shots": 0,
		"moves_used": 0,
		"move_limit": 0,
		"moves_remaining": 0,
		"normal_complete": false,
		"vip_complete": false,
	}


func _normal_cost(definition: Dictionary) -> int:
	var total := 0
	for order in definition.get("orders", []):
		total += (1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"])
	return total


func _vip_enabled(definition: Dictionary) -> bool:
	var vip: Variant = definition.get("vip", null)
	return vip is Dictionary and bool(vip.get("enabled", true))


func _count_vip_samples(trials: Array) -> int:
	var count := 0
	for trial in trials:
		if bool(trial.get("vip_enabled_optional", false)) and str(trial.get("classification", "")).begins_with("MECHANICAL_"):
			count += 1
	return count


func _count_vip_skips(trials: Array) -> int:
	var count := 0
	for trial in trials:
		if bool(trial.get("vip_enabled_optional", false)) and bool(trial.get("normal_complete", false)) and not bool(trial.get("vip_complete", false)):
			count += 1
	return count


func _write_report(report: Dictionary) -> void:
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write %s: %s" % [OUTPUT_PATH, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()


func _min_int(values: Array[int]) -> int:
	var result := 0
	if values.is_empty():
		return result
	result = values[0]
	for value in values:
		result = mini(result, value)
	return result


func _max_int(values: Array[int]) -> int:
	var result := 0
	for value in values:
		result = maxi(result, value)
	return result


func _median_int(values: Array[int]) -> int:
	if values.is_empty():
		return 0
	var sorted := values.duplicate()
	sorted.sort()
	return sorted[int(sorted.size() / 2)]
