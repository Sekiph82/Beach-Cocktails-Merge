extends Control

## Opt-in owner-real-play sample chooser and local telemetry. This node exists
## only when the in-project R06 launcher sets BCM_M33_OWNER_PLAYTEST.

const SAMPLE_ROWS := [
	{"sample_id": "ENTRY_TIKI", "title": "Tiki Island · generated entry", "island_id": "tiki_island", "level_id": 1, "global_level_id": 101},
	{"sample_id": "ENTRY_AZURE", "title": "Azure Bay · generated entry", "island_id": "azure_bay", "level_id": 1, "global_level_id": 201},
	{"sample_id": "ENTRY_COCONUT", "title": "Coconut Beach · generated entry", "island_id": "coconut_beach", "level_id": 1, "global_level_id": 301},
	{"sample_id": "ENTRY_SUNSET", "title": "Sunset Island · generated entry", "island_id": "sunset_island", "level_id": 1, "global_level_id": 401},
	{"sample_id": "ENTRY_PARTY", "title": "Party Beach · generated entry", "island_id": "party_beach", "level_id": 1, "global_level_id": 501},
	{"sample_id": "ENTRY_FROZEN", "title": "Frozen Paradise · generated entry", "island_id": "frozen_paradise", "level_id": 1, "global_level_id": 601},
	{"sample_id": "ENTRY_VOLCANO", "title": "Volcano Bay · generated entry", "island_id": "volcano_bay", "level_id": 1, "global_level_id": 701},
	{"sample_id": "ENTRY_BILLIONAIRE", "title": "Billionaire Island · generated entry", "island_id": "billionaire_island", "level_id": 1, "global_level_id": 801},
	{"sample_id": "ENTRY_FINAL", "title": "Final Island · generated entry", "island_id": "final_island", "level_id": 1, "global_level_id": 901},
	{"sample_id": "CONTRAST_EMPTY", "title": "Starter contrast · empty tabletop", "island_id": "azure_bay", "level_id": 1, "global_level_id": 201},
	{"sample_id": "CONTRAST_ONE", "title": "Starter contrast · one L6 starter", "island_id": "azure_bay", "level_id": 8, "global_level_id": 208},
	{"sample_id": "CONTRAST_TWO", "title": "Starter contrast · two L5 starters", "island_id": "tiki_island", "level_id": 27, "global_level_id": 127},
	{"sample_id": "OPTIONAL_L9_CAPSTONE", "title": "Optional L9 prestige capstone", "island_id": "final_island", "level_id": 100, "global_level_id": 1000},
]

var navigation
var _selected_sample: Dictionary = {}
var _panel: PanelContainer
var _background: ColorRect
var _preview: Label
var _start_button: Button
var _chooser_button: Button
var _toolbar_layer: CanvasLayer
var _attempt: Dictionary = {}
var _active_sample: Dictionary = {}
var _attempt_number := 0
var _sample_retry_count := 0
var _retry_pending := false
var _run_id := "%d" % Time.get_ticks_usec()
var _run_attempts: Array[Dictionary] = []
var _content_revision := "BCM-M33.5"
var _profile_error := ""


func configure(configured_navigation) -> void:
	navigation = configured_navigation


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if navigation == null or navigation.get_content_load_error() != "":
		_profile_error = "Campaign data did not load: %s" % (navigation.get_content_load_error() if navigation != null else "navigation unavailable")
	_content_revision = _read_content_revision()
	_build_ui()
	if not _profile_is_isolated():
		_profile_error = "PROFILE IS NOT ISOLATED. Close this window and use the R06 launcher."
		_start_button.disabled = true
	if navigation != null:
		navigation.gameplay_session_started.connect(_on_gameplay_started)
		navigation.gameplay_session_finished.connect(_on_gameplay_finished)
		var bridge = navigation.get_session_bridge()
		if is_instance_valid(bridge):
			bridge.normal_delivery_recorded.connect(_on_normal_delivery)
			bridge.vip_state_changed.connect(_on_vip_state_changed)
		var results = navigation.get_result_feedback_overlay()
		if is_instance_valid(results) and results.has_signal("action_requested"):
			results.action_requested.connect(_on_result_action)
	call_deferred("_connect_result_actions")
	_select_sample(SAMPLE_ROWS[0])
	_refresh_profile_message()
	_write_report()


func _profile_is_isolated() -> bool:
	var actual := ProjectSettings.globalize_path("user://").replace("\\", "/").to_lower().trim_suffix("/")
	var expected_root := OS.get_environment("BCM_M33_TEST_PROFILE_ROOT").replace("\\", "/").to_lower().trim_suffix("/")
	var normal_user := OS.get_environment("BCM_M33_NORMAL_USER_DATA").replace("\\", "/").to_lower().trim_suffix("/")
	if expected_root.is_empty() or normal_user.is_empty():
		return false
	return actual.begins_with(expected_root + "/") and actual != normal_user and not actual.begins_with(normal_user + "/")


func _build_ui() -> void:
	_background = ColorRect.new()
	_background.color = Color(0.06, 0.12, 0.16, 0.92)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_background)
	_panel = PanelContainer.new()
	_panel.name = "OwnerPlaytestSampleChooser"
	_panel.anchor_left = 0.04
	_panel.anchor_top = 0.025
	_panel.anchor_right = 0.96
	_panel.anchor_bottom = 0.975
	add_child(_panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	_panel.add_child(outer)
	var heading := Label.new()
	heading.text = "OWNER PLAYTEST · ISOLATED PROFILE"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 26)
	outer.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "Samples use real campaign IDs and the production gameplay scene. Test unlocks and results stay in this separate profile."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 15)
	outer.add_child(subtitle)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 560
	outer.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 4)
	scroll.add_child(rows)
	for sample in SAMPLE_ROWS:
		var button := Button.new()
		button.text = "%s  ·  %s/%d  ·  G%d" % [sample["title"], sample["island_id"], sample["level_id"], sample["global_level_id"]]
		button.custom_minimum_size.y = 38
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select_sample.bind(sample))
		rows.add_child(button)
	_preview = Label.new()
	_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview.custom_minimum_size.y = 112
	_preview.add_theme_font_size_override("font_size", 16)
	outer.add_child(_preview)
	_start_button = Button.new()
	_start_button.text = "START SELECTED SAMPLE IN PRODUCTION GAMEPLAY"
	_start_button.custom_minimum_size.y = 52
	_start_button.pressed.connect(_start_selected_sample)
	outer.add_child(_start_button)
	var controls := Label.new()
	controls.text = "Controls: tap/click the tabletop to launch, same live ShotController as normal play. Tap/click the gameplay Samples button to leave. Retry and result controls use production UI."
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_theme_font_size_override("font_size", 14)
	outer.add_child(controls)
	var profile := Label.new()
	profile.name = "ProfileVerification"
	profile.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile.add_theme_font_size_override("font_size", 12)
	outer.add_child(profile)
	_toolbar_layer = CanvasLayer.new()
	_toolbar_layer.layer = 10
	add_child(_toolbar_layer)
	_chooser_button = Button.new()
	_chooser_button.text = "SAMPLES"
	_chooser_button.position = Vector2(12, 310)
	_chooser_button.custom_minimum_size = Vector2(130, 48)
	_chooser_button.visible = false
	_chooser_button.z_index = 20
	_chooser_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_chooser_button.pressed.connect(_return_to_chooser)
	_toolbar_layer.add_child(_chooser_button)


func _select_sample(sample: Dictionary) -> void:
	_selected_sample = sample.duplicate(true)
	if navigation == null or navigation.level_database == null:
		_preview.text = _profile_error if not _profile_error.is_empty() else "Campaign database unavailable."
		_start_button.disabled = true
		return
	var level: Dictionary = navigation.level_database.get_level(str(sample["island_id"]), int(sample["level_id"]))
	var island: Dictionary = navigation.level_database.get_island(str(sample["island_id"]))
	if level.is_empty() or int(level.get("global_level_id", -1)) != int(sample["global_level_id"]):
		_preview.text = "Sample identity check failed for %s. Launch disabled." % str(sample["sample_id"])
		_start_button.disabled = true
		return
	var orders: Array[String] = []
	for order in level.get("orders", []):
		orders.append("L%d × %d" % [int(order.get("cocktail_level", 0)), int(order.get("quantity", 0))])
	var vip: Variant = level.get("vip", null)
	var vip_text := "none"
	if vip is Dictionary and bool(vip.get("enabled", true)):
		vip_text = "L%d × %d optional" % [int(vip.get("cocktail_level", 0)), int(vip.get("quantity", 0))]
	var starters: Array[String] = []
	for drink in level.get("initial_tabletop_drinks", []):
		starters.append("L%d" % int(drink.get("cocktail_level", 0)))
	var theoretical := int(level.get("theoretical_shots_total", 0))
	var move_limit := int(level.get("move_limit", theoretical * 4))
	var starter_text := "empty" if starters.is_empty() else "%d starter(s): %s" % [starters.size(), ", ".join(starters)]
	_preview.text = "%s · global ID %d\nIsland: %s · Level %d\nTo-Go: %s · VIP: %s\nInitial stock: %s\nPredicted T: %d committed shots · move limit: %d\nContent: %s" % [str(sample["title"]), int(sample["global_level_id"]), str(island.get("display_name", sample["island_id"])), int(sample["level_id"]), ", ".join(orders), vip_text, starter_text, theoretical, move_limit, _content_revision]
	_start_button.disabled = not _profile_error.is_empty()


func _start_selected_sample() -> void:
	if _selected_sample.is_empty() or not _profile_is_isolated():
		return
	_active_sample = _selected_sample.duplicate(true)
	if navigation.launch_owner_playtest_sample(str(_selected_sample["island_id"]), int(_selected_sample["level_id"])):
		_panel.visible = false
		_background.visible = false
		_chooser_button.visible = true
		visible = true
		_sample_retry_count = 0
	else:
		_active_sample.clear()


func _on_gameplay_started(configuration: Dictionary) -> void:
	var island_id := str(configuration.get("island_id", ""))
	var level_id := int(configuration.get("level_id", 0))
	if _active_sample.is_empty() or str(_active_sample.get("island_id", "")) != island_id or int(_active_sample.get("level_id", 0)) != level_id:
		if not _active_sample.is_empty():
			_sample_retry_count = 0
		_active_sample = _sample_for_level(island_id, level_id)
	if _active_sample.is_empty():
		return
	if _retry_pending:
		_sample_retry_count += 1
		_retry_pending = false
		_start_attempt()
	elif _attempt.is_empty():
		_start_attempt()
	var gameplay = navigation.get_node_or_null("CampaignGameplay")
	var shot_controller = gameplay.get("shot_controller") if is_instance_valid(gameplay) else null
	if is_instance_valid(shot_controller) and shot_controller.has_signal("shot_fired") and not shot_controller.shot_fired.is_connected(_on_shot_fired):
		shot_controller.shot_fired.connect(_on_shot_fired)


func _sample_for_level(island_id: String, level_id: int) -> Dictionary:
	for sample in SAMPLE_ROWS:
		if str(sample["island_id"]) == island_id and int(sample["level_id"]) == level_id:
			return sample.duplicate(true)
	if navigation != null and navigation.level_database != null:
		var level: Dictionary = navigation.level_database.get_level(island_id, level_id)
		if not level.is_empty():
			return {
				"sample_id": "PLAYTHROUGH_%s_%d" % [island_id.to_upper(), level_id],
				"title": "Production next-level playthrough",
				"island_id": island_id,
				"level_id": level_id,
				"global_level_id": int(level.get("global_level_id", 0)),
			}
	return {}


func _start_attempt() -> void:
	_attempt_number += 1
	var level: Dictionary = navigation.level_database.get_level(str(_active_sample["island_id"]), int(_active_sample["level_id"]))
	_attempt = {
		"run_id": _run_id,
		"attempt_number": _attempt_number,
		"sample_id": _active_sample["sample_id"],
		"global_level_id": int(_active_sample["global_level_id"]),
		"island_id": _active_sample["island_id"],
		"level_id": int(_active_sample["level_id"]),
		"content_revision": _content_revision,
		"start_monotonic_usec": Time.get_ticks_usec(),
		"end_monotonic_usec": 0,
		"duration_seconds": 0.0,
		"shots": 0,
		"completed_to_go": 0,
		"completed_vip": 0,
		"outcome": "IN_PROGRESS",
		"wins": 0,
		"losses": 0,
		"retry_count": _sample_retry_count,
		"stars": 0,
		"leave_reason": "",
		"starter_inventory": _starter_inventory(level),
	}


func _on_shot_fired(_drink, _velocity: Vector2) -> void:
	if not _attempt.is_empty():
		_attempt["shots"] = int(_attempt.get("shots", 0)) + 1


func _on_normal_delivery(delivery: Dictionary) -> void:
	if not _attempt.is_empty():
		_attempt["completed_to_go"] = int(_attempt.get("completed_to_go", 0)) + int(delivery.get("accepted", 0))


func _on_vip_state_changed(state: Dictionary) -> void:
	if not _attempt.is_empty():
		_attempt["completed_vip"] = int(state.get("delivered", 0))


func _on_gameplay_finished(result: Dictionary) -> void:
	if _attempt.is_empty():
		return
	var outcome := str(result.get("outcome", "UNKNOWN"))
	_finish_attempt(outcome, "completed" if outcome == "WIN" else "failed", int(result.get("stars", 0)))


func _on_result_action(action: String) -> void:
	if action == "RETRY" and not _active_sample.is_empty():
		_retry_pending = true


func _connect_result_actions() -> void:
	if navigation == null:
		return
	var results = navigation.get_result_feedback_overlay()
	if is_instance_valid(results) and results.has_signal("action_requested") and not results.action_requested.is_connected(_on_result_action):
		results.action_requested.connect(_on_result_action)


func _finish_attempt(outcome: String, reason: String, stars: int = 0) -> void:
	if _attempt.is_empty():
		return
	_attempt["end_monotonic_usec"] = Time.get_ticks_usec()
	_attempt["duration_seconds"] = maxf(0.0, float(int(_attempt["end_monotonic_usec"]) - int(_attempt["start_monotonic_usec"])) / 1000000.0)
	_attempt["outcome"] = outcome
	_attempt["wins"] = 1 if outcome == "WIN" else 0
	_attempt["losses"] = 1 if outcome == "LOSE" else 0
	_attempt["leave_reason"] = reason
	_attempt["stars"] = clampi(stars, 0, 3)
	_run_attempts.append(_attempt.duplicate(true))
	_append_telemetry(_attempt)
	_attempt.clear()
	_write_report()


func _return_to_chooser() -> void:
	if not _attempt.is_empty():
		_finish_attempt("ABANDONED", "returned_to_samples")
	_retry_pending = false
	_sample_retry_count = 0
	if navigation != null:
		navigation.show_world_map()
		navigation.visible = false
	_panel.visible = true
	_background.visible = true
	_chooser_button.visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not _attempt.is_empty():
		_finish_attempt("ABANDONED", "application_closed")


func _starter_inventory(level: Dictionary) -> String:
	var values: Array[String] = []
	for drink in level.get("initial_tabletop_drinks", []):
		values.append("L%d" % int(drink.get("cocktail_level", 0)))
	return "empty" if values.is_empty() else ";".join(values)


func _read_content_revision() -> String:
	var file := FileAccess.open("res://data/campaign/content_manifest_m33.json", FileAccess.READ)
	if file == null:
		return "UNKNOWN"
	var manifest = JSON.parse_string(file.get_as_text())
	return str(manifest.get("content_version", "UNKNOWN")) if manifest is Dictionary else "UNKNOWN"


func _telemetry_path(file_name: String) -> String:
	var directory := "user://m33_r06"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	return ProjectSettings.globalize_path(directory.path_join(file_name))


func _append_telemetry(row: Dictionary) -> void:
	var json_path := _telemetry_path("attempts.jsonl")
	var json_file := FileAccess.open(json_path, FileAccess.READ_WRITE) if FileAccess.file_exists(json_path) else FileAccess.open(json_path, FileAccess.WRITE)
	if json_file != null:
		json_file.seek_end()
		json_file.store_line(JSON.stringify(row))
		json_file.close()
	var csv_path := _telemetry_path("attempts.csv")
	var existed := FileAccess.file_exists(csv_path)
	var csv_file := FileAccess.open(csv_path, FileAccess.READ_WRITE) if existed else FileAccess.open(csv_path, FileAccess.WRITE)
	if csv_file == null:
		return
	if not existed:
		csv_file.store_line("run_id,attempt_number,sample_id,global_level_id,island_id,level_id,content_revision,start_monotonic_usec,end_monotonic_usec,duration_seconds,shots,completed_to_go,completed_vip,wins,losses,outcome,retry_count,stars,leave_reason,starter_inventory")
	csv_file.seek_end()
	var columns := ["run_id", "attempt_number", "sample_id", "global_level_id", "island_id", "level_id", "content_revision", "start_monotonic_usec", "end_monotonic_usec", "duration_seconds", "shots", "completed_to_go", "completed_vip", "wins", "losses", "outcome", "retry_count", "stars", "leave_reason", "starter_inventory"]
	var values: Array[String] = []
	for column in columns:
		values.append(_csv_value(str(row.get(column, ""))))
	csv_file.store_line(",".join(values))
	csv_file.close()


func _csv_value(value: String) -> String:
	return "\"%s\"" % value.replace("\"", "\"\"")


func _write_report() -> void:
	var report := "# Owner Playtest Report\n\n"
	report += "Profile: isolated R06 test profile at `%s`. Campaign progression and economy persistence are disabled.\n\n" % ProjectSettings.globalize_path("user://")
	report += "Content revision: %s. Attempts: %d.\n\n" % [_content_revision, _run_attempts.size()]
	report += "| Sample | Global ID | Duration | Shots | To-Go | VIP | Result | Retry | Stars | Leave reason | Starters |\n|---|---:|---:|---:|---:|---:|---|---:|---:|---|---|\n"
	for row in _run_attempts:
		report += "| %s | %d | %.1fs | %d | %d | %d | %s | %d | %d | %s | %s |\n" % [str(row["sample_id"]), int(row["global_level_id"]), float(row["duration_seconds"]), int(row["shots"]), int(row["completed_to_go"]), int(row["completed_vip"]), str(row["outcome"]), int(row["retry_count"]), int(row["stars"]), str(row["leave_reason"]), str(row["starter_inventory"])]
	report += "\nControls use the production live gameplay scene and ShotController. To share, send this report and `attempts.csv` from `%s`. Do not include save files.\n" % _telemetry_path("").get_base_dir()
	var output := FileAccess.open(_telemetry_path("OWNER_PLAYTEST_REPORT.md"), FileAccess.WRITE)
	if output != null:
		output.store_string(report)
		output.close()


func _refresh_profile_message() -> void:
	var profile: Label = find_child("ProfileVerification", true, false)
	if profile == null:
		return
	var actual := ProjectSettings.globalize_path("user://")
	if _profile_is_isolated():
		profile.text = "SAVE ISOLATION VERIFIED · user:// → %s · telemetry/report → user://m33_r06" % actual
	else:
		profile.text = "ISOLATION CHECK FAILED · user:// → %s\n%s" % [actual, _profile_error]
		_start_button.disabled = true
