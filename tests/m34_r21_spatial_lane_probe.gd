extends SceneTree

const HARNESS = preload("res://scripts/campaign/m17_seeded_validation_harness.gd")

var failures: Array[String] = []
var assertions := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(label: String, condition: bool) -> void:
	assertions += 1
	if condition:
		print("R21_PROBE_PASS: %s" % label)
	else:
		failures.append(label)
		push_error("R21_PROBE_FAIL: %s" % label)

func _run() -> void:
	var harness = HARNESS.new(root)
	var lanes: Array[float] = [150.0, 220.0, 290.0, 360.0, 430.0, 500.0, 570.0]
	var history: Dictionary = {}
	var fired: Array[float] = []
	var tied_scores_stayed_center := true
	for decision in range(19):
		var action: Dictionary = harness.choose_r21_action_from_observations(2, [], [6, 7], lanes, 960.0, 1060.0, history, 34117026, decision)
		var chosen := float(action.get("x_position", -1.0))
		fired.append(chosen)
		var evaluations: Array = action.get("r21_candidate_evaluations", [])
		_check("decision %d evaluates every legal candidate" % decision, evaluations.size() == lanes.size())
		var first_score := float(evaluations[0].get("base_score", -INF)) if not evaluations.is_empty() else -INF
		for evaluation in evaluations:
			if absf(float(evaluation.get("base_score", INF)) - first_score) > 0.0001:
				tied_scores_stayed_center = false
		_check("decision %d selects a legal top-ranked candidate" % decision, lanes.has(chosen) and int(action.get("r21_selected_candidate", {}).get("rank", 0)) == 1)
		history[str(int(round(chosen * 1000.0)))] = int(history.get(str(int(round(chosen * 1000.0))), 0)) + 1
	var distinct := {}
	for x in fired: distinct[str(x)] = true
	_check("fixture keeps all lane heuristic scores deliberately tied", tied_scores_stayed_center)
	_check("19 tied-score decisions never collapse to center-only", distinct.size() >= 3 and (fired.count(360.0) < fired.size()))
	_check("diversification is state-aware and visits the least-used tied lanes", _max_visit_count(history) - _min_visit_count(history) <= 1)
	var replay: Dictionary = harness.choose_r21_action_from_observations(2, [], [6, 7], lanes, 960.0, 1060.0, {}, 34117026, 0)
	var different_seed: Dictionary = harness.choose_r21_action_from_observations(2, [], [6, 7], lanes, 960.0, 1060.0, {}, 34117027, 0)
	var changed_state: Dictionary = harness.choose_r21_action_from_observations(2, [{"level": 99, "x": 10000.0, "y": 0.0, "radius": 1.0, "instance_id": 999}], [6, 7], lanes, 960.0, 1060.0, {}, 34117026, 0)
	_check("same seed and state replay exactly", replay.x_position == fired[0])
	_check("tie start changes with the seed without reading future RNG", lanes.has(float(different_seed.x_position)) and float(different_seed.x_position) != float(replay.x_position))
	_check("tie rotation incorporates current board state", replay.get("r21_selected_candidate", {}).get("state_signature") != changed_state.get("r21_selected_candidate", {}).get("state_signature"))
	var danger_board := [{"level": 2, "x": 360.0, "y": 1045.0, "radius": 36.0, "instance_id": 1}]
	var safe_action: Dictionary = harness.choose_r21_action_from_observations(2, danger_board, [6, 7], lanes, 960.0, 1060.0, {}, 34117026, 0)
	var center_eval: Dictionary = _evaluation_at(safe_action.get("r21_candidate_evaluations", []), 360.0)
	var selected_eval: Dictionary = safe_action.get("r21_selected_candidate", {})
	_check("danger occupancy has a measurable candidate penalty", float(center_eval.get("danger_occupancy", 0.0)) > float(selected_eval.get("danger_occupancy", 0.0)))
	_check("danger-occupied center is avoided when safe legal alternatives exist", float(safe_action.get("x_position", 360.0)) != 360.0)
	_check("danger avoidance never selects a lower-ranked candidate", int(safe_action.get("r21_selected_candidate", {}).get("rank", 0)) == 1)
	_check("all evaluated candidates label spatial forecasts as heuristics", _all_heuristic_labels(safe_action.get("r21_candidate_evaluations", [])))
	if failures.is_empty():
		print("M34_R21_SPATIAL_LANE_RESULT=PASS assertions=%d tied_lane_count=%d fired=%s" % [assertions, distinct.size(), str(fired)])
		quit(0)
	else:
		print("M34_R21_SPATIAL_LANE_RESULT=FAIL assertions=%d failures=%s" % [assertions, str(failures)])
		quit(1)

func _evaluation_at(evaluations: Array, x_value: float) -> Dictionary:
	for evaluation in evaluations:
		if is_equal_approx(float(evaluation.get("candidate_x", -1.0)), x_value):
			return evaluation
	return {}

func _all_heuristic_labels(evaluations: Array) -> bool:
	if evaluations.is_empty(): return false
	for evaluation in evaluations:
		if str(evaluation.get("model_label", "")) != "spatial_occupancy_and_objective_heuristic_not_physics_proof": return false
	return true

func _max_visit_count(history: Dictionary) -> int:
	var result := 0
	for count in history.values(): result = maxi(result, int(count))
	return result

func _min_visit_count(history: Dictionary) -> int:
	var result := 2147483647
	for count in history.values(): result = mini(result, int(count))
	return result
