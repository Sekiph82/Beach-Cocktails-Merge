class_name M32ContentWorkflow
extends RefCounted

## Seeded candidate authoring and verification helpers for the M32 campaign.
## Shipping validation stays in LevelDatabase and the M17 production-rule
## models. Physical reachability evidence comes from M17SeededValidationHarness,
## which launches production drinks through the real physics/merge/objective path.

const DIFFICULTY_MODEL := preload("res://scripts/campaign/m17_difficulty_model.gd")
const SCREENING_MODEL := preload("res://scripts/campaign/m17_canonical_screening_model.gd")
const VIP_OPTIONALITY_MODEL := preload("res://scripts/campaign/m17_vip_optionality_model.gd")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const SESSION_BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")


static func generate_candidates(database, island_id: String, first_level_id: int, quantity: int, seed_value: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if database == null or quantity <= 0 or first_level_id <= 0:
		return result
	var island: Dictionary = database.get_island(island_id)
	if island.is_empty():
		return result
	var policy: Dictionary = island.get("target_policy", {})
	var minimum := maxi(3, int(policy.get("min_level", 3)))
	var maximum := mini(12, int(policy.get("max_level", 8)))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var signatures: Dictionary = {}
	var attempts := 0
	while result.size() < quantity and attempts < quantity * 40:
		attempts += 1
		var first_target := rng.randi_range(minimum, maximum)
		var orders: Array[Dictionary] = [{"cocktail_level": first_target, "quantity": 1}]
		if rng.randf() < 0.55:
			var second_target := rng.randi_range(minimum, first_target)
			orders.append({"cocktail_level": second_target, "quantity": 1 + (1 if rng.randf() < 0.18 else 0)})
		var level_id := first_level_id + result.size()
		var candidate := {
			"island_id": island_id,
			"level_id": level_id,
			"time_limit_sec": 0,
			"orders": orders,
			"vip": null,
			"rewards": {"coins": 0},
			"score_star_thresholds": {"one_star": 0, "two_stars": 0, "three_stars": 0},
			"feature_flags": {"timed": false, "vip": false, "boosters": false},
		}
		var signature := SCREENING_MODEL.signature_key(SCREENING_MODEL.challenge_signature(candidate))
		if signatures.has(signature) or not verify_candidate(database, candidate).get("ok", false):
			continue
		signatures[signature] = true
		result.append(candidate)
	return result


static func verify_candidate(database, candidate: Dictionary) -> Dictionary:
	var island_id := str(candidate.get("island_id", ""))
	var errors: Array[String] = []
	if island_id.is_empty() or database == null or database.get_island(island_id).is_empty():
		errors.append("UNKNOWN_ISLAND")
	else:
		var legality := SCREENING_MODEL.level_reachability(candidate, DATABASE_SCRIPT.MAX_COCKTAIL_LEVEL)
		if not bool(legality.get("valid", false)):
			errors.append("IMPOSSIBLE_OBJECTIVE:%s" % JSON.stringify(legality.get("invalid_reasons", [])))
		for order in candidate.get("orders", []):
			if not database.is_campaign_target_level_eligible(island_id, int(order.get("cocktail_level", 0))):
				errors.append("TARGET_OUTSIDE_ISLAND_POLICY")
		var move_budget := DATABASE_SCRIPT.calculate_ideal_l3_move_budget(candidate)
		if move_budget.is_empty() or int(move_budget.get("move_limit", 0)) != int(move_budget.get("theoretical_shots_total", 0)) * 4:
			errors.append("INVALID_PERCENT400_MOVE_BUDGET")
		var ideal_shots := int(move_budget.get("theoretical_shots_total", 0))
		var star_bridge = SESSION_BRIDGE_SCRIPT.new()
		if ideal_shots <= 0 or star_bridge.calculate_stars(true, ideal_shots, ideal_shots) != 3 or star_bridge.calculate_stars(true, ideal_shots * 2, ideal_shots) != 2 or star_bridge.calculate_stars(true, ideal_shots * 4, ideal_shots) != 1 or star_bridge.calculate_stars(true, ideal_shots * 4 + 1, ideal_shots) != 0:
			errors.append("PERCENT400_STAR_BOUNDARY_MISMATCH")
		var vip_analysis := SCREENING_MODEL.vip_interception_analysis(candidate)
		if bool(vip_analysis.get("vip_interception_risk", false)):
			errors.append("VIP_NOT_OPTIONAL:%s" % JSON.stringify(vip_analysis))
		var vip: Variant = candidate.get("vip", null)
		if vip is Dictionary and bool(vip.get("enabled", true)):
			var normal_remaining: Dictionary = {}
			for order in candidate.get("orders", []):
				var target_level := int(order.get("cocktail_level", 0))
				normal_remaining[target_level] = int(normal_remaining.get(target_level, 0)) + int(order.get("quantity", 0))
			var vip_level := int(vip.get("cocktail_level", 0))
			var optionality_reserve := VIP_OPTIONALITY_MODEL.mandatory_reserve_cost(normal_remaining, [vip_level])
			if optionality_reserve > VIP_OPTIONALITY_MODEL.mandatory_reserve_cost(normal_remaining, []):
				errors.append("VIP_CAPTURE_INCREASES_NORMAL_OBJECTIVE_RESERVE")
		if float(candidate.get("time_limit_sec", 0.0)) != 0.0:
			errors.append("TIMER_FORBIDDEN")
	return {"ok": errors.is_empty(), "errors": errors, "move_budget": DATABASE_SCRIPT.calculate_ideal_l3_move_budget(candidate)}


static func verify_campaign_readiness(database) -> Dictionary:
	if database == null or not database.is_loaded():
		return {"ok": false, "status": "INVALID_DATABASE", "errors": ["DATABASE_NOT_LOADED"]}
	var readiness: Dictionary = database.get_campaign_readiness()
	var ids: Array[String] = database.get_island_ids_in_order()
	var errors: Array[String] = []
	if not database.get_campaign_contract().is_empty() and ids.size() != 10:
		errors.append("ISLAND_COUNT_MISMATCH")
	return {
		"ok": errors.is_empty(),
		"status": str(readiness.get("status", "UNSPECIFIED")),
		"readiness": readiness,
		"errors": errors,
	}


static func run_physics_screen(harness, database, candidate: Dictionary, seed_value: int) -> Dictionary:
	## This delegates to the established M17 harness; it does not predict a win
	## with a second, content-tool-specific simulator.
	if harness == null:
		return {"ok": false, "reason": "M17_HARNESS_REQUIRED"}
	var static_result := verify_candidate(database, candidate)
	if not bool(static_result.get("ok", false)):
		return {"ok": false, "reason": "STATIC_SCREEN_FAILED", "static": static_result}
	var trial: Dictionary = await harness.run_trial(database, str(candidate["island_id"]), int(candidate["level_id"]), seed_value)
	return {"ok": str(trial.get("outcome", "")) == "completed", "static": static_result, "physics_trial": trial}
