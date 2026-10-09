extends SceneTree

const FEEDBACK_SCRIPT := preload("res://scripts/feedback_service.gd")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const DRINK_SCRIPT := preload("res://scripts/drink.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R02/regression/m23_001_micro_feedback_probe/M23-001_micro_feedback_probe.json"

var _checks := 0
var _failures: Array[String] = []
var _requests: Array[Dictionary] = []
var _drink_contact_events := 0
var _drink_contact_payloads: Array[Dictionary] = []


class MockGFF:
	extends Node
	const EFFECT_REGISTRY := preload("res://addons/game_feel_flow/core/gff_effect_registry.gd")
	var calls: Array[String] = []
	var params: Array[Dictionary] = []
	var stopped := 0
	var should_fail := false

	func play(effect_name: Variant, _target: Node, options: Dictionary = {}) -> bool:
		calls.append("color" if effect_name is GFFEffect else str(effect_name))
		params.append(options.duplicate(true))
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
	var should_fail := false
	var base := {"amount": 1, "lifetime": 0.1, "speed": 1.0}
	var presets := {"hit": {}}

	func burst(_position: Vector2, options: Dictionary) -> bool:
		calls.append(options.duplicate(true))
		return not should_fail
	func at(_node: Node, _options: Dictionary) -> bool: return true
	func clear() -> void: cleared += 1


class VisualTarget:
	extends Node2D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service := FEEDBACK_SCRIPT.new()
	root.add_child(service)
	service.semantic_requested.connect(_capture_request)
	var bridge := BRIDGE_SCRIPT.new()
	root.add_child(bridge)
	bridge.configure(service, root)
	bridge.set_visual_diagnostics_enabled(true)
	var gff := MockGFF.new()
	var spark := MockSpark.new()
	root.add_child(gff)
	root.add_child(spark)
	bridge._contract.refresh_with_nodes(gff, spark)
	var target := VisualTarget.new()
	target.add_to_group("presentation_effect_target")
	root.add_child(target)
	var source = DRINK_SCRIPT.create(2)
	source.position = Vector2(120.0, 300.0)
	root.add_child(source)
	var source_visual: Node = source.get_node("Visual")
	var source_collider := source.get_child(0) as CollisionShape2D
	source.set_held()
	source.launch_up(700.0)
	var launch_velocity_at_fire: Vector2 = source.linear_velocity
	var merge_candidate = DRINK_SCRIPT.create(2)
	merge_candidate.position = Vector2(600.0, 500.0)
	root.add_child(merge_candidate)
	merge_candidate.table_contact.connect(_capture_drink_contact)
	merge_candidate.start_sliding(Vector2(0.0, -700.0))
	merge_candidate._on_body_entered(source)
	await process_frame
	_check("same-level authoritative merge contact emits no table-contact feedback", _drink_contact_events == 0)
	var rail := Node2D.new()
	root.add_child(rail)
	merge_candidate._on_body_entered(rail)
	await process_frame
	_check("meaningful rail contact is emitted after the deferred collision callback", _drink_contact_events == 1 and _drink_contact_payloads[0].contact_type == "rail")
	_check("contact carries only the visual child as its effect target", _drink_contact_payloads[0].presentation_target == merge_candidate.get_node("Visual"))
	var launch_velocity_before_effect: Vector2 = source.linear_velocity
	var body_transform_before_effect: Transform2D = source.transform
	var collider_transform_before_effect: Transform2D = source_collider.transform

	var expected_velocity := Vector2(0.0, -700.0)
	bridge.set_production_dispatch_enabled(true)
	_check("production launch event accepted", service.emit_cocktail_launch(2, Vector2(100.0, 300.0), expected_velocity, source))
	_check("duplicate launch event suppressed per source instance", not service.emit_cocktail_launch(2, Vector2(100.0, 300.0), expected_velocity, source))
	_check("one launch semantic dispatch with unchanged velocity and visual child target", _requests.size() == 1 and _requests[0].payload.velocity == expected_velocity and _requests[0].payload.presentation_target == source_visual and bridge.dispatch_count == 1)
	_check("FULL launch uses the 4 particle / 0.14 second cap", spark.calls.size() == 1 and int(spark.calls[0].amount) == 4 and is_equal_approx(float(spark.calls[0].lifetime), 0.14))
	_check("FULL launch uses the R03 midpoint punch intensity", is_equal_approx(float(gff.params[0].get("intensity", 0.0)), 0.48))
	var launch_trace: Dictionary = bridge.get_visual_diagnostic_trace().back()
	_check("production launch trace links semantic ID, accepted policy, GFF and Spark calls", str(launch_trace.get("event_id", "")).begins_with("launch:") and bool(launch_trace.get("policy", {}).get("ok", false)) and bool(launch_trace.get("gff_call", {}).get("invoked", false)) and bool(launch_trace.get("spark_call", {}).get("invoked", false)))
	_check("launch target is presentation-only, not a physics body or camera", source_visual.is_in_group("presentation_effect_target") and not _is_physics_or_camera(source_visual))
	_check("launch starts at the existing authoritative velocity", launch_velocity_at_fire == Vector2(0.0, -700.0))
	_check("presentation dispatch does not shift current velocity or body/collider transforms", source.linear_velocity == launch_velocity_before_effect and source.transform == body_transform_before_effect and source_collider.transform == collider_transform_before_effect)

	var before_contacts := _requests.size()
	var drink_contact := {"source_level": 2, "contact_type": "drink", "contact_level": 3, "position": Vector2(120.0, 240.0), "source_instance": "drink-A", "presentation_target": target}
	_check("first meaningful drink contact accepted", service.emit_table_contact(drink_contact))
	_check("bounce spam for same drink/class is suppressed", not service.emit_table_contact(drink_contact))
	var rail_contact := drink_contact.duplicate(true)
	rail_contact.contact_type = "rail"
	_check("different contact class has an independent cooldown", service.emit_table_contact(rail_contact))
	var contact_timestamp_before_wait := int(service._micro_contact_times.get("drink-A:drink", -1))
	OS.delay_msec(130)
	var elapsed_contact_ms := Time.get_ticks_msec() - contact_timestamp_before_wait
	var later_contact_accepted := service.emit_table_contact(drink_contact)
	_check("same contact class is accepted after at least 120ms", elapsed_contact_ms >= FEEDBACK_SCRIPT.MICRO_CONTACT_COOLDOWN_MS and later_contact_accepted)
	_check("contact semantic count reflects cooldown and class", _requests.size() == before_contacts + 3)
	_check("FULL contact stays within 5 / 0.16 second cap", spark.calls.size() == 4 and int(spark.calls[1].amount) == 5 and is_equal_approx(float(spark.calls[1].lifetime), 0.16))
	_check("FULL contact passes a non-white target tint to avoid the old no-op color effect", gff.params[1].has("color") and gff.params[1].color != Color.WHITE)
	_check("launch/contact particle radii sit between the original and rejected R02 sizes", is_equal_approx(float(spark.calls[0].get("size", -1.0)), 4.0) and is_equal_approx(float(spark.calls[1].get("size", -1.0)), 4.25))
	_check("FULL micro emphasis duration stays inside its event cap", is_equal_approx(float(gff.params[0].duration), 0.14) and is_equal_approx(float(gff.params[1].duration), 0.16))

	bridge.set_presentation_mode("REDUCED")
	var reduced_count := spark.calls.size()
	service.emit_table_contact({"source_level": 1, "contact_type": "rail", "contact_level": 0, "position": Vector2.ZERO, "source_instance": "drink-B", "presentation_target": target})
	_check("REDUCED contact invokes alpha/color only, <=0.10 seconds, and no particles", spark.calls.size() == reduced_count and gff.calls.back() == "color" and float(gff.params.back().duration) <= 0.10)
	_check("REDUCED contact color is explicitly configured", gff.params.back().has("color") and gff.params.back().color != Color.WHITE)
	_check("invalid presentation mode is rejected", not bridge.set_presentation_mode("UNKNOWN"))

	var calls_before_missing := gff.calls.size() + spark.calls.size()
	bridge._contract.refresh_with_nodes(null, spark)
	bridge.set_presentation_mode("FULL")
	service.emit_table_contact({"source_level": 1, "contact_type": "drink", "contact_level": 4, "position": Vector2.ZERO, "source_instance": "drink-C", "presentation_target": target})
	_check("missing plugin safely prevents partial dispatch", gff.calls.size() + spark.calls.size() == calls_before_missing)
	bridge._contract.refresh_with_nodes(gff, spark)
	gff.should_fail = true
	service.emit_table_contact({"source_level": 1, "contact_type": "rail", "contact_level": 0, "position": Vector2.ZERO, "source_instance": "drink-D", "presentation_target": target})
	_check("failed GameFeelFlow call does not call Spark", spark.calls.size() == reduced_count)
	gff.should_fail = false
	spark.should_fail = true
	service.emit_table_contact({"source_level": 1, "contact_type": "drink", "contact_level": 5, "position": Vector2.ZERO, "source_instance": "drink-E", "presentation_target": target})
	_check("failed Spark call cancels active GameFeelFlow outputs", gff.stopped > 0)
	bridge.cancel_presentation()
	_check("session cancellation clears Spark outputs", spark.cleared > 0)

	var result := {
		"probe": "BCM-M23-001",
		"checks": _checks,
		"failures": _failures,
		"semantic_requests": _requests.size(),
		"bridge_dispatch_count": bridge.dispatch_count,
		"bridge_no_op_count": bridge.no_op_count,
		"spark_dispatches": spark.calls.size(),
		"gff_effects": gff.calls,
		"launch_velocity": [expected_velocity.x, expected_velocity.y],
		"drink_launch_velocity_after_presentation": [source.linear_velocity.x, source.linear_velocity.y],
		"same_level_merge_contact_feedback_events": _drink_contact_events,
		"meaningful_contact_event_count": _drink_contact_events,
		"contact_cooldown_ms": FEEDBACK_SCRIPT.MICRO_CONTACT_COOLDOWN_MS,
		"contact_wait_elapsed_ms": elapsed_contact_ms,
		"reduced_spark_dispatches": 0,
		"visual_capture_count": 0,
		"owner_visual_status": "PENDING_OWNER_VISUAL_EVIDENCE",
		"diagnostics": bridge.get_diagnostics(),
	}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("evidence output is writable")
	else:
		file.store_string(JSON.stringify(result, "\t") + "\n")
		file.close()
	print("M23_001_MICRO_FEEDBACK_RESULT=%s checks=%d failures=%d dispatches=%d cooldown_ms=%d captures=0" % ["PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), bridge.dispatch_count, FEEDBACK_SCRIPT.MICRO_CONTACT_COOLDOWN_MS])
	for failure in _failures:
		push_error(failure)
	bridge.queue_free()
	service.queue_free()
	quit(0 if _failures.is_empty() else 1)


func _capture_request(request: Dictionary) -> void:
	_requests.append(request.duplicate(true))


func _capture_drink_contact(_contact: Dictionary) -> void:
	_drink_contact_events += 1
	_drink_contact_payloads.append(_contact.duplicate(true))


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)


func _is_physics_or_camera(target: Node) -> bool:
	return target is CollisionObject2D or target is Camera2D
