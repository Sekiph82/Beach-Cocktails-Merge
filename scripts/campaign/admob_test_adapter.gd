class_name AdmobTestAdapter
extends RefCounted

## Nonshipping adapter for the installed Godot AdMob plugin. Native earned
## callbacks are lifecycle signals only; they never grant game currency.

signal native_reward_earned(placement_id: String, transaction_id: String, session_id: String)

const ANDROID_TEST_UNIT := "ca-app-pub-3940256099942544/5224354917"
const IOS_TEST_UNIT := "ca-app-pub-3940256099942544/1712485313"
const TEST_PLACEMENTS := ["energy_20", "daily_slot_2", "daily_slot_3", "daily_slot_4", "daily_slot_5"]

var admob: Object
var ads_service: AdsService
var claim_transport: Object
var _transaction_id := ""
var _session_id := ""
var _placement_id := ""
var _ad_id := ""
var _earned := false
var _connected := false


func configure(plugin: Object, service: AdsService) -> Dictionary:
	if not OS.is_debug_build() or not (OS.has_feature("android") or OS.has_feature("ios")):
		return {"ok": false, "reason": "TEST_ADAPTER_UNSUPPORTED_PLATFORM"}
	if plugin == null or service == null or not plugin.has_method("load_rewarded_ad") or not plugin.has_method("show_rewarded_ad") or not plugin.has_method("is_rewarded_ad_loaded") or not plugin.has_method("create_basic_ad_request") or not plugin.has_method("get_consent_status"):
		return {"ok": false, "reason": "ADMOB_PLUGIN_UNAVAILABLE"}
	if not bool(plugin.get("is_initialization_completed")) or bool(plugin.get("is_real")):
		return {"ok": false, "reason": "TEST_ADMOB_NOT_INITIALIZED_OR_REAL_MODE"}
	var consent: Object = plugin.get_consent_status()
	if consent == null or int(consent.get("status")) not in [UserConsent.Status.OBTAINED, UserConsent.Status.NOT_REQUIRED]:
		return {"ok": false, "reason": "UMP_CONSENT_NOT_RESOLVED"}
	if not _has_required_signals(plugin):
		return {"ok": false, "reason": "ADMOB_REWARDED_SIGNALS_UNAVAILABLE"}
	return _attach(plugin, service)


func configure_test_fixture(plugin: Object, service: AdsService) -> Dictionary:
	if not OS.is_debug_build() or plugin == null or not plugin.has_method("is_test_fixture") or not bool(plugin.is_test_fixture()):
		return {"ok": false, "reason": "TEST_FIXTURE_REQUIRED"}
	if service == null or not _has_required_signals(plugin):
		return {"ok": false, "reason": "ADMOB_REWARDED_SIGNALS_UNAVAILABLE"}
	var consent: Object = plugin.get_consent_status()
	if consent == null or int(consent.get("status")) not in [UserConsent.Status.OBTAINED, UserConsent.Status.NOT_REQUIRED]:
		return {"ok": false, "reason": "UMP_CONSENT_NOT_RESOLVED"}
	return _attach(plugin, service)


func _attach(plugin: Object, service: AdsService) -> Dictionary:
	admob = plugin
	ads_service = service
	_connect_signals()
	var consent: Object = admob.get_consent_status()
	var consent_source := "UMP_OBTAINED" if int(consent.get("status")) == UserConsent.Status.OBTAINED else "UMP_NOT_REQUIRED"
	if not ads_service.set_provider_adapter(self, consent_source):
		_disconnect_signals()
		return {"ok": false, "reason": "ADS_SERVICE_REJECTED_TEST_ADAPTER"}
	return {"ok": true, "test_only": true, "consent_source": "UMP_PLUGIN_STATE"}


func set_claim_transport(transport: Object) -> bool:
	if transport == null or not transport.has_method("request_ad_claim") or not transport.has_signal("ad_claim_created"):
		return false
	if claim_transport != null and claim_transport.is_connected("ad_claim_created", _on_claim_created):
		claim_transport.disconnect("ad_claim_created", _on_claim_created)
	claim_transport = transport
	if not claim_transport.is_connected("ad_claim_created", _on_claim_created):
		claim_transport.connect("ad_claim_created", _on_claim_created)
	return true


func is_test_provider() -> bool:
	return true


func request_rewarded(placement_id: String, transaction_id: String, session_id: String = "") -> Dictionary:
	if admob == null or ads_service == null or placement_id not in TEST_PLACEMENTS or transaction_id.is_empty() or session_id.is_empty():
		return {"ok": false, "reason": "TEST_REWARDED_REQUEST_INVALID"}
	if claim_transport == null:
		return {"ok": false, "reason": "REWARD_CLAIM_TRANSPORT_UNAVAILABLE"}
	var consent: Object = admob.get_consent_status()
	if consent == null or int(consent.get("status")) not in [UserConsent.Status.OBTAINED, UserConsent.Status.NOT_REQUIRED]:
		return {"ok": false, "reason": "UMP_CONSENT_NOT_RESOLVED"}
	if OS.has_feature("ios"):
		_ad_id = IOS_TEST_UNIT
	else:
		_ad_id = ANDROID_TEST_UNIT
	_placement_id = placement_id
	_transaction_id = transaction_id
	_session_id = session_id
	_earned = false
	var consent_state := "UMP_OBTAINED" if int(consent.get("status")) == UserConsent.Status.OBTAINED else "UMP_NOT_REQUIRED"
	var platform := "ios" if OS.has_feature("ios") else "android"
	var claim: Dictionary = claim_transport.request_ad_claim(placement_id, platform, transaction_id, session_id, consent_state)
	if not bool(claim.get("ok", false)):
		_clear_session()
		return claim
	return {"ok": true, "pending": true}


func request_rewarded_with_session(placement_id: String, transaction_id: String, session_id: String) -> Dictionary:
	return request_rewarded(placement_id, transaction_id, session_id)


func show_rewarded(transaction_id: String, session_id: String = "") -> Dictionary:
	if admob == null or transaction_id != _transaction_id or session_id != _session_id or _ad_id.is_empty() or not bool(admob.is_rewarded_ad_loaded()):
		return {"ok": false, "reason": "TEST_REWARDED_AD_NOT_READY"}
	admob.show_rewarded_ad(_ad_id)
	return {"ok": true}


func show_rewarded_with_session(transaction_id: String, session_id: String) -> Dictionary:
	return show_rewarded(transaction_id, session_id)


func cancel_rewarded(transaction_id: String = "", session_id: String = "") -> void:
	if not transaction_id.is_empty() and transaction_id != _transaction_id:
		return
	if not session_id.is_empty() and session_id != _session_id:
		return
	if admob != null and not _ad_id.is_empty() and admob.has_method("remove_rewarded_ad"):
		admob.remove_rewarded_ad(_ad_id)
	_clear_session()


func _has_required_signals(plugin: Object) -> bool:
	for signal_name in ["rewarded_ad_loaded", "rewarded_ad_failed_to_load", "rewarded_ad_user_earned_reward", "rewarded_ad_dismissed_full_screen_content", "rewarded_ad_failed_to_show_full_screen_content"]:
		if not plugin.has_signal(signal_name):
			return false
	return true


func _connect_signals() -> void:
	if _connected:
		return
	admob.rewarded_ad_loaded.connect(_on_loaded)
	admob.rewarded_ad_failed_to_load.connect(_on_load_failed)
	admob.rewarded_ad_user_earned_reward.connect(_on_earned)
	admob.rewarded_ad_dismissed_full_screen_content.connect(_on_dismissed)
	admob.rewarded_ad_failed_to_show_full_screen_content.connect(_on_show_failed)
	_connected = true
	if claim_transport != null and not claim_transport.is_connected("ad_claim_created", _on_claim_created):
		claim_transport.connect("ad_claim_created", _on_claim_created)


func _disconnect_signals() -> void:
	if not _connected or admob == null:
		return
	for pair in [["rewarded_ad_loaded", Callable(self, "_on_loaded")], ["rewarded_ad_failed_to_load", Callable(self, "_on_load_failed")], ["rewarded_ad_user_earned_reward", Callable(self, "_on_earned")], ["rewarded_ad_dismissed_full_screen_content", Callable(self, "_on_dismissed")], ["rewarded_ad_failed_to_show_full_screen_content", Callable(self, "_on_show_failed")]]:
		if admob.is_connected(pair[0], pair[1]):
			admob.disconnect(pair[0], pair[1])
	_connected = false
	if claim_transport != null and claim_transport.is_connected("ad_claim_created", _on_claim_created):
		claim_transport.disconnect("ad_claim_created", _on_claim_created)


func _on_loaded(ad_info: Object, _response_info: Object) -> void:
	if _transaction_id.is_empty() or ad_info == null or not ad_info.has_method("get_ad_id") or str(ad_info.get_ad_id()) != _ad_id:
		return
	ads_service.notify_provider_loaded(_transaction_id, _session_id)


func _on_claim_created(placement_id: String, transaction_id: String, session_id: String, response: Dictionary) -> void:
	if placement_id != _placement_id or transaction_id != _transaction_id or session_id != _session_id or not ads_service.is_active_provider_session(_transaction_id, _session_id):
		return
	if not bool(response.get("ok", false)):
		ads_service.notify_provider_load_failed(_transaction_id, _session_id, str(response.get("reason", "SERVER_CLAIM_DENIED")), false)
		_clear_session()
		return
	var expected := _expected_reward(_placement_id)
	if str(response.get("user_id", "")).is_empty() or str(response.get("ad_unit", "")) != _ad_id or str(response.get("reward_item", "")) != str(expected.get("item", "")) or int(response.get("reward_amount", 0)) != int(expected.get("amount", -1)) or str(response.get("nonce", "")).is_empty():
		ads_service.notify_provider_load_failed(_transaction_id, _session_id, "SERVER_CLAIM_MISMATCH", false)
		_clear_session()
		return
	var request: Object = admob.create_basic_ad_request()
	if request == null or not request.has_method("set_ad_unit_id") or not request.has_method("set_custom_data"):
		ads_service.notify_provider_load_failed(_transaction_id, _session_id, "ADMOB_SSV_REQUEST_API_UNAVAILABLE", false)
		_clear_session()
		return
	request.set_ad_unit_id(_ad_id)
	request.set_custom_data(str(response["nonce"]))
	admob.load_rewarded_ad(request)


func _on_load_failed(ad_info: Object, _error_data: Object) -> void:
	if _transaction_id.is_empty() or ad_info == null or not ad_info.has_method("get_ad_id") or str(ad_info.get_ad_id()) != _ad_id:
		return
	ads_service.notify_provider_load_failed(_transaction_id, _session_id, "ADMOB_TEST_LOAD_FAILED", true)


func _on_earned(ad_info: Object, _reward_data: Object) -> void:
	if _earned or _transaction_id.is_empty() or not ads_service.is_active_provider_session(_transaction_id, _session_id) or ad_info == null or not ad_info.has_method("get_ad_id") or str(ad_info.get_ad_id()) != _ad_id:
		return
	_earned = true
	native_reward_earned.emit(_placement_id, _transaction_id, _session_id)
	ads_service.notify_native_reward_earned(_transaction_id, _session_id)


func _on_dismissed(ad_info: Object) -> void:
	if _transaction_id.is_empty() or ad_info == null or not ad_info.has_method("get_ad_id") or str(ad_info.get_ad_id()) != _ad_id:
		return
	if not _earned:
		ads_service.notify_provider_closed_without_reward(_transaction_id, _session_id)
	_clear_session()


func _on_show_failed(ad_info: Object, _error_data: Object) -> void:
	if _transaction_id.is_empty() or ad_info == null or not ad_info.has_method("get_ad_id") or str(ad_info.get_ad_id()) != _ad_id:
		return
	ads_service.notify_provider_show_failed(_transaction_id, _session_id, "ADMOB_TEST_SHOW_FAILED")
	_clear_session()


func _clear_session() -> void:
	_transaction_id = ""
	_session_id = ""
	_placement_id = ""
	_ad_id = ""
	_earned = false


func _expected_reward(placement_id: String) -> Dictionary:
	match placement_id:
		"energy_20", "daily_slot_2":
			return {"item": "energy", "amount": 20}
		"daily_slot_3":
			return {"item": "coins", "amount": 40}
		"daily_slot_4":
			return {"item": "gems", "amount": 2}
		"daily_slot_5":
			return {"item": "coins", "amount": 80}
	return {}
