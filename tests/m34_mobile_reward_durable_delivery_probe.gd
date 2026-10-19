extends SceneTree

const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const DELIVERY_SCRIPT := preload("res://scripts/campaign/mobile_reward_delivery.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_REWARD_DELIVERY PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_REWARD_DELIVERY FAIL: %s" % label)


func _run() -> void:
	var save_manager: SaveManager = SAVE_SCRIPT.new()
	var delivery: MobileRewardDelivery = DELIVERY_SCRIPT.new()
	var path := "user://m34_reward_delivery_probe.json"
	var backup := path + ".bak"
	var now := int(Time.get_unix_time_from_system())
	var date_parts := Time.get_datetime_dict_from_unix_time(now)
	var today := "%04d-%02d-%02d" % [date_parts["year"], date_parts["month"], date_parts["day"]]
	var user_id := "test-player-42"
	var state: Dictionary = save_manager.create_default_state()
	state["energy"] = 60
	var economy: GameEconomy = ECONOMY_SCRIPT.new()
	economy.configure_from_state(state)
	var ack_state := {"calls": 0}
	var persist := func() -> Dictionary:
		var persisted: Dictionary = save_manager.create_default_state()
		persisted.merge(economy.export_state(), true)
		return save_manager.write_state(persisted, path, backup)
	var ack := func(_transaction_id: String) -> Dictionary:
		ack_state["calls"] += 1
		return {"ok": false, "reason": "simulated_timeout"}
	var row := {"transaction_id": "ad-tx-0001", "client_transaction_id": "", "user_id": user_id, "placement_id": "energy_20", "reward_item": "energy", "reward_amount": 20}
	var first := delivery.settle_pending_rows([row], user_id, economy, persist, ack, now)
	_check("server verified energy is applied in canonical GameEconomy and SaveManager before ACK", not first.get("ok", false) and first.get("reason", "") == "SERVER_ACK_PENDING" and economy.energy == 80 and ack_state["calls"] == 1)
	var loaded: Dictionary = save_manager.read_state(path, backup, "user://missing_legacy.cfg")
	var reopened: GameEconomy = ECONOMY_SCRIPT.new()
	_check("the saved campaign snapshot reloads and validates after process recreation", loaded.get("status", "") == save_manager.STATUS_VALID and reopened.configure_from_state(loaded.get("state", {})).get("ok", false) and reopened.energy == 80)
	var successful_ack := func(_transaction_id: String) -> Dictionary:
		ack_state["calls"] += 1
		return {"ok": true}
	var replay := delivery.settle_pending_rows([row], user_id, reopened, func() -> Dictionary:
		var persisted: Dictionary = save_manager.create_default_state()
		persisted.merge(reopened.export_state(), true)
		return save_manager.write_state(persisted, path, backup), successful_ack, now)
	_check("crash before ACK safely retries as a durable duplicate without a second grant", replay.get("ok", false) and reopened.energy == 80 and ack_state["calls"] == 2)
	var mismatched_user := row.duplicate(true)
	mismatched_user["user_id"] = "other-player"
	var before_ack_calls := int(ack_state["calls"])
	var wrong_user := delivery.settle_pending_rows([mismatched_user], user_id, reopened, persist, successful_ack, now)
	_check("user mismatch fails closed before mutation or ACK", not wrong_user.get("ok", false) and wrong_user.get("reason", "") == "PENDING_USER_MISMATCH" and ack_state["calls"] == before_ack_calls)
	var malformed := row.duplicate(true)
	malformed["reward_amount"] = 20000
	var bad_amount := delivery.settle_pending_rows([malformed], user_id, reopened, persist, successful_ack, now)
	_check("oversized reward payload is rejected before mutation", not bad_amount.get("ok", false) and reopened.energy == 80)
	var save_failure := delivery.settle_pending_rows([{"transaction_id": "ad-tx-0002", "client_transaction_id": "", "user_id": user_id, "placement_id": "energy_20", "reward_item": "energy", "reward_amount": 20}], user_id, reopened, func() -> Dictionary:
		return {"ok": false, "reason": "injected_save_failure"}, successful_ack, now)
	_check("save failure rolls back the in-memory economy and withholds ACK", not save_failure.get("ok", false) and save_failure.get("reason", "") == "LOCAL_DURABLE_SAVE_FAILED" and reopened.energy == 80 and ack_state["calls"] == before_ack_calls)
	var recovered_save := delivery.settle_pending_rows([{"transaction_id": "ad-tx-0002", "client_transaction_id": "", "user_id": user_id, "placement_id": "energy_20", "reward_item": "energy", "reward_amount": 20}], user_id, reopened, func() -> Dictionary:
		var persisted: Dictionary = save_manager.create_default_state()
		persisted.merge(reopened.export_state(), true)
		return save_manager.write_state(persisted, path, backup), successful_ack, now)
	_check("same server transaction recovers after storage returns, persists once and only then retries ACK", recovered_save.get("ok", false) and recovered_save.get("settled", 0) == 1 and reopened.energy == 100 and ack_state["calls"] == before_ack_calls + 1)
	var daily_state := reopened.export_state()
	daily_state["energy"] = 50
	reopened.configure_from_state(daily_state)
	var daily_rows: Array = [
		{"transaction_id": "server-google-tx-2", "client_transaction_id": "daily:%s:2" % today, "user_id": user_id, "placement_id": "daily_slot_2", "reward_item": "energy", "reward_amount": 20},
		{"transaction_id": "server-google-tx-3", "client_transaction_id": "daily:%s:3" % today, "user_id": user_id, "placement_id": "daily_slot_3", "reward_item": "coins", "reward_amount": 40},
		{"transaction_id": "server-google-tx-4", "client_transaction_id": "daily:%s:4" % today, "user_id": user_id, "placement_id": "daily_slot_4", "reward_item": "gems", "reward_amount": 2},
		{"transaction_id": "server-google-tx-5", "client_transaction_id": "daily:%s:5" % today, "user_id": user_id, "placement_id": "daily_slot_5", "reward_item": "coins", "reward_amount": 80},
	]
	var daily_result := delivery.settle_pending_rows(daily_rows, user_id, reopened, func() -> Dictionary:
		var persisted: Dictionary = save_manager.create_default_state()
		persisted.merge(reopened.export_state(), true)
		return save_manager.write_state(persisted, path, backup), successful_ack, now)
	_check("UTC daily slots 2-5 preserve configured reward quantities and one-claim ledger", daily_result.get("ok", false) and daily_result.get("settled", 0) == 4 and reopened.energy == 70 and reopened.coins == 220 and reopened.gems == 7 and reopened.daily_slot_claimed(today, 2) and reopened.daily_slot_claimed(today, 5))
	var yesterday_parts := Time.get_datetime_dict_from_unix_time(now - 86400)
	var yesterday := "%04d-%02d-%02d" % [yesterday_parts["year"], yesterday_parts["month"], yesterday_parts["day"]]
	var delayed_row := {"transaction_id": "server-google-delayed", "client_transaction_id": "daily:%s:3" % yesterday, "user_id": user_id, "placement_id": "daily_slot_3", "reward_item": "coins", "reward_amount": 40}
	var delayed := delivery.settle_pending_rows([delayed_row], user_id, reopened, func() -> Dictionary:
		var persisted: Dictionary = save_manager.create_default_state()
		persisted.merge(reopened.export_state(), true)
		return save_manager.write_state(persisted, path, backup), successful_ack, now)
	_check("a previously SSV-settled daily claim survives app closure across UTC midnight", delayed.get("ok", false) and reopened.coins == 260 and reopened.daily_slot_claimed(yesterday, 3))
	var energy_edge := reopened.export_state()
	energy_edge["energy"] = 100
	reopened.configure_from_state(energy_edge)
	var full_energy_row := {"transaction_id": "ad-tx-full", "client_transaction_id": "", "user_id": user_id, "placement_id": "energy_20", "reward_item": "energy", "reward_amount": 20}
	var ack_calls_before_full_energy := int(ack_state["calls"])
	var full_energy := delivery.settle_pending_rows([full_energy_row], user_id, reopened, persist, successful_ack, now)
	_check("full energy remains a no-op, exposes retry UX and withholds server ACK", not full_energy.get("ok", false) and full_energy.get("reason", "") == "ENERGY_ALREADY_FULL" and full_energy.get("retryable", false) and full_energy.get("retry_when", "") == "energy_below_cap" and full_energy.get("server_ack", "") == "withheld_reward_remains_pending" and ack_state["calls"] == ack_calls_before_full_energy)
	if failures.is_empty():
		print("M34_REWARD_DELIVERY_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_REWARD_DELIVERY_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
