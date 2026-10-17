class_name ObjectiveCostModel
extends RefCounted

## Order cost arithmetic in L1-equivalent units.
##
## A level-n cocktail costs 2^(n-1) L1 cocktails. Launches spawn L1-L3 at
## equal probability, so one launch is worth 7/3 L1 on average. These are
## planning values only; they do not grade or classify levels.

const EXPECTED_SPAWN_VALUE_L1_EQUIVALENT := 7.0 / 3.0


static func cocktail_cost(cocktail_level: int) -> int:
	if cocktail_level < 1:
		return 0
	return 1 << (cocktail_level - 1)


static func normal_objective_cost(level_definition: Dictionary) -> int:
	var total := 0
	var orders: Variant = level_definition.get("orders", [])
	if orders is Array:
		for order in orders:
			if order is Dictionary:
				total += int(order.get("quantity", 0)) * cocktail_cost(int(order.get("cocktail_level", 0)))
	return total


static func expected_spawn_count(objective_cost: int) -> float:
	if objective_cost <= 0:
		return 0.0
	return float(objective_cost) / EXPECTED_SPAWN_VALUE_L1_EQUIVALENT
