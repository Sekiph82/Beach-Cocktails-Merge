class_name M17VipOptionalityModel
extends RefCounted

## Deterministic mandatory-reserve planner for optional VIP capture.
##
## A board cocktail is an indivisible power-of-two resource.  A cocktail may
## contribute to a remaining normal objective only when its level is not above
## that objective's level and its full L1-equivalent value fits in that
## objective's production bin.  Missing value is additional production.  The
## resulting bounded bin assignment is equivalent to legal equal-level merges:
## any remaining power-of-two value can be produced from L1 pieces and merged
## into the bin, while a higher existing cocktail can never be split downward.

static func candidate_is_surplus(normal_remaining: Dictionary, board_levels: Array[int], candidate_level: int) -> bool:
	if candidate_level <= 0:
		return false
	var with_candidate := mandatory_reserve_cost(normal_remaining, board_levels)
	var without_candidate_levels := board_levels.duplicate()
	var candidate_index := without_candidate_levels.find(candidate_level)
	if candidate_index < 0:
		return false
	without_candidate_levels.remove_at(candidate_index)
	var without_candidate := mandatory_reserve_cost(normal_remaining, without_candidate_levels)
	return without_candidate <= with_candidate


static func mandatory_reserve_cost(normal_remaining: Dictionary, board_levels: Array[int]) -> int:
	var capacities: Array[int] = _objective_capacities(normal_remaining)
	if capacities.is_empty():
		return 0
	var total_required := 0
	for capacity in capacities:
		total_required += capacity
	var assignable := _max_assignable_value(board_levels, capacities)
	return maxi(0, total_required - assignable)


static func _objective_capacities(normal_remaining: Dictionary) -> Array[int]:
	var capacities: Array[int] = []
	for raw_level in normal_remaining:
		var level := int(raw_level)
		var quantity := maxi(0, int(normal_remaining[raw_level]))
		if level <= 0 or quantity <= 0:
			continue
		var value := cocktail_value(level)
		for _index in quantity:
			capacities.append(value)
	capacities.sort_custom(func(a: int, b: int) -> bool: return a > b)
	return capacities


static func cocktail_value(level: int) -> int:
	if level < 1:
		return 0
	return 1 << (level - 1)


static func _max_assignable_value(board_levels: Array[int], capacities: Array[int]) -> int:
	var items: Array[int] = []
	for level in board_levels:
		var value := cocktail_value(int(level))
		if value > 0:
			items.append(value)
	items.sort_custom(func(a: int, b: int) -> bool: return a > b)
	var memo: Dictionary = {}
	return _assign_items(items, capacities, 0, memo)


static func _assign_items(items: Array[int], capacities: Array[int], index: int, memo: Dictionary) -> int:
	if index >= items.size():
		return 0
	var key := "%d|%s" % [index, ",".join(capacities.map(func(value: int) -> String: return str(value)))]
	if memo.has(key):
		return int(memo[key])

	var item := int(items[index])
	var best := _assign_items(items, capacities, index + 1, memo)
	var tried_capacities: Dictionary = {}
	for capacity_index in capacities.size():
		var capacity := int(capacities[capacity_index])
		if capacity < item or tried_capacities.has(capacity):
			continue
		tried_capacities[capacity] = true
		var next_capacities := capacities.duplicate()
		next_capacities[capacity_index] = capacity - item
		next_capacities.sort_custom(func(a: int, b: int) -> bool: return a > b)
		best = maxi(best, item + _assign_items(items, next_capacities, index + 1, memo))
		if best == _sum_capacities(capacities):
			break
	memo[key] = best
	return best


static func _sum_capacities(capacities: Array[int]) -> int:
	var total := 0
	for capacity in capacities:
		total += int(capacity)
	return total
