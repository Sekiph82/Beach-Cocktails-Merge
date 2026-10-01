extends SceneTree

## BCM-M21 superseding M18 reward regression for the owner-locked no-timer rule.

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ISLAND_ID := "sunny_cove"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M18_UNTIMED_REWARD_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M18_UNTIMED_REWARD_PROBE FAIL: %s" % label)


func _state_before_star_threshold(threshold: int) -> Dictionary:
	var state: Dictionary = SAVE_SCRIPT.new().create_default_state()
	state["unlocked_islands"] = [ISLAND_ID]
	state["islands"][ISLAND_ID]["highest_unlocked_level"] = 100
	var completed: Dictionary = {}
	var full_levels := int((threshold - 2) / 3)
	for level_id in range(1, full_levels + 1):
		completed[str(level_id)] = {"completed": true, "stars": 3, "best_score": 300}
	completed[str(full_levels + 1)] = {"completed": true, "stars": 2, "best_score": 200}
	state["islands"][ISLAND_ID]["completed_levels"] = completed
	return state


func _configured(state: Dictionary) -> Dictionary:
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove loads", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	var economy = ECONOMY_SCRIPT.new()
	_check("economy configures from campaign state", economy.configure_from_state(state).get("ok", false))
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("campaign configures with economy authority", campaign.configure(database, state, economy))
	return {"campaign": campaign, "economy": economy}


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove loads", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	var track: Array = database.get_island(ISLAND_ID).get("reward_track", {}).get("cumulative_star_rewards", [])
	_check("all cumulative reward thresholds are preserved", track.size() == 10)
	var configured_thresholds := [150, 300]
	var valid_payloads := track.size() == 10
	for entry in track:
		var threshold := int(entry.get("threshold", 0))
		var reward: Dictionary = entry.get("reward", {})
		if configured_thresholds.has(threshold):
			valid_payloads = valid_payloads and reward.get("type", "") == "booster" and reward.get("id", "") == "upgrade" and int(reward.get("quantity", 0)) == 1
		else:
			valid_payloads = valid_payloads and reward.is_empty()
		_check("threshold %d is empty or an approved upgrade only" % threshold, reward.is_empty() or reward.get("id", "") == "upgrade")
	_check("only approved upgrade thresholds remain configured", valid_payloads)

	var thirty_bundle := _configured(_state_before_star_threshold(30))
	var thirty: Dictionary = thirty_bundle["campaign"].mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 300})
	_check("30 stars do not grant or claim retired +Time", thirty.get("cumulative_rewards", []).is_empty() and thirty_bundle["economy"].get_booster_count("time") == 0 and not thirty_bundle["campaign"].get_progression_state()["islands"][ISLAND_ID]["claimed_star_rewards"].has(30))

	var one_fifty_bundle := _configured(_state_before_star_threshold(150))
	var one_fifty: Dictionary = one_fifty_bundle["campaign"].mark_level_completed(ISLAND_ID, 50, {"stars": 3, "score": 300})
	_check("150 stars grant the approved upgrade once", one_fifty.get("cumulative_rewards", []).size() == 1 and one_fifty["cumulative_rewards"][0].get("threshold", 0) == 150 and one_fifty_bundle["economy"].get_booster_count("upgrade") == 1 and one_fifty_bundle["economy"].get_booster_count("time") == 0)
	var replay: Dictionary = one_fifty_bundle["campaign"].mark_level_completed(ISLAND_ID, 50, {"stars": 3, "score": 300})
	_check("150-star upgrade replay is idempotent", replay.get("cumulative_rewards", []).is_empty() and one_fifty_bundle["economy"].get_booster_count("upgrade") == 1)

	var three_hundred_bundle := _configured(_state_before_star_threshold(300))
	var three_hundred: Dictionary = three_hundred_bundle["campaign"].mark_level_completed(ISLAND_ID, 100, {"stars": 3, "score": 300})
	_check("300 stars grant only the two approved upgrades", three_hundred.get("cumulative_rewards", []).size() == 2 and three_hundred_bundle["economy"].get_booster_count("upgrade") == 2 and three_hundred_bundle["economy"].get_booster_count("time") == 0)
	_check("no production cumulative threshold grants +Time", three_hundred_bundle["economy"].get_booster_count("time") == 0)

	if failures.is_empty():
		print("M18_UNTIMED_CUMULATIVE_REWARD_RESULT=PASS")
		quit(0)
		return
	print("M18_UNTIMED_CUMULATIVE_REWARD_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
