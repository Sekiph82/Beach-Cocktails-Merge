extends SceneTree

## Focused runtime contract probe for the owner-selected R04 surface migration.

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const ISLAND_IDS := [
	"azure_bay", "billionaire_island", "coconut_beach", "final_island",
	"frozen_paradise", "party_beach", "sunny_cove", "sunset_island",
	"tiki_island", "volcano_bay",
]

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_R04_SURFACE_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_R04_SURFACE_PROBE FAIL: %s" % label)


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK or context.update(bytes) != OK:
		return ""
	return context.finish().hex_encode()


func _frame(count: int = 1) -> void:
	for _index in range(count):
		await process_frame


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	_check("canonical island and level data load with R04 profiles", database.load_canonical())
	if not database.is_loaded():
		printerr("R04_LEVEL_DATABASE_ERROR=%s" % database.get_last_error())
		quit(1)
		return
	var reference_geometry: Dictionary = {}
	for island_id in ISLAND_IDS:
		var island: Dictionary = database.get_island(island_id)
		var theme: Dictionary = island.get("theme", {})
		var surface_path := str(theme.get("gameplay_surface", ""))
		var geometry: Dictionary = island.get("playable_geometry", {})
		var surface_bytes := FileAccess.get_file_as_bytes(surface_path)
		_check("%s uses its own generic R04 runtime surface" % island_id, surface_path == "res://assets/ui_assets/campaign/islands/%s/gameplay_surface.png" % island_id)
		_check("%s runtime bytes match profile SHA" % island_id, not surface_bytes.is_empty() and _sha256(surface_bytes) == str(geometry.get("surface_sha256", "")))
		_check("%s provides geometry derived from its profile" % island_id, geometry.has_all(["playable_polygon", "launch_y", "spawn_y", "death_y", "surface_sha256"]))
		if reference_geometry.is_empty():
			reference_geometry = geometry.duplicate(true)
		else:
			geometry.erase("surface_sha256")
			var expected := reference_geometry.duplicate(true)
			expected.erase("surface_sha256")
			_check("%s preserves common R11 gameplay geometry" % island_id, geometry == expected)
	var gameplay := GameManager.new()
	root.add_child(gameplay)
	await _frame(2)
	for island_id in ISLAND_IDS:
		var island: Dictionary = database.get_island(island_id)
		var theme: Dictionary = database.get_island_theme(island_id).duplicate(true)
		theme["playable_geometry"] = island["playable_geometry"].duplicate(true)
		gameplay._apply_campaign_theme(theme)
		var expected_path := "res://assets/ui_assets/campaign/islands/%s/gameplay_surface.png" % island_id
		_check("%s runtime renders its canonical single surface" % island_id, gameplay._background.name == "GameplaySurface" and gameplay._background.texture != null and gameplay._background.texture.resource_path == expected_path)
		_check("%s runtime geometry matches its profile" % island_id, gameplay.get_active_theme_paths().get("playable_geometry", {}) == island["playable_geometry"])
		_check("%s runtime has no legacy split layers" % island_id, gameplay._theme_table == null and gameplay._theme_table_shadow == null and gameplay._theme_edge_overlay == null)
	gameplay.queue_free()
	await _frame()
	if not failures.is_empty():
		printerr("M21_R04_SURFACE_PROBE_RESULT=FAIL count=%d" % failures.size())
		quit(1)
		return
	print("M21_R04_SURFACE_PROBE_RESULT=PASS islands=%d checks=%d" % [ISLAND_IDS.size(), ISLAND_IDS.size() * 7 + 1])
	quit(0)
