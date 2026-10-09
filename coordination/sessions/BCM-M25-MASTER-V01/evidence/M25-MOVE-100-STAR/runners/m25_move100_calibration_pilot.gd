extends SceneTree

const LEVEL_DB := preload("res://scripts/campaign/level_database.gd")
const HARNESS := preload("res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-100-STAR/runners/m25_move100_physics_harness.gd")

var output_dir := ""
var failures: Array[String] = []

func _initialize() -> void:
	output_dir = OS.get_environment("M25_MOVE_CALIBRATION_OUTPUT").strip_edges()
	if not output_dir.begins_with("res://") or output_dir.contains(".."):
		output_dir = "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-100-STAR/calibration/pilot"
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var database = LEVEL_DB.new()
	if not database.load_canonical():
		_failures_append("database load failed: %s" % database.get_last_error())
		quit(1)
		return
	var levels: Array[int] = [1, 6, 20, 60, 100]
	var policies: Array[String] = ["WEAK_V02", "MERGE_AWARE_V01"]
	var seeds: Array[int] = [101, 202]
	var harness = HARNESS.new(root)
	harness.set_time_scale(1.0)
	var trials: Array[Dictionary] = []
	for level_id in levels:
		for policy in policies:
			for seed_value in seeds:
				var result: Dictionary = await harness.run_trial(database, "sunny_cove", level_id, seed_value, [], policy)
				var row := {
					"island_id": "sunny_cove", "level_id": level_id, "policy": policy,
					"seed": seed_value, "outcome": result.get("outcome", ""),
					"terminal_reason": result.get("terminal_reason", ""),
					"moves": int(result.get("shot_count", 0)),
					"merges": int(result.get("merge_count", 0)),
					"peak_live_drinks": int(result.get("peak_live_drinks", 0)),
					"mean_live_drinks": float(result.get("mean_live_drinks", 0.0)),
					"peak_board_occupancy": float(result.get("peak_board_occupancy", 0.0)),
					"normal_objective_complete": bool(result.get("normal_objective_complete", false)),
					"physics_hook": result.get("physics_hook", ""),
				}
				trials.append(row)
				print("M25_MOVE100_PILOT level=%d policy=%s seed=%d outcome=%s moves=%d merges=%d" % [level_id, policy, seed_value, row.outcome, row.moves, row.merges])
	var csv := "island_id,level_id,policy,seed,outcome,terminal_reason,moves,merges,peak_live_drinks,mean_live_drinks,peak_board_occupancy,normal_objective_complete\n"
	for row in trials:
		csv += "%s,%d,%s,%d,%s,%s,%d,%d,%d,%.4f,%.6f,%s\n" % [row.island_id, row.level_id, row.policy, row.seed, row.outcome, str(row.terminal_reason).replace(",", ";"), row.moves, row.merges, row.peak_live_drinks, row.mean_live_drinks, row.peak_board_occupancy, str(row.normal_objective_complete)]
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/pilot_trials.csv" % output_dir), FileAccess.WRITE)
	if file == null:
		_failures_append("could not open pilot_trials.csv")
	else:
		file.store_string(csv)
		file.close()
	var report := {"work_item": "BCM-M25-MOVE-100-STAR", "trial_count": trials.size(), "levels": levels, "policies": policies, "seeds": seeds, "time_scale": 1.0, "physics_harness": "M17SeededValidationHarness production GameManager/Drink bodies + Godot physics", "trials": trials, "failures": failures}
	var report_file := FileAccess.open(ProjectSettings.globalize_path("%s/pilot_summary.json" % output_dir), FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t") + "\n")
		report_file.close()
	print("M25_MOVE100_PILOT_RESULT %s trials=%d failures=%d" % ["PASS" if failures.is_empty() else "FAIL", trials.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func _failures_append(reason: String) -> void:
	failures.append(reason)
	push_error(reason)
