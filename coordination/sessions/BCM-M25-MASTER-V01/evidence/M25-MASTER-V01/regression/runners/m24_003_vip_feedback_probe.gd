extends SceneTree

const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const POLICY_SCRIPT := preload("res://scripts/presentation_effect_policy.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MASTER-V01/regression/m24_003_vip_feedback_probe/vip_feedback_probe.json"

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var bridge = BRIDGE_SCRIPT.new()
	root.add_child(bridge)
	bridge.set_visual_diagnostics_enabled(true)
	var policy = POLICY_SCRIPT.new()
	var target := Label.new()
	target.add_to_group("presentation_effect_target")
	root.add_child(target)

	var delivery_payload := {"accepted": 1, "completed_transition": false, "presentation_target": target}
	var completion_payload := {"accepted": 1, "completed_transition": true, "presentation_target": target}
	var full_delivery: Dictionary = bridge._vip_delivery_plan("FULL", delivery_payload)
	var full_completion: Dictionary = bridge._vip_complete_plan("FULL")
	var final_delivery: Dictionary = bridge._vip_delivery_plan("FULL", completion_payload)
	var reduced_delivery: Dictionary = bridge._vip_delivery_plan("REDUCED", delivery_payload)
	var reduced_completion: Dictionary = bridge._vip_complete_plan("REDUCED")
	_check("FULL VIP delivery is capped at 12 particles / 0.35 seconds", int(full_delivery.spark_overrides.amount) == 10 and float(full_delivery.spark_overrides.lifetime) <= 0.35 and bool(policy.validate_dispatch({"kind": "vip_delivery", "payload": delivery_payload}, "FULL", full_delivery).get("ok", false)))
	_check("FULL VIP completion is capped at 24 particles / 0.65 seconds", int(full_completion.spark_overrides.amount) == 20 and float(full_completion.spark_overrides.lifetime) <= 0.65 and bool(policy.validate_dispatch({"kind": "vip_complete", "payload": completion_payload}, "FULL", full_completion).get("ok", false)))
	_check("completion delivery yields its burst to the VIP completion event", not final_delivery.has("spark_preset"))
	_check("REDUCED VIP delivery and completion use zero particles", not reduced_delivery.has("spark_preset") and not reduced_completion.has("spark_preset") and bool(policy.validate_dispatch({"kind": "vip_delivery", "payload": delivery_payload}, "REDUCED", reduced_delivery).get("ok", false)) and bool(policy.validate_dispatch({"kind": "vip_complete", "payload": completion_payload}, "REDUCED", reduced_completion).get("ok", false)))

	bridge._on_semantic_requested(_request("vip_delivery", {"accepted": 0, "completed_transition": false, "presentation_target": target}, "rejected"))
	_check("zero-accepted VIP delivery is silent", bridge.get_visual_diagnostic_trace().is_empty())
	bridge._on_semantic_requested(_request("vip_complete", {"accepted": 1, "completed_transition": false, "presentation_target": target}, "not-transition"))
	_check("already-complete VIP state does not replay completion", bridge.get_visual_diagnostic_trace().is_empty())
	bridge._on_semantic_requested(_request("vip_delivery", delivery_payload, "accepted"))
	_check("accepted VIP delivery enters the sole presentation bridge", bridge.get_visual_diagnostic_trace().size() == 1)
	bridge._on_semantic_requested(_request("vip_complete", completion_payload, "completed"))
	_check("false-to-true VIP completion enters the sole presentation bridge", bridge.get_visual_diagnostic_trace().size() == 2)

	var report := {"checks": _checks, "failures": _failures, "result": "PASS" if _failures.is_empty() else "FAIL", "full_delivery": full_delivery, "full_completion": full_completion, "reduced_delivery": reduced_delivery, "reduced_completion": reduced_completion, "bridge_traces": bridge.get_visual_diagnostic_trace().size()}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write M24-003 evidence: %s" % error_string(FileAccess.get_open_error()))
		quit(2)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print(JSON.stringify(report))
	target.queue_free()
	bridge.queue_free()
	await process_frame
	quit(0 if _failures.is_empty() else 1)


func _request(kind: String, payload: Dictionary, token: String) -> Dictionary:
	return {"kind": kind, "payload": payload, "event_id": token, "sequence": _checks + 1, "source_context": {}}


func _check(label: String, condition: bool) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)

