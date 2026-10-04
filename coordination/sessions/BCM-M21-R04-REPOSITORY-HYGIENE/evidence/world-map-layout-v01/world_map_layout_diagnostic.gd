extends SceneTree

const WORLD_MAP_SCENE := preload("res://scenes/campaign/WorldMapScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const OUTPUT_DIR := "res://coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/evidence/world-map-layout-v01"

func _init() -> void:
	call_deferred("_run")

func _json_safe(value: Variant) -> Variant:
	if value is Vector2:
		return {"x": value.x, "y": value.y}
	if value is Rect2:
		return {"position": _json_safe(value.position), "size": _json_safe(value.size), "end": _json_safe(value.end)}
	if value is Dictionary:
		var output := {}
		for key in value:
			output[str(key)] = _json_safe(value[key])
		return output
	if value is Array:
		var output: Array = []
		for item in value:
			output.append(_json_safe(item))
		return output
	return value

func _rect(control: Control) -> Dictionary:
	var global_rect := control.get_global_rect()
	return {"rect": _json_safe(global_rect), "visible": control.is_visible_in_tree(), "clip_contents": control.clip_contents}

func _layout_snapshot(world_map: Control, label: String) -> Dictionary:
	var map_canvas: Control = world_map.get("_map_canvas")
	var entries: Dictionary = world_map.get("_entries")
	var header: Control = world_map.get_node("Header")
	var header_elements := {}
	for element_name in ["BackButton", "TitlePanel", "Compass"]:
		var element: Control = header.get_node(element_name)
		header_elements[element_name] = {
			"bounds": _rect(element),
			"minimum_size": _json_safe(element.get_combined_minimum_size()),
			"custom_minimum_size": _json_safe(element.custom_minimum_size)
		}
	var output := {
		"scenario": label,
		"viewport": _json_safe(get_root().get_visible_rect()),
		"layout_report": _json_safe(world_map.get_layout_report(Vector2(720, 1280))),
		"map_canvas": _rect(map_canvas),
		"header": _rect(header),
		"header_elements": header_elements,
		"status_panel": _rect(world_map.get_node("StatusPanel")),
		"selection_boundary": _rect(world_map.get_node("SelectionBoundary")),
		"markers": []
	}
	for island_id in world_map.get_entry_ids():
		var entry: Control = entries[island_id]
		var definition: Dictionary = entry.get("island_definition")
		var ring: Control = entry.get_node("SelectionRing")
		var name_label: Control = entry.get_node("IslandName")
		var state_label: Control = entry.get_node("IslandState")
		var art: Control = entry.get_node("IslandArt")
		var marker := {
			"island_id": island_id,
			"map_position": definition.get("map_position", []),
			"calibrated_center_canvas": _json_safe(entry.position + Vector2(68.0, 58.0)),
			"calibrated_center_screen": _json_safe(map_canvas.global_position + entry.position + Vector2(68.0, 58.0)),
			"entry": _rect(entry),
			"selection_ring": _rect(ring),
			"island_art": _rect(art),
			"name_label": _rect(name_label),
			"state_label": _rect(state_label),
			"state": entry.get("island_state")
		}
		output["markers"].append(marker)
	return output

func _save_image(filename: String) -> void:
	RenderingServer.force_draw(false)
	await process_frame
	var image := get_root().get_texture().get_image()
	if image.is_empty():
		push_error("Renderer returned an empty viewport image: %s" % filename)
		return
	image.save_png("%s/%s" % [OUTPUT_DIR, filename])

func _campaign(database):
	var campaign = CAMPAIGN_SCRIPT.new()
	campaign.configure(database, SAVE_SCRIPT.new().create_default_state())
	return campaign

func _mount(database, campaign):
	var map: Control = WORLD_MAP_SCENE.instantiate()
	map.level_database = database
	map.campaign_manager = campaign
	root.add_child(map)
	await process_frame
	await process_frame
	return map

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	DisplayServer.window_set_size(Vector2i(720, 1280))
	await process_frame
	var records := {}
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical():
		push_error("Could not load canonical campaign")
		quit(2)
		return
	var world_map = await _mount(database, _campaign(database))
	await process_frame
	records["canonical_fresh"] = _layout_snapshot(world_map, "canonical_fresh")
	var boat: Control = world_map.get_node("MapBoat")
	records["canonical_fresh"]["map_boat"] = {"bounds": _rect(boat), "z_index": boat.z_index, "minimum_size": _json_safe(boat.get_combined_minimum_size())}
	await _save_image("post-fix-full-fresh-720x1280.png")
	world_map.select_island("frozen_paradise")
	await process_frame
	records["canonical_locked"] = _layout_snapshot(world_map, "canonical_locked")
	await _save_image("post-fix-locked-selection-720x1280.png")
	world_map.select_island("sunny_cove")
	await process_frame
	records["canonical_selected_current"] = _layout_snapshot(world_map, "canonical_selected_current")
	await _save_image("post-fix-selected-current-720x1280.png")
	var image := get_root().get_texture().get_image()
	image.get_region(Rect2i(0, 0, 720, 360)).save_png("%s/post-fix-top-area-720x360.png" % OUTPUT_DIR)
	image.get_region(Rect2i(0, 920, 720, 360)).save_png("%s/post-fix-bottom-area-720x360.png" % OUTPUT_DIR)
	world_map.queue_free()
	await process_frame
	var fixture_data := {
		"schema_version": 1,
		"islands": [
			{"id": "sunny_cove", "display_name": "Sunny Cove", "order_index": 1, "level_count": 2, "unlock_rule": {"type": "default_open"}, "next_island_id": "tiki_island", "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png", "map_position": [0.18, 0.72], "reward_track": {"milestones": [2]}},
			{"id": "tiki_island", "display_name": "Tiki Island", "order_index": 2, "level_count": 0, "unlock_rule": {"type": "requires_island_completion", "island_id": "sunny_cove", "level_id": 2}, "next_island_id": "", "map_asset": "res://assets/ui_assets/campaign/world_map/tiki_island.png", "map_position": [0.72, 0.38], "reward_track": {"milestones": []}}
		]
	}
	var level_data := {"schema_version": 1, "island_id": "sunny_cove", "levels": []}
	var fixture = DATABASE_SCRIPT.new()
	if not fixture.load_from_data(fixture_data, level_data):
		push_error("Could not load two-island diagnostic fixture")
		quit(3)
		return
	var fixture_map = await _mount(fixture, _campaign(fixture))
	records["two_island_fixture"] = _layout_snapshot(fixture_map, "two_island_fixture")
	var output_file := FileAccess.open("%s/post-fix-layout-report.json" % OUTPUT_DIR, FileAccess.WRITE)
	output_file.store_string(JSON.stringify(_json_safe(records), "\t"))
	output_file.close()
	print("M21_WORLD_MAP_DIAGNOSTIC_RESULT=PASS viewport=%s output=%s" % [str(get_root().size), OUTPUT_DIR])
	quit(0)
