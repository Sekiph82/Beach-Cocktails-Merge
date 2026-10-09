extends SceneTree

const FEEDBACK_SCRIPT := preload("res://scripts/feedback_service.gd")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const POLICY_SCRIPT := preload("res://scripts/presentation_effect_policy.gd")
const GAME_MANAGER_SCRIPT := preload("res://scripts/game_manager.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-LIMIT-001/regression/m24_002.json"

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
	var label := Label.new()
	label.add_to_group("presentation_effect_target")
	root.add_child(label)
	var manager = GAME_MANAGER_SCRIPT.new()
	manager.feedback_service = service
	manager._to_go_progress_label = label

	var full_plan: Dictionary = bridge._order_complete_plan("FULL")
	var reduced_plan: Dictionary = bridge._order_complete_plan("REDUCED")
	var request := {"kind": "order_complete", "payload": {"accepted": 1, "presentation_target": label}}
	_check("FULL completion stays within 16 particles / 0.45 seconds", int(full_plan.spark_overrides.amount) == 12 and float(full_plan.spark_overrides.lifetime) <= 0.45 and bool(policy.validate_dispatch(request, "FULL", full_plan).get("ok", false)))
	_check("REDUCED completion has no particles or spring", not reduced_plan.has("spark_preset") and reduced_plan.gff_effect == "color" and bool(policy.validate_dispatch(request, "REDUCED", reduced_plan).get("ok", false)))

	manager._on_normal_delivery_recorded({"accepted": 1, "level": 6, "completed": {6: 1}, "remaining": {6: 1, 7: 1}, "delivery_id": "progress-1"})
	_check("incomplete order emits progress only", _requests.size() == 1 and _requests[0].kind == "order_progress")
	var completing_delivery := {"accepted": 1, "level": 6, "completed": {6: 2}, "remaining": {6: 0, 7: 1}, "delivery_id": "complete-6"}
	manager._on_normal_delivery_recorded(completing_delivery)
	_check("authoritative incomplete-to-complete transition emits completion only", _requests.size() == 2 and _requests[1].kind == "order_complete" and str(_requests[1].payload.completion_token) == "complete-6:L6")
	_check("completion targets the existing progress label", _requests[1].payload.presentation_target == label)
	manager._on_normal_delivery_recorded(completing_delivery)
	_check("duplicate completion token is suppressed", _requests.size() == 2 and service.event_count("order_complete") == 1)
	manager._on_normal_delivery_recorded({"accepted": 1, "level": 7, "completed": {6: 2, 7: 1}, "remaining": {6: 0, 7: 0}, "delivery_id": "final-win"})
	_check("immediate terminal WIN suppresses ORDER completion flourish", _requests.size() == 2)
	_check("legacy full-panel flash path is removed", not manager.has_method("_order_completion_feedback"))

	var report := {"checks": _checks, "failures": _failures, "result": "PASS" if _failures.is_empty() else "FAIL", "mode_plans": {"FULL": full_plan, "REDUCED": reduced_plan}, "captured_requests": _requests.size(), "order_complete_events": service.event_count("order_complete")}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write M24-002 evidence: %s" % error_string(FileAccess.get_open_error()))
		quit(2)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print(JSON.stringify(report))
	label.queue_free()
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

