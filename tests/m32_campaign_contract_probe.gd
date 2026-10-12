extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const WORKFLOW_SCRIPT := preload("res://scripts/campaign/m32_content_workflow.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M32_CONTRACT_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M32_CONTRACT_PROBE FAIL: %s" % label)


func _run() -> void:
	var seed_database = DATABASE_SCRIPT.new()
	var seed_loaded := seed_database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.SEED)
	_check("canonical staged campaign loads in SEED mode", seed_loaded)
	if not seed_loaded:
		print("M32_DATABASE_ERROR=%s" % seed_database.get_last_error())
		quit(1)
		return
	var contract: Dictionary = seed_database.get_campaign_contract()
	_check("contract states ten islands and one hundred levels apiece", int(contract.get("island_count", 0)) == 10 and int(contract.get("levels_per_island", 0)) == 100 and int(contract.get("total_levels", 0)) == 1000)
	_check("the ordered registry contains the ten canonical IDs", seed_database.get_island_ids_in_order() == contract.get("ordered_island_ids", []))
	var readiness := WORKFLOW_SCRIPT.verify_campaign_readiness(seed_database)
	_check("missing future content is reported as pending", readiness.get("status", "") == "PENDING_CONTENT" and not readiness.get("readiness", {}).get("pending_islands", []).is_empty())
	_check("Sunny Cove remains exactly one hundred authored rows", int(readiness.get("readiness", {}).get("authored_level_counts", {}).get("sunny_cove", {}).get("authored", 0)) == 100)
	_check("Tiki Island exposes its twelve-level first slice without claiming full readiness", int(readiness.get("readiness", {}).get("authored_level_counts", {}).get("tiki_island", {}).get("authored", 0)) == 12)
	var first_candidates: Array[Dictionary] = WORKFLOW_SCRIPT.generate_candidates(seed_database, "sunny_cove", 101, 8, 32001)
	var second_candidates: Array[Dictionary] = WORKFLOW_SCRIPT.generate_candidates(seed_database, "sunny_cove", 101, 8, 32001)
	_check("seeded authoring is deterministic", first_candidates == second_candidates and first_candidates.size() == 8)
	var candidate_checks_pass := true
	for candidate in first_candidates:
		candidate_checks_pass = candidate_checks_pass and bool(WORKFLOW_SCRIPT.verify_candidate(seed_database, candidate).get("ok", false))
	_check("generated candidates pass production objective, VIP, move-limit and star checks", candidate_checks_pass)
	var full_database = DATABASE_SCRIPT.new()
	var full_loaded := full_database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("FULL mode fails closed while the 900 future levels are missing", not full_loaded and full_database.get_last_error().contains("full campaign content is missing or incomplete"))
	if failures.is_empty():
		print("M32_CONTRACT_PROBE_RESULT=PASS")
		quit(0)
	else:
		print("M32_CONTRACT_PROBE_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
