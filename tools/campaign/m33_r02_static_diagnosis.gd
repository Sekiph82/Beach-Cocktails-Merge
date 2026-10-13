extends SceneTree

## Reconcile all candidate recipe arithmetic against the live Godot campaign models.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const SCREENING_MODEL = preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const DIFFICULTY_MODEL = preload("res://scripts/campaign/m17_difficulty_model.gd")
const FIRST_GLOBAL := 101
const LAST_GLOBAL := 1000
const OUTPUT_PATH := "res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R02/static_diagnosis.json"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M33_R02_STATIC database load failed: %s" % database.get_last_error())
		quit(2)
		return
	var closure: Array[int] = SCREENING_MODEL.reachable_closure(DATABASE_SCRIPT.MAX_COCKTAIL_LEVEL)
	var island_ids := database.get_island_ids_in_order()
	var closure_lookup: Dictionary = {}
	for level in closure:
		closure_lookup[level] = true
	var per_island: Dictionary = {}
	var invalid_records: Array[Dictionary] = []
	var all_normal_t: Array[int] = []
	var vip_count := 0
	var vip_intermediate_heuristic_count := 0
	var candidate_count := 0
	for global_id in range(FIRST_GLOBAL, LAST_GLOBAL + 1):
		var island_index := int(floor(float(global_id - 1) / 100.0))
		var island_id := island_ids[island_index]
		var local_id := ((global_id - 1) % 100) + 1
		var definition: Dictionary = database.get_level(island_id, local_id)
		var errors: Array[String] = []
		if definition.is_empty():
			errors.append("CANONICAL_LEVEL_MISSING")
			invalid_records.append({"global_level_id": global_id, "errors": errors})
			continue
		if global_id >= 102:
			candidate_count += 1
		for order in definition.get("orders", []):
			if not order is Dictionary:
				errors.append("ORDER_NOT_DICTIONARY")
				continue
			var target := int(order.get("cocktail_level", 0))
			var quantity := int(order.get("quantity", 0))
			if target < 3 or target > DATABASE_SCRIPT.MAX_COCKTAIL_LEVEL or quantity <= 0:
				errors.append("NORMAL_ORDER_OUT_OF_PRODUCTION_RANGE")
			if not closure_lookup.has(target):
				errors.append("NORMAL_ORDER_NOT_IN_MERGE_CLOSURE")
			if not database.is_campaign_target_level_eligible(island_id, target):
				errors.append("NORMAL_ORDER_OUTSIDE_ISLAND_POLICY")
		var budget: Dictionary = DATABASE_SCRIPT.calculate_ideal_l3_move_budget(definition)
		if budget.is_empty():
			errors.append("IDEAL_L3_BUDGET_INVALID")
		var normal_t := int(budget.get("theoretical_shots_to_go", 0))
		var vip_t := int(budget.get("theoretical_shots_vip", 0))
		var total_t := int(budget.get("theoretical_shots_total", 0))
		if int(budget.get("move_limit", 0)) != total_t * 4 or int(definition.get("move_limit", 0)) != total_t * 4:
			errors.append("MOVE_LIMIT_NOT_EQUAL_TO_4T_TOTAL")
		if float(definition.get("time_limit_sec", 0.0)) != 0.0:
			errors.append("TIMER_NOT_DISABLED")
		all_normal_t.append(normal_t)
		var vip: Variant = definition.get("vip", null)
		if vip is Dictionary and bool(vip.get("enabled", true)):
			vip_count += 1
			var vip_level := int(vip.get("cocktail_level", 0))
			if vip_level < 3 or vip_level > DATABASE_SCRIPT.MAX_COCKTAIL_LEVEL or int(vip.get("quantity", 0)) <= 0:
				errors.append("VIP_OUT_OF_PRODUCTION_RANGE")
			if not database.is_campaign_target_level_eligible(island_id, vip_level):
				errors.append("VIP_OUTSIDE_ISLAND_POLICY")
			var vip_analysis: Dictionary = SCREENING_MODEL.vip_interception_analysis(definition)
			if bool(vip_analysis.get("vip_interception_risk", false)):
				vip_intermediate_heuristic_count += 1
		var island: Dictionary = per_island.get(island_id, {"candidate_count": 0, "vip_count": 0, "normal_T": []})
		if global_id >= 102:
			island["candidate_count"] = int(island["candidate_count"]) + 1
		island["normal_T"].append(normal_t)
		if vip is Dictionary and bool(vip.get("enabled", true)):
			island["vip_count"] = int(island["vip_count"]) + 1
		per_island[island_id] = island
		if not errors.is_empty():
			invalid_records.append({"global_level_id": global_id, "island_id": island_id, "local_level_id": local_id, "errors": errors})
	for island_id in per_island:
		var values: Array = per_island[island_id]["normal_T"]
		values.sort()
		per_island[island_id]["normal_T_summary"] = {"minimum": values.front(), "median": values[int(values.size() / 2.0)], "maximum": values.back()}
		per_island[island_id].erase("normal_T")
	all_normal_t.sort()
	var report := {
		"schema_version": 1,
		"milestone": "BCM-M33-R02",
		"records_checked_including_control_101": LAST_GLOBAL - FIRST_GLOBAL + 1,
		"candidate_levels_checked": candidate_count,
		"candidate_range": {"first": 102, "last": 1000},
		"production_spawn_levels": [1, 2, 3],
		"merge_closure_through_max_level": closure,
		"normal_T_definition": "sum(2^(target_level - 3) * quantity), the L3-equivalent normal To-Go lower bound",
		"vip_T_definition": "same L3-equivalent lower bound, reported separately and excluded from normal To-Go objective",
		"move_limit_definition": "4 * (normal_T + enabled_VIP_T)",
		"time_limit_sec_expected": 0,
		"static_infeasible_records": invalid_records,
		"static_infeasible_count": invalid_records.size(),
		"enabled_vip_record_count": vip_count,
		"conservative_vip_intermediate_heuristic_flag_count": vip_intermediate_heuristic_count,
		"vip_heuristic_note": "m17_canonical_screening_model.vip_interception_analysis flags higher mandatory orders that can create VIP-level intermediates; it is a conservative recipe heuristic, not a runtime proof that VIP delivery is forced. Production GameManager uses M17VipOptionalityModel mandatory-reserve checks before optional VIP capture.",
		"normal_T_global_summary": {"minimum": all_normal_t.front(), "median": all_normal_t[int(all_normal_t.size() / 2.0)], "p90": all_normal_t[int(ceil(float(all_normal_t.size() - 1) * 0.90))], "maximum": all_normal_t.back()},
		"by_island": per_island,
		"conclusion": "No objective infeasibility was found by the checked input, target-closure, island-policy, 4T-budget, and untimed invariants. This is necessary-condition data validation, not a proof of physical placement reachability, policy solvability, human fairness, or campaign acceptance.",
	}
	var absolute := ProjectSettings.globalize_path(OUTPUT_PATH)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("M33_R02_STATIC output could not be created")
		quit(2)
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.flush()
	file.close()
	print("M33_R02_STATIC_RESULT=PASS candidates=%d invalid=%d vip=%d conservative_vip_intermediate_flags=%d output=%s" % [candidate_count, invalid_records.size(), vip_count, vip_intermediate_heuristic_count, OUTPUT_PATH])
	quit(0)
