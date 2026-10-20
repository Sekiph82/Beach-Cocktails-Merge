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
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		_finish({"status": "FAIL", "reason": "expected exactly one pack path"}, 2)
		return
	if not ProjectSettings.load_resource_pack(args[0], true):
		_finish({"status": "FAIL", "reason": "Godot rejected resource pack"}, 3)
		return

	var missing: Array[String] = []
	for path in REQUIRED_FILES:
		if not FileAccess.file_exists(path):
			missing.append(path)
	var main_scene := ResourceLoader.load("res://scenes/campaign/ApplicationShellScene.tscn")
	var policy := _read_ads_policy()
	var helper_present := FileAccess.file_exists("res://addons/godot_ai/runtime/game_helper.gd")
	var billing_adapter_present := FileAccess.file_exists("res://scripts/campaign/play_billing_test_adapter.gd")
	var ads_source_present := ResourceLoader.exists("res://addons/AdmobPlugin/Admob.gd")
	var ads_disabled := bool(policy.get("default_enabled", true)) == false
	for placement in policy.get("placements", {}).values():
		if bool(placement.get("enabled", true)):
			ads_disabled = false

	var passed := missing.is_empty() and main_scene is PackedScene \
		and not helper_present and ads_source_present \
		and not billing_adapter_present and ads_disabled
	_finish({
		"status": "PASS" if passed else "FAIL",
		"engine_pack_reader": "Godot ProjectSettings.load_resource_pack + ResourceLoader; directory coverage is verified independently from the PCK index",
		"missing_required_runtime_files": missing,
		"main_scene_resource_loaded": main_scene is PackedScene,
		"godot_ai_game_helper_present": helper_present,
		"admob_runtime_source_preserved": ads_source_present,
		"billing_test_adapter_present": billing_adapter_present,
		"ads_default_and_placements_disabled": ads_disabled,
	}, 0 if passed else 1)


func _read_ads_policy() -> Dictionary:
	var file := FileAccess.open("res://data/campaign/ads_provider_policy.json", FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _finish(value: Dictionary, exit_code: int) -> void:
	print("BCM_PCK_REPORT=" + JSON.stringify(value))
	quit(exit_code)
