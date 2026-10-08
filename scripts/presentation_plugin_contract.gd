class_name PresentationPluginContract
extends RefCounted

## Optional, cached capability view over the installed presentation plugins.
## This class inspects APIs only; it never dispatches an effect.

const GFF_REQUIRED_METHODS := [
	"play", "play_combo", "play_global", "stop", "stop_all",
	"get_effect", "get_combo", "resolve_combo", "get_effect_names", "get_combo_names",
]
const SPARK_REQUIRED_METHODS := ["burst", "at", "clear"]

var game_feel_flow: Node
var spark: Node
var game_feel_flow_methods: Dictionary = {}
var spark_methods: Dictionary = {}
var generation := 0


func refresh_from_tree(root: Node) -> Dictionary:
	if not is_instance_valid(root):
		return refresh_with_nodes(null, null)
	return refresh_with_nodes(
		root.get_node_or_null("GameFeelFlow"),
		root.get_node_or_null("Spark")
	)


func refresh_with_nodes(gff_node: Variant, spark_node: Variant) -> Dictionary:
	game_feel_flow = gff_node as Node if gff_node is Node and is_instance_valid(gff_node) else null
	spark = spark_node as Node if spark_node is Node and is_instance_valid(spark_node) else null
	game_feel_flow_methods = _method_snapshot(game_feel_flow, GFF_REQUIRED_METHODS)
	spark_methods = _method_snapshot(spark, SPARK_REQUIRED_METHODS)
	generation += 1
	return snapshot()


func snapshot() -> Dictionary:
	return {
		"generation": generation,
		"game_feel_flow_present": is_instance_valid(game_feel_flow),
		"spark_present": is_instance_valid(spark),
		"game_feel_flow_methods": game_feel_flow_methods.duplicate(true),
		"spark_methods": spark_methods.duplicate(true),
		"game_feel_flow_ready": _all_present(game_feel_flow_methods),
		"spark_ready": _all_present(spark_methods),
	}


func has_game_feel_flow() -> bool:
	return is_instance_valid(game_feel_flow) and _all_present(game_feel_flow_methods)


func has_spark() -> bool:
	return is_instance_valid(spark) and _all_present(spark_methods)


func has_game_feel_flow_effect(effect_name: String) -> bool:
	if not has_game_feel_flow() or effect_name.is_empty():
		return false
	var names: Variant = game_feel_flow.call("get_effect_names")
	return names is Array and names.has(effect_name)


func has_game_feel_flow_combo(combo_name: String) -> bool:
	if not has_game_feel_flow() or combo_name.is_empty():
		return false
	var names: Variant = game_feel_flow.call("get_combo_names")
	return names is Array and names.has(combo_name)


func has_spark_preset(preset_name: String) -> bool:
	if not has_spark() or preset_name.is_empty() or not _has_property(spark, "presets"):
		return false
	var presets: Variant = spark.get("presets")
	return presets is Dictionary and presets.has(preset_name)


static func _method_snapshot(candidate: Node, methods: Array) -> Dictionary:
	var result: Dictionary = {}
	for method_name in methods:
		result[method_name] = is_instance_valid(candidate) and candidate.has_method(method_name)
	return result


static func _all_present(methods: Dictionary) -> bool:
	if methods.is_empty():
		return false
	for method_name in methods:
		if not bool(methods[method_name]):
			return false
	return true


static func _has_property(candidate: Object, property_name: String) -> bool:
	if not is_instance_valid(candidate):
		return false
	for property_info in candidate.get_property_list():
		if str(property_info.get("name", "")) == property_name:
			return true
	return false
