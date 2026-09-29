extends SceneTree

## Generates immutable V05 structural evidence from canonical data, historical
## V04 records, and the production reserve planner.

const MODEL_SCRIPT = preload("res://scripts/campaign/m17_vip_optionality_model.gd")
const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const V04_PATH := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.json"
const OUT_JSON := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.json"
const OUT_MD := "res://coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.md"


func _init() -> void:
	call_deferred("_run")


func _sha256(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(file.get_buffer(file.get_length()))
	return context.finish().hex_encode().to_upper()


func _load_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed != null else {}


func _normal_remaining(definition: Dictionary) -> Dictionary:
	var remaining: Dictionary = {}
	for order in definition.get("orders", []):
		var level := int(order.get("cocktail_level", 0))
		var quantity := maxi(0, int(order.get("quantity", 0)))
		remaining[level] = int(remaining.get(level, 0)) + quantity
	return remaining


func _minimal_vip_intermediate_board(definition: Dictionary, vip_level: int) -> Array[int]:
	var board: Array[int] = []
	for order in definition.get("orders", []):
		var normal_level := int(order.get("cocktail_level", 0))
		var quantity := maxi(0, int(order.get("quantity", 0)))
		if normal_level < vip_level:
			continue
		var pieces_per_order := 1 << (normal_level - vip_level)
		for _order_index in quantity:
			for _piece_index in pieces_per_order:
				board.append(vip_level)
	return board


func _forced_capture_count(normal_remaining: Dictionary, minimal_board: Array[int], vip_level: int) -> int:
	var board := minimal_board.duplicate()
	var captures := 0
	while board.has(vip_level):
		if not MODEL_SCRIPT.candidate_is_surplus(normal_remaining, board, vip_level):
			break
		board.erase(vip_level)
		captures += 1
	return captures


func _record(level: Dictionary, historical: Dictionary) -> Dictionary:
	var level_id := int(level.get("level_id", 0))
	var normal: Array = level.get("orders", []).duplicate(true)
	var vip: Dictionary = level.get("vip", {}) if level.get("vip", null) is Dictionary else {}
	var vip_enabled := bool(vip.get("enabled", false))
	var vip_level := int(vip.get("cocktail_level", 0)) if vip_enabled else 0
	var vip_quantity := int(vip.get("quantity", 0)) if vip_enabled else 0
	var normal_remaining := _normal_remaining(level)
	var minimal_board: Array[int] = []
	if vip_enabled:
		minimal_board = _minimal_vip_intermediate_board(level, vip_level)
	var forced_count := _forced_capture_count(normal_remaining, minimal_board, vip_level) if vip_enabled else 0
	var surplus_board := minimal_board.duplicate()
	if vip_enabled:
		surplus_board.append(vip_level)
	var surplus_possible := vip_enabled and MODEL_SCRIPT.candidate_is_surplus(normal_remaining, surplus_board, vip_level)
	var v04: Dictionary = historical.get(str(level_id), {})
	return {
		"level_id": level_id,
		"normal_objectives": normal,
		"vip_target": {"enabled": vip_enabled, "cocktail_level": vip_level, "quantity": vip_quantity},
		"minimal_mandatory_vip_level_board": minimal_board,
		"v04_historical_forced_capture_count": int(v04.get("forced_capture_count", 0)),
		"v04_historical_forced_capture_cost": int(v04.get("forced_capture_cost", 0)),
		"post_v05_forced_capture_count": forced_count,
		"post_v05_surplus_vip_possible": surplus_possible,
	}


func _run() -> void:
	var v04_root: Dictionary = _load_json(V04_PATH)
	var historical: Dictionary = {}
	for entry in v04_root.get("levels", []):
		var vip_interception: Dictionary = entry.get("vip_interception", {})
		historical[str(int(entry.get("level_id", 0)))] = {
			"forced_capture_count": int(vip_interception.get("minimum_forced_vip_captures", 0)),
			"forced_capture_cost": int(vip_interception.get("forced_vip_interception_cost", 0)),
		}

	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL):
		push_error("M17 V05 canonical database failed to load")
		quit(1)
		return
	var records: Array[Dictionary] = []
	var validation_errors: Array[String] = []
	for level in database.get_levels_for_island("sunny_cove"):
		var level_vip: Variant = level.get("vip", null)
		if not level_vip is Dictionary or not bool(level_vip.get("enabled", false)):
			continue
		var record := _record(level, historical)
		records.append(record)
		if int(record["post_v05_forced_capture_count"]) != 0:
			validation_errors.append("L%d forced capture count was %d" % [int(record["level_id"]), int(record["post_v05_forced_capture_count"])])
		if not bool(record["post_v05_surplus_vip_possible"]):
			validation_errors.append("L%d has no surplus VIP path" % int(record["level_id"]))

	var historical_risk_count := 0
	for level in v04_root.get("levels", []):
		if bool(level.get("vip_interception", {}).get("vip_interception_risk", false)):
			historical_risk_count += 1
	var post_forced_count := records.filter(func(record: Dictionary) -> bool: return int(record["post_v05_forced_capture_count"]) > 0).size()
	var surplus_count := records.filter(func(record: Dictionary) -> bool: return bool(record["post_v05_surplus_vip_possible"])).size()
	var report := {
		"schema_version": 1,
		"report_version": "M17_VIP_OPTIONALITY_V05",
		"status": "PASS" if validation_errors.is_empty() else "FAIL",
		"island_id": "sunny_cove",
		"level_count": records.size(),
		"authority": "CHATGPT_AUDIT_CRITERIA_V05 / CHATGPT_EXECUTION_PROMPT_V05",
		"M17_CANONICAL_SCREENING_V04": "PRE_OPTIONALITY_FIX / HISTORICAL_FOR_PHYSICAL_CLASSIFICATION",
		"canonical_data_path": "data/campaign/levels/sunny_cove.json",
		"canonical_data_sha256": _sha256(DATABASE_SCRIPT.DEFAULT_LEVELS_PATH),
		"v04_historical_path": V04_PATH,
		"v04_historical_sha256": _sha256(V04_PATH),
		"historical_v04_risk_count": historical_risk_count,
		"historical_v04_risk_denominator": 25,
		"post_v05_forced_capture_count": post_forced_count,
		"post_v05_forced_capture_denominator": 25,
		"post_v05_surplus_path_count": surplus_count,
		"post_v05_surplus_path_denominator": 25,
		"validation_errors": validation_errors,
		"levels": records,
	}
	var json_file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "\t"))
	json_file.close()
	var markdown := "# M17 VIP Optionality V05 Structural Evidence\n\n"
	markdown += "Status: **%s**\n\n" % str(report["status"])
	markdown += "`M17_CANONICAL_SCREENING_V04 = PRE_OPTIONALITY_FIX / HISTORICAL_FOR_PHYSICAL_CLASSIFICATION`\n\n"
	markdown += "V04 historical evidence remains immutable; this report is a post-fix structural analysis and does not perform physical screening or canonical tuning.\n\n"
	markdown += "## Aggregate results\n\n"
	markdown += "- Canonical Sunny Cove levels analyzed: `%d`.\n" % records.size()
	markdown += "- Historical V04 interception risk: `%d/25`.\n" % historical_risk_count
	markdown += "- Post-V05 forced VIP captures on minimal mandatory production path: `%d/25`.\n" % post_forced_count
	markdown += "- Post-V05 surplus VIP path remains possible: `%d/25`.\n\n" % surplus_count
	markdown += "Canonical data SHA-256: `%s`.\n\n" % str(report["canonical_data_sha256"])
	markdown += "V04 historical report SHA-256: `%s`.\n\n" % str(report["v04_historical_sha256"])
	markdown += "## Per-level evidence\n\n"
	markdown += "| Level | Normal | VIP | V04 forced count/cost | Post-V05 forced captures | Surplus path |\n|---:|---|---|---:|---:|---|\n"
	for record in records:
		var normal_text := ", ".join(record["normal_objectives"].map(func(order: Dictionary) -> String: return "L%d x%d" % [int(order["cocktail_level"]), int(order["quantity"])]))
		var vip: Dictionary = record["vip_target"]
		var vip_text := "L%d x%d" % [int(vip["cocktail_level"]), int(vip["quantity"])] if bool(vip["enabled"]) else "none"
		markdown += "| %d | %s | %s | %d / %d | %d | %s |\n" % [int(record["level_id"]), normal_text, vip_text, int(record["v04_historical_forced_capture_count"]), int(record["v04_historical_forced_capture_cost"]), int(record["post_v05_forced_capture_count"]), "YES" if bool(record["post_v05_surplus_vip_possible"]) else "NO"]
	markdown += "\n## Governance boundary\n\n"
	markdown += "- No Sunny Cove normal order, timer, VIP target, VIP quantity, reward, HUD, score, WIN/LOSE, progression, or physics data was changed.\n"
	markdown += "- Post-fix physical screening is required before M17-008 tuning.\n"
	markdown += "- This report is builder evidence for independent ChatGPT audit, not acceptance.\n"
	var md_file := FileAccess.open(OUT_MD, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()
	print("M17_VIP_OPTIONALITY_V05_RESULT=%s historical=%d/25 forced=%d/25 surplus=%d/25" % [str(report["status"]), historical_risk_count, post_forced_count, surplus_count])
	quit(0 if validation_errors.is_empty() else 1)
