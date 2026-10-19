extends SceneTree

const ADS_SCRIPT := preload("res://scripts/campaign/ads_service.gd")
const ADAPTER_SCRIPT := preload("res://scripts/campaign/admob_test_adapter.gd")
const LOAD_AD_REQUEST_SCRIPT := preload("res://addons/AdmobPlugin/model/LoadAdRequest.gd")

var failures: Array[String] = []
var earned_notifications := 0


class FakeAdInfo extends RefCounted:
	var ad_id := ""
	func _init(value: String) -> void:
		ad_id = value
	func get_ad_id() -> String:
		return ad_id


class FakeAdmob extends RefCounted:
	signal rewarded_ad_loaded(ad_info: Object, response_info: Object)
	signal rewarded_ad_failed_to_load(ad_info: Object, error_data: Object)
	signal rewarded_ad_user_earned_reward(ad_info: Object, reward_data: Object)
	signal rewarded_ad_dismissed_full_screen_content(ad_info: Object)
	signal rewarded_ad_failed_to_show_full_screen_content(ad_info: Object, error_data: Object)
	var is_initialization_completed := true
	var is_real := false
	var consent := UserConsent.new("OBTAINED")
	var requested_id := ""
	var requested_user_id := ""
	var requested_custom_data := ""
	var requested_raw_data: Dictionary = {}
	var shown_id := ""
	var loaded := false
	func is_test_fixture() -> bool:
		return true
	func get_consent_status() -> Object:
		return consent
	func create_basic_ad_request() -> Object:
		return LOAD_AD_REQUEST_SCRIPT.new()
	func load_rewarded_ad(request: Object) -> void:
		requested_id = request.get_ad_unit_id()
		requested_user_id = request.get_user_id()
		requested_custom_data = request.get_custom_data()
		requested_raw_data = request.get_raw_data().duplicate(true)
		loaded = false
	func is_rewarded_ad_loaded() -> bool:
		return loaded
	func show_rewarded_ad(ad_id: String) -> void:
		shown_id = ad_id
	func remove_rewarded_ad(_ad_id: String) -> void:
		loaded = false


class FakeClaimTransport extends RefCounted:
	signal ad_claim_created(placement_id: String, client_transaction_id: String, session_id: String, response: Dictionary)
	var placement := ""
	var transaction := ""
	var session := ""
	var consent := ""
	var authenticated_subject := "test-player"
	func get_authenticated_subject() -> String:
		return authenticated_subject
	func request_ad_claim(placement_id: String, platform: String, client_transaction_id: String, session_id: String, consent_state: String) -> Dictionary:
		placement = placement_id
		transaction = client_transaction_id
		session = session_id
		consent = consent_state
		return {"ok": platform in ["android", "ios"], "pending": true}
	func resolve(response: Dictionary) -> void:
		ad_claim_created.emit(placement, transaction, session, response)


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_ADMOB_ADAPTER PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_ADMOB_ADAPTER FAIL: %s" % label)


func _on_native_earned(_placement: String, _transaction: String, _session: String) -> void:
	earned_notifications += 1


func _run() -> void:
	var service: AdsService = ADS_SCRIPT.new()
	root.add_child(service)
	var plugin := FakeAdmob.new()
	var claim_transport := FakeClaimTransport.new()
	var adapter: AdmobTestAdapter = ADAPTER_SCRIPT.new()
	plugin.consent = UserConsent.new("UNKNOWN")
	var no_consent := adapter.configure_test_fixture(plugin, service)
	_check("unresolved UMP consent blocks provider setup", not no_consent.get("ok", false) and no_consent.get("reason", "") == "UMP_CONSENT_NOT_RESOLVED")
	plugin.consent = UserConsent.new("OBTAINED")
	var attached := adapter.configure_test_fixture(plugin, service)
	_check("native test adapter attaches only in debug fixture mode with resolved UMP state", attached.get("ok", false) and attached.get("test_only", false))
	_check("TEST adapter requires the Worker claim transport", adapter.set_claim_transport(claim_transport))
	adapter.native_reward_earned.connect(_on_native_earned)
	var requested := service.request_rewarded("energy_20", "native-tx-1")
	_check("placement maps to a user-bound test claim and carries resolved UMP state", requested.get("pending", false) and claim_transport.placement == "energy_20" and claim_transport.consent == "UMP_OBTAINED")
	claim_transport.resolve({"ok": true, "nonce": "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a471", "user_id": "test-player", "platform": "android", "placement_id": "energy_20", "client_transaction_id": "native-tx-1", "session_id": str(requested.get("session_id", "")), "ad_unit": AdmobTestAdapter.ANDROID_TEST_UNIT, "reward_item": "energy", "reward_amount": 20})
	_check("installed LoadAdRequest serialization carries authenticated user_id and SSV nonce", plugin.requested_id == AdmobTestAdapter.ANDROID_TEST_UNIT and plugin.requested_user_id == "test-player" and plugin.requested_custom_data == "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a471" and plugin.requested_raw_data.get("user_id", "") == "test-player" and plugin.requested_raw_data.get("custom_data", "") == "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a471")
	var session := str(requested.get("session_id", ""))
	var ad_info := FakeAdInfo.new(plugin.requested_id)
	plugin.loaded = true
	plugin.rewarded_ad_loaded.emit(ad_info, null)
	_check("actual rewarded_ad_loaded signal transitions AdsService to READY", service.state == AdsService.STATE_READY)
	var shown := service.show_rewarded()
	_check("show uses the loaded ad id through the installed plugin method", shown.get("ok", false) and plugin.shown_id == plugin.requested_id)
	plugin.rewarded_ad_user_earned_reward.emit(ad_info, null)
	plugin.rewarded_ad_user_earned_reward.emit(ad_info, null)
	_check("earned callback is correlated to the active session and idempotent", service.state == AdsService.STATE_VERIFYING and earned_notifications == 1)
	_check("native earned callback alone does not emit a verified reward", not service.accept_provider_reward("native-tx-1", "client-receipt", false, session).get("ok", false))
	plugin.rewarded_ad_dismissed_full_screen_content.emit(ad_info)
	service.expire_active_request()
	_check("server verification timeout fails closed and releases the active transaction", service.state == AdsService.STATE_FAILED)
	var second := service.request_rewarded("daily_slot_2", "native-tx-2")
	claim_transport.resolve({"ok": true, "nonce": "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a472", "user_id": "test-player", "platform": "android", "placement_id": "daily_slot_2", "client_transaction_id": "native-tx-2", "session_id": str(second.get("session_id", "")), "ad_unit": AdmobTestAdapter.ANDROID_TEST_UNIT, "reward_item": "energy", "reward_amount": 20})
	var second_info := FakeAdInfo.new(plugin.requested_id)
	plugin.rewarded_ad_failed_to_load.emit(second_info, null)
	_check("rewarded_ad_failed_to_load follows bounded retry lifecycle", second.get("pending", false) and service.state == AdsService.STATE_RETRY_WAIT)
	service.notify_skipped_or_closed_without_reward()
	plugin.rewarded_ad_user_earned_reward.emit(second_info, null)
	_check("cancelled session rejects stale earned callback", earned_notifications == 1 and service.state == AdsService.STATE_CANCELLED)
	var switched_user := service.request_rewarded("energy_20", "native-tx-switch")
	claim_transport.authenticated_subject = "different-authenticated-user"
	claim_transport.resolve({"ok": true, "nonce": "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a473", "user_id": "test-player", "platform": "android", "placement_id": "energy_20", "client_transaction_id": "native-tx-switch", "session_id": str(switched_user.get("session_id", "")), "ad_unit": AdmobTestAdapter.ANDROID_TEST_UNIT, "reward_item": "energy", "reward_amount": 20})
	_check("claim response for a stale authenticated account cannot reach AdMob", service.state == AdsService.STATE_FAILED and plugin.requested_user_id == "test-player")
	claim_transport.authenticated_subject = "test-player"
	plugin.consent = UserConsent.new("REQUIRED")
	var denied_request := adapter.request_rewarded_with_session("energy_20", "native-tx-3", "session-3")
	_check("consent is rechecked immediately before native ad request", not denied_request.get("ok", false) and denied_request.get("reason", "") == "UMP_CONSENT_NOT_RESOLVED")
	plugin.consent = UserConsent.new("OBTAINED")
	var denied_claim := service.request_rewarded("energy_20", "native-tx-4")
	claim_transport.resolve({"ok": false, "reason": "SERVER_CLAIM_DENIED"})
	_check("Worker claim denial blocks SDK ad loading and grants nothing", denied_claim.get("pending", false) and service.state == AdsService.STATE_FAILED and plugin.requested_custom_data == "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a472")
	adapter.cancel_rewarded()
	service.free()
	if failures.is_empty():
		print("M34_ADMOB_ADAPTER_RESULT=PASS")
		quit(0)
	else:
		printerr("M34_ADMOB_ADAPTER_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
