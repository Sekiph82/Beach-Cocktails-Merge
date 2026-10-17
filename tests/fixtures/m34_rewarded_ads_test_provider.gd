extends RefCounted

## Deterministic fixture only. This script lives under tests/ and is not loaded
## by production scenes or the project autoload registry.

var load_results: Array[Dictionary] = []
var show_result: Dictionary = {"ok": true}
var load_calls := 0
var show_calls := 0
var cancel_calls := 0
var last_transaction_id := ""
var last_session_id := ""


func is_test_provider() -> bool:
	return true


func request_rewarded(_placement_id: String, transaction_id: String) -> Dictionary:
	load_calls += 1
	last_transaction_id = transaction_id
	if load_results.is_empty():
		return {"ok": true, "ready": true}
	return load_results.pop_front()


func show_rewarded(transaction_id: String) -> Dictionary:
	show_calls += 1
	last_transaction_id = transaction_id
	return show_result.duplicate(true)


func cancel_rewarded(transaction_id: String, session_id: String) -> void:
	cancel_calls += 1
	last_transaction_id = transaction_id
	last_session_id = session_id
