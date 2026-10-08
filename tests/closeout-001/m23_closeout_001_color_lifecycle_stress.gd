extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BRIDGE_SCRIPT := preload("res://scripts/presentation_feedback_bridge.gd")
const TARGET_COUNT := 64

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager := MAIN_SCENE.instantiate()
	root.add_child(manager)
	current_scene = manager
	await process_frame
	await process_frame
	var plugin := root.get_node_or_null("GameFeelFlow")
	var bridge := BRIDGE_SCRIPT.new()
	root.add_child(bridge)
	bridge.configure(null, root)
	bridge._contract.refresh_with_nodes(plugin, root.get_node_or_null("Spark"))
	var targets: Array[Node2D] = []
	var original_colors: Array[Color] = []
	for index in range(TARGET_COUNT):
		var target := Node2D.new()
		target.modulate = Color(0.12 + float(index % 7) * 0.09, 0.18 + float(index % 5) * 0.11, 0.22 + float(index % 9) * 0.07, 0.55 + float(index % 4) * 0.1)
		root.add_child(target)
		targets.append(target)
		original_colors.append(target.modulate)
		bridge._start_color_output(target, {"duration": 1.0, "color": Color(0.96, 0.68, 0.29, 1.0)}, "stress-%d" % index, "merge", "closeout-stress")
	bridge.cancel_presentation()
	var restored_count := 0
	for index in range(targets.size()):
		if is_instance_valid(targets[index]) and targets[index].modulate == original_colors[index]:
			restored_count += 1
		else:
			_failures.append("target %d did not restore exact source modulation" % index)
	_check("all stress targets restore and clear active outputs", restored_count == TARGET_COUNT and bridge._active_color_outputs.is_empty())
	for target in targets:
		if is_instance_valid(target):
			root.remove_child(target)
			target.free()
	root.remove_child(bridge)
	bridge.free()
	if is_instance_valid(plugin) and plugin.has_method("stop_all"):
		plugin.call("stop_all")
	manager.queue_free()
	await process_frame
	await process_frame
	print("M23_CLOSEOUT_STRESS_RESULT=%s targets=%d restored=%d active=%d" % ["PASS" if _failures.is_empty() else "FAIL", TARGET_COUNT, restored_count, 0])
	for failure in _failures:
		push_error(failure)
	quit(0 if _failures.is_empty() else 1)


func _check(label: String, condition: bool) -> void:
	if not condition:
		_failures.append(label)
