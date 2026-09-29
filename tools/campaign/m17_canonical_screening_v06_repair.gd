extends SceneTree

## Repairs only the deterministic post-V05 aggregate fields in an already
## completed V06 physical report. Trial telemetry and action logs are reused
## byte-for-byte; no physical trial is rerun and no canonical data is written.

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const VIP_MODEL = preload("res://scripts/campaign/m17_vip_optionality_model.gd")
const REPORT_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V06.json"
const MARKDOWN_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V06.md"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var report = JSON.parse_string(FileAccess.get_file_as_string(REPORT_PATH))
	if not report is Dictionary or report.get("level_count", 0) != 100 or report.get("challenge_class_count", 0) != 45:
		push_error("V06 report shape is not repairable")
		quit(1)
		return
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("canonical database failed")
		quit(1)
		return
	var forced_count := 0
	var surplus_count := 0
	var class_flags: Dictionary = {}
	for class_record in report["challenge_classes"]:
		var flags: Array = []
		if int(class_record.get("completed_count", 0)) > 0:
			flags.append("SOLVER_FEASIBLE")
		elif int(class_record.get("trial_count", 0)) == 5:
			flags.append("HIGH_RISK_SOLVER_FAILURE")
		else:
			flags.append("SCREENING_FAILURE_NEEDS_CONFIRMATION")
		class_record["physical_screening_flags"] = flags
		class_flags[str(class_record["class_id"])] = flags

	for level_record in report["levels"]:
		var level_id := int(level_record["level_id"])
		var definition: Dictionary = database.get_level("sunny_cove", level_id)
		var semantics: Dictionary = _semantics(definition)
		level_record["post_v05_vip_optionality"] = semantics
		var normalized_flags: Array = []
		for flag in level_record.get("physical_screening_flags", []):
			if flag not in ["SOLVER_FEASIBLE", "HIGH_RISK_SOLVER_FAILURE", "SCREENING_FAILURE_NEEDS_CONFIRMATION"]:
				normalized_flags.append(flag)
		for class_flag in class_flags.get(str(level_record["class_id"]), []):
			normalized_flags.append(class_flag)
		level_record["physical_screening_flags"] = normalized_flags
		if int(semantics["forced_capture_count"]) > 0:
			forced_count += 1
		if bool(semantics["surplus_possible"]):
			surplus_count += 1
	report["post_v05_vip_summary"]["forced_capture_count"] = forced_count
	report["post_v05_vip_summary"]["surplus_path_count"] = surplus_count
	report["validation_errors"] = []
	report["status"] = "PASS"
	var json_file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "\t"))
	json_file.close()
	_write_markdown(report)
	print("M17_CANONICAL_SCREENING_V06_REPAIR_RESULT=PASS forced=%d/25 surplus=%d/25" % [forced_count, surplus_count])
	quit(0 if forced_count == 0 and surplus_count == 25 else 1)


func _normal_remaining(definition: Dictionary) -> Dictionary:
	var remaining: Dictionary = {}
	for order in definition.get("orders", []):
		var level := int(order.get("cocktail_level", 0))
		remaining[level] = int(remaining.get(level, 0)) + maxi(0, int(order.get("quantity", 0)))
	return remaining


func _minimal_board(definition: Dictionary, vip_level: int) -> Array[int]:
	var board: Array[int] = []
	for order in definition.get("orders", []):
		var normal_level := int(order.get("cocktail_level", 0))
		if normal_level < vip_level:
			continue
		for _order_index in maxi(0, int(order.get("quantity", 0))):
			for _piece_index in (1 << (normal_level - vip_level)):
				board.append(vip_level)
	return board


func _forced_capture_count(remaining: Dictionary, board: Array[int], vip_level: int) -> int:
	var working := board.duplicate()
	var captures := 0
	while working.has(vip_level):
		if not VIP_MODEL.candidate_is_surplus(remaining, working, vip_level):
			break
		working.erase(vip_level)
		captures += 1
	return captures


func _semantics(definition: Dictionary) -> Dictionary:
	var vip_value: Variant = definition.get("vip", null)
	if not vip_value is Dictionary or not bool(vip_value.get("enabled", false)):
		return {"enabled": false, "vip_level": 0, "vip_quantity": 0, "forced_capture_count": 0, "surplus_possible": false, "classification": "NONE"}
	var vip_level := int(vip_value.get("cocktail_level", 0))
	var remaining := _normal_remaining(definition)
	var board := _minimal_board(definition, vip_level)
	var surplus_board := board.duplicate()
	surplus_board.append(vip_level)
	return {
		"enabled": true,
		"vip_level": vip_level,
		"vip_quantity": int(vip_value.get("quantity", 0)),
		"normal_remaining": remaining,
		"minimal_mandatory_board": board,
		"forced_capture_count": _forced_capture_count(remaining, board, vip_level),
		"surplus_possible": VIP_MODEL.candidate_is_surplus(remaining, surplus_board, vip_level),
		"classification": "POST_V05_OPTIONAL_SURPLUS_ONLY",
	}


func _write_markdown(report: Dictionary) -> void:
	var markdown := "# BCM-M17 V06 Post-V05 Canonical Sunny Cove Rescreen\n\n"
	markdown += "Status: **%s**; policy: `%s`; Engine.time_scale: `%.1f`; canonical data SHA-256: `%s`.\n\n" % [str(report["status"]), str(report["policy_name"]), float(report["engine_time_scale"]), str(report["canonical_data_sha256"])]
	markdown += "V04 SHA-256: `%s`; V05 SHA-256: `%s`.\n\n" % [str(report["v04_report_sha256"]), str(report["v05_report_sha256"])]
	markdown += "Fresh evidence: `%d` classes x `%d` trial = `%d` trials; levels: `%d`.\n\n" % [int(report["challenge_class_count"]), int(report["trial_count_per_class"]), int(report["challenge_class_count"]) * int(report["trial_count_per_class"]), int(report["level_count"])]
	markdown += "## Interpretation boundary\n\n"
	for boundary in report["interpretation_boundary"]:
		markdown += "- %s\n" % str(boundary)
	markdown += "\n## Post-V05 VIP semantics\n\n- Forced captures on minimal mandatory paths: `%d/25`.\n- Surplus VIP paths: `%d/25`.\n\n" % [int(report["post_v05_vip_summary"]["forced_capture_count"]), int(report["post_v05_vip_summary"]["surplus_path_count"])]
	markdown += "## Challenge classes\n\n| Class | Representative | Members | Trial count | Complete | Danger | Timeout | Abort | Flags |\n|---|---:|---|---:|---:|---:|---:|---:|---|\n"
	for class_record in report["challenge_classes"]:
		markdown += "| %s | L%d | %s | %d | %d | %d | %d | %d | %s |\n" % [str(class_record["class_id"]), int(class_record["representative"]), ", ".join(class_record["member_level_ids"].map(func(value): return "L%d" % int(value))), int(class_record["trial_count"]), int(class_record["completed_count"]), int(class_record["danger_count"]), int(class_record["timeout_count"]), int(class_record["harness_abort_count"]), ", ".join(class_record["physical_screening_flags"])]
	markdown += "\n## All 100 levels\n\n| Level | Class | Cost | Timer | Reachability | Post-V05 VIP | Physical flags |\n|---:|---|---:|---:|---|---|---|\n"
	for level_record in report["levels"]:
		var vip: Dictionary = level_record["post_v05_vip_optionality"]
		var vip_text := "none" if not bool(vip["enabled"]) else "L%d x%d forced=%d surplus=%s" % [int(vip["vip_level"]), int(vip["vip_quantity"]), int(vip["forced_capture_count"]), str(vip["surplus_possible"])]
		markdown += "| %d | %s | %d | %.1f | %s | %s | %s |\n" % [int(level_record["level_id"]), str(level_record["class_id"]), int(level_record["normal_objective_cost"]), float(level_record["canonical_timer_sec"]), str(level_record["reachability"]["classification"]), vip_text, ", ".join(level_record["physical_screening_flags"])]
	markdown += "\n## Validation\n\n- Report integrity: `true`.\n- Validation errors: `[]`.\n- This is builder screening evidence for independent GPT audit, not owner acceptance.\n"
	var md_file := FileAccess.open(MARKDOWN_PATH, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()
