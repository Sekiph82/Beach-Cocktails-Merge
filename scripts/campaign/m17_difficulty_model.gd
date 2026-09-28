class_name M17DifficultyModel
extends RefCounted

## Reusable M17 analytical model.
##
## This class is deliberately independent from player progression and runtime
## state.  Its planning values are lower-bound production estimates only: they
## do not claim that separated cocktails merge for free or that a random spawn
## sequence is guaranteed to produce the expectation.

const SPAWN_LEVELS: Array[int] = [1, 2, 3]
const SPAWN_VALUES_L1_EQUIVALENT: Array[int] = [1, 2, 4]
const EXPECTED_SPAWN_VALUE_L1_EQUIVALENT := 7.0 / 3.0

# Provisional planning calibration.  It is intentionally named, visible, and
# overrideable; it is not a measured claim about a player's launch cadence.
# 1.5 seconds is a round planning assumption for one launch opportunity.
const DEFAULT_SECONDS_PER_LAUNCH := 1.5
const PLANNING_MULTIPLIER := 2.0


static func cocktail_cost(cocktail_level: int) -> int:
	if cocktail_level < 1:
		return 0
	return 1 << (cocktail_level - 1)


static func normal_objective_cost(level_definition: Dictionary) -> int:
	return _orders_cost(level_definition.get("orders", []))


static func vip_objective_cost(level_definition: Dictionary) -> int:
	var vip: Variant = level_definition.get("vip", null)
	if not vip is Dictionary or not bool(vip.get("enabled", true)):
		return 0
	return cocktail_cost(int(vip.get("cocktail_level", 0))) * int(vip.get("quantity", 0))


static func expected_spawn_count(objective_cost: int) -> float:
	if objective_cost <= 0:
		return 0.0
	return float(objective_cost) / EXPECTED_SPAWN_VALUE_L1_EQUIVALENT


static func timer_calculation(level_definition: Dictionary, seconds_per_launch: float = DEFAULT_SECONDS_PER_LAUNCH) -> Dictionary:
	var calibration := maxf(0.001, seconds_per_launch)
	var objective_cost := normal_objective_cost(level_definition)
	var expected_spawns := expected_spawn_count(objective_cost)
	var raw_time := expected_spawns * calibration
	var planning_target := raw_time * PLANNING_MULTIPLIER
	return {
		"level_id": int(level_definition.get("level_id", 0)),
		"normal_objective_cost": objective_cost,
		"expected_spawn_value_l1_equivalent": EXPECTED_SPAWN_VALUE_L1_EQUIVALENT,
		"expected_spawn_count_planning": expected_spawns,
		"seconds_per_launch_calibration": calibration,
		"raw_calculated_production_time_sec": raw_time,
		"planning_target_time_sec": planning_target,
		"canonical_timer_sec": float(level_definition.get("time_limit_sec", 0.0)),
		"planning_target_minus_canonical_timer_sec": planning_target - float(level_definition.get("time_limit_sec", 0.0)),
		"vip_objective_cost_separate": vip_objective_cost(level_definition),
	}


static func level_summary(level_definition: Dictionary, seconds_per_launch: float = DEFAULT_SECONDS_PER_LAUNCH) -> Dictionary:
	var summary := timer_calculation(level_definition, seconds_per_launch)
	summary["island_id"] = str(level_definition.get("island_id", ""))
	summary["normal_orders"] = level_definition.get("orders", []).duplicate(true)
	return summary


static func percentile(values: Array, probability: float) -> float:
	## Deterministic R7 linear-interpolation percentile over sorted values.
	if values.is_empty():
		return 0.0
	var sorted_values: Array[float] = []
	for value in values:
		sorted_values.append(float(value))
	sorted_values.sort()
	var p := clampf(probability, 0.0, 1.0)
	var position := (sorted_values.size() - 1) * p
	var lower_index := int(floor(position))
	var upper_index := int(ceil(position))
	if lower_index == upper_index:
		return sorted_values[lower_index]
	var fraction := position - float(lower_index)
	return lerpf(sorted_values[lower_index], sorted_values[upper_index], fraction)


static func validate_level_definition(level_definition: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(level_definition.get("level_id", 0)) <= 0:
		errors.append("level_id must be positive")
	var orders: Variant = level_definition.get("orders", null)
	if not orders is Array or orders.is_empty():
		errors.append("orders must be a non-empty array")
	else:
		for order in orders:
			if not order is Dictionary:
				errors.append("order must be an object")
				continue
			if int(order.get("cocktail_level", 0)) < 1 or int(order.get("quantity", 0)) <= 0:
				errors.append("order level and quantity must be positive")
	if float(level_definition.get("time_limit_sec", 0.0)) <= 0.0:
		errors.append("time_limit_sec must be positive")
	return errors


static func _orders_cost(orders: Variant) -> int:
	var total := 0
	if not orders is Array:
		return total
	for order in orders:
		if order is Dictionary:
			total += int(order.get("quantity", 0)) * cocktail_cost(int(order.get("cocktail_level", 0)))
	return total
