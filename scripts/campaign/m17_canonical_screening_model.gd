class_name M17CanonicalScreeningModel
extends RefCounted

## Pure V04 analytical helpers.
##
## This model describes canonical challenge signatures, mathematical merge
## reachability, timer/cost diagnostics, and the minimum VIP-interception
## workload implied by production's normal-first/VIP-second routing. It never
## mutates campaign data or runtime gameplay state.

const DIFFICULTY_MODEL = preload("res://scripts/campaign/m17_difficulty_model.gd")


static func challenge_signature(level_definition: Dictionary) -> Dictionary:
	var orders: Array = []
	for order in level_definition.get("orders", []):
		if order is Dictionary:
			orders.append({
				"cocktail_level": int(order.get("cocktail_level", 0)),
				"quantity": int(order.get("quantity", 0)),
			})
	var vip: Dictionary = {"enabled": false, "cocktail_level": 0, "quantity": 0}
	var vip_value: Variant = level_definition.get("vip", null)
	if vip_value is Dictionary and bool(vip_value.get("enabled", true)):
		vip = {
			"enabled": true,
			"cocktail_level": int(vip_value.get("cocktail_level", 0)),
			"quantity": int(vip_value.get("quantity", 0)),
		}
	return {
		"orders": orders,
		"time_limit_sec": float(level_definition.get("time_limit_sec", 0.0)),
		"vip": vip,
	}


static func signature_key(signature: Dictionary) -> String:
	var orders: Array = []
	for order_variant in signature.get("orders", []):
		if order_variant is Dictionary:
			var order: Dictionary = order_variant
			orders.append({
				"cocktail_level": int(order.get("cocktail_level", 0)),
				"quantity": int(order.get("quantity", 0)),
			})
	var vip_variant = signature.get("vip", {})
	var vip: Dictionary = vip_variant if vip_variant is Dictionary else {}
	var normalized := {
		"orders": orders,
		"time_limit_sec": float(signature.get("time_limit_sec", 0.0)),
		"vip": {
			"enabled": bool(vip.get("enabled", false)),
			"cocktail_level": int(vip.get("cocktail_level", 0)),
			"quantity": int(vip.get("quantity", 0)),
		},
	}
	return JSON.stringify(normalized)


static func build_challenge_classes(levels: Array[Dictionary]) -> Array[Dictionary]:
	var by_signature: Dictionary = {}
	for level_definition in levels:
		var signature := challenge_signature(level_definition)
		var key := signature_key(signature)
		if not by_signature.has(key):
			by_signature[key] = {
				"signature": signature,
				"member_level_ids": [],
			}
		by_signature[key]["member_level_ids"].append(int(level_definition.get("level_id", 0)))
	var classes: Array[Dictionary] = []
	for value in by_signature.values():
		var class_record: Dictionary = value
		var members: Array = class_record["member_level_ids"]
		members.sort()
		class_record["member_level_ids"] = members
		class_record["representative"] = int(members[0]) if not members.is_empty() else 0
		classes.append(class_record)
	classes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["representative"]) < int(b["representative"])
	)
	for index in range(classes.size()):
		classes[index]["class_id"] = "C%02d" % (index + 1)
	return classes


static func reachable_closure(max_level: int) -> Array[int]:
	var reachable: Dictionary = {}
	for spawn_level in [1, 2, 3]:
		if spawn_level <= max_level:
			reachable[spawn_level] = true
	var changed := true
	while changed:
		changed = false
		for level in range(1, max_level):
			if reachable.has(level) and not reachable.has(level + 1):
				reachable[level + 1] = true
				changed = true
	var result: Array[int] = []
	for level in reachable.keys():
		result.append(int(level))
	result.sort()
	return result


static func level_reachability(level_definition: Dictionary, max_level: int) -> Dictionary:
	var closure := reachable_closure(max_level)
	var closure_lookup: Dictionary = {}
	for level in closure:
		closure_lookup[level] = true
	var invalid_orders: Array = []
	for order in level_definition.get("orders", []):
		if not order is Dictionary:
			invalid_orders.append({"reason": "ORDER_NOT_DICTIONARY"})
			continue
		var target_level := int(order.get("cocktail_level", 0))
		var quantity := int(order.get("quantity", 0))
		if not closure_lookup.has(target_level):
			invalid_orders.append({"cocktail_level": target_level, "reason": "TARGET_NOT_REACHABLE"})
		if quantity <= 0:
			invalid_orders.append({"cocktail_level": target_level, "quantity": quantity, "reason": "NONPOSITIVE_QUANTITY"})
	var timer := float(level_definition.get("time_limit_sec", 0.0))
	if timer <= 0.0:
		invalid_orders.append({"reason": "NONPOSITIVE_TIMER"})
	return {
		"reachable_closure": closure,
		"max_level": max_level,
		"valid": invalid_orders.is_empty(),
		"invalid_reasons": invalid_orders,
		"classification": "NONE" if invalid_orders.is_empty() else "MATHEMATICALLY_UNREACHABLE",
	}


static func timer_scan(levels: Array[Dictionary], seconds_per_launch: float = DIFFICULTY_MODEL.DEFAULT_SECONDS_PER_LAUNCH) -> Dictionary:
	var ratios: Array = []
	var preliminary: Array[Dictionary] = []
	for level_definition in levels:
		var calculation := DIFFICULTY_MODEL.timer_calculation(level_definition, seconds_per_launch)
		var cost := int(calculation["normal_objective_cost"])
		var timer := float(calculation["canonical_timer_sec"])
		var ratio := timer / float(cost) if cost > 0 else 0.0
		ratios.append(ratio)
		preliminary.append({
			"level_id": int(level_definition.get("level_id", 0)),
			"normal_objective_cost": cost,
			"canonical_timer_sec": timer,
			"timer_cost_ratio": ratio,
			"planning_target_time_sec": float(calculation["planning_target_time_sec"]),
			"planning_target_minus_canonical_timer_sec": float(calculation["planning_target_minus_canonical_timer_sec"]),
		})
	var median_ratio := DIFFICULTY_MODEL.percentile(ratios, 0.5)
	for record in preliminary:
		var ratio := float(record["timer_cost_ratio"])
		var deviation := ((ratio - median_ratio) / median_ratio * 100.0) if median_ratio > 0.0 else 0.0
		record["timer_cost_ratio_deviation_percent"] = deviation
		record["analytical_timer_ratio_outlier"] = absf(deviation) > 5.0
	return {
		"seconds_per_launch_calibration": seconds_per_launch,
		"cohort_median_timer_cost_ratio": median_ratio,
		"levels": preliminary,
	}


static func vip_interception_analysis(level_definition: Dictionary) -> Dictionary:
	var normal_cost := DIFFICULTY_MODEL.normal_objective_cost(level_definition)
	var vip_value: Variant = level_definition.get("vip", null)
	if not vip_value is Dictionary or not bool(vip_value.get("enabled", true)):
		return {
			"vip_enabled": false,
			"vip_level": 0,
			"vip_quantity_remaining": 0,
			"higher_mandatory_target_generates_vip_intermediates": false,
			"intermediate_vip_piece_demand": 0,
			"minimum_forced_vip_captures": 0,
			"forced_vip_interception_cost": 0,
			"effective_mandatory_production_lower_bound": normal_cost,
			"forced_overhead_percent": 0.0,
			"vip_interception_risk": false,
		}
	var vip_level := int(vip_value.get("cocktail_level", 0))
	var vip_quantity := int(vip_value.get("quantity", 0))
	var intermediate_demand := 0
	var contributing_orders: Array = []
	for order in level_definition.get("orders", []):
		if not order is Dictionary:
			continue
		var target_level := int(order.get("cocktail_level", 0))
		var quantity := int(order.get("quantity", 0))
		if target_level > vip_level and quantity > 0:
			var pieces := quantity * (1 << (target_level - vip_level))
			intermediate_demand += pieces
			contributing_orders.append({
				"cocktail_level": target_level,
				"quantity": quantity,
				"vip_level_intermediates_per_order": 1 << (target_level - vip_level),
				"vip_level_intermediate_pieces": pieces,
			})
	var forced_captures := mini(maxi(0, vip_quantity), intermediate_demand)
	var forced_cost := forced_captures * DIFFICULTY_MODEL.cocktail_cost(vip_level)
	var overhead := forced_cost / float(normal_cost) * 100.0 if normal_cost > 0 else 0.0
	return {
		"vip_enabled": true,
		"vip_level": vip_level,
		"vip_quantity_remaining": vip_quantity,
		"higher_mandatory_target_generates_vip_intermediates": intermediate_demand > 0,
		"intermediate_vip_piece_demand": intermediate_demand,
		"contributing_higher_orders": contributing_orders,
		"minimum_forced_vip_captures": forced_captures,
		"forced_vip_interception_cost": forced_cost,
		"effective_mandatory_production_lower_bound": normal_cost + forced_cost,
		"forced_overhead_percent": overhead,
		"vip_interception_risk": forced_captures > 0,
	}


static func production_route_for_merge(normal_target_level: int, vip_level: int, merged_level: int) -> String:
	if merged_level == normal_target_level:
		return "NORMAL"
	if vip_level > 0 and merged_level == vip_level:
		return "VIP"
	return "NONE"
