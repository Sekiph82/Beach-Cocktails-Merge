extends SceneTree

## R07 production Home frontier-label regression.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence"

var failures: Array[String] = []
var shell


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_HOME_LABEL_R07 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_HOME_LABEL_R07 FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _capture_home() -> void:
	await _frames()
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/home_level_10.png" % EVIDENCE_DIR
	_check("Home LEVEL 10 capture is production viewport", not image.is_empty() and image.save_png(ProjectSettings.globalize_path(path)) == OK)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	root.size = Vector2i(720, 1280)
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m21_home_label_r07_onboarding.json"
	root.add_child(shell)
	await _frames()
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	await _frames()
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign data loads", database.load_canonical())
	var state := {
		"schema_version": 2,
		"unlocked_islands": ["sunny_cove"],
		"islands": {"sunny_cove": {"highest_unlocked_level": 10, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("ten-level frontier configures", campaign.configure(database, state))
	var navigation = shell.get_campaign_navigation()
	_check("production shell accepts frontier campaign", navigation.configure_campaign(database, campaign))
	shell._refresh_home_values()
	_check("campaign manager exposes frontier 10", campaign.get_frontier_level_id() == 10)
	_check("PLAY plaque text is exactly LEVEL 10", shell._home_value_labels.continue.text == "LEVEL 10")
	_check("top Level bar displays the campaign frontier", shell._home_value_labels.level.text == "10")
	await _capture_home()
	_check("replay selection moves to level 4", campaign.select_level("sunny_cove", 4))
	shell._refresh_home_values()
	_check("both Home level displays stay at frontier 10 during old replay", campaign.selected_level_id == 4 and campaign.get_frontier_level_id() == 10 and shell._home_value_labels.level.text == "10" and shell._home_value_labels.continue.text == "LEVEL 10")
	var completion: Dictionary = campaign.mark_level_completed("sunny_cove", 10, {"stars": 1, "score": 100})
	shell._refresh_home_values()
	_check("first completion of frontier 10 advances both Home levels to 11", completion.get("ok", false) and campaign.get_frontier_level_id() == 11 and shell._home_value_labels.level.text == "11" and shell._home_value_labels.continue.text == "LEVEL 11")
	_check("replaying level 4 cannot move Home or frontier backward", campaign.select_level("sunny_cove", 4) and campaign.get_frontier_level_id() == 11 and shell._home_value_labels.level.text == "11" and shell._home_value_labels.continue.text == "LEVEL 11")

	if failures.is_empty():
		print("M21_HOME_LABEL_R07_RESULT=PASS")
		quit(0)
		return
	print("M21_HOME_LABEL_R07_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
