extends SceneTree

const REQUIRED_FILES := [
	"res://data/drinks.json",
	"res://data/ui/home_layout.json",
	"res://data/campaign/islands.json",
	"res://data/campaign/daily_rewards.json",
	"res://data/campaign/store_catalog.json",
	"res://data/campaign/ads_provider_policy.json",
	"res://data/campaign/content_manifest_m33.json",
	"res://data/campaign/content_generation_profiles_m33.json",
	"res://data/campaign/levels/sunny_cove.json",
	"res://data/campaign/levels/tiki_island_full.json",
	"res://data/campaign/levels/azure_bay.json",
	"res://data/campaign/levels/coconut_beach.json",
	"res://data/campaign/levels/sunset_island.json",
	"res://data/campaign/levels/party_beach.json",
	"res://data/campaign/levels/frozen_paradise.json",
	"res://data/campaign/levels/volcano_bay.json",
	"res://data/campaign/levels/billionaire_island.json",
	"res://data/campaign/levels/final_island.json",
	"res://scenes/campaign/ApplicationShellScene.tscn",
	"res://addons/AdmobPlugin/Admob.gd",
]
const FORBIDDEN_PREFIXES := [
	"res://coordination/",
	"res://docs/",
	"res://tests/",
	"res://tools/",
	"res://backend/",
	"res://.github/",
	"res://_m32_validation/",
	"res://addons/godot_ai/",
	"res://addons/GodotGooglePlayBilling/",
	"res://addons/AdmobPlugin/AdmobPlugin.gd",
	"res://addons/AdmobPlugin/plugin.cfg",
	"res://addons/AdmobPlugin/config/",
	"res://addons/AdmobPlugin/model/",
	"res://addons/AdmobPlugin/icon.png",
	"res://addons/game_feel_flow/editor/",
	"res://addons/game_feel_flow/icons/",
	"res://addons/game_feel_flow/plugin.gd",
	"res://addons/game_feel_flow/plugin.cfg",
	"res://addons/game_feel_flow/presets/generate",
	"res://addons/saltmire_spark/plugin.gd",
	"res://addons/saltmire_spark/plugin.cfg",
	"res://scripts/campaign/play_billing_test_adapter.gd",
	"res://scripts/campaign/admob_test_adapter.gd",
	"res://scripts/campaign/m17_seeded_validation_harness.gd",
	"res://scripts/campaign/m17_canonical_screening_model.gd",
	"res://scripts/campaign/m32_content_workflow.gd",
	"res://scripts/campaign/owner_playtest_console.gd",
	"res://assets/ui_assets/source/",
	"res://assets/ui_assets/v04_masters/",
	"res://assets/ui_assets/v05_sources/",
	"res://f647e4ff-b906-40e7-93f8-3c4b59d95b23.png",
	"res://data/campaign/shop_catalog.json",
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		_finish({"status": "FAIL", "reason": "expected exactly one pack path"}, 2)
		return
	if not ProjectSettings.load_resource_pack(args[0], true):
		_finish({"status": "FAIL", "reason": "Godot rejected resource pack"}, 3)
		return

	var files: Array[String] = []
	_collect("res://", files)
	var forbidden: Array[String] = []
	var manifest: Array[Dictionary] = []
	for path in files:
		if path in ["res://project.godot", "res://inspect_godot_pck.gd"]:
			continue
		for prefix in FORBIDDEN_PREFIXES:
			if path.begins_with(prefix):
				forbidden.append(path)
				break
		var file := FileAccess.open(path, FileAccess.READ)
		var size := file.get_length() if file != null else -1
		if file != null:
			file.close()
		manifest.append({"path": path.trim_prefix("res://"), "bytes": size, "sha256": FileAccess.get_sha256(path)})

	var missing: Array[String] = []
	for path in REQUIRED_FILES:
		if path in [
			"res://scenes/campaign/ApplicationShellScene.tscn",
			"res://addons/AdmobPlugin/Admob.gd",
		]:
			continue  # Godot maps packed scenes and scripts to generated export entries.
		if not FileAccess.file_exists(path):
			missing.append(path)
	var main_scene := ResourceLoader.load("res://scenes/campaign/ApplicationShellScene.tscn")
	var policy := _read_ads_policy()
	var helper_present := FileAccess.file_exists("res://addons/godot_ai/runtime/game_helper.gd")
	var admob_binary_entries := _matching_files(manifest, "addons/AdmobPlugin/bin/")
	var billing_entries := _matching_files(manifest, "addons/GodotGooglePlayBilling/")
	var billing_adapter_present := FileAccess.file_exists("res://scripts/campaign/play_billing_test_adapter.gd")
	var ads_source_present := ResourceLoader.exists("res://addons/AdmobPlugin/Admob.gd")
	var ads_disabled := bool(policy.get("default_enabled", true)) == false
	for placement in policy.get("placements", {}).values():
		if bool(placement.get("enabled", true)):
			ads_disabled = false

	var passed := forbidden.is_empty() and missing.is_empty() and main_scene is PackedScene \
		and not helper_present and ads_source_present and admob_binary_entries.is_empty() \
		and billing_entries.is_empty() and not billing_adapter_present and ads_disabled
	_finish({
		"status": "PASS" if passed else "FAIL",
		"engine_pack_reader": "Godot ProjectSettings.load_resource_pack + DirAccess + ResourceLoader",
		"listed_file_count": manifest.size(),
		"forbidden_entries": forbidden,
		"missing_required_runtime_files": missing,
		"main_scene_resource_loaded": main_scene is PackedScene,
		"godot_ai_game_helper_present": helper_present,
		"admob_runtime_source_preserved": ads_source_present,
		"admob_native_binary_entries": admob_binary_entries,
		"billing_plugin_entries": billing_entries,
		"billing_test_adapter_present": billing_adapter_present,
		"ads_default_and_placements_disabled": ads_disabled,
		"file_manifest": manifest,
	}, 0 if passed else 1)


func _read_ads_policy() -> Dictionary:
	var file := FileAccess.open("res://data/campaign/ads_provider_policy.json", FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _matching_files(manifest: Array[Dictionary], prefix: String) -> Array[String]:
	var paths: Array[String] = []
	for entry in manifest:
		var path := str(entry.get("path", ""))
		if path.begins_with(prefix):
			paths.append(path)
	return paths


func _collect(path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	for file_name in directory.get_files():
		output.append(path.path_join(file_name).replace("\\", "/"))
	for child in directory.get_directories():
		if child.begins_with("."):
			continue
		_collect(path.path_join(child).replace("\\", "/"), output)


func _finish(value: Dictionary, exit_code: int) -> void:
	print("BCM_PCK_REPORT=" + JSON.stringify(value))
	quit(exit_code)
