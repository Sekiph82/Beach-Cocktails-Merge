extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const EFFECT_REGISTRY := preload("res://addons/game_feel_flow/core/gff_effect_registry.gd")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M24-MASTER-V01/evidence/M24-R01/regression/m23_color_lifecycle_probe.json"

var _checks := 0
var _failures: Array[String] = []
var _scenarios: Array[Dictionary] = []
var _targets: Array[Node] = []
var _bridge: Node
var _manager: Node
var _plugin: Node
var _failing_plugin: Node


class VisualTarget:
	extends Node2D


class FailingPlugin:
	extends Node
	var calls := 0
	var stopped := 0

	func get_effect(_effect_name: String):
		return EFFECT_REGISTRY.create_effect("color", "color")

	func play(_effect_name: Variant, target: Node, params: Dictionary = {}) -> bool:
		calls += 1
		if target is CanvasItem:
			(target as CanvasItem).modulate = params.get("color", Color.WHITE)
		return false

	func stop(_target: Node) -> void:
		stopped += 1

	func play_combo(_combo_name: String, _target: Node, _params = null) -> void: pass
	func play_global(_effect_name: String, _params = null) -> void: pass
	func stop_all(_target: Node = null) -> void: pass
	func get_combo(_combo_name: String): return null
	func resolve_combo(_combo_name: String): return null
	func get_effect_names() -> Array[String]: return ["color"]
	func get_combo_names() -> Array[String]: return []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager := MAIN_SCENE.instantiate()
	_manager = manager
	root.add_child(manager)
	current_scene = manager
	await process_frame
	await process_frame
	var plugin: Node = root.get_node_or_null("GameFeelFlow")
	_plugin = plugin
	_check("real GameFeelFlow autoload initialized", is_instance_valid(plugin) and plugin.has_method("get_effect") and plugin.has_method("play"))
	if not is_instance_valid(plugin):
		_finish()
		return
	var bridge := BRIDGE_SCRIPT.new()
	_bridge = bridge
	root.add_child(bridge)
	bridge.configure(null, root)
	bridge._contract.refresh_with_nodes(plugin, root.get_node_or_null("Spark"))
	var target := _new_target(Color(0.37, 0.61, 0.83, 0.74))
	var initial: Color = target.modulate
	var natural := bridge._start_color_output(target, {"duration": 0.10, "color": Color(0.93, 0.59, 0.37, 1.0)}, "natural-score", "score_mastery", "probe")
	await create_timer(0.14).timeout
	_check("single natural completion restores a non-white initial modulation exactly", not natural.is_empty() and target.modulate == initial)
	_scenarios.append({"scenario": "natural_completion", "initial": initial, "final": target.modulate, "exact": target.modulate == initial})
	var first := bridge._start_color_output(target, {"duration": 0.12, "color": Color(1.0, 0.55, 0.32, 1.0)}, "contact-1", "table_contact", "probe")
	_check("real plugin starts first bridge-owned color output", not first.is_empty())
	await create_timer(0.04).timeout
	var second := bridge._start_color_output(target, {"duration": 0.24, "color": Color(0.42, 0.92, 0.64, 1.0)}, "score-2", "score_mastery", "probe")
	_check("rapid mixed event replaces same-target generation", not second.is_empty() and int(second.get("generation", 0)) > int(first.get("generation", 0)))
	await create_timer(0.04).timeout
	var third := bridge._start_color_output(target, {"duration": 0.20, "color": Color(0.82, 0.58, 0.94, 1.0)}, "merge-3", "merge", "probe")
	_check("rapid merge replaces the score generation on the same target", not third.is_empty() and int(third.get("generation", 0)) > int(second.get("generation", 0)))
	await create_timer(0.08).timeout
	_check("stale first completion cannot restore over the newer tint", target.modulate != initial and bridge._active_color_outputs.has(target.get_instance_id()))
	await create_timer(0.18).timeout
	_check("replacement chain restores exact original CanvasItem.modulate", target.modulate == initial)
	_scenarios.append({"scenario": "rapid_contact_score_merge_replacement", "initial": initial, "final": target.modulate, "exact": target.modulate == initial, "events": ["contact-1", "score-2", "merge-3"]})

	var left := _new_target(Color(0.21, 0.44, 0.73, 0.63))
	var right := _new_target(Color(0.83, 0.31, 0.49, 0.88))
	var left_initial: Color = left.modulate
	var right_initial: Color = right.modulate
	bridge._start_color_output(left, {"duration": 0.16, "color": Color(0.99, 0.70, 0.34, 1.0)}, "merge-base", "merge", "probe")
	await create_timer(0.03).timeout
	bridge._start_color_output(right, {"duration": 0.22, "color": Color(0.28, 0.76, 0.97, 1.0)}, "score-concurrent", "score_mastery", "probe")
	await create_timer(0.24).timeout
	_check("concurrent targets restore their independent exact base colors", left.modulate == left_initial and right.modulate == right_initial)
	_scenarios.append({"scenario": "concurrent_targets", "left_initial": left_initial, "left_final": left.modulate, "left_exact": left.modulate == left_initial, "right_initial": right_initial, "right_final": right.modulate, "right_exact": right.modulate == right_initial})

	var cancelled := _new_target(Color(0.54, 0.41, 0.79, 0.91))
	var cancel_initial: Color = cancelled.modulate
	bridge._start_color_output(cancelled, {"duration": 0.5, "color": Color(1.0, 0.72, 0.28, 1.0)}, "retry-before-view-change", "table_contact", "probe")
	_check("view change cancels in-flight output", bridge.set_presentation_mode("REDUCED") and cancelled.modulate == cancel_initial)
	_scenarios.append({"scenario": "view_change_cancel", "initial": cancel_initial, "final": cancelled.modulate, "exact": cancelled.modulate == cancel_initial})
	bridge.set_presentation_mode("FULL")

	var exiting := _new_target(Color(0.26, 0.67, 0.45, 0.82))
	var exit_initial: Color = exiting.modulate
	bridge._start_color_output(exiting, {"duration": 0.5, "color": Color(0.95, 0.45, 0.23, 1.0)}, "target-exit", "merge", "probe")
	root.remove_child(exiting)
	_check("target tree exit restores before detachment", exiting.modulate == exit_initial)
	_scenarios.append({"scenario": "target_exit", "initial": exit_initial, "final": exiting.modulate, "exact": exiting.modulate == exit_initial})

	var teardown_target := _new_target(Color(0.62, 0.29, 0.71, 0.77))
	var teardown_initial: Color = teardown_target.modulate
	bridge._start_color_output(teardown_target, {"duration": 0.5, "color": Color(0.96, 0.84, 0.30, 1.0)}, "scene-teardown", "score_mastery", "probe")
	root.remove_child(bridge)
	_check("bridge teardown restores active targets", teardown_target.modulate == teardown_initial)
	_scenarios.append({"scenario": "bridge_teardown", "initial": teardown_initial, "final": teardown_target.modulate, "exact": teardown_target.modulate == teardown_initial})
	root.add_child(bridge)
	bridge.configure(null, root)

	var failing := FailingPlugin.new()
	_failing_plugin = failing
	bridge._contract.refresh_with_nodes(failing, root.get_node_or_null("Spark"))
	var failed_target := _new_target(Color(0.18, 0.59, 0.77, 0.68))
	var failed_initial: Color = failed_target.modulate
	var failure_result := bridge._start_color_output(failed_target, {"duration": 0.2, "color": Color(1.0, 0.2, 0.1, 1.0)}, "plugin-failure", "table_contact", "probe")
	await process_frame
	await process_frame
	_check("plugin failure restores a target it mutated before returning failure", failure_result.is_empty() and failing.calls == 1 and failed_target.modulate == failed_initial and not bridge._active_color_outputs.has(failed_target.get_instance_id()))
	_scenarios.append({"scenario": "plugin_failure_after_mutation", "initial": failed_initial, "final": failed_target.modulate, "exact": failed_target.modulate == failed_initial})

	var lifecycle := bridge.get_color_lifecycle_diagnostics()
	var all_restored := true
	for record in lifecycle:
		if str(record.get("operation", "")) == "restored" and not bool(record.get("restored_exactly", false)):
			all_restored = false
	_check("all emitted restoration diagnostics report exact Color equality", all_restored)
	var result := {
		"probe": "BCM-M23-R03-color-restoration",
		"checks": _checks,
		"failures": _failures,
		"scenarios": _scenarios,
		"lifecycle_records": lifecycle,
		"restoration_equality": "exact Color ==",
		"renderer_visual_acceptance": "not claimed by headless probe",
	}
	# The failure stub is deliberately detached from the scene tree, so the
	# contract must stop retaining it and the probe must explicitly free it.
	bridge._contract.refresh_with_nodes(plugin, root.get_node_or_null("Spark"))
	if is_instance_valid(_failing_plugin):
		_failing_plugin.free()
	_failing_plugin = null
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("lifecycle evidence path is writable")
	else:
		file.store_string(JSON.stringify(result, "\t") + "\n")
		file.close()
	_finish()


func _new_target(initial: Color) -> VisualTarget:
	var target := VisualTarget.new()
	target.add_to_group("m22_test_presentation_target")
	target.modulate = initial
	root.add_child(target)
	_targets.append(target)
	return target


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)


func _finish() -> void:
	print("M23_R03_COLOR_RESTORATION_RESULT=%s checks=%d failures=%d scenarios=%d" % ["PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), _scenarios.size()])
	for failure in _failures:
		push_error(failure)
	for target in _targets:
		if is_instance_valid(target):
			target.queue_free()
	if is_instance_valid(_bridge):
		_bridge.queue_free()
	if is_instance_valid(_manager):
		_manager.queue_free()
	if is_instance_valid(_plugin) and _plugin.has_method("stop_all"):
		_plugin.call("stop_all")
	call_deferred("_quit_after_cleanup")


func _quit_after_cleanup() -> void:
	await process_frame
	await create_timer(0.8, true, false, true).timeout
	quit(0 if _failures.is_empty() else 1)
