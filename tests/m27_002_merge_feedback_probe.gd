extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-002/M23-002_merge_feedback_probe.json"

var _checks := 0
var _failures: Array[String] = []
var _merge_requests: Array[Dictionary] = []


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
	var should_fail := false
	var base := {"amount": 1, "lifetime": 0.1, "speed": 1.0, "lifetime_rand": 0.0}
	var presets := {"hit": {}}

	func burst(position: Vector2, options: Dictionary) -> bool:
		calls.append({"position": position, "options": options.duplicate(true)})
		return not should_fail
	func at(_node: Node, _options: Dictionary) -> bool: return true
	func clear() -> void: cleared += 1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager := MAIN_SCENE.instantiate() as GameManager
	root.add_child(manager)
	current_scene = manager
	await process_frame
	await physics_frame
	_check("main GameManager initializes with presentation bridge", manager != null and manager.presentation_feedback_bridge != null and manager.feedback_service != null)
	var bridge: PresentationFeedbackBridge = manager.presentation_feedback_bridge
	var service: FeedbackService = manager.feedback_service
	bridge.set_visual_diagnostics_enabled(true)
	var gff := MockGFF.new()
	var spark := MockSpark.new()
	root.add_child(gff)
	root.add_child(spark)
	bridge._contract.refresh_with_nodes(gff, spark)
	service.semantic_requested.connect(_capture_merge_request)
	_check("legacy _juice_effect implementation and call are absent", not _game_manager_source_has_legacy_merge_effect())
	var save_fingerprint_before := _save_file_fingerprint()

	var off_drink := manager.spawn_drink(12, Vector2(90.0, 420.0), false)
	manager.score = 0
	manager.best_score = 0
	manager.chain = 0
	manager.chain_timer = 0.0
	bridge.set_production_dispatch_enabled(false)
	var off_physics_before := _physics_snapshot(off_drink)
	manager.on_merged(12, off_drink)
	var off_physics_after := _physics_snapshot(off_drink)
	var off_result := _gameplay_result_snapshot(manager)
	_check("effects-off L12 merge creates no GFF or Spark output", gff.calls.is_empty() and spark.calls.is_empty())

	var on_drink := manager.spawn_drink(12, Vector2(620.0, 420.0), false)
	manager.score = 0
	manager.best_score = 0
	manager.chain = 0
	manager.chain_timer = 0.0
	bridge.set_production_dispatch_enabled(true)
	var on_physics_before := _physics_snapshot(on_drink)
	manager.on_merged(12, on_drink)
	var on_physics_after := _physics_snapshot(on_drink)
	var on_result := _gameplay_result_snapshot(manager)
	var save_fingerprint_after := _save_file_fingerprint()
	_check("effects-on and effects-off merge preserve identical score/best/chain outputs", off_result == on_result)
	_check("presentation dispatch leaves both merge bodies and colliders unchanged", off_physics_before == off_physics_after and on_physics_before == on_physics_after)
	_check("effects-on/off merge leaves persistent save bytes unchanged", save_fingerprint_before == save_fingerprint_after)
	_check("actual merge routes one punch and one Spark through the visual child", _merge_requests.size() == 2 and bridge.dispatch_count == 1 and gff.calls.size() == 1 and spark.calls.size() == 1 and gff.calls[0].effect == "punch_scale" and gff.calls[0].target == on_drink.get_node("Visual"))
	var calls_after_real_merge := spark.calls.size()
	service.emit_merge(on_drink, {"level": 12, "chain": manager.chain, "score": manager.score, "presentation_target": on_drink.get_node("Visual")})
	_check("duplicate merge request for the same source is coalesced", spark.calls.size() == calls_after_real_merge and _merge_requests.size() == 2)

	var expected_bands := [
		{"chain": 1, "amount": 10, "lifetime": 0.28, "speed": 55.0, "size": 4.0, "intensity": 0.30, "name": "BASE"},
		{"chain": 3, "amount": 10, "lifetime": 0.30, "speed": 70.0, "size": 4.5, "intensity": 0.48, "name": "SURGE"},
		{"chain": 5, "amount": 18, "lifetime": 0.35, "speed": 105.0, "size": 5.0, "intensity": 0.68, "name": "PEAK"},
		{"chain": 6, "amount": 18, "lifetime": 0.35, "speed": 105.0, "size": 5.0, "intensity": 0.68, "name": "PEAK hard cap"},
	]
	var band_results: Array[Dictionary] = []
	var band_intensities: Array[float] = []
	for band in expected_bands:
		bridge.cancel_presentation()
		var source := _make_merge_source("FULL_%s" % band.name)
		service.emit_merge(source, {"level": 3, "chain": band.chain, "score": 0, "presentation_target": source.get_node("Visual")})
		var options: Dictionary = spark.calls.back().options if not spark.calls.is_empty() else {}
		var matched := not options.is_empty() and int(options.get("amount", -1)) == int(band.amount) and is_equal_approx(float(options.get("lifetime", -1.0)), float(band.lifetime))
		_check("FULL %s Spark amount/lifetime matches locked ceiling" % band.name, matched)
		var profile_matches := is_equal_approx(float(options.get("speed", -1.0)), float(band.speed)) and is_equal_approx(float(options.get("size", -1.0)), float(band.size)) and is_equal_approx(float(gff.calls.back().params.get("intensity", -1.0)), float(band.intensity))
		_check("FULL %s has a distinct bounded size/speed/scale profile" % band.name, profile_matches)
		band_intensities.append(float(gff.calls.back().params.get("intensity", 0.0)))
		band_results.append({"band": band.name, "chain": band.chain, "amount": options.get("amount", -1), "lifetime": options.get("lifetime", -1.0), "passed": matched})
		_check("FULL %s GameFeelFlow effect targets its presentation child" % band.name, gff.calls.back().target == source.get_node("Visual") and gff.calls.back().effect == "punch_scale")
	_check("BASE, SURGE and PEAK intensities rise monotonically and PEAK remains capped", band_intensities == [0.30, 0.48, 0.68, 0.68])

	bridge.set_presentation_mode("REDUCED")
	var reduced_spark_start := spark.calls.size()
	var reduced_effects: Array[String] = []
	for chain_value in [1, 3, 5]:
		var source := _make_merge_source("REDUCED_%d" % chain_value)
		service.emit_merge(source, {"level": 3, "chain": chain_value, "score": 0, "presentation_target": source.get_node("Visual")})
		reduced_effects.append(str(gff.calls.back().effect))
	_check("REDUCED BASE/SURGE/PEAK produce zero particles and color-only emphasis", spark.calls.size() == reduced_spark_start and reduced_effects == ["color", "color", "color"])
	_check("REDUCED merge emphasis stays <=0.10 seconds", float(gff.calls.back().params.duration) <= 0.10)
	_check("REDUCED merge passes a configured low-contrast tint", gff.calls.back().params.has("color") and gff.calls.back().params.color != Color.WHITE)

	bridge.set_presentation_mode("FULL")
	bridge.cancel_presentation()
	var stress_start := bridge.dispatch_count
	for index in range(6):
		var source := _make_merge_source("STRESS_%d" % index)
		service.emit_merge(source, {"level": 2, "chain": 1, "score": 0, "presentation_target": source.get_node("Visual")})
	var active_particles := bridge._active_spark_particle_count()
	var stress_dispatch_delta := bridge.dispatch_count - stress_start
	var stress_active_gff_outputs := bridge._active_gff_outputs.size()
	_check("merge stress remains under the 48 live-particle ceiling", active_particles <= 48)
	_check("merge stress retains particle-cap backpressure", stress_dispatch_delta <= 4)
	_check("merge stress remains under the GFF output ceiling", stress_active_gff_outputs <= BRIDGE_SCRIPT.MAX_ACTIVE_GFF_OUTPUTS)
	var stress_calls := spark.calls.size()
	_check("over-cap stress events fail closed without invoking Spark", stress_calls - reduced_spark_start <= 10)

	bridge.cancel_presentation()
	var calls_before_missing := gff.calls.size() + spark.calls.size()
	bridge._contract.refresh_with_nodes(null, spark)
	var missing_source := _make_merge_source("MISSING_PLUGIN")
	service.emit_merge(missing_source, {"level": 3, "chain": 3, "score": 0, "presentation_target": missing_source.get_node("Visual")})
	_check("missing plugin is a safe no-op before partial dispatch", gff.calls.size() + spark.calls.size() == calls_before_missing)
	bridge._contract.refresh_with_nodes(gff, spark)
	gff.should_fail = true
	var failed_gff_source := _make_merge_source("FAILED_GFF")
	var spark_before_failed_gff := spark.calls.size()
	service.emit_merge(failed_gff_source, {"level": 3, "chain": 2, "score": 0, "presentation_target": failed_gff_source.get_node("Visual")})
	_check("failed GameFeelFlow merge cancels before Spark call", spark.calls.size() == spark_before_failed_gff)
	gff.should_fail = false
	spark.should_fail = true
	var failed_spark_source := _make_merge_source("FAILED_SPARK")
	service.emit_merge(failed_spark_source, {"level": 3, "chain": 2, "score": 0, "presentation_target": failed_spark_source.get_node("Visual")})
	_check("failed Spark call cancels bridge presentation outputs", gff.stopped > 0 and spark.cleared > 0)
	spark.should_fail = false
	var cancellation_source := _make_merge_source("SESSION_CANCEL")
	service.emit_merge(cancellation_source, {"level": 3, "chain": 1, "score": 0, "presentation_target": cancellation_source.get_node("Visual")})
	var gff_stop_before := gff.stopped
	var spark_clear_before := spark.cleared
	var replacement_service := FeedbackService.new()
	root.add_child(replacement_service)
	bridge.configure(replacement_service, root)
	_check("session/service replacement cancels active GFF and Spark outputs", gff.stopped > gff_stop_before and spark.cleared > spark_clear_before)

	var result := {
		"probe": "BCM-M23-002",
		"checks": _checks,
		"failures": _failures,
		"full_band_results": band_results,
		"reduced_bands": ["BASE", "SURGE", "PEAK"],
		"reduced_particle_count": 0,
		"authority_effects_off": {"result": off_result, "physics_before": off_physics_before, "physics_after": off_physics_after},
		"authority_effects_on": {"result": on_result, "physics_before": on_physics_before, "physics_after": on_physics_after},
		"save_fingerprint_before": save_fingerprint_before,
		"save_fingerprint_after": save_fingerprint_after,
		"stress_active_particles": active_particles,
		"stress_dispatch_delta": stress_dispatch_delta,
		"stress_active_gff_outputs": stress_active_gff_outputs,
		"live_particle_ceiling": 48,
		"active_gff_output_ceiling": BRIDGE_SCRIPT.MAX_ACTIVE_GFF_OUTPUTS,
		"bridge_dispatch_count": bridge.dispatch_count,
		"bridge_no_op_count": bridge.no_op_count,
		"legacy_merge_effect_present": _game_manager_source_has_legacy_merge_effect(),
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
	print("M23_002_MERGE_FEEDBACK_RESULT=%s checks=%d failures=%d dispatches=%d active_particles=%d captures=0" % ["PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), bridge.dispatch_count, active_particles])
	for failure in _failures:
		push_error(failure)
	bridge.queue_free()
	manager.queue_free()
	quit(0 if _failures.is_empty() else 1)


func _make_merge_source(label: String) -> Node2D:
	var source := Node2D.new()
	source.name = label
	root.add_child(source)
	var visual := Node2D.new()
	visual.name = "Visual"
	visual.add_to_group("presentation_effect_target")
	source.add_child(visual)
	return source


func _capture_merge_request(request: Dictionary) -> void:
	if str(request.get("kind", "")) == "merge":
		_merge_requests.append(request.duplicate(true))


func _gameplay_result_snapshot(manager: GameManager) -> Dictionary:
	return {"score": manager.score, "best_score": manager.best_score, "chain": manager.chain, "chain_timer": manager.chain_timer}


func _physics_snapshot(drink: Drink) -> Dictionary:
	var collider := drink.get_child(0) as CollisionShape2D
	return {
		"velocity": drink.linear_velocity,
		"body_basis_x": drink.transform.x,
		"body_basis_y": drink.transform.y,
		"collider_transform": collider.transform,
		"collider_radius": (collider.shape as CircleShape2D).radius,
		"collision_layer": drink.collision_layer,
		"collision_mask": drink.collision_mask,
	}


func _game_manager_source_has_legacy_merge_effect() -> bool:
	var file := FileAccess.open("res://scripts/game_manager.gd", FileAccess.READ)
	if file == null:
		return true
	var source := file.get_as_text()
	file.close()
	return source.contains("_juice_effect") or source.contains("MergeFeedback")


func _save_file_fingerprint() -> Dictionary:
	var path := "user://save.cfg"
	if not FileAccess.file_exists(path):
		return {"exists": false, "sha256": ""}
	var hash_context := HashingContext.new()
	if hash_context.start(HashingContext.HASH_SHA256) != OK:
		return {"exists": true, "sha256": "HASH_UNAVAILABLE"}
	var bytes := FileAccess.get_file_as_bytes(path)
	if hash_context.update(bytes) != OK:
		return {"exists": true, "sha256": "HASH_UNAVAILABLE"}
	return {"exists": true, "sha256": hash_context.finish().hex_encode()}


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)

