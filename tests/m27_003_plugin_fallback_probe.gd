extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const EFFECT_REGISTRY := preload("res://addons/game_feel_flow/core/gff_effect_registry.gd")
const REPORT_PATH := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-003/plugin_fallback_authority.json"

var _failures: Array[String] = []
var _results: Dictionary = {}


class MockGFF:
	extends Node
	var calls := 0
	var should_fail := false

	func play(_effect: Variant, _target: Node, _params: Dictionary = {}) -> bool:
		calls += 1
		return not should_fail
	func stop(_target: Node) -> void: pass
	func stop_all() -> void: pass
	func get_effect(effect_name: String):
		return EFFECT_REGISTRY.create_effect("color", "color") if effect_name == "color" else null
	func get_effect_names() -> Array[String]: return ["punch_scale", "color", "alpha"]
	func play_combo(_name: String, _target: Node) -> bool: return true
	func play_global(_name: String) -> bool: return true
	func get_combo(_name: String): return null
	func resolve_combo(_name: String): return null
	func get_combo_names() -> Array[String]: return []


class MockSpark:
	extends Node
	var calls := 0
	var clears := 0
	var should_fail := false
	var base := {"amount": 1, "lifetime": 0.1, "speed": 1.0, "lifetime_rand": 0.0}
	var presets := {"hit": {}, "pickup": {}, "confetti": {}, "dust": {}, "spark": {}}

	func burst(_position: Vector2, _options: Dictionary) -> bool:
		calls += 1
		return not should_fail
	func at(_target: Node, _options: Dictionary) -> bool: return true
	func clear() -> void: clears += 1


func _initialize() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M27_003_PLUGIN_FALLBACK PASS: %s" % label)
	else:
		_failures.append(label)
		print("M27_003_PLUGIN_FALLBACK FAIL: %s" % label)


func _physics_snapshot(drink: Drink) -> Dictionary:
	var collider := drink.get_child(0) as CollisionShape2D
	return {"velocity": drink.linear_velocity, "position": drink.global_position, "transform": drink.global_transform, "radius": (collider.shape as CircleShape2D).radius, "layer": drink.collision_layer, "mask": drink.collision_mask}


func _run_scenario(manager: GameManager, gff: MockGFF, spark: MockSpark, mode: String, fail_plugins: bool = false) -> Dictionary:
	var bridge: PresentationFeedbackBridge = manager.presentation_feedback_bridge
	manager.score = 0
	manager.best_score = 0
	manager.chain = 0
	manager.chain_timer = 0.0
	gff.calls = 0
	spark.calls = 0
	gff.should_fail = fail_plugins
	spark.should_fail = fail_plugins
	bridge._contract.refresh_with_nodes(gff if mode in ["BOTH", "GFF_ONLY"] else null, spark if mode in ["BOTH", "SPARK_ONLY"] else null)
	bridge.set_presentation_mode("FULL")
	bridge.set_production_dispatch_enabled(true)
	var drink := manager.spawn_drink(12, Vector2(350.0, 400.0), false)
	var before := _physics_snapshot(drink)
	manager.on_merged(12, drink)
	await process_frame
	var after := _physics_snapshot(drink)
	var result := {"score": manager.score, "best_score": manager.best_score, "chain": manager.chain, "physics_before": before, "physics_after": after, "gff_calls": gff.calls, "spark_calls": spark.calls, "plugin_mode": mode, "injected_failure": fail_plugins}
	bridge.cancel_presentation()
	bridge.set_production_dispatch_enabled(false)
	return result


func _run() -> void:
	var manager := MAIN_SCENE.instantiate() as GameManager
	root.add_child(manager)
	current_scene = manager
	await process_frame
	await physics_frame
	var gff := MockGFF.new()
	var spark := MockSpark.new()
	root.add_child(gff)
	root.add_child(spark)
	var modes := ["BOTH", "GFF_ONLY", "SPARK_ONLY", "NEITHER"]
	for mode in modes:
		_results[mode] = await _run_scenario(manager, gff, spark, mode)
	_results["INJECTED_FAILURE"] = await _run_scenario(manager, gff, spark, "BOTH", true)
	var baseline: Dictionary = _results["BOTH"]
	for mode in modes.slice(1):
		_check("authoritative score and physics match with %s" % mode, _results[mode].score == baseline.score and _results[mode].best_score == baseline.best_score and _results[mode].chain == baseline.chain and _results[mode].physics_before == baseline.physics_before and _results[mode].physics_after == baseline.physics_after)
	var failed_plugins: Dictionary = _results["INJECTED_FAILURE"]
	_check("injected GFF and Spark failure changes no authoritative result", failed_plugins.score == baseline.score and failed_plugins.best_score == baseline.best_score and failed_plugins.chain == baseline.chain and failed_plugins.physics_after == baseline.physics_after)
	_check("merged authoritative score remains the expected value", baseline.score == 6500 and baseline.best_score == 6500 and baseline.chain == 1)
	_check("one or both missing plugins degrade to presentation no-op", _results["GFF_ONLY"].spark_calls == 0 and _results["SPARK_ONLY"].gff_calls == 0 and _results["NEITHER"].gff_calls == 0 and _results["NEITHER"].spark_calls == 0)
	var stale_target := Node.new()
	root.add_child(stale_target)
	stale_target.free()
	var bridge: PresentationFeedbackBridge = manager.presentation_feedback_bridge
	bridge.set_visual_diagnostics_enabled(true)
	var stale_trace_id := bridge._begin_visual_trace({"kind": "merge", "event_id": "m27-stale-target", "payload": {"presentation_target": stale_target}})
	var stale_trace: Dictionary = bridge.get_visual_diagnostic_trace().back() if not bridge.get_visual_diagnostic_trace().is_empty() else {}
	_check("diagnostics safely record delayed events with freed presentation targets", not stale_trace_id.is_empty() and stale_trace.get("target", {}).is_empty() and bool(stale_trace.get("payload", {}).get("presentation_target", {}).get("invalid_object", false)))
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("fallback evidence is writable")
	else:
		file.store_string(JSON.stringify({"scenario_results": _results, "failures": _failures, "authority_independence": _failures.is_empty(), "owner_visual_acceptance": "PENDING_OWNER_NATIVE_REVIEW"}, "\t") + "\n")
		file.close()
	print("M27_003_PLUGIN_FALLBACK_RESULT=%s scenarios=%d failures=%d" % ["PASS" if _failures.is_empty() else "FAIL", _results.size(), _failures.size()])
	manager.queue_free()
	quit(0 if _failures.is_empty() else 1)
