extends SceneTree

const FEEDBACK_SCRIPT := preload("res://scripts/feedback_service.gd")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const POLICY_SCRIPT := preload("res://scripts/presentation_effect_policy.gd")
const GAME_MANAGER_SCRIPT := preload("res://scripts/game_manager.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-LIMIT-001/regression/m24_001.json"

var _checks := 0
var _failures: Array[String] = []
var _requests: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service = FEEDBACK_SCRIPT.new()
	root.add_child(service)
	service.semantic_requested.connect(_capture_request)
	var bridge = BRIDGE_SCRIPT.new()
	root.add_child(bridge)
	var policy = POLICY_SCRIPT.new()
	var target := Label.new()
	target.add_to_group("presentation_effect_target")
	root.add_child(target)
	var physics_target := StaticBody2D.new()
	physics_target.add_to_group("presentation_effect_target")
	root.add_child(physics_target)
	var manager = GAME_MANAGER_SCRIPT.new()
	manager.feedback_service = service
	manager._to_go_progress_label = target

	_check("order progress is an approved non-physics presentation target", bridge._is_presentation_target(target, false) and not bridge._is_presentation_target(physics_target, false))
	var full_plan: Dictionary = bridge._order_progress_plan("FULL")
	var reduced_plan: Dictionary = bridge._order_progress_plan("REDUCED")
	var full_request := {"kind": "order_progress", "payload": {"accepted": 1, "presentation_target": target}}
	var reduced_request := {"kind": "order_progress", "payload": {"accepted": 1, "presentation_target": target}}
	_check("FULL progress stays inside the M24 8 particle / 0.25 second cap", int(full_plan.spark_overrides.amount) == 8 and is_equal_approx(float(full_plan.spark_overrides.lifetime), 0.25) and bool(policy.validate_dispatch(full_request, "FULL", full_plan).get("ok", false)))
	_check("REDUCED progress uses no particles", not reduced_plan.has("spark_preset") and bool(policy.validate_dispatch(reduced_request, "REDUCED", reduced_plan).get("ok", false)))
	var delivery := {"accepted": 1, "level": 3, "completed": {3: 1}, "remaining": {3: 1}, "delivery_id": "delivery-1"}
	manager._on_normal_delivery_recorded(delivery)
	_check("one accepted nonterminal delivery emits progress at the existing label", _requests.size() == 1 and _requests[0].kind == "order_progress" and _requests[0].payload.presentation_target == target)
	manager._on_normal_delivery_recorded(delivery)
	_check("duplicate delivery event token is suppressed", _requests.size() == 1)
	manager._on_normal_delivery_recorded({"accepted": 0, "level": 3, "completed": {3: 1}, "remaining": {3: 1}, "delivery_id": "rejected"})
	_check("zero-accepted delivery is silent", _requests.size() == 1)
	manager._on_normal_delivery_recorded({"accepted": 1, "level": 3, "completed": {3: 2}, "remaining": {3: 0}, "delivery_id": "final-order"})
	_check("final normal order leaves celebration precedence to WIN", _requests.size() == 1)

	var report := {"checks": _checks, "failures": _failures, "result": "PASS" if _failures.is_empty() else "FAIL", "mode_plans": {"FULL": full_plan, "REDUCED": reduced_plan}, "captured_requests": _requests.size()}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write M24-001 evidence: %s" % error_string(FileAccess.get_open_error()))
		quit(2)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print(JSON.stringify(report))
	physics_target.queue_free()
	target.queue_free()
	service.queue_free()
	bridge.queue_free()
	manager.free()
	await process_frame
	quit(0 if _failures.is_empty() else 1)


func _capture_request(request: Dictionary) -> void:
	_requests.append(request.duplicate(true))


func _check(label: String, condition: bool) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)

