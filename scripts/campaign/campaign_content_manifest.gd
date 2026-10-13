class_name CampaignContentManifest
extends RefCounted

## Verifies the bundled campaign package before campaign save I/O.

const MANIFEST_PATH := "res://data/campaign/content_manifest_m33.json"
const ISLANDS_PATH := "res://data/campaign/islands.json"
const CONTENT_VERSION := "BCM-M33.4"
const SUPPORTED_GAME_VERSION := "4.7.x"
const EXPECTED_ISLANDS := [
	"sunny_cove",
	"tiki_island",
	"azure_bay",
	"coconut_beach",
	"sunset_island",
	"party_beach",
	"frozen_paradise",
	"volcano_bay",
	"billionaire_island",
	"final_island",
]

var last_error := ""


func validate() -> Dictionary:
	last_error = ""
	var manifest: Variant = _read_object(MANIFEST_PATH)
	if not manifest is Dictionary:
		return _failure("manifest is missing or malformed")
	if int(manifest.get("schema_version", 0)) != 1:
		return _failure("unsupported manifest schema")
	if str(manifest.get("content_version", "")) != CONTENT_VERSION:
		return _failure("unsupported campaign content version")
	if str(manifest.get("supported_game_version", "")) != SUPPORTED_GAME_VERSION:
		return _failure("manifest game compatibility line is invalid")
	var engine_version: Dictionary = Engine.get_version_info()
	if int(engine_version.get("major", -1)) != 4 or int(engine_version.get("minor", -1)) != 7:
		return _failure("campaign package requires Godot 4.7.x")
	if not bool(manifest.get("read_only", false)) or str(manifest.get("delivery_mode", "")) != "versioned_bundled_app_update":
		return _failure("campaign package delivery mode is invalid")
	if int(manifest.get("island_count", 0)) != EXPECTED_ISLANDS.size() or int(manifest.get("levels_per_island", 0)) != 100 or int(manifest.get("total_levels", 0)) != 1000:
		return _failure("manifest campaign counts are invalid")
	if manifest.get("ordered_island_ids", []) != EXPECTED_ISLANDS:
		return _failure("manifest island order differs from the canonical campaign")
	var islands_root: Variant = _read_object(ISLANDS_PATH)
	if not islands_root is Dictionary or not islands_root.get("campaign_contract", {}) is Dictionary:
		return _failure("campaign island contract is missing or malformed")
	var contract: Dictionary = islands_root["campaign_contract"]
	if int(contract.get("island_count", 0)) != 10 or int(contract.get("levels_per_island", 0)) != 100 or int(contract.get("total_levels", 0)) != 1000 or contract.get("ordered_island_ids", []) != EXPECTED_ISLANDS:
		return _failure("campaign island contract differs from the manifest")
	var entries: Variant = manifest.get("islands", null)
	if not entries is Array or entries.size() != EXPECTED_ISLANDS.size():
		return _failure("manifest island entries are incomplete")
	for index in entries.size():
		var entry: Variant = entries[index]
		if not entry is Dictionary:
			return _failure("manifest island entry is malformed")
		var island_id: String = EXPECTED_ISLANDS[index]
		var path := str(entry.get("path", ""))
		if str(entry.get("id", "")) != island_id or int(entry.get("level_count", 0)) != 100:
			return _failure("manifest island identity/count mismatch: %s" % island_id)
		if not path.begins_with("res://data/campaign/levels/") or path.contains(".."):
			return _failure("manifest path is outside the bundled campaign data directory")
		var bytes := FileAccess.get_file_as_bytes(path)
		if bytes.is_empty():
			return _failure("campaign data file is missing or empty: %s" % island_id)
		if _sha256(bytes) != str(entry.get("sha256", "")).to_upper():
			return _failure("campaign data hash mismatch: %s" % island_id)
		var level_root: Variant = JSON.parse_string(bytes.get_string_from_utf8())
		if not level_root is Dictionary or str(level_root.get("island_id", "")) != island_id or not level_root.get("levels", []) is Array or level_root["levels"].size() != 100:
			return _failure("campaign data identity/count mismatch: %s" % island_id)
	return {"ok": true, "content_version": CONTENT_VERSION, "supported_game_version": SUPPORTED_GAME_VERSION}


func get_last_error() -> String:
	return last_error


func _read_object(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else null


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK or context.update(bytes) != OK:
		return ""
	return context.finish().hex_encode().to_upper()


func _failure(message: String) -> Dictionary:
	last_error = message
	return {"ok": false, "error": message}
