extends SceneTree

const ADS_SCRIPT := preload("res://scripts/campaign/ads_service.gd")
const CONFIG_SCRIPT := preload("res://scripts/campaign/ads_provider_config.gd")
const PROVIDER_SCRIPT := preload("res://tests/fixtures/m34_rewarded_ads_test_provider.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_ADS PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_ADS FAIL: %s" % label)


func _service() -> AdsService:
	var service: AdsService = ADS_SCRIPT.new()
	root.add_child(service)
	return service


func _fixture() -> RefCounted:
	return PROVIDER_SCRIPT.new()


func _run() -> void:
	var configuration: AdsProviderConfig = CONFIG_SCRIPT.new()
	_check("tracked provider policy parses with explicit unset owner gates", configuration.load_config() and configuration.valid)
	var android_gate: Dictionary = configuration.production_gate_state("Android")
	var ios_gate: Dictionary = configuration.production_gate_state("iOS")
	_check("Android and iOS production gates stay blocked on owner input", not android_gate.get("ready", true) and android_gate.get("reason", "") == "OWNER_INPUT_REQUIRED" and not ios_gate.get("ready", true) and ios_gate.get("reason", "") == "OWNER_INPUT_REQUIRED")
	_check("unsupported desktop platform remains blocked", configuration.production_gate_state("Windows").get("reason", "") == "UNSUPPORTED_PLATFORM")
	var sanitized := JSON.stringify(configuration.sanitized_diagnostics("Android"))
	_check("diagnostics expose no raw IDs, URLs, receipt, or user values", not sanitized.contains("ca-app-pub") and not sanitized.contains("http://") and not sanitized.contains("https://"))
	var production_guard := ADS_SCRIPT.new() as AdsService
	var attempted_enable := production_guard.configure_production({"default_enabled": true, "configuration": {"android_app_id": "synthetic-id"}})
	_check("production adapter and enable flags cannot be activated by configuration", not attempted_enable.get("ok", false) and not production_guard.production_enabled and production_guard.provider_adapter == null)
	production_guard.free()
	var unconfigured := ADS_SCRIPT.new() as AdsService
	var no_provider: Dictionary = unconfigured.request_rewarded("energy_20", "offline-1")
	_check("missing provider and unknown consent fail closed", not no_provider.get("ok", false) and no_provider.get("reason", "") == "CONSENT_REQUIRED" and not unconfigured.production_enabled)
	unconfigured.free()

	var service := _service()
	var provider: RefCounted = _fixture()
	_check("debug-only fixture injection requires explicit consent", service.set_provider_adapter(provider, "GRANTED_NONPERSONALIZED"))
	_check("show before load is rejected", service.show_rewarded().get("reason", "") == "REWARDED_NOT_READY")
	var ready: Dictionary = service.request_rewarded("energy_20", "lifecycle-ready")
	_check("deterministic provider loads a rewarded placement", ready.get("ready", false) and service.state == ADS_SCRIPT.STATE_READY)
	var shown: Dictionary = service.show_rewarded()
	_check("show returns an opaque active session", shown.get("ok", false) and service.state == ADS_SCRIPT.STATE_SHOWING and not str(shown.get("session_id", "")).is_empty())
	var paid_callbacks: Array[String] = []
	service.verified_rewarded.connect(func(_placement: String, transaction: String, _receipt: String) -> void: paid_callbacks.append(transaction))
	_check("native/client earned callback without trusted SSV is rejected", not service.accept_provider_reward("lifecycle-ready", "unsigned-receipt").get("ok", false) and paid_callbacks.is_empty() and service.state == ADS_SCRIPT.STATE_SHOWING)
	_check("stale session callback is rejected", service.accept_provider_reward("lifecycle-ready", "trusted-1", true, "stale-session").get("reason", "") == "STALE_REWARDED_SESSION")
	var accepted: Dictionary = service.accept_provider_reward("lifecycle-ready", "trusted-1", true, str(shown["session_id"]))
	_check("trusted verified callback grants once and closes the session", accepted.get("verified", false) and paid_callbacks == ["lifecycle-ready"] and service.state == ADS_SCRIPT.STATE_REWARDED)
	_check("duplicate transaction cannot be replayed", service.request_rewarded("energy_20", "lifecycle-ready").get("reason", "") == "DUPLICATE_REWARDED_TRANSACTION")
	service.free()

	var retry_service := _service()
	var retry_provider: RefCounted = _fixture()
	retry_provider.load_results.append_array([{"ok": false, "retryable": true, "reason": "NO_FILL"}, {"ok": true, "ready": true}])
	retry_service.set_provider_adapter(retry_provider, "GRANTED_NONPERSONALIZED")
	var first_load: Dictionary = retry_service.request_rewarded("daily_slot_3", "retry-once")
	_check("retryable load failure enters bounded backoff", first_load.get("retry_scheduled", false) and retry_service.state == ADS_SCRIPT.STATE_RETRY_WAIT)
	retry_service.expire_active_request()
	_check("scheduled retry reaches READY after provider recovers", retry_provider.load_calls == 2 and retry_service.state == ADS_SCRIPT.STATE_READY)
	retry_service.free()

	var exhausted_service := _service()
	var exhausted_provider: RefCounted = _fixture()
	exhausted_provider.load_results.append_array([{"ok": false, "retryable": true}, {"ok": false, "retryable": true}, {"ok": false, "retryable": true}])
	exhausted_service.set_provider_adapter(exhausted_provider, "GRANTED_NONPERSONALIZED")
	exhausted_service.request_rewarded("daily_slot_4", "retry-exhausted")
	exhausted_service.expire_active_request()
	exhausted_service.expire_active_request()
	_check("retry count is finite and exhausted provider fails closed", exhausted_provider.load_calls == ADS_SCRIPT.MAX_LOAD_ATTEMPTS and exhausted_service.state == ADS_SCRIPT.STATE_FAILED)
	exhausted_service.free()

	var load_timeout_service := _service()
	var pending_provider: RefCounted = _fixture()
	pending_provider.load_results.append({"ok": true, "pending": true})
	load_timeout_service.set_provider_adapter(pending_provider, "GRANTED_NONPERSONALIZED")
	var pending_load: Dictionary = load_timeout_service.request_rewarded("daily_slot_5", "load-timeout")
	_check("asynchronous load waits in LOADING", pending_load.get("pending", false) and load_timeout_service.state == ADS_SCRIPT.STATE_LOADING)
	_check("matching asynchronous load callback transitions to READY once", load_timeout_service.notify_provider_loaded("load-timeout", str(pending_load["session_id"])).get("ok", false) and load_timeout_service.state == ADS_SCRIPT.STATE_READY)
	_check("duplicate or stale load callback cannot change state", not load_timeout_service.notify_provider_loaded("load-timeout", str(pending_load["session_id"])).get("ok", false) and load_timeout_service.state == ADS_SCRIPT.STATE_READY)
	load_timeout_service.notify_provider_closed_without_reward("load-timeout", str(pending_load["session_id"]))
	pending_provider.load_results.append({"ok": true, "pending": true})
	var pending_timeout: Dictionary = load_timeout_service.request_rewarded("daily_slot_5", "load-timeout-2")
	load_timeout_service.expire_active_request()
	_check("load timeout cancels provider and cannot pay", pending_timeout.get("pending", false) and load_timeout_service.state == ADS_SCRIPT.STATE_FAILED and pending_provider.cancel_calls == 2 and not load_timeout_service.accept_provider_reward("load-timeout-2", "late", true).get("ok", false))
	load_timeout_service.free()

	var show_failure_service := _service()
	var show_failure_provider: RefCounted = _fixture()
	show_failure_provider.show_result = {"ok": false, "reason": "SHOW_FAILED"}
	show_failure_service.set_provider_adapter(show_failure_provider, "GRANTED_NONPERSONALIZED")
	show_failure_service.request_rewarded("energy_20", "show-fail")
	var failed_show: Dictionary = show_failure_service.show_rewarded()
	_check("show failure grants no reward", not failed_show.get("ok", false) and show_failure_service.state == ADS_SCRIPT.STATE_FAILED and not show_failure_service.accept_provider_reward("show-fail", "late", true).get("ok", false))
	show_failure_service.free()

	var show_timeout_service := _service()
	var show_timeout_provider: RefCounted = _fixture()
	show_timeout_service.set_provider_adapter(show_timeout_provider, "GRANTED_NONPERSONALIZED")
	show_timeout_service.request_rewarded("energy_20", "show-timeout")
	show_timeout_service.show_rewarded()
	show_timeout_service.expire_active_request()
	_check("show timeout invalidates outstanding callbacks", show_timeout_service.state == ADS_SCRIPT.STATE_FAILED and not show_timeout_service.accept_provider_reward("show-timeout", "late", true).get("ok", false))
	show_timeout_service.free()

	var shutdown_service := _service()
	var shutdown_provider: RefCounted = _fixture()
	shutdown_service.set_provider_adapter(shutdown_provider, "GRANTED_NONPERSONALIZED")
	shutdown_service.request_rewarded("energy_20", "shutdown-pending")
	shutdown_service.show_rewarded()
	shutdown_service.free()
	_check("shutdown cancels outstanding provider session", shutdown_provider.cancel_calls == 1)
	var restarted_service := _service()
	_check("restart begins with no provider and cannot accept prior callback", not restarted_service.accept_provider_reward("shutdown-pending", "old", true).get("ok", false) and not restarted_service.production_enabled)
	restarted_service.free()

	if failures.is_empty():
		print("M34_ADS_RESULT=PASS")
		quit(0)
	else:
		print("M34_ADS_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
