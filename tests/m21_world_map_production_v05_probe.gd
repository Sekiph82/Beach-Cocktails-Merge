extends SceneTree

## V05 production probe: boots the real app shell, sends viewport pointer input,
## checks the full Sunny Cove navigation chain, and captures the rendered scene.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/production-v05"
const LAYOUT_REPORT := "res://coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/WORLD_MAP_PRODUCTION_LAYOUT_V05.json"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

const EXPECTED := {
	"sunny_cove": {"center": Vector2(540, 300), "size": Vector2(225, 225)},
	"tiki_island": {"center": Vector2(175, 440), "size": Vector2(183, 183)},
	"azure_bay": {"center": Vector2(485, 545), "size": Vector2(234, 234)},
	"coconut_beach": {"center": Vector2(145, 645), "size": Vector2(192, 192)},
	"sunset_island": {"center": Vector2(410, 765), "size": Vector2(213, 213)},
	"party_beach": {"center": Vector2(610, 870), "size": Vector2(186, 186)},
	"frozen_paradise": {"center": Vector2(400, 1020), "size": Vector2(228, 228)},
	"volcano_bay": {"center": Vector2(180, 920), "size": Vector2(207, 207)},
	"billionaire_island": {"center": Vector2(180, 1180), "size": Vector2(177, 177)},
	"final_island": {"center": Vector2(615, 1178), "size": Vector2(201, 201)},
}

var failures: Array[String] = []
var captures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_WORLD_MAP_V05 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_WORLD_MAP_V05 FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _mouse_motion(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = Vector2.ZERO
	return event


func _mouse_button(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	return event


func _touch(position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	return event


func _push(event: InputEvent) -> void:
	root.get_viewport().push_input(event, true)
	await process_frame


func _click_at(position: Vector2) -> void:
	await _push(_mouse_motion(position))
	await _push(_mouse_button(position, true))
	await _push(_mouse_button(position, false))
	await _frames(3)


func _tap_at(position: Vector2) -> void:
	await _push(_touch(position, true))
	await _push(_touch(position, false))
	await _frames(3)


func _capture(name: String) -> Image:
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE_DIR, name]
	var error := image.save_png(ProjectSettings.globalize_path(path))
	_check("rendered capture %s is 720x1280 and saved" % name, error == OK and image.get_width() == 720 and image.get_height() == 1280)
	if error == OK:
		captures.append(path)
	return image


func _write_crop(source: Image, name: String, rect: Rect2i) -> void:
	var crop := source.get_region(rect)
	var path := "%s/%s.png" % [EVIDENCE_DIR, name]
	var error := crop.save_png(ProjectSettings.globalize_path(path))
	_check("rendered composition crop %s saved" % name, error == OK)
	if error == OK:
		captures.append(path)


func _write_layout_report(world) -> Dictionary:
	var report: Dictionary = world.get_layout_report(Vector2(720, 1280))
	var rows: Array = report.get("islands", [])
	for row: Dictionary in rows:
		var reference: Dictionary = EXPECTED[str(row["id"])]
		var expected_center: Vector2 = reference["center"]
		var expected_size: Vector2 = reference["size"]
		var actual_center := Vector2(float(row["actual_center"]["x"]), float(row["actual_center"]["y"]))
		var actual_size := Vector2(float(row["actual_size"]["x"]), float(row["actual_size"]["y"]))
		row["expected_center"] = {"x": expected_center.x, "y": expected_center.y}
		row["expected_size"] = {"x": expected_size.x, "y": expected_size.y}
		row["center_delta"] = {"x": actual_center.x - expected_center.x, "y": actual_center.y - expected_center.y}
		row["size_delta"] = {"x": actual_size.x - expected_size.x, "y": actual_size.y - expected_size.y}
		row["overlap"] = false
	for index in range(rows.size()):
		var rect: Dictionary = rows[index]["hit_rect"]
		var bounds := Rect2(Vector2(float(rect["x"]), float(rect["y"])), Vector2(float(rect["width"]), float(rect["height"])))
		for other_index in range(index + 1, rows.size()):
			var other_rect: Dictionary = rows[other_index]["hit_rect"]
			var other_bounds := Rect2(Vector2(float(other_rect["x"]), float(other_rect["y"])), Vector2(float(other_rect["width"]), float(other_rect["height"])))
			if bounds.intersects(other_bounds):
				rows[index]["overlap"] = true
				rows[other_index]["overlap"] = true
	report["work_item"] = "BCM-M21-001"
	report["prompt_version"] = "V05"
	report["visual_authority"] = "owner-approved V04 preview; sha256 d2c9693f5040a5a67b9292a07a0b19873840b23f842d3e6d5e44954760d8895f"
	report["runtime_background"] = "res://assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png"
	var file := FileAccess.open(LAYOUT_REPORT, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	_check("production layout report written", FileAccess.file_exists(LAYOUT_REPORT))
	return report


func _check_layout(world) -> Dictionary:
	var report := _write_layout_report(world)
	var background: TextureRect = world.get_node("WorldMapBackground") as TextureRect
	_check("owner V02 clean ocean is production background", background != null and background.texture.resource_path.ends_with("world_map_ocean_background_owner_v02.png"))
	_check("rejected baked background is not production authority", background == null or not background.texture.resource_path.ends_with("world_map_background.png"))
	_check("all ten canonical island PNGs are separate visible bodies", world.get_entry_ids().size() == 10 and world.get_visual_marker_count() == 10)
	_check("production layout has no clipping, hitbox overlap or header collision", not bool(report["horizontal_clipping"]) and not bool(report["vertical_clipping"]) and not bool(report["overlap"]) and not bool(report["header_overlap"]) and bool(report["header_controls_fit"]))
	var ids: Array[String] = world.get_entry_ids()
	var required_order := ["sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island"]
	_check("campaign route order remains canonical", ids == required_order)
	var unique_sizes: Dictionary = {}
	for row: Dictionary in report.get("islands", []):
		var island_id := str(row["id"])
		var expected: Dictionary = EXPECTED[island_id]
		var entry: IslandEntry = world.get_entry(island_id) as IslandEntry
		var actual_center: Vector2 = entry.get_art_global_rect().get_center()
		var actual_size: Vector2 = entry.get_art_global_rect().size
		var center_delta: Vector2 = actual_center - expected["center"]
		var size_delta: Vector2 = actual_size - expected["size"]
		_check("%s visible center within ±2px" % island_id, absf(center_delta.x) <= 2.0 and absf(center_delta.y) <= 2.0)
		_check("%s visible size within ±2px" % island_id, absf(size_delta.x) <= 2.0 and absf(size_delta.y) <= 2.0)
		_check("%s art and hit centers coincide" % island_id, entry.get_art_global_rect().get_center().distance_to(entry.get_global_rect().get_center()) <= 0.1)
		_check("%s label center within ±4px" % island_id, entry.get_label_global_rect().get_center().distance_to(expected["center"] + Vector2(0, float((world._definitions_by_id[island_id]["world_map_layout"]["label_offset"])[1]))) <= 4.0)
		unique_sizes[str(actual_size)] = true
		_check("%s canonical icon is visible" % island_id, entry.get_node("IslandArt").visible and entry.get_node("IslandArt").texture.resource_path.ends_with("%s.png" % island_id))
	_check("island sizes remain intentionally non-uniform", unique_sizes.size() == 10)
	var sunny_entry: IslandEntry = world.get_entry("sunny_cove") as IslandEntry
	var sunny_center := sunny_entry.get_art_global_rect().get_center()
	_check("Sunny Cove is the upper-right starting island", sunny_center.x > 500.0 and sunny_center.y < 350.0 and world.get_entry_state("sunny_cove") == "CURRENT")
	return report


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	var onboarding := FileAccess.open("user://m21_world_map_v05_onboarding.json", FileAccess.WRITE)
	if onboarding == null:
		_check("isolated onboarding fixture opens", false)
		_finish()
		return
	onboarding.store_string("{\"schema_version\":1,\"completed\":true}")
	onboarding.close()
	var shell := SHELL_SCENE.instantiate() as ApplicationShell
	shell.onboarding_storage_path = "user://m21_world_map_v05_onboarding.json"
	shell.settings_storage_path = "user://m21_world_map_v05_settings.json"
	root.add_child(shell)
	await _frames(8)
	_check("real application shell starts at Main Menu", shell.get_current_view() == "MAIN_MENU")
	var navigation := shell.get_campaign_navigation()
	var database = DATABASE_SCRIPT.new()
	var campaign = CAMPAIGN_SCRIPT.new()
	var configured := database.load_canonical() and campaign.configure(database, SAVE_SCRIPT.new().create_default_state())
	_check("isolated fresh campaign configured", configured and navigation.configure_campaign(database, campaign))
	var play: Control = shell.get_menu_controls()["play"]
	await _click_at(play.get_global_rect().get_center())
	_check("real viewport PLAY click enters production World Map", shell.get_current_view() == "CAMPAIGN" and navigation.get_current_view() == navigation.VIEW_WORLD_MAP)
	var world = navigation.get_world_map()
	await _frames(4)
	var layout := _check_layout(world)
	_check("production GUI shows all future islands locked on fresh state", world.get_entry_state("sunny_cove") == "CURRENT" and not world.is_entry_selectable("tiki_island") and world.get_entry_state("tiki_island") == "LOCKED")
	var initial_image := _capture("01_world_map_full_fresh")
	_write_crop(initial_image, "02_world_map_top_section", Rect2i(0, 0, 720, 430))
	_write_crop(initial_image, "03_world_map_middle_section", Rect2i(0, 425, 720, 430))
	_write_crop(initial_image, "04_world_map_bottom_section", Rect2i(0, 850, 720, 430))
	_write_crop(initial_image, "05_sunny_cove_current_selectable", Rect2i(420, 175, 290, 275))
	_write_crop(initial_image, "06_tiki_island_locked", Rect2i(55, 325, 265, 250))

	var selected: Array[String] = []
	var requested: Array[String] = []
	var entered: Array[String] = []
	var mouse_selected := func(id: String) -> void: selected.append(id)
	var mouse_requested := func(id: String) -> void: requested.append(id)
	world.island_selected.connect(mouse_selected)
	world.island_map_requested.connect(mouse_requested)
	navigation.island_map_entered.connect(func(id: String) -> void: entered.append(id))
	var sunny: IslandEntry = world.get_entry("sunny_cove") as IslandEntry
	var sunny_center := sunny.get_global_rect().get_center()
	_check("Sunny Cove real hit center derived from production control", sunny_center.distance_to(Vector2(540, 300)) <= 2.0)
	await _click_at(sunny_center)
	_check("real mouse input emits one select and navigation event", selected == ["sunny_cove"] and requested == ["sunny_cove"] and entered == ["sunny_cove"])
	_check("mouse path reaches visible Sunny Cove Island Map with 100 levels", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_active_island_id() == "sunny_cove" and navigation.get_island_map().island_id == "sunny_cove" and navigation.get_island_map().get_level_button_count() == 100 and navigation.get_island_map().visible)
	_capture("07_sunny_cove_island_map_after_real_mouse")
	var back_to_world: Control = navigation.get_island_map().get_node("IslandMapHeader/BackToWorldMap")
	await _click_at(back_to_world.get_global_rect().get_center())
	_check("real Island Map Back returns to one visible World Map", navigation.get_current_view() == navigation.VIEW_WORLD_MAP and navigation.get_world_map().visible and navigation.get_map_instance_count() == 2)
	world = navigation.get_world_map()
	world.island_selected.disconnect(mouse_selected)
	world.island_map_requested.disconnect(mouse_requested)
	world.island_selected.connect(func(id: String) -> void: selected.append(id))
	world.island_map_requested.connect(func(id: String) -> void: requested.append(id))
	var touch_center: Vector2 = (world.get_entry("sunny_cove") as IslandEntry).get_global_rect().get_center()
	await _tap_at(touch_center)
	_check("real InputEventScreenTouch enters Sunny Cove Island Map exactly once", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_active_island_id() == "sunny_cove" and navigation.get_island_map().get_level_button_count() == 100 and selected == ["sunny_cove", "sunny_cove"] and requested == ["sunny_cove", "sunny_cove"] and entered == ["sunny_cove", "sunny_cove"])
	_check("repeated World Map and Island Map navigation keeps one map pair", navigation.get_map_instance_count() == 2 and navigation.get_world_map().get_entry_count() == 10)
	await _click_at(navigation.get_island_map().get_node("IslandMapHeader/BackToWorldMap").get_global_rect().get_center())
	await _click_at(navigation.get_world_map().get_node("Header/BackButton").get_global_rect().get_center())
	_check("real World Map Back button returns to Main Menu", shell.get_current_view() == "MAIN_MENU" and not navigation.visible)
	if layout.is_empty():
		_check("production layout report contains island rows", false)
	_finish()


func _finish() -> void:
	var report := {"work_item": "BCM-M21-001", "prompt_version": "V05", "captures": captures, "checks_failed": failures, "owner_f5_acceptance": "PENDING", "independent_gpt_audit": "PENDING"}
	var file := FileAccess.open("%s/WORLD_MAP_PRODUCTION_V05_GUI_REPORT.json" % EVIDENCE_DIR, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	if failures.is_empty():
		print("M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=%d mouse=PASS touch=PASS" % captures.size())
		quit(0)
		return
	print("M21_WORLD_MAP_PRODUCTION_V05_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
