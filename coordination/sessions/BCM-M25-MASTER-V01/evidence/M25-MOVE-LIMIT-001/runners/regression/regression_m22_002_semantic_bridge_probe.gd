extends SceneTree

const FEEDBACK_SCRIPT := preload("res://scripts/feedback_service.gd")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-LIMIT-001/regression/m22_002/semantic_bridge_probe.json"

var _checks := 0
var _failures: Array[String] = []
var _received: Array[Dictionary] = []


class MockGFF:
	extends Node
	var calls := 0
	var stop_calls := 0
	var should_fail := false

	func play(_effect_name: String, _target: Node) -> bool:
		calls += 1
		return not should_fail
	func play_combo(_combo_name: String, _target: Node) -> bool: return true
	func play_global(_effect_name: String) -> bool: return true
	func stop(_target: Node) -> void: stop_calls += 1
	func stop_all() -> void: pass
	func get_effect(_effect_name: String): return null
	func get_combo(_combo_name: String): return null
	func resolve_combo(_combo_name: String): return null
	func get_effect_names() -> Array[String]: return ["punch_scale", "color", "alpha"]
	func get_combo_names() -> Array[String]: return []


class MockSpark:
	extends Node
	var calls := 0
	var clear_calls := 0
	var should_fail := false
	var base := {"amount": 1, "lifetime": 0.1, "speed": 1.0}
	var presets := {"hit": {}}

	func burst(_position: Vector2, _options: Dictionary) -> bool:
		calls += 1
		return not should_fail
	func at(_position: Vector2, _options: Dictionary) -> bool: return true
	func clear() -> void: clear_calls += 1


class FixtureTarget:
	extends Node2D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var navigation := NAVIGATION_SCENE.instantiate()
	root.add_child(navigation)
	await process_frame
	await process_frame
	var baseline_hash := _authority_fingerprint(navigation)
	var service := FEEDBACK_SCRIPT.new()
	root.add_child(service)
	var bridge := BRIDGE_SCRIPT.new()
	root.add_child(bridge)
	bridge.configure(service, root)
	service.semantic_requested.connect(_capture_request)
	var baseline_listener_count := bridge.get_listener_count()
	bridge.configure(service, root)
	_check("reconfigure retains one bridge listener", bridge.get_listener_count() == baseline_listener_count)
	_check("bridge starts with production dispatch disabled", not bridge._production_dispatch_enabled)

	service.set_session_context({"session_id": "probe-session", "metadata": {"value": 9}})
	var payload := {"nested": {"value": 7}, "values": [1, 2]}
	var source_context := {"source": "probe", "metadata": {"value": 8}}
	service.request_semantic("merge", payload, "merge:probe:1", source_context)
	_check("semantic request deep-copies payload and context before consumer emission", payload.nested.value == 7 and payload.values == [1, 2] and source_context.metadata.value == 8 and service.session_context.metadata.value == 9)
	_check("semantic event sequence is monotonic", _received.size() == 1 and _received[0].sequence == 1)
	_check("semantic consumer mutation does not change caller payload", payload.nested.value == 7)
	_check("non-MICRO event duplicate is suppressed", not service.request_semantic("merge", payload, "merge:probe:1"))
	service.request_semantic("cocktail_launch", {"level": 1})
	service.request_semantic("cocktail_launch", {"level": 1})
	_check("MICRO requests are not token-deduped", int(service.semantic_counts.get("cocktail_launch", 0)) == 2)
	_check("non-MICRO request without token is rejected", not service.request_semantic("vip_complete", {}))
	_check("unknown semantic kind is rejected", not service.request_semantic("unknown", {}))
	_check("diagnostics stay bounded and capture invalid semantics", service.semantic_diagnostics.size() == 2)
	var merge_source := Node.new()
	root.add_child(merge_source)
	service.emit_merge(merge_source, {"level": 2})
	service.emit_merge(merge_source, {"level": 2})
	_check("legacy merge source dedupe emits one semantic merge", int(service.semantic_counts.get("merge", 0)) == 2)
	service.emit_order_complete(9, 4, {"accepted": 1})
	service.emit_order_complete(9, 4, {"accepted": 1})
	_check("legacy order token dedupe emits one semantic completion", int(service.semantic_counts.get("order_complete", 0)) == 1 and service.event_count("order_complete") == 1)
	service.emit_game_success({"score": 100, "stars": 3, "economy": {"grants": [{"granted": true, "reward_id": "fixture"}]}})
	service.emit_game_success({"score": 100, "stars": 3, "economy": {"grants": [{"granted": true, "reward_id": "fixture"}]}})
	_check("terminal success and reward semantics are one-shot", int(service.semantic_counts.get("game_success", 0)) == 1 and int(service.semantic_counts.get("score_mastery", 0)) == 1 and int(service.semantic_counts.get("reward_granted", 0)) == 1)

	var fixture := FixtureTarget.new()
	fixture.add_to_group("m22_test_presentation_target")
	root.add_child(fixture)
	var gff := MockGFF.new()
	root.add_child(gff)
	var spark := MockSpark.new()
	root.add_child(spark)
	var plan := {
		"gff_effect": "punch_scale",
		"spark_preset": "hit",
		"spark_overrides": {"amount": 8, "lifetime": 0.25, "speed": 24.0},
	}
	var authority_before_dispatch := _authority_fingerprint(navigation)
	service.request_semantic("game_success", {"score": 123}, "success:probe")
	_check("production semantic request never dispatches in M22", gff.calls == 0 and spark.calls == 0)
	bridge._production_dispatch_enabled = true
	service.request_semantic("game_fail", {"score": 123}, "fail:probe")
	_check("enabled production path still no-ops without an explicit mapping target", gff.calls == 0 and spark.calls == 0)
	bridge._production_dispatch_enabled = false
	_check("fixture dispatch reaches both available mocks", bridge.dispatch_fixture_request({"kind": "merge"}, fixture, plan, gff, spark) and gff.calls == 1 and spark.calls == 1)
	var calls_before_absent := gff.calls + spark.calls
	bridge.dispatch_fixture_request({"kind": "merge"}, fixture, plan, null, spark)
	_check("missing GameFeelFlow no-ops before calls", gff.calls + spark.calls == calls_before_absent)
	bridge.dispatch_fixture_request({"kind": "merge"}, fixture, {"spark_preset": "hit", "spark_overrides": plan.spark_overrides}, gff, null)
	_check("missing Spark no-ops before calls", gff.calls + spark.calls == calls_before_absent)
	bridge.dispatch_fixture_request({"kind": "merge"}, fixture, {"spark_preset": "hit", "spark_overrides": plan.spark_overrides}, null, null)
	_check("both plugins absent no-op safely", gff.calls + spark.calls == calls_before_absent)
	gff.should_fail = true
	_check("GameFeelFlow failure returns safe no-op", not bridge.dispatch_fixture_request({"kind": "merge"}, fixture, {"gff_effect": "punch_scale"}, gff, null))
	gff.should_fail = false
	spark.should_fail = true
	_check("Spark failure returns safe no-op", not bridge.dispatch_fixture_request({"kind": "merge"}, fixture, {"spark_preset": "hit", "spark_overrides": plan.spark_overrides}, null, spark))
	_check("unknown fixture mapping no-ops", not bridge.dispatch_fixture_request({"kind": "merge"}, fixture, {}, gff, spark))
	var disallowed_target := FixtureTarget.new()
	root.add_child(disallowed_target)
	_check("non-allowlisted fixture target no-ops", not bridge.dispatch_fixture_request({"kind": "merge"}, disallowed_target, plan, gff, spark))
	_check("authority state hash is unchanged by semantic and fixture bridge", authority_before_dispatch == _authority_fingerprint(navigation) and baseline_hash == authority_before_dispatch)
	_check("bridge diagnostics remain bounded", bridge.get_diagnostics().size() <= BRIDGE_SCRIPT.MAX_DIAGNOSTICS)
	var replacement_service := FEEDBACK_SCRIPT.new()
	root.add_child(replacement_service)
	bridge.configure(replacement_service, root)
	_check("session replacement detaches old listener and keeps one new listener", bridge.get_listener_count() == 1 and not service.semantic_requested.is_connected(Callable(bridge, "_on_semantic_requested")))
	_check("fixture outputs are canceled on service replacement", gff.stop_calls == 1 and spark.clear_calls == 1)

	var catalog: Array = FEEDBACK_SCRIPT.SEMANTIC_KINDS.duplicate()
	var output := {
		"probe": "BCM-M22-002",
		"checks": _checks,
		"failures": _failures,
		"catalog": catalog,
		"semantic_counts": service.semantic_counts.duplicate(true),
		"legacy_event_counts": service.event_counts.duplicate(true),
		"listener_count_after_reconfigure": bridge.get_listener_count(),
		"listener_count_initial": baseline_listener_count,
		"authority_hash_before": baseline_hash,
		"authority_hash_after": _authority_fingerprint(navigation),
		"gff_fixture_calls": gff.calls,
		"spark_fixture_calls": spark.calls,
		"bridge_dispatch_count": bridge.dispatch_count,
		"bridge_no_op_count": bridge.no_op_count,
		"bridge_diagnostics": bridge.get_diagnostics(),
		"service_diagnostics": service.semantic_diagnostics.duplicate(),
	}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("evidence file is writable")
	else:
		file.store_string(JSON.stringify(output, "\t") + "\n")
		file.close()
	bridge.queue_free()
	service.queue_free()
	navigation.queue_free()
	print("M22_002_SEMANTIC_BRIDGE_RESULT=%s checks=%d failures=%d authority_hash=%d" % ["PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), baseline_hash])
	for failure in _failures:
		push_error(failure)
	quit(0 if _failures.is_empty() else 1)


func _capture_request(request: Dictionary) -> void:
	_received.append(request.duplicate(true))
	if request.payload.has("nested"):
		request.payload.nested.value = -99
	if request.source_context.has("metadata"):
		request.source_context.metadata.value = -99


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)


func _authority_fingerprint(navigation: Node) -> int:
	var manager = navigation.get("campaign_manager")
	var economy = navigation.get("economy")
	return hash(JSON.stringify({
		"campaign": manager.get_progression_state() if manager != null else {},
		"economy": economy.get_ledger_state() if economy != null else {},
		"view": navigation.get("current_view"),
		"active_island": navigation.get("active_island_id"),
		"gameplay_instances": navigation.get_gameplay_instance_count(),
	}))

