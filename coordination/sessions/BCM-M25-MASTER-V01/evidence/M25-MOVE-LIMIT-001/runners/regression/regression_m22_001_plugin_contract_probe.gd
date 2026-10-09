extends SceneTree

const CONTRACT_SCRIPT := preload("res://scripts/presentation_plugin_contract.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-LIMIT-001/regression/m22_001/plugin_runtime_inventory.json"

var _checks := 0
var _failures: Array[String] = []


class PartialGFF:
	extends Node

	func get_effect_names() -> Array[String]:
		return []


class PartialSpark:
	extends Node

	var presets := {"spark": {}}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var contract = CONTRACT_SCRIPT.new()
	var navigation = NAVIGATION_SCENE.instantiate()
	root.add_child(navigation)
	await process_frame
	await process_frame
	var baseline_hash := _authority_fingerprint(navigation)
	_check("production campaign startup authority is ready", navigation.campaign_manager != null and navigation.economy != null)

	var gff := root.get_node_or_null("GameFeelFlow")
	var spark := root.get_node_or_null("Spark")
	var present := contract.refresh_with_nodes(gff, spark)
	_check("both installed plugins leave production startup state unchanged", _authority_fingerprint(navigation) == baseline_hash)
	_check("installed GameFeelFlow singleton resolves", present.game_feel_flow_present)
	_check("installed Spark singleton resolves", present.spark_present)
	_check("installed GameFeelFlow API is complete", present.game_feel_flow_ready)
	_check("installed Spark API is complete", present.spark_ready)
	_check("unknown GFF effect is unavailable", not contract.has_game_feel_flow_effect("m22_unknown_effect"))
	_check("unknown GFF combo is unavailable", not contract.has_game_feel_flow_combo("m22_unknown_combo"))
	_check("unknown Spark preset is unavailable", not contract.has_spark_preset("m22_unknown_preset"))
	_check("known Spark preset is inspectable", contract.has_spark_preset("spark"))

	var absent_gff := contract.refresh_with_nodes(null, spark)
	_check("GFF absence is represented as unavailable", not absent_gff.game_feel_flow_ready)
	_check("GFF absence leaves production startup state unchanged", _authority_fingerprint(navigation) == baseline_hash)
	var absent_spark := contract.refresh_with_nodes(gff, null)
	_check("Spark absence is represented as unavailable", not absent_spark.spark_ready)
	_check("Spark absence leaves production startup state unchanged", _authority_fingerprint(navigation) == baseline_hash)
	var both_absent := contract.refresh_with_nodes(null, null)
	_check("both plugin singletons absent is safe", not both_absent.game_feel_flow_ready and not both_absent.spark_ready)
	_check("both absent leaves production startup state unchanged", _authority_fingerprint(navigation) == baseline_hash)

	var partial_gff := PartialGFF.new()
	var partial_spark := PartialSpark.new()
	root.add_child(partial_gff)
	root.add_child(partial_spark)
	var partial := contract.refresh_with_nodes(partial_gff, partial_spark)
	_check("partial GFF API is rejected", not partial.game_feel_flow_ready)
	_check("partial Spark API is rejected", not partial.spark_ready)
	_check("partial APIs leave production startup state unchanged", _authority_fingerprint(navigation) == baseline_hash)
	_check("partial Spark preset lookup still fails closed", not contract.has_spark_preset("explode"))
	_check("capability result contains no gameplay authority fields", not partial.has("score") and not partial.has("progression"))
	_write_runtime_inventory(gff, spark, baseline_hash)

	partial_gff.free()
	partial_spark.free()
	navigation.queue_free()
	print("M22_001_PLUGIN_CONTRACT_RESULT=%s checks=%d failures=%d authority_hash=%d" % [
		"PASS" if _failures.is_empty() else "FAIL", _checks, _failures.size(), baseline_hash
	])
	for failure in _failures:
		push_error(failure)
	quit(0 if _failures.is_empty() else 1)


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures.append(label)


func _write_runtime_inventory(gff: Node, spark: Node, authority_hash: int) -> void:
	var effects: Array = gff.call("get_effect_names") if is_instance_valid(gff) else []
	var combo_names: Array = gff.call("get_combo_names") if is_instance_valid(gff) else []
	var combos: Dictionary = {}
	for combo_name in combo_names:
		var combo: Object = gff.call("resolve_combo", combo_name)
		var entries: Array = []
		for entry in combo.get("entries"):
			var effect: Object = entry.get("effect")
			var target: Object = effect.get("target") if effect != null and _has_property(effect, "target") else null
			entries.append({
				"effect_class": effect.get_class() if effect != null else "null",
				"effect_script": effect.get_script().resource_path if effect != null and effect.get_script() != null else "",
				"target_class": target.get_class() if target != null else "",
				"target_script": target.get_script().resource_path if target != null and target.get_script() != null else "",
				"start_time": entry.get("start_time"),
				"duration": entry.get("duration"),
			})
		combos[str(combo_name)] = entries
	var spark_base: Dictionary = spark.get("base") if is_instance_valid(spark) else {}
	var spark_presets: Dictionary = spark.get("presets") if is_instance_valid(spark) else {}
	var merged_presets: Dictionary = {}
	for preset_name in spark_presets:
		var merged := spark_base.duplicate(true)
		var preset: Dictionary = spark_presets[preset_name]
		for key in preset:
			merged[key] = preset[key]
		merged_presets[str(preset_name)] = {
			"amount": merged.get("amount"),
			"speed": merged.get("speed"),
			"lifetime": merged.get("lifetime"),
			"lifetime_rand": merged.get("lifetime_rand"),
			"speed_min": merged.get("speed_min"),
		}
	var inventory := {
		"gff": {"registered_effect_count": effects.size(), "registered_effects": effects, "registered_combo_count": combo_names.size(), "combos": combos},
		"spark": {"base": {"amount": spark_base.get("amount"), "speed": spark_base.get("speed"), "lifetime": spark_base.get("lifetime"), "lifetime_rand": spark_base.get("lifetime_rand")}, "preset_overrides": merged_presets},
		"consumer_fallback_probe": {"checks": _checks, "failures": _failures, "authority_fingerprint": authority_hash},
	}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write M22-001 runtime inventory: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(inventory, "\t") + "\n")
	file.close()


func _has_property(candidate: Object, property_name: String) -> bool:
	for property_info in candidate.get_property_list():
		if str(property_info.get("name", "")) == property_name:
			return true
	return false


func _authority_fingerprint(navigation: Node) -> int:
	var manager = navigation.get("campaign_manager")
	var economy = navigation.get("economy")
	var state := {
		"campaign": manager.get_progression_state() if manager != null else {},
		"economy": economy.get_ledger_state() if economy != null else {},
		"view": navigation.get("current_view"),
		"active_island": navigation.get("active_island_id"),
		"gameplay_instances": navigation.get_gameplay_instance_count(),
	}
	return hash(JSON.stringify(state))

