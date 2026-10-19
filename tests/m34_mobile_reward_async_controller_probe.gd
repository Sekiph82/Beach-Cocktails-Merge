extends SceneTree

const NAVIGATION_SCRIPT := preload("res://scripts/campaign/campaign_navigation_controller.gd")
const TRANSPORT_SCRIPT := preload("res://scripts/campaign/mobile_reward_http_transport.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var failures: Array[String] = []
var last_delivery_status: Dictionary = {}


class FakeIdentityProvider extends RefCounted:
	var subject := "account-a"
	var active_save_subject := "account-a"
	func get_bearer_token() -> String:
		return "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2NvdW50LWEifQ.c2lnbmF0dXJl"
	func get_subject() -> String:
		return subject
	func is_subject_bound_to_active_profile(value: String) -> bool:
		return value == subject and value == active_save_subject


class FakeHttpDriver extends Node:
	signal request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)
	var requests: Array[Dictionary] = []
	func request(url: String, headers: PackedStringArray, method: int, body: String = "") -> int:
		requests.append({"url": url, "headers": headers, "method": method, "body": body})
		return OK
	func respond(response_code: int, payload: Dictionary) -> void:
		request_completed.emit(HTTPRequest.RESULT_SUCCESS, response_code, PackedStringArray(), JSON.stringify(payload).to_utf8_buffer())
	func last_request() -> Dictionary:
		return requests.back() if not requests.is_empty() else {}


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_ASYNC_REWARD PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_ASYNC_REWARD FAIL: %s" % label)


func _on_delivery_status(result: Dictionary) -> void:
	last_delivery_status = result.duplicate(true)


func _add_navigation(provider: FakeIdentityProvider, driver: FakeHttpDriver) -> CampaignNavigationController:
	var navigation: CampaignNavigationController = NAVIGATION_SCRIPT.new()
	root.add_child(navigation)
	var configured := navigation.configure_mobile_reward_delivery("https://rewards.test", provider, true)
	if not bool(configured.get("ok", false)):
		return navigation
	navigation.mobile_reward_transport.set_http_request_driver_for_test(driver)
	return navigation


func _reward(transaction_id: String, slot: int, item: String, amount: int, day: String, user_id: String = "account-a") -> Dictionary:
	return {
		"transaction_id": transaction_id,
		"client_transaction_id": "daily:%s:%d" % [day, slot],
		"user_id": user_id,
		"placement_id": "daily_slot_%d" % slot,
		"reward_item": item,
		"reward_amount": amount,
		"granted_at": int(Time.get_unix_time_from_system()),
	}


func _run() -> void:
	var provider := FakeIdentityProvider.new()
	var server_pending: Array[Dictionary] = []
	var driver := FakeHttpDriver.new()
	var navigation := _add_navigation(provider, driver)
	await process_frame
	navigation.mobile_reward_delivery_status.connect(_on_delivery_status)
	_check("real CampaignNavigationController configures authenticated HTTPS transport", navigation.mobile_reward_transport != null and navigation.economy != null and navigation.save_manager != null)
	if navigation.mobile_reward_transport == null or navigation.economy == null:
		quit(1)
		return
	var today_parts := Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()))
	var today := "%04d-%02d-%02d" % [today_parts.year, today_parts.month, today_parts.day]
	var reward_a := _reward("ssv-google-tx-a", 3, "coins", 40, today)
	var reward_b := _reward("ssv-google-tx-b", 4, "gems", 2, today)
	server_pending = [reward_a.duplicate(true), reward_b.duplicate(true)]
	var baseline: Dictionary = navigation.economy.export_state()
	var profile_changed := driver.last_request()
	provider.subject = "account-b"
	driver.respond(200, {"rewards": [reward_a]})
	_check("startup automatically reconciles; authenticated account switch before response prevents credit", profile_changed.get("url", "").ends_with("/v1/ads/rewards/pending") and int(navigation.economy.coins) == int(baseline["coins"]) and int(navigation.economy.gems) == int(baseline["gems"]))
	var unbound_b := navigation.reconcile_pending_mobile_rewards()
	_check("account B cannot query/apply rewards while account A save is active", not unbound_b.get("ok", false) and unbound_b.get("reason", "") == "AUTHENTICATED_PROFILE_BINDING_REQUIRED")
	provider.subject = "account-a"
	var first_fetch := navigation.reconcile_pending_mobile_rewards()
	driver.respond(200, {"rewards": server_pending.duplicate(true)})
	_check("first pending row is applied and canonically persisted before asynchronous ACK", first_fetch.get("pending", false) and last_delivery_status.get("reason", "") == "SERVER_ACK_PENDING" and int(navigation.economy.coins) == int(baseline["coins"]) + 40 and int(navigation.economy.gems) == int(baseline["gems"]) and int(driver.last_request().get("method", -1)) == HTTPClient.METHOD_POST)
	driver.respond(503, {})
	_check("failed asynchronous ACK leaves the server row pending and local grant durable", server_pending.size() == 2 and int(navigation.economy.coins) == int(baseline["coins"]) + 40)
	navigation.queue_free()
	await process_frame

	var restarted_driver := FakeHttpDriver.new()
	var restarted := _add_navigation(provider, restarted_driver)
	restarted.mobile_reward_delivery_status.connect(_on_delivery_status)
	await process_frame
	var restored_baseline: Dictionary = restarted.economy.export_state()
	restarted_driver.respond(200, {"rewards": server_pending.duplicate(true)})
	_check("process recreation automatically reloads the saved first reward without granting it twice", int(restarted.economy.coins) == int(baseline["coins"]) + 40 and int(restarted.economy.gems) == int(baseline["gems"]))
	restarted_driver.respond(200, {"ok": true, "transaction_id": "ssv-google-tx-a", "duplicate": false})
	server_pending.erase(reward_a)
	_check("successful ACK callback automatically starts the next authenticated pending fetch method=%s pending=%d" % [str(restarted_driver.last_request().get("method", -1)), server_pending.size()], int(restarted_driver.last_request().get("method", -1)) == HTTPClient.METHOD_GET and server_pending.size() == 1)
	restarted_driver.respond(200, {"rewards": server_pending.duplicate(true)})
	_check("second pending reward traverses controller signal, GameEconomy and SaveManager economy=%s status=%s request=%s" % [JSON.stringify(restarted.economy.export_state()), JSON.stringify(last_delivery_status), JSON.stringify(restarted_driver.last_request())], int(restarted.economy.coins) == int(baseline["coins"]) + 40 and int(restarted.economy.gems) == int(baseline["gems"]) + 2 and int(restarted_driver.last_request().get("method", -1)) == HTTPClient.METHOD_POST)
	restarted_driver.respond(200, {"ok": true, "transaction_id": "ssv-google-tx-b", "duplicate": false})
	server_pending.erase(reward_b)
	restarted_driver.respond(200, {"rewards": server_pending.duplicate(true)})
	var saved := SAVE_SCRIPT.new().read_state()
	_check("after ACK and empty fetch, persisted campaign state contains each reward exactly once saved=%s status=%s pending=%d" % [JSON.stringify(saved.get("state", {})), JSON.stringify(last_delivery_status), server_pending.size()], server_pending.is_empty() and int(saved.get("state", {}).get("coins", -1)) == int(baseline["coins"]) + 40 and int(saved.get("state", {}).get("gems", -1)) == int(baseline["gems"]) + 2 and int(restored_baseline.get("coins", -1)) == int(baseline["coins"]) + 40 and int(restored_baseline.get("gems", -1)) == int(baseline["gems"]))
	restarted.queue_free()
	await process_frame
	if failures.is_empty():
		print("M34_ASYNC_REWARD_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_ASYNC_REWARD_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
