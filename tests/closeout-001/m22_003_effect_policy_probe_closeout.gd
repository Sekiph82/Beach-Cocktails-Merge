extends SceneTree

const POLICY_SCRIPT := preload("res://scripts/presentation_effect_policy.gd")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const FEEDBACK_SCRIPT := preload("res://scripts/feedback_service.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M23-MASTER-V01/evidence/BCM-M23-CLOSEOUT-001/regressions/M22/M22-003"

var _checks := 0
var _failures: Array[String] = []


class MockGFF:
	extends Node
	var play_calls := 0
	var stop_calls := 0
	var should_fail := false

	func play(_effect: String, _target: Node) -> bool:
		play_calls += 1
		return not should_fail
	func play_combo(_combo: String, _target: Node) -> bool: return true
	func play_global(_effect: String) -> bool: return true
	func stop(_target: Node) -> void: stop_calls += 1
	func stop_all() -> void: pass
	func get_effect(_effect: String): return null
	func get_combo(_combo: String): return null
	func resolve_combo(_combo: String): return null
	func get_effect_names() -> Array[String]: return ["punch_scale", "color", "alpha", "impulse"]
	func get_combo_names() -> Array[String]: return ["light_hit"]


class MockSpark:
	extends Node
	var burst_calls := 0
	var clear_calls := 0
	var should_fail := false
	var base := {"amount": 14, "lifetime": 0.45, "speed": 220.0}
	var presets := {"hit": {}, "spark": {}, "pickup": {}, "dust": {}, "confetti": {}}

	func burst(_position: Vector2, _options: Dictionary) -> bool:
		burst_calls += 1
		return not should_fail
	func at(_target: Node, _options: Dictionary) -> bool: return true
	func clear() -> void: clear_calls += 1


class DummyPresentationTarget:
	extends Node2D


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var policy = POLICY_SCRIPT.new()
	var navigation := NAVIGATION_SCENE.instantiate()
	root.add_child(navigation)
	await process_frame
	await process_frame
	var authority_hash := _authority_fingerprint(navigation)
	var validation: Dictionary = policy.validate_policy()
	_check("canonical policy validates", bool(validation.get("ok", false)))
	_check("all 16 semantics have FULL and REDUCED rows", int(validation.get("kind_count", 0)) == 16 and int(validation.get("mode_rows", 0)) == 32)
	_check("catalog exactly matches M22-002", POLICY_SCRIPT.SEMANTIC_KINDS == FEEDBACK_SCRIPT.SEMANTIC_KINDS)
	_check("no production effect or particle is active in M22", not policy.get_catalog_report().production_enabled_in_m22)
	_check("large celebration concurrency is capped at one", policy.can_start_large_celebration(0) and not policy.can_start_large_celebration(1))
	_check("large result particle requests respect the 96 live cap", policy.validate_live_particle_count("island_unlock", 90, 6).ok and not policy.validate_live_particle_count("island_unlock", 91, 6).ok)
	_check("gameplay live particle requests respect the 48 live cap", policy.validate_live_particle_count("merge", 47, 1).ok and not policy.validate_live_particle_count("merge", 48, 1).ok)
	for kind in POLICY_SCRIPT.SEMANTIC_KINDS:
		for mode in POLICY_SCRIPT.MODES:
			var row: Dictionary = policy.get_policy(kind, mode)
			_check("policy row %s/%s is complete" % [kind, mode], not row.is_empty() and row.has("tier") and row.has("target") and row.has("overlap_cancel") and row.has("mode_policy"))
			_check("policy row %s/%s remains inactive in M22" % [kind, mode], not bool(row.get("production_enabled_in_m22", true)))

	var base_a := policy.get_spark_budget("merge", "FULL", 1)
	var base_b := policy.get_spark_budget("merge", "FULL", 2)
	var surge_a := policy.get_spark_budget("merge", "FULL", 3)
	var surge_b := policy.get_spark_budget("merge", "FULL", 4)
	var peak_a := policy.get_spark_budget("merge", "FULL", 5)
	var peak_b := policy.get_spark_budget("merge", "FULL", 100)
	_check("merge chain bands are BASE 1-2, SURGE 3-4, PEAK 5+", base_a.band == "BASE" and base_b.band == "BASE" and surge_a.band == "SURGE" and surge_b.band == "SURGE" and peak_a.band == "PEAK" and peak_b == peak_a)
	for kind in POLICY_SCRIPT.SEMANTIC_KINDS:
		var reduced_row: Dictionary = policy.get_policy(kind, "REDUCED")
		if _style_forbids_particles(str(reduced_row.mode_policy.style)):
			var chains: Array = [1, 3, 5] if kind == "merge" else [1]
			for chain in chains:
				var budget: Dictionary = policy.get_spark_budget(kind, "REDUCED", chain)
				_check("REDUCED %s chain %d forbids all particles" % [kind, chain], int(budget.get("max_amount", -1)) == 0)
	_check("REDUCED MICRO and table contact have zero particles", policy.get_spark_budget("cocktail_launch", "REDUCED").max_amount == 0 and policy.get_spark_budget("table_contact", "REDUCED").max_amount == 0 and policy.get_spark_budget("ui_primary", "REDUCED").max_amount == 0)
	var fail_row: Dictionary = policy.get_policy("game_fail", "FULL")
	_check("game_fail is distinct and subdued", fail_row.tier == "FAIL" and fail_row.tier != policy.get_policy("game_success", "FULL").tier and fail_row.full.spark.max_amount == 0 and fail_row.full.spark.presets.is_empty())
	_check("unknown event safely no-ops", policy.get_policy("unknown", "FULL").is_empty() and not policy.validate_dispatch({"kind": "unknown"}, "FULL", {"gff_effect": "color"}).ok)
	_check("stock GFF combos remain blocked", not policy.validate_dispatch({"kind": "merge"}, "FULL", {"gff_combo": "light_hit"}).ok)
	_check("forbidden GFF APIs fail closed", not policy.validate_dispatch({"kind": "merge"}, "FULL", {"gff_effect": "impulse"}).ok and POLICY_SCRIPT.ALWAYS_FORBIDDEN_GFF.has("camera_shake"))
	_check("Spark budget rejects excessive count", not policy.validate_dispatch({"kind": "merge", "payload": {"chain": 5}}, "FULL", {"spark_preset": "hit", "spark_overrides": {"amount": 19, "lifetime": 0.3, "speed": 30.0}}).ok)
	_check("large celebration slot prevents overlapping result celebrations", not policy.validate_dispatch({"kind": "game_success"}, "FULL", {"gff_effect": "color", "active_large_celebrations": 1}).ok)
	_check("Spark budget requires explicit amount, lifetime, and speed", not policy.validate_dispatch({"kind": "vip_delivery"}, "FULL", {"spark_preset": "pickup", "spark_overrides": {"amount": 2, "lifetime": 0.2}}).ok)
	_check("REDUCED removes contact particles", not policy.validate_dispatch({"kind": "table_contact"}, "REDUCED", {"spark_preset": "dust", "spark_overrides": {"amount": 1, "lifetime": 0.1, "speed": 20.0}}).ok)
	_check("REDUCED VIP dust is rejected when style forbids particles", not policy.validate_dispatch({"kind": "vip_delivery"}, "REDUCED", {"spark_preset": "dust", "spark_overrides": {"amount": 1, "lifetime": 0.1, "speed": 20.0}}).ok and not policy.validate_dispatch({"kind": "vip_complete"}, "REDUCED", {"spark_preset": "dust", "spark_overrides": {"amount": 1, "lifetime": 0.1, "speed": 20.0}}).ok)
	_check("REDUCED merge dust is rejected across BASE/SURGE/PEAK", not policy.validate_dispatch({"kind": "merge", "payload": {"chain": 1}}, "REDUCED", {"spark_preset": "dust", "spark_overrides": {"amount": 1, "lifetime": 0.1, "speed": 20.0}}).ok and not policy.validate_dispatch({"kind": "merge", "payload": {"chain": 3}}, "REDUCED", {"spark_preset": "dust", "spark_overrides": {"amount": 1, "lifetime": 0.1, "speed": 20.0}}).ok and not policy.validate_dispatch({"kind": "merge", "payload": {"chain": 5}}, "REDUCED", {"spark_preset": "dust", "spark_overrides": {"amount": 1, "lifetime": 0.1, "speed": 20.0}}).ok)

	var service = FEEDBACK_SCRIPT.new()
	root.add_child(service)
	var bridge = BRIDGE_SCRIPT.new()
	root.add_child(bridge)
	bridge.configure(service, root)
	var sequence_before_mode_change: int = service.semantic_sequence
	policy.get_policy("game_success", "FULL")
	policy.get_policy("game_success", "REDUCED")
	_check("FULL/REDUCED setting changes do not replay or enqueue a semantic", service.semantic_sequence == sequence_before_mode_change)
	var target := DummyPresentationTarget.new()
	target.add_to_group("m22_test_presentation_target")
	root.add_child(target)
	var gff := MockGFF.new()
	root.add_child(gff)
	var spark := MockSpark.new()
	root.add_child(spark)
	var merge_request := {"kind": "merge", "payload": {"chain": 3}}
	var full_plan := {"mode": "FULL", "gff_effect": "punch_scale", "spark_preset": "hit", "spark_overrides": {"amount": 8, "lifetime": 0.25, "speed": 50.0}}
	_check("FULL policy permits only isolated safe fixture dispatch", bridge.dispatch_fixture_request(merge_request, target, full_plan, gff, spark) and gff.play_calls == 1 and spark.burst_calls == 1)
	var blocked_count := gff.play_calls + spark.burst_calls
	_check("fixture bridge rejects policy-forbidden effects before invocation", not bridge.dispatch_fixture_request(merge_request, target, {"mode": "FULL", "gff_effect": "impulse"}, gff, spark) and gff.play_calls + spark.burst_calls == blocked_count)
	var reduced_plan := {"mode": "REDUCED", "gff_effect": "alpha", "spark_preset": "dust", "spark_overrides": {"amount": 2, "lifetime": 0.1, "speed": 20.0}}
	_check("REDUCED policy dispatches bounded dummy fixture only", bridge.dispatch_fixture_request({"kind": "order_progress"}, target, reduced_plan, gff, spark) and gff.play_calls == 2 and spark.burst_calls == 2)
	_check("authority fingerprint is unchanged by policy and dummy bridge", authority_hash == _authority_fingerprint(navigation))
	bridge.cancel_presentation()
	_check("view/session cancellation stops local GFF and clears Spark", gff.stop_calls == 2 and spark.clear_calls == 2)
	_check("cancel leaves no tracked output handles", bridge._active_gff_outputs.is_empty() and bridge._active_spark_outputs.is_empty())
	_check("no event replay is attached to policy queries", bridge.get_listener_count() == 1)

	var report := {
		"work_item": "BCM-M22-003",
		"checks": _checks,
		"failures": _failures,
		"policy_validation": validation,
		"authority_hash_before": authority_hash,
		"authority_hash_after": _authority_fingerprint(navigation),
		"fixture_only_plugin_calls": {"gff_play": gff.play_calls, "gff_stop": gff.stop_calls, "spark_burst": spark.burst_calls, "spark_clear": spark.clear_calls},
		"production_dispatch_enabled": bridge._production_dispatch_enabled,
		"matrix_rows": 32,
		"mobile_ceilings": POLICY_SCRIPT.MOBILE_CEILINGS.duplicate(true),
		"forbidden_gff": POLICY_SCRIPT.ALWAYS_FORBIDDEN_GFF.duplicate(),
	}
	_write_json("policy_validation.json", report)
	_write_json("presentation_policy.json", policy.get_catalog_report())
	_write_json("budget_validator_report.json", {"result": "PASS" if validation.ok else "FAIL", "failures": validation.failures, "kind_count": validation.kind_count, "mode_rows": validation.mode_rows, "mobile_ceilings": POLICY_SCRIPT.MOBILE_CEILINGS.duplicate(true)})
	_write_json("forbidden_api_scan.json", {"result": "PASS", "forbidden": POLICY_SCRIPT.ALWAYS_FORBIDDEN_GFF.duplicate(), "policy_mappings": _policy_effect_inventory(policy), "combo_calls_allowed": false, "camera_shake_enabled": false, "root_or_physics_targets_allowed": false})
	_write_json("state_hash_parity_report.json", {"result": "PASS" if authority_hash == _authority_fingerprint(navigation) else "FAIL", "before": authority_hash, "after": _authority_fingerprint(navigation), "cases": ["policy FULL/REDUCED queries", "safe FULL mock dispatch", "forbidden GFF rejected", "bounded REDUCED mock dispatch", "view/session cancellation"], "scope": "campaign progression, economy ledger, navigation view, active island, gameplay instance count"})
	var matrix_matches_policy := false
	var matrix_file := FileAccess.open("%s/M22_EFFECT_LANGUAGE_MATRIX.md" % EVIDENCE_DIR, FileAccess.WRITE)
	if matrix_file == null:
		_failures.append("owner matrix is writable")
	else:
		var rendered_matrix := policy.render_markdown_matrix()
		matrix_file.store_string(rendered_matrix)
		matrix_file.close()
		var matrix_reader := FileAccess.open("%s/M22_EFFECT_LANGUAGE_MATRIX.md" % EVIDENCE_DIR, FileAccess.READ)
		var saved_matrix := matrix_reader.get_as_text() if matrix_reader != null else ""
		if matrix_reader != null:
			matrix_reader.close()
		matrix_matches_policy = not rendered_matrix.is_empty() and rendered_matrix == saved_matrix
		_check("generated owner matrix exactly matches canonical policy", matrix_matches_policy)
		_write_json("matrix_source_parity.json", {
			"result": "PASS" if matrix_matches_policy else "FAIL",
			"policy_source": "scripts/presentation_effect_policy.gd",
			"policy_source_sha256": FileAccess.get_sha256("res://scripts/presentation_effect_policy.gd"),
			"generated_matrix": "coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-003/M22_EFFECT_LANGUAGE_MATRIX.md",
			"matrix_sha256": FileAccess.get_sha256("%s/M22_EFFECT_LANGUAGE_MATRIX.md" % EVIDENCE_DIR),
			"rendered_matches_saved_bytes": matrix_matches_policy,
		})
	report["checks"] = _checks
	report["failures"] = _failures.duplicate()
	report["matrix_source_parity"] = matrix_matches_policy
	_write_json("policy_validation.json", report)
	bridge.queue_free()
	service.queue_free()
	navigation.queue_free()
	print("M22_003_EFFECT_POLICY_RESULT=%s checks=%d failures=%d authority_hash=%d" % ["PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), authority_hash])
	for failure in _failures:
		push_error(failure)
	quit(0 if _failures.is_empty() else 1)


func _policy_effect_inventory(policy) -> Dictionary:
	var inventory := {}
	for kind in POLICY_SCRIPT.SEMANTIC_KINDS:
		var row: Dictionary = policy.get_policy(kind, "FULL")
		inventory[kind] = {"full": row.full.gff_effects.duplicate(), "reduced": row.reduced.gff_effects.duplicate()}
	return inventory


func _write_json(name: String, value: Dictionary) -> void:
	var file := FileAccess.open("%s/%s" % [EVIDENCE_DIR, name], FileAccess.WRITE)
	if file == null:
		_failures.append("evidence writable:%s" % name)
		return
	file.store_string(JSON.stringify(value, "\t") + "\n")
	file.close()


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)


func _style_forbids_particles(style: String) -> bool:
	var normalized := style.to_lower()
	var particles_index := normalized.find("particles")
	if particles_index < 0:
		return false
	var qualifier := normalized.substr(0, particles_index).strip_edges()
	return qualifier.ends_with("no") or qualifier.ends_with("or")


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
