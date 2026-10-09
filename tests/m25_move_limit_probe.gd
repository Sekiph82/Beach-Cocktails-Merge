extends SceneTree

## BCM-M25 PERCENT400 contract probe. The canonical 100-level formula audit
## deliberately derives expected totals independently from LevelDatabase.

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const EVIDENCE_PATH := "res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-PERCENT400/level_formula_audit.json"

var failures: Array[String] = []
var audit_rows: Array[Dictionary] = []
var overlap_levels: Array[int] = []
var vip_level_count := 0


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M25_PERCENT400 PASS: %s" % label)
	else:
		failures.append(label)
		print("M25_PERCENT400 FAIL: %s" % label)


func _ideal_shots(level: int, quantity: int) -> int:
	if level < 3 or quantity <= 0:
		return 0
	return (1 << (level - 3)) * quantity


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign loads with full validation", database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, LEVELS_PATH, DATABASE_SCRIPT.ValidationMode.FULL))
	var canonical := JSON.parse_string(FileAccess.get_file_as_string(LEVELS_PATH)) as Dictionary
	var source_levels: Array = canonical.get("levels", [])
	var levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	_check("exactly 100 canonical Sunny Cove levels are present", source_levels.size() == 100 and levels.size() == 100)
	var bridge = BRIDGE_SCRIPT.new()
	var expected_overlap_levels: Array[int] = [8, 24, 32, 36, 56, 64, 72, 76, 80, 92, 96, 100]
	for level_id in range(1, 101):
		var raw_level: Dictionary = source_levels[level_id - 1] if level_id <= source_levels.size() else {}
		var level: Dictionary = database.get_level("sunny_cove", level_id)
		_check("L%d id is unique and ordered" % level_id, int(raw_level.get("level_id", 0)) == level_id and int(level.get("level_id", 0)) == level_id)
		var to_go := 0
		var normal_levels: Dictionary = {}
		for order in raw_level.get("orders", []):
			var target_level := int(order.get("cocktail_level", 0))
			var quantity := int(order.get("quantity", 0))
			to_go += _ideal_shots(target_level, quantity)
			normal_levels[target_level] = true
		var vip_shots := 0
		var vip: Variant = raw_level.get("vip", null)
		var enabled_vip := vip is Dictionary and bool(vip.get("enabled", true))
		if enabled_vip:
			vip_level_count += 1
			vip_shots = _ideal_shots(int(vip.get("cocktail_level", 0)), int(vip.get("quantity", 0)))
			if normal_levels.has(int(vip.get("cocktail_level", 0))):
				overlap_levels.append(level_id)
		var total := to_go + vip_shots
		var cap := total * 4
		_check("L%d derived To-Go/VIP denominator and 400%% cap match canonical inputs" % level_id,
			int(level.get("theoretical_shots_to_go", -1)) == to_go
			and int(level.get("theoretical_shots_vip", -1)) == vip_shots
			and int(level.get("theoretical_shots_total", -1)) == total
			and int(level.get("move_limit", -1)) == cap)
		_check("L%d exact 199/200/299/300/400/401%% star edges" % level_id,
			bridge.calculate_stars(true, total * 2 - 1, total) == 3
			and bridge.calculate_stars(true, total * 2, total) == 2
			and bridge.calculate_stars(true, total * 3 - 1, total) == 2
			and bridge.calculate_stars(true, total * 3, total) == 1
			and bridge.calculate_stars(true, total * 4, total) == 1
			and bridge.calculate_stars(true, total * 4 + 1, total) == 0
			and bridge.calculate_stars(false, total * 4, total) == 0)
		audit_rows.append({
			"level_id": level_id,
			"t_to_go": to_go,
			"t_vip": vip_shots,
			"t_total_inclusive": total,
			"move_limit_400_percent": cap,
			"vip_enabled": enabled_vip,
			"vip_target_overlaps_normal_level": enabled_vip and normal_levels.has(int(vip.get("cocktail_level", 0))),
			"vip_optional_even_if_normal_win_ends_first": enabled_vip,
		})
	_check("all 25 configured VIP levels are included", vip_level_count == 25)
	_check("the 12 same-level normal/VIP cases are disclosed", overlap_levels == expected_overlap_levels)
	_check("L6 anchor is T=12 and cap=48", int(database.get_level("sunny_cove", 6).get("theoretical_shots_total", 0)) == 12 and int(database.get_level("sunny_cove", 6).get("move_limit", 0)) == 48)
	_check("L8 anchor includes VIP: T=12+4=16 and cap=64", int(database.get_level("sunny_cove", 8).get("theoretical_shots_to_go", 0)) == 12 and int(database.get_level("sunny_cove", 8).get("theoretical_shots_vip", 0)) == 4 and int(database.get_level("sunny_cove", 8).get("move_limit", 0)) == 64)
	_check("L100 anchor includes VIP: T=60+16=76 and cap=304", int(database.get_level("sunny_cove", 100).get("theoretical_shots_to_go", 0)) == 60 and int(database.get_level("sunny_cove", 100).get("theoretical_shots_vip", 0)) == 16 and int(database.get_level("sunny_cove", 100).get("move_limit", 0)) == 304)
	_write_formula_audit()
	_probe_runtime_boundaries(database)

	if failures.is_empty():
		print("M25_PERCENT400_RESULT PASS levels=100 vip_levels=%d overlap_levels=%s" % [vip_level_count, str(overlap_levels)])
		quit(0)
	else:
		print("M25_PERCENT400_RESULT FAIL count=%d" % failures.size())
		quit(1)


func _probe_runtime_boundaries(database) -> void:
	var bridge = BRIDGE_SCRIPT.new()
	_check("runtime session bridge configures", bridge.configure(database))
	var configuration: Dictionary = bridge.start_session("sunny_cove", 6)
	_check("L6 session starts with derived 48-move budget and inclusive denominator", int(configuration.get("move_limit", 0)) == 48 and int(configuration.get("theoretical_shots_total", 0)) == 12)
	_check("session is active", bridge.mark_gameplay_ready())
	for move in range(1, 48):
		var response: Dictionary = bridge.record_committed_shot("shot-%d" % move)
		_check("committed shot %d counted exactly once" % move, bool(response.get("ok", false)) and int(response.state.moves_used) == move)
	var last := bridge.record_committed_shot("shot-48")
	_check("48th successful shot is committed", bool(last.get("ok", false)) and int(last.state.moves_remaining) == 0 and bool(last.state.exhausted))
	_check("duplicate 48th signal does not count twice", bool(bridge.record_committed_shot("shot-48").get("duplicate", false)) and int(bridge.get_move_budget_state().moves_used) == 48)
	_check("49th shot is rejected", not bool(bridge.record_committed_shot("shot-49").get("ok", false)) and int(bridge.get_move_budget_state().moves_used) == 48)
	var before_final := bridge.get_terminal_result()
	_check("last-shot completion wins with one move star", before_final.is_empty())
	bridge.record_to_go_delivery(6, 1, "last-shot-L6", 999999)
	var final_delivery: Dictionary = bridge.record_to_go_delivery(5, 1, "last-shot-L5", 0)
	_check("final 4T shot objective completion takes WIN precedence", final_delivery.get("terminal", {}).get("outcome", "") == "WIN")
	_check("score and VIP completion do not alter move-based stars", int(bridge.get_terminal_result().get("stars", 0)) == 1 and not bool(bridge.get_terminal_result().get("vip_completed", true)))
	var retry: Dictionary = bridge.retry_session()
	_check("retry restores the complete derived budget", int(retry.get("move_limit", 0)) == 48 and int(bridge.get_move_budget_state().get("moves_used", -1)) == 0 and bridge.mark_gameplay_ready())
	var lose := BRIDGE_SCRIPT.new()
	lose.configure(database)
	lose.start_session("sunny_cove", 8)
	lose.mark_gameplay_ready()
	var l8: Dictionary = lose.get_session_configuration()
	_check("L8 denominator includes optional VIP despite normal-first terminal semantics", int(l8.get("theoretical_shots_to_go", 0)) == 12 and int(l8.get("theoretical_shots_vip", 0)) == 4 and int(l8.get("move_limit", 0)) == 64)
	for move in range(1, 32):
		lose.record_committed_shot("l8-%d" % move)
	lose.record_to_go_delivery(5, 1, "l8-normal-shared-level")
	lose.record_to_go_delivery(6, 1, "l8-normal-final")
	_check("normal To-Go WIN may end before optional VIP; three stars still use inclusive T", int(lose.get_terminal_result().get("stars", 0)) == 3 and not bool(lose.get_terminal_result().get("vip_completed", true)))
	var exhausted := BRIDGE_SCRIPT.new()
	exhausted.configure(database)
	exhausted.start_session("sunny_cove", 6)
	exhausted.mark_gameplay_ready()
	for move in range(1, 49):
		exhausted.record_committed_shot("lose-%d" % move)
	var loss: Dictionary = exhausted.resolve_lose("MOVES_EXHAUSTED", 7654321)
	_check("incomplete 4T session naturally resolves MOVES_EXHAUSTED with zero stars", loss.get("outcome", "") == "LOSE" and loss.get("reason", "") == "MOVES_EXHAUSTED" and int(loss.get("stars", -1)) == 0 and int(loss.get("score", 0)) == 7654321)
	var no_vip_configuration: Dictionary = database.get_level("sunny_cove", 6)
	_check("no-VIP formula has T_vip=0 and leaves order targets intact", int(no_vip_configuration.get("theoretical_shots_vip", -1)) == 0 and no_vip_configuration.get("orders", []).size() == 2)


func _write_formula_audit() -> void:
	var payload := {
		"prompt": "BCM-M25-PERCENT400",
		"formula": "T = sum(quantity * 2^(cocktail_level-3)) for mandatory To-Go plus enabled VIP; move_limit=4*T",
		"star_policy": "WIN only: moves <2T=3; 2T<=moves<3T=2; 3T<=moves<=4T=1; incomplete at 4T=LOSE/0; 4T+1 rejected",
		"vip_denominator_note": "T includes configured VIP even if normal To-Go completion ends the session first. Fulfillment remains normal-first and a cocktail is never credited to both objectives.",
		"vip_levels": vip_level_count,
		"same_target_overlap_levels": overlap_levels,
		"levels": audit_rows,
	}
	var file := FileAccess.open(EVIDENCE_PATH, FileAccess.WRITE)
	if file == null:
		_failures_placeholder()
		return
	file.store_string(JSON.stringify(payload, "\t") + "\n")
	file.close()


func _failures_placeholder() -> void:
	failures.append("formula audit evidence path is writable")
