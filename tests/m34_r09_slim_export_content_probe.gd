extends SceneTree

const MANIFEST_SCRIPT := preload("res://scripts/campaign/campaign_content_manifest.gd")
const ISLAND_IDS := [
	"sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
	"party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest = MANIFEST_SCRIPT.new()
	var result: Dictionary = manifest.validate()
	_check(bool(result.get("ok", false)), "dynamic campaign manifest loads all 1,000 level records: %s" % result)
	var island_data := _read_json("res://data/campaign/islands.json")
	var islands: Array = island_data.get("islands", [])
	_check(islands.size() == ISLAND_IDS.size(), "island data contains exactly ten runtime entries")
	for index in mini(islands.size(), ISLAND_IDS.size()):
		var island: Dictionary = islands[index]
		var island_id: String = ISLAND_IDS[index]
		_check(str(island.get("id", "")) == island_id, "campaign entry %d preserves canonical id %s" % [index, island_id])
		_check(ResourceLoader.exists(str(island.get("map_asset", ""))), "%s dynamic world map art resolves" % island_id)
		var theme: Dictionary = island.get("theme", {})
		_check(ResourceLoader.exists(str(theme.get("island_map_background", ""))), "%s dynamic island-map background resolves" % island_id)
		_check(ResourceLoader.exists(str(theme.get("gameplay_surface", ""))), "%s dynamic gameplay surface resolves" % island_id)
		_check(FileAccess.file_exists(str(theme.get("playable_geometry_profile", ""))), "%s dynamic R04 profile resolves" % island_id)
	for level in range(1, 13):
		var cocktail_path := "res://assets/cocktails/L%02d.png" % level
		_check(ResourceLoader.exists(cocktail_path), "cocktail L%02d resolves" % level)
	_check(ResourceLoader.exists("res://scenes/campaign/ApplicationShellScene.tscn"), "application shell scene loads")
	_check(ResourceLoader.exists("res://assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png"), "excluded contact-sheet source remains available in repository")
	_check(not ResourceLoader.exists("res://coordination/"), "coordination is not a runtime resource dependency")
	print("R09_SLIM_EXPORT_CONTENT_PROBE completed")
	quit()


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_check(false, "%s exists" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	_check(parsed is Dictionary, "%s parses as JSON object" % path)
	return parsed if parsed is Dictionary else {}


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		push_error("FAIL: %s" % description)
		quit(1)
