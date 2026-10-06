extends SceneTree

## BCM-M21-002 bounded production-shell performance/stability profile.
## This is a host measurement, not a physical-device benchmark.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const SETTINGS_SCRIPT := preload("res://scripts/campaign/user_settings.gd")
const REPORT_DIR := "res://coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/performance"
const PROFILE_SAVE_PATH := "user://m21_child02_profile_campaign.json"
const PROFILE_SETTINGS_PATH := "user://m21_child02_profile_settings.json"
const MAP_CYCLES := 12
const GAMEPLAY_CYCLES := 8
const IO_CYCLES := 20

var failures: Array[String] = []
var samples: Array[Dictionary] = []
var frame_samples_ms: Array[float] = []
var shell
var navigation
var campaign
var database


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_CHILD_02_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_CHILD_02_PROBE FAIL: %s" % label)


func _frame(count: int = 2) -> void:
	for _index in range(count):
		await process_frame


func _sample(label: String) -> void:
	var world = navigation.get_world_map() if navigation != null else null
	var island_map = navigation.get_island_map() if navigation != null else null
	var object_count := int(Performance.get_monitor(Performance.OBJECT_COUNT))
	var orphan_count := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	var sample := {
		"label": label,
		"world_map_nodes": world.get_map_node_count() if world != null else 0,
		"world_map_entries": world.get_entry_count() if world != null else 0,
		"island_map_level_buttons": island_map.get_level_button_count() if island_map != null else 0,
		"map_instance_count": navigation.get_map_instance_count() if navigation != null else 0,
		"gameplay_instance_count": navigation.get_gameplay_instance_count() if navigation != null else 0,
		"object_count": object_count,
		"orphan_node_count": orphan_count,
	}
	samples.append(sample)
	print("M21_CHILD_02_SAMPLE %s" % JSON.stringify(sample))


func _fresh_campaign() -> void:
	database = DATABASE_SCRIPT.new()
	_check("canonical campaign data loads", database.load_canonical())
	campaign = CAMPAIGN_SCRIPT.new()
	_check("fresh campaign fixture configures", campaign.configure(database, SAVE_SCRIPT.new().create_default_state()))


func _mount_shell() -> void:
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m21_child02_onboarding_profile.json"
	shell.settings_storage_path = PROFILE_SETTINGS_PATH
	root.add_child(shell)
	await _frame(4)
	_fresh_campaign()
	navigation = shell.get_campaign_navigation()
	_check("production navigation accepts profiling campaign", navigation.configure_campaign(database, campaign))
	await _frame(4)
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	await _frame(2)
	_check("production PLAY path opens the current frontier gameplay", shell.press_play_continue() and navigation.get_current_view() == navigation.VIEW_GAMEPLAY)
	_check("World Map profiling starts through the production router", navigation.show_world_map() and navigation.get_current_view() == navigation.VIEW_WORLD_MAP)
	await _frame(4)
	_sample("warmup_world_map")


func _profile_map_cycles() -> void:
	var world = navigation.get_world_map()
	_check("World Map node count is bounded at warmup", world.get_map_node_count() == world.get_entry_count())
	for cycle in range(MAP_CYCLES):
		var sunny_entry = world._entries.get("sunny_cove")
		_check("map cycle %d opens Sunny Cove" % (cycle + 1), sunny_entry != null)
		if sunny_entry != null:
			sunny_entry.pressed.emit()
		await _frame(3)
		var island_map = navigation.get_island_map()
		island_map.set_scroll_vertical(999999)
		await _frame()
		_check("map cycle %d keeps 100 level buttons" % (cycle + 1), island_map.get_level_button_count() == 100)
		_check("map cycle %d remains vertically scrollable" % (cycle + 1), island_map.get_scroll_vertical() > 0)
		navigation.show_world_map()
		await _frame(3)
		_sample("map_cycle_%02d" % (cycle + 1))
	_check("map node count remains bounded", world.get_map_node_count() == world.get_entry_count())
	_check("map instance authority remains singular", navigation.get_map_instance_count() == 2)


func _profile_gameplay_cycles() -> void:
	var world = navigation.get_world_map()
	for cycle in range(GAMEPLAY_CYCLES):
		world._entries["sunny_cove"].pressed.emit()
		await _frame(3)
		var island_map = navigation.get_island_map()
		island_map.get_level_button(1).pressed.emit()
		await _frame(5)
		_check("gameplay cycle %d has one active instance" % (cycle + 1), navigation.get_gameplay_instance_count() == 1)
		var bridge = navigation.get_session_bridge()
		bridge.resolve_lose("M21_CHILD_02_PROFILE_%d" % cycle)
		await _frame(2)
		_check("gameplay cycle %d reaches one result overlay" % (cycle + 1), navigation.get_result_feedback_overlay().visible)
		_check("gameplay cycle %d returns through production result action" % (cycle + 1), navigation.get_result_feedback_overlay().trigger_action("ISLAND_MAP"))
		await _frame(4)
		_check("gameplay cycle %d disposes gameplay instance" % (cycle + 1), navigation.get_gameplay_instance_count() == 0)
		_sample("gameplay_cycle_%02d" % (cycle + 1))


func _profile_io() -> Dictionary:
	var save_manager = SAVE_SCRIPT.new()
	var state: Dictionary = save_manager.create_default_state()
	var save_write_us: Array[int] = []
	var save_read_us: Array[int] = []
	var save_sizes: Array[int] = []
	for cycle in range(IO_CYCLES):
		var write_start := Time.get_ticks_usec()
		var write_result: Dictionary = save_manager.write_state(state, PROFILE_SAVE_PATH)
		var write_elapsed := Time.get_ticks_usec() - write_start
		var read_start := Time.get_ticks_usec()
		var read_result: Dictionary = save_manager.read_state(PROFILE_SAVE_PATH)
		var read_elapsed := Time.get_ticks_usec() - read_start
		var serialized := save_manager.encode_state(state)
		save_write_us.append(write_elapsed)
		save_read_us.append(read_elapsed)
		save_sizes.append(serialized.to_utf8_buffer().size())
		_check("save IO cycle %d writes valid state" % (cycle + 1), bool(write_result.get("ok", false)))
		_check("save IO cycle %d reads valid state" % (cycle + 1), bool(read_result.get("ok", false)))

	var settings = SETTINGS_SCRIPT.new()
	var settings_write_us: Array[int] = []
	var settings_read_us: Array[int] = []
	for cycle in range(IO_CYCLES):
		settings.load_settings(PROFILE_SETTINGS_PATH)
		var write_start := Time.get_ticks_usec()
		var write_ok: bool = settings.set_value("reduced_motion", cycle % 2 == 0, false) and settings.save_settings(PROFILE_SETTINGS_PATH)
		var write_elapsed := Time.get_ticks_usec() - write_start
		var read_start := Time.get_ticks_usec()
		var loaded: Dictionary = settings.load_settings(PROFILE_SETTINGS_PATH)
		var read_elapsed := Time.get_ticks_usec() - read_start
		settings_write_us.append(write_elapsed)
		settings_read_us.append(read_elapsed)
		_check("settings IO cycle %d writes" % (cycle + 1), write_ok)
		_check("settings IO cycle %d reads" % (cycle + 1), int(loaded.get("schema_version", -1)) == SETTINGS_SCRIPT.SCHEMA_VERSION)

	var onboarding_write_us: Array[int] = []
	var onboarding_read_us: Array[int] = []
	var onboarding_path := "user://m21_child02_onboarding_io.json"
	for _cycle in range(IO_CYCLES):
		var write_start := Time.get_ticks_usec()
		var write_file := FileAccess.open(onboarding_path, FileAccess.WRITE)
		write_file.store_string(JSON.stringify({"schema_version": 1, "completed": true}))
		write_file.close()
		onboarding_write_us.append(Time.get_ticks_usec() - write_start)
		var read_start := Time.get_ticks_usec()
		var read_file := FileAccess.open(onboarding_path, FileAccess.READ)
		var onboarding_state = JSON.parse_string(read_file.get_as_text())
		read_file.close()
		onboarding_read_us.append(Time.get_ticks_usec() - read_start)
		_check("onboarding IO cycle %d reads completed state" % (_cycle + 1), onboarding_state is Dictionary and bool(onboarding_state.get("completed", false)))

	return {
		"save": {"write_us": save_write_us, "read_us": save_read_us, "payload_bytes": save_sizes},
		"settings": {"write_us": settings_write_us, "read_us": settings_read_us},
		"onboarding": {"write_us": onboarding_write_us, "read_us": onboarding_read_us},
	}


func _profile_frames() -> Dictionary:
	for _sample_index in range(60):
		var start := Time.get_ticks_usec()
		await process_frame
		frame_samples_ms.append(float(Time.get_ticks_usec() - start) / 1000.0)
	var total := 0.0
	for value in frame_samples_ms:
		total += value
	var sorted := frame_samples_ms.duplicate()
	sorted.sort()
	return {
		"sample_count": frame_samples_ms.size(),
		"min_ms": sorted.front() if not sorted.is_empty() else 0.0,
		"median_ms": sorted[sorted.size() / 2] if not sorted.is_empty() else 0.0,
		"max_ms": sorted.back() if not sorted.is_empty() else 0.0,
		"average_ms": total / frame_samples_ms.size() if not frame_samples_ms.is_empty() else 0.0,
	}


func _range_summary(values: Array) -> Dictionary:
	var numbers: Array[float] = []
	for value in values:
		numbers.append(float(value))
	if numbers.is_empty():
		return {"count": 0, "min": 0.0, "max": 0.0, "average": 0.0}
	numbers.sort()
	var total := 0.0
	for value in numbers:
		total += value
	return {"count": numbers.size(), "min": numbers.front(), "max": numbers.back(), "average": total / numbers.size()}


func _write_report(io_report: Dictionary, frame_report: Dictionary) -> void:
	var object_values: Array = []
	var orphan_values: Array = []
	for sample in samples:
		object_values.append(sample.get("object_count", 0))
		orphan_values.append(sample.get("orphan_node_count", 0))
	var report := {
		"work_item": "BCM-M21-002",
		"environment": {
			"godot": Engine.get_version_info(),
			"renderer": "GL Compatibility",
			"host": "Windows desktop / Intel Iris Xe",
			"physical_device": false,
		},
		"cycle_counts": {"map": MAP_CYCLES, "gameplay": GAMEPLAY_CYCLES, "io": IO_CYCLES},
		"samples": samples,
		"object_count_summary": _range_summary(object_values),
		"orphan_node_count_summary": _range_summary(orphan_values),
		"io": io_report,
		"frame_time_ms": frame_report,
		"checks_failed": failures,
		"physical_device_performance": "UNVERIFIED_OWNER_NATIVE_GATE",
	}
	var file := FileAccess.open("%s/M21-002_PERFORMANCE_STABILITY_PROFILE.json" % REPORT_DIR, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()


func _finish() -> void:
	if failures.is_empty():
		print("M21_CHILD_02_RESULT=PASS samples=%d frame_samples=%d" % [samples.size(), frame_samples_ms.size()])
		quit(0)
		return
	print("M21_CHILD_02_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REPORT_DIR))
	await _mount_shell()
	await _profile_map_cycles()
	await _profile_gameplay_cycles()
	var io_report: Dictionary = _profile_io()
	var frame_report: Dictionary = await _profile_frames()
	_write_report(io_report, frame_report)
	_finish()
