class_name PresentationFeedbackBridge
extends Node

## Sole plugin-call boundary. M22 keeps normal production dispatch disabled;
## only isolated fixture requests can execute the plugin calls below.

const CONTRACT_SCRIPT := preload("res://scripts/presentation_plugin_contract.gd")
const MAX_DIAGNOSTICS := 16
const FIXTURE_TARGET_GROUP := "m22_test_presentation_target"
const SAFE_SPARK_OPTIONS := ["amount", "lifetime", "speed", "speed_min", "lifetime_rand", "size", "size_end", "gravity", "damping", "spread", "direction", "color", "color2"]

var _contract: PresentationPluginContract
var _feedback_service: Node
var _production_dispatch_enabled := false
var _diagnostics: Array[String] = []
var dispatch_count := 0
var no_op_count := 0


func configure(feedback_service: Node, capability_root: Node) -> void:
	_disconnect_feedback_service()
	_feedback_service = feedback_service if is_instance_valid(feedback_service) else null
	_contract = CONTRACT_SCRIPT.new()
	_contract.refresh_from_tree(capability_root)
	if is_instance_valid(_feedback_service) and _feedback_service.has_signal("semantic_requested"):
		var callback := Callable(self, "_on_semantic_requested")
		if not _feedback_service.semantic_requested.is_connected(callback):
			_feedback_service.semantic_requested.connect(callback)


func refresh_capabilities(capability_root: Node) -> Dictionary:
	if _contract == null:
		_contract = CONTRACT_SCRIPT.new()
	return _contract.refresh_from_tree(capability_root)


func get_listener_count() -> int:
	if not is_instance_valid(_feedback_service) or not _feedback_service.has_signal("semantic_requested"):
		return 0
	return _feedback_service.semantic_requested.get_connections().size()


func get_diagnostics() -> Array[String]:
	return _diagnostics.duplicate(true)


func dispatch_fixture_request(
	request: Dictionary,
	target: Node,
	plan: Dictionary,
	gff_fixture: Node,
	spark_fixture: Node
) -> bool:
	if not is_instance_valid(target) or not target.is_in_group(FIXTURE_TARGET_GROUP):
		return _no_op("fixture_target_not_allowlisted")
	if _contract == null:
		_contract = CONTRACT_SCRIPT.new()
	_contract.refresh_with_nodes(gff_fixture, spark_fixture)
	return _dispatch_plan(request.duplicate(true), target, plan.duplicate(true), true)


func _exit_tree() -> void:
	_disconnect_feedback_service()
	if _contract != null:
		_contract.refresh_with_nodes(null, null)


func _disconnect_feedback_service() -> void:
	if is_instance_valid(_feedback_service) and _feedback_service.has_signal("semantic_requested"):
		var callback := Callable(self, "_on_semantic_requested")
		if _feedback_service.semantic_requested.is_connected(callback):
			_feedback_service.semantic_requested.disconnect(callback)
	_feedback_service = null


func _on_semantic_requested(request: Dictionary) -> void:
	if not _production_dispatch_enabled:
		return
	# Policy authority is introduced in M22-003. Until then, an absent explicit
	# plan is a safe no-op; M22 does not activate gameplay visuals.
	_no_op("production_dispatch_disabled")


func _dispatch_plan(request: Dictionary, target: Node, plan: Dictionary, fixture: bool) -> bool:
	if not _valid_request(request):
		return _no_op("unknown_semantic_kind")
	if not _is_presentation_target(target, fixture):
		return _no_op("target_not_allowlisted")
	var effect_name := str(plan.get("gff_effect", ""))
	var spark_preset := str(plan.get("spark_preset", ""))
	var has_effect := not effect_name.is_empty()
	var has_spark := not spark_preset.is_empty()
	if not has_effect and not has_spark:
		return _no_op("unknown_mapping")
	if has_effect and (_contract == null or not _contract.has_game_feel_flow_effect(effect_name)):
		return _no_op("gff_effect_unavailable:%s" % effect_name)
	var spark_options: Dictionary = {}
	if has_spark:
		if _contract == null or not _contract.has_spark_preset(spark_preset):
			return _no_op("spark_preset_unavailable:%s" % spark_preset)
		spark_options = _build_spark_options(spark_preset, plan.get("spark_overrides", {}))
		if spark_options.is_empty():
			return _no_op("spark_overrides_invalid")
	# Preflight all requested components before invoking either plugin.
	if has_effect:
		var result: Variant = _contract.game_feel_flow.callv("play", [effect_name, target])
		if result is bool and not result:
			return _no_op("gff_call_failed")
	if has_spark:
		var position := _target_global_position(target)
		var result: Variant = _contract.spark.callv("burst", [position, spark_options])
		if result is bool and not result:
			return _no_op("spark_call_failed")
	dispatch_count += 1
	return true


func _build_spark_options(preset_name: String, overrides_value: Variant) -> Dictionary:
	if not overrides_value is Dictionary or _contract == null or not _contract.has_spark():
		return {}
	var preset_table: Variant = _contract.spark.get("presets")
	var base: Variant = _contract.spark.get("base")
	if not preset_table is Dictionary or not base is Dictionary:
		return {}
	var merged: Dictionary = base.duplicate(true)
	var preset: Variant = preset_table.get(preset_name, null)
	if not preset is Dictionary:
		return {}
	for key in preset:
		merged[key] = preset[key]
	for key in overrides_value:
		if not SAFE_SPARK_OPTIONS.has(str(key)):
			return {}
		merged[key] = overrides_value[key]
	for required in ["amount", "lifetime", "speed"]:
		if not overrides_value.has(required):
			return {}
	var amount_value: Variant = merged.get("amount", -1)
	var lifetime_value: Variant = merged.get("lifetime", -1.0)
	var speed_value: Variant = merged.get("speed", -1.0)
	if not _is_finite_number(amount_value) or not is_equal_approx(float(amount_value), float(int(amount_value))) or int(amount_value) < 0 or int(amount_value) > 72:
		return {}
	if not _is_finite_number(lifetime_value) or float(lifetime_value) < 0.0 or float(lifetime_value) > 1.6:
		return {}
	if not _is_finite_number(speed_value) or float(speed_value) < 0.0 or float(speed_value) > 120.0:
		return {}
	return merged


func _valid_request(request: Dictionary) -> bool:
	return FeedbackService.SEMANTIC_KINDS.has(str(request.get("kind", "")))


func _is_presentation_target(target: Node, fixture: bool) -> bool:
	if not is_instance_valid(target):
		return false
	if fixture:
		return target.is_in_group(FIXTURE_TARGET_GROUP) and not target is CollisionObject2D and not target is Camera2D
	return target.is_in_group("presentation_effect_target") and not target is CollisionObject2D and not target is Camera2D


func _target_global_position(target: Node) -> Vector2:
	if target is Node2D:
		return (target as Node2D).global_position
	if target is Control:
		return (target as Control).global_position
	return Vector2.ZERO


func _is_finite_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))


func _no_op(reason: String) -> bool:
	no_op_count += 1
	if _diagnostics.size() < MAX_DIAGNOSTICS:
		_diagnostics.append(reason)
	return false
