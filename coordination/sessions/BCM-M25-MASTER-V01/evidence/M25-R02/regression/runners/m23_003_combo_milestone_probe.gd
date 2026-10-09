extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const GFF_COLOR_TARGET_SCRIPT := preload("res://addons/game_feel_flow/core/targets/gff_color_target.gd")
const GFF_PARAMS_SCRIPT := preload("res://addons/game_feel_flow/core/gff_params.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R02/regression/m23_003_combo_milestone_probe/M23-003_combo_milestone_probe.json"

var _checks := 0
var _failures: Array[String] = []
var _score_requests: Array[Dictionary] = []
var _mock_gff: MockGFF


class FakeSession:
	extends RefCounted
	var configuration := {"score_star_thresholds": {"two_stars": 100, "three_stars": 250}, "vip": null}
	var vip_state := {"enabled": false, "completed": false}

	func is_session_active() -> bool: return true
	func is_terminal() -> bool: return false
	func get_session_configuration() -> Dictionary: return configuration.duplicate(true)
	func get_vip_state() -> Dictionary: return vip_state.duplicate(true)


class MockGFF:
	extends Node
	const EFFECT_REGISTRY := preload("res://addons/game_feel_flow/core/gff_effect_registry.gd")
	var calls: Array[Dictionary] = []
	var stopped := 0
	var should_fail := false

	func play(effect_name: Variant, target: Node, params: Dictionary = {}) -> bool:
		calls.append({"effect": "color" if effect_name is GFFEffect else str(effect_name), "target": target, "params": params.duplicate(true)})
		return not should_fail
	func play_combo(_combo_name: String, _target: Node) -> bool: return true
	func play_global(_effect_name: String) -> bool: return true
	func stop(_target: Node) -> void: stopped += 1
	func stop_all() -> void: pass
	func get_effect(effect_name: String): return EFFECT_REGISTRY.create_effect("color", "color") if effect_name == "color" else null
	func get_combo(_combo_name: String): return null
	func resolve_combo(_combo_name: String): return null
	func get_effect_names() -> Array[String]: return ["punch_scale", "color", "alpha"]
	func get_combo_names() -> Array[String]: return []


class MockSpark:
	extends Node
	var calls: Array[Dictionary] = []
	var cleared := 0
	var base := {"amount": 1, "lifetime": 0.1, "speed": 1.0, "lifetime_rand": 0.0}
	var presets := {"hit": {}}

	func burst(position: Vector2, options: Dictionary) -> bool:
		calls.append({"position": position, "options": options.duplicate(true)})
		return true
	func at(_node: Node, _options: Dictionary) -> bool: return true
	func clear() -> void: cleared += 1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var color_target = GFF_COLOR_TARGET_SCRIPT.new()
	var requested_tint := Color(1.0, 0.68, 0.30, 1.0)
	color_target.apply_params(GFF_PARAMS_SCRIPT.create().with_color("color", requested_tint))
	_check("installed GFF color target applies per-call color params", color_target.target_color.is_equal_approx(requested_tint))
	var manager := MAIN_SCENE.instantiate() as GameManager
	root.add_child(manager)
	current_scene = manager
	await process_frame
	await physics_frame
	var bridge: PresentationFeedbackBridge = manager.presentation_feedback_bridge
	var service: FeedbackService = manager.feedback_service
	bridge.set_visual_diagnostics_enabled(true)
	var gff := MockGFF.new()
	_mock_gff = gff
	var spark := MockSpark.new()
	root.add_child(gff)
	root.add_child(spark)
	bridge._contract.refresh_with_nodes(gff, spark)
	bridge.set_presentation_mode("FULL")
	service.set_session_context({"session_id": "m23-003-chain"})
	service.semantic_requested.connect(_capture_score_request)
	manager.campaign_session_bridge = null
	manager._target_level = 0
	manager.score = 0
	manager.best_score = 1000000
	manager.chain = 0
	manager.chain_timer = 0.0
	var expected_gained := [6500, 8125, 9750, 11375, 13000, 14625]
	var expected_amounts := [10, 10, 10, 10, 18, 18]
	var expected_lifetimes := [0.28, 0.28, 0.30, 0.30, 0.35, 0.35]
	var sequence: Array[Dictionary] = []
	var expected_score := 0
	for index in range(6):
		bridge.cancel_presentation()
		var drink := manager.spawn_drink(12, Vector2(120.0 + float(index) * 92.0, 500.0), false)
		var previous_score := manager.score
		manager.on_merged(12, drink)
		expected_score += int(expected_gained[index])
		var spark_call: Dictionary = spark.calls.back().options
		var chain_passed := manager.chain == index + 1 and manager.score - previous_score == int(expected_gained[index])
		var budget_passed := int(spark_call.amount) == int(expected_amounts[index]) and is_equal_approx(float(spark_call.lifetime), float(expected_lifetimes[index]))
		_check("chain %d preserves merge score and correct BASE/SURGE/PEAK band" % (index + 1), chain_passed and budget_passed)
		_check("chain %d effects stay on the Drink visual child" % (index + 1), gff.calls.back().target == drink.get_node("Visual") and gff.calls.back().effect == "punch_scale")
		sequence.append({"chain": manager.chain, "gained": manager.score - previous_score, "spark_amount": spark_call.amount, "spark_lifetime": spark_call.lifetime, "passed": chain_passed and budget_passed})
	_check("1-to-6 chain sequence preserves total score math", manager.score == expected_score)
	var final_drink := manager.world.get_children().filter(func(child: Node) -> bool: return child is Drink).back() as Drink
	var calls_before_duplicate := spark.calls.size()
	service.emit_merge(final_drink, {"level": 12, "chain": 6, "score": manager.score, "presentation_target": final_drink.get_node("Visual")})
	_check("same-band duplicate merge event is coalesced per source", spark.calls.size() == calls_before_duplicate)

	var session := FakeSession.new()
	manager.campaign_session_bridge = session
	manager._score_milestones_emitted.clear()
	manager.score = 0
	manager.best_score = 1000
	manager.chain = 0
	service.set_session_context({"session_id": "m23-003-threshold-session-A"})
	var score_requests_before := _score_requests.size()
	var spark_before_milestones := spark.calls.size()
	manager._add_score(100)
	manager._refresh_hud()
	manager._refresh_hud()
	_check("2-star edge crossing emits exactly once despite repeated HUD refresh", _milestone_count("two_stars", score_requests_before) == 1)
	manager._add_score(150)
	_check("3-star threshold emits once at exact crossing", _milestone_count("three_stars", score_requests_before) == 1)
	manager._add_score(750)
	_check("equal prior-best score is not treated as a new record", _milestone_count("prior_best", score_requests_before) == 0 and manager.score == manager.best_score)
	manager._add_score(1)
	manager._add_score(1)
	_check("prior-best crossing fires once only after strictly exceeding record", _milestone_count("prior_best", score_requests_before) == 1 and manager.best_score == 1002)
	_check("score milestones dispatch zero Spark particles", spark.calls.size() == spark_before_milestones)
	_check("FULL score emphasis targets approved dynamic score labels", _milestone_targets_are_score_labels(score_requests_before, manager) and manager._best_value.is_in_group("presentation_effect_target") and manager._score_value.is_in_group("presentation_effect_target"))
	_check("FULL score emphasis uses a configured CanvasItem color effect supported by Control labels", _gff_effect_for("prior_best", score_requests_before) == "color" and gff.calls.back().target is Control and gff.calls.back().params.has("color"))

	var session_b := FakeSession.new()
	manager.campaign_session_bridge = session_b
	manager._score_milestones_emitted.clear()
	manager.score = 0
	manager.best_score = 10000
	service.set_session_context({"session_id": "m23-003-threshold-session-B-retry"})
	var retry_start := _score_requests.size()
	manager._add_score(250)
	_check("replay/retry session gets one new 2-star and 3-star crossing", _milestone_count("two_stars", retry_start) == 1 and _milestone_count("three_stars", retry_start) == 1)
	_check("retry semantic tokens include the new session identity", _milestone_ids_have_prefix(retry_start, "score-milestone:m23-003-threshold-session-B-retry:"))

	var vip_session := FakeSession.new()
	vip_session.configuration["vip"] = {"cocktail_level": 5, "quantity": 1}
	vip_session.vip_state = {"enabled": true, "completed": false}
	manager.campaign_session_bridge = vip_session
	manager._score_milestones_emitted.clear()
	manager.score = 0
	manager.best_score = 10000
	service.set_session_context({"session_id": "m23-003-vip-threshold"})
	var vip_start := _score_requests.size()
	manager._add_score(250)
	_check("VIP-gated third star waits until the existing VIP condition is complete", _milestone_count("two_stars", vip_start) == 1 and _milestone_count("three_stars", vip_start) == 0)
	vip_session.vip_state.completed = true
	manager._emit_score_threshold_crossings(manager.score, manager.best_score, true)
	manager._emit_score_threshold_crossings(manager.score, manager.best_score, true)
	_check("eligible VIP-gated third star emits once after completion", _milestone_count("three_stars", vip_start) == 1)

	bridge.set_presentation_mode("REDUCED")
	manager._score_milestones_emitted.clear()
	manager.score = 0
	manager.best_score = 0
	service.set_session_context({"session_id": "m23-003-reduced"})
	var reduced_start := _score_requests.size()
	var spark_before_reduced := spark.calls.size()
	manager._add_score(1)
	_check("REDUCED prior-best emphasis uses color without Spark", spark.calls.size() == spark_before_reduced and _gff_effect_for("prior_best", reduced_start) == "color")
	_check("REDUCED score emphasis duration is at most 0.10 seconds", float(gff.calls.back().params.duration) <= 0.10)

	bridge.set_presentation_mode("FULL")
	bridge.cancel_presentation()
	_check("presentation cancellation clears transient GFF and Spark handles", bridge._active_gff_outputs.is_empty() and bridge._active_spark_outputs.is_empty())
	_check("M23 bridge live particle count remains under 48", bridge._active_spark_particle_count() <= 48)

	var result := {
		"probe": "BCM-M23-003",
		"checks": _checks,
		"failures": _failures,
		"chain_sequence": sequence,
		"chain_total_score": expected_score,
		"threshold_events": _score_request_summaries(),
		"score_milestone_spark_particles": 0,
		"active_live_particles_after_cancel": bridge._active_spark_particle_count(),
		"live_particle_ceiling": 48,
		"visual_capture_count": 0,
		"owner_visual_status": "PENDING_OWNER_VISUAL_EVIDENCE",
		"diagnostics": bridge.get_diagnostics(),
	}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("evidence file is writable")
	else:
		file.store_string(JSON.stringify(result, "\t") + "\n")
		file.close()
	print("M23_003_COMBO_MILESTONE_RESULT=%s checks=%d failures=%d score_milestones=%d captures=0" % ["PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), _score_requests.size()])
	for failure in _failures:
		push_error(failure)
	bridge.queue_free()
	manager.queue_free()
	quit(0 if _failures.is_empty() else 1)


func _capture_score_request(request: Dictionary) -> void:
	if str(request.get("kind", "")) == "score_mastery":
		_score_requests.append(request.duplicate(true))


func _milestone_count(name: String, start: int) -> int:
	var count := 0
	for index in range(start, _score_requests.size()):
		if str(_score_requests[index].payload.get("milestone", "")) == name:
			count += 1
	return count


func _milestone_targets_are_score_labels(start: int, manager: GameManager) -> bool:
	for index in range(start, _score_requests.size()):
		var milestone := str(_score_requests[index].payload.get("milestone", ""))
		var target: Variant = _score_requests[index].payload.get("presentation_target", null)
		if not is_instance_valid(target) or not target.is_in_group("presentation_effect_target"):
			return false
		if milestone == "prior_best" and target != manager._best_value:
			return false
		if milestone in ["two_stars", "three_stars"] and target != manager._score_value:
			return false
	return true


func _milestone_ids_have_prefix(start: int, prefix: String) -> bool:
	for index in range(start, _score_requests.size()):
		if not str(_score_requests[index].get("event_id", "")).begins_with(prefix):
			return false
	return true


func _gff_effect_for(milestone: String, start: int) -> String:
	for index in range(start, _score_requests.size()):
		if str(_score_requests[index].payload.get("milestone", "")) == milestone:
			var target: Node = _score_requests[index].payload.presentation_target
			for call_index in range(_mock_gff.calls.size() - 1, -1, -1):
				var call: Dictionary = _mock_gff.calls[call_index]
				if call.target == target:
					return str(call.effect)
	return ""


func _score_request_summaries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for request in _score_requests:
		result.append({
			"event_id": request.get("event_id", ""),
			"milestone": request.payload.get("milestone", ""),
			"threshold": request.payload.get("threshold", 0),
			"score": request.payload.get("score", 0),
		})
	return result


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)
