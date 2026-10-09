extends SceneTree

## BCM-M25 move-budget session-contract probe. Runtime mouse/touch trials are
## recorded separately; this probe covers the authoritative session ledger.

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M25_MOVE_LIMIT PASS: %s" % label)
	else:
		failures.append(label)
		print("M25_MOVE_LIMIT FAIL: %s" % label)


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	_check("canonical level database loads", database.load_canonical())
	var bridge = BRIDGE_SCRIPT.new()
	_check("session bridge configures", bridge.configure(database))
	var configuration: Dictionary = bridge.start_session("sunny_cove", 6)
	_check("L6 config carries the candidate 35-move limit", int(configuration.get("move_limit", 0)) == 35)
	_check("L6 starts with all 35 moves", int(configuration.get("moves_remaining", 0)) == 35)
	_check("session snapshot is immutable", configuration.get("level_definition", {}).is_read_only())
	_check("session becomes active", bridge.mark_gameplay_ready())
	for move in range(1, 35):
		var response: Dictionary = bridge.record_committed_shot("shot-%d" % move)
		_check("successful shot %d is counted once" % move, bool(response.get("ok", false)) and int(response.state.moves_used) == move)
	var paused_before: Dictionary = bridge.get_move_budget_state()
	_check("active session can pause", bridge.set_gameplay_paused(true))
	_check("paused session rejects shot commits", not bool(bridge.record_committed_shot("paused-shot").get("ok", false)))
	_check("pause does not change budget", bridge.get_move_budget_state() == paused_before)
	_check("active session resumes", bridge.set_gameplay_paused(false))
	var last: Dictionary = bridge.record_committed_shot("shot-35")
	_check("35th committed shot exhausts budget", bool(last.get("ok", false)) and bool(last.state.exhausted) and int(last.state.moves_remaining) == 0)
	_check("duplicate signal for last drink is idempotent", bool(bridge.record_committed_shot("shot-35").get("duplicate", false)) and int(bridge.get_move_budget_state().moves_used) == 35)
	_check("36th distinct shot is rejected", not bool(bridge.record_committed_shot("shot-36").get("ok", false)) and int(bridge.get_move_budget_state().moves_used) == 35)
	var lost: Dictionary = bridge.resolve_lose("MOVES_EXHAUSTED", 123)
	_check("move exhaustion resolves one immutable LOSE result", lost.get("outcome", "") == "LOSE" and lost.get("reason", "") == "MOVES_EXHAUSTED" and int(lost.get("score", -1)) == 123)
	var retry: Dictionary = bridge.retry_session()
	_check("retry restores all configured moves", int(retry.get("move_limit", 0)) == 35 and int(bridge.get_move_budget_state().moves_remaining) == 35)
	_check("retry resets the shot-token ledger", bridge.mark_gameplay_ready() and bool(bridge.record_committed_shot("shot-1").get("ok", false)) and int(bridge.get_move_budget_state().moves_used) == 1)

	var unlimited = BRIDGE_SCRIPT.new()
	_check("unlimited bridge configures", unlimited.configure(database))
	var ordinary: Dictionary = unlimited.start_session("sunny_cove", 7)
	var ordinary_thresholds: Dictionary = ordinary.get("score_star_thresholds", {})
	_check("unset levels retain unlimited fallback", int(ordinary.get("move_limit", -1)) == 0 and not bool(unlimited.get_move_budget_state().get("enabled", true)))
	_check("existing score-star thresholds remain unchanged", int(ordinary_thresholds.get("one_star", -1)) == 0 and int(ordinary_thresholds.get("two_stars", -1)) == 1350 and int(ordinary_thresholds.get("three_stars", -1)) == 1650)

	var final_move = BRIDGE_SCRIPT.new()
	_check("final-move bridge configures", final_move.configure(database))
	_check("final-move level starts", not final_move.start_session("sunny_cove", 6).is_empty() and final_move.mark_gameplay_ready())
	for move in range(1, 35):
		final_move.record_committed_shot("final-route-%d" % move)
	var final_commit: Dictionary = final_move.record_committed_shot("final-route-35")
	_check("final route reaches zero after successful commit", bool(final_commit.get("ok", false)) and bool(final_commit.state.exhausted))
	final_move.record_to_go_delivery(6, 1, "final-L6", 2850)
	var final_order: Dictionary = final_move.record_to_go_delivery(5, 1, "final-L5", 2850)
	_check("completed objectives on the last move resolve WIN", final_order.get("terminal", {}).get("outcome", "") == "WIN")
	_check("objective completion keeps existing score stars", int(final_move.get_terminal_result().get("stars", 0)) == 2)

	if failures.is_empty():
		print("M25_MOVE_LIMIT_RESULT PASS")
		quit(0)
	else:
		print("M25_MOVE_LIMIT_RESULT FAIL count=%d" % failures.size())
		quit(1)
