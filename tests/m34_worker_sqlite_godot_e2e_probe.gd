extends "res://tests/support/isolated_test_scene_tree.gd"

const BCM_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")
const NAVIGATION_SCRIPT := preload("res://scripts/campaign/campaign_navigation_controller.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")


class E2EIdentityProvider extends RefCounted:
	var token := OS.get_environment("BCM_E2E_AUTH_TOKEN")
	var subject := OS.get_environment("BCM_E2E_USER_ID")
	func get_bearer_token() -> String:
		return token
	func get_subject() -> String:
		return subject
	func is_subject_bound_to_active_profile(value: String) -> bool:
		return value == subject


var failures: Array[String] = []
var pending_responses := 0
var ack_responses := 0
var last_pending: Dictionary = {}
var last_delivery: Dictionary = {}
var durable_before_async_ack := false


func _init() -> void:
	if not BCM_SANDBOX_GUARD.enforce(self):
		return
	call_deferred("_run")


func _on_pending(_subject: String, response: Dictionary) -> void:
	pending_responses += 1
	last_pending = response.duplicate(true)


func _on_ack(_subject: String, _transaction_id: String, response: Dictionary) -> void:
	ack_responses += 1
	last_delivery = response.duplicate(true)


func _on_delivery_status(response: Dictionary) -> void:
	last_delivery = response.duplicate(true)
	if str(response.get("reason", "")) == "SERVER_ACK_PENDING" and bool(response.get("persisted", false)):
		durable_before_async_ack = true


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_WORKER_SQLITE_E2E PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_WORKER_SQLITE_E2E FAIL: %s" % label)


func _new_navigation(provider: E2EIdentityProvider) -> CampaignNavigationController:
	var navigation = NAVIGATION_SCRIPT.new()
	root.add_child(navigation)
	var configured: Dictionary = navigation.configure_mobile_reward_delivery("https://local-test.invalid", provider, true)
	if not bool(configured.get("ok", false)):
		return navigation
	navigation.mobile_reward_transport.endpoint = OS.get_environment("BCM_E2E_WORKER_ENDPOINT")
	navigation.mobile_reward_transport.pending_rewards_received.connect(_on_pending)
	navigation.mobile_reward_transport.acknowledgement_received.connect(_on_ack)
	navigation.mobile_reward_delivery_status.connect(_on_delivery_status)
	return navigation


func _wait_for(predicate: Callable, frames: int = 120) -> bool:
	for _frame in range(frames):
		if predicate.call():
			return true
		await create_timer(0.05).timeout
	return predicate.call()


func _run() -> void:
	if OS.get_environment("BCM_E2E_REPLAY_ONLY") == "1":
		await _run_process_restart_replay()
		return
	var initial_provider := E2EIdentityProvider.new()
	var navigation: CampaignNavigationController = _new_navigation(initial_provider)
	var endpoint := OS.get_environment("BCM_E2E_WORKER_ENDPOINT")
	var baseline: Dictionary = navigation.economy.export_state() if navigation.economy != null else {}
	_check("test-only fixture configures the genuine CampaignNavigationController", navigation.mobile_reward_transport != null and navigation.economy != null and navigation.save_manager != null and endpoint.begins_with("http://127.0.0.1:"))
	if navigation.mobile_reward_transport == null or navigation.economy == null:
		quit(1)
		return
	_check("production transport's requestCompleted path receives a real local Worker pending response", await _wait_for(func(): return pending_responses >= 1))
	_check("SQLite-backed Worker reward is granted and persisted before its asynchronous ACK", int(navigation.economy.coins) == int(baseline.get("coins", -1)) + 40 and durable_before_async_ack)
	_check("Worker ACK response and queue refresh complete", await _wait_for(func(): return pending_responses >= 2 and last_pending.get("rewards", []).is_empty()))
	var after_first := SAVE_SCRIPT.new().read_state()
	_check("SaveManager persisted the one verified reward", int(after_first.get("state", {}).get("coins", -1)) == int(baseline.get("coins", -1)) + 40)
	navigation.queue_free()
	await process_frame

	pending_responses = 0
	ack_responses = 0
	var restarted := _new_navigation(E2EIdentityProvider.new())
	_check("restart reloads saved economy without replaying a second grant", await _wait_for(func(): return pending_responses >= 1) and int(restarted.economy.coins) == int(baseline.get("coins", -1)) + 40)
	_check("restart observes empty Worker pending queue and preserves durable balance", last_pending.get("rewards", []).is_empty() and int(restarted.economy.coins) == int(baseline.get("coins", -1)) + 40)
	restarted.queue_free()
	await process_frame
	if failures.is_empty():
		print("M34_WORKER_SQLITE_E2E_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_WORKER_SQLITE_E2E_RESULT=FAIL checks=%s" % JSON.stringify(failures))
		quit(1)





func _run_process_restart_replay() -> void:
	var restarted: CampaignNavigationController = _new_navigation(E2EIdentityProvider.new())
	var restored: Dictionary = restarted.economy.export_state()
	_check("fresh Godot process reloads durable SaveManager balance and transaction ledger", int(restored.get("coins", -1)) == 140 and restored.get("transaction_ledger", []).has("bcm-v07-e2e-transaction"))
	_check("fresh process replay sees empty acknowledged Worker queue without a second grant", await _wait_for(func(): return pending_responses >= 1) and last_pending.get("rewards", []).is_empty() and int(restarted.economy.coins) == 140)
	restarted.queue_free()
	await process_frame
	if failures.is_empty():
		print("M34_WORKER_SQLITE_E2E_RESTART_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_WORKER_SQLITE_E2E_RESTART_RESULT=FAIL checks=%s" % JSON.stringify(failures))
		quit(1)
