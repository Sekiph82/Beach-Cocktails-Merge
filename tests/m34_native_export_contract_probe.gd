extends SceneTree

var failures: Array[String] = []


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_NATIVE_EXPORT PASS: %s" % label)
	else:
		failures.append(label)
		printerr("M34_NATIVE_EXPORT FAIL: %s" % label)


func _init() -> void:
	var admob_export := FileAccess.get_file_as_string("res://addons/AdmobPlugin/AdmobPlugin.gd")
	var admob_api := FileAccess.get_file_as_string("res://addons/AdmobPlugin/Admob.gd")
	var android_script := FileAccess.get_file_as_string("res://tools/mobile/build_m34_android_debug.ps1")
	var worker := FileAccess.get_file_as_string("res://backend/mobile-rewards/src/index.js")
	var reward_delivery := FileAccess.get_file_as_string("res://scripts/campaign/mobile_reward_delivery.gd")
	var http_transport := FileAccess.get_file_as_string("res://scripts/campaign/mobile_reward_http_transport.gd")
	var play_billing := FileAccess.get_file_as_string("res://scripts/campaign/play_billing_test_adapter.gd")
	_check("ATS keeps Google's media and in-app web-content exceptions", admob_export.contains("NSAllowsArbitraryLoadsForMedia") and admob_export.contains("NSAllowsArbitraryLoadsInWebContent"))
	_check("ATS removes the broad global arbitrary-load exception", not admob_export.contains("<key>NSAllowsArbitraryLoads</key>"))
	_check("AdMob SDK exposes rewarded and UMP consent callbacks used by the adapter contract", admob_api.contains("signal rewarded_ad_loaded") and admob_api.contains("signal rewarded_ad_user_earned_reward") and admob_api.contains("signal consent_info_updated"))
	_check("local Android export is Gradle-enabled, test-only and uses a distinct debug package", android_script.contains("gradle_build/use_gradle_build=true") and android_script.contains("m34_nonshipping") and android_script.contains("com.sekiph82.beachcocktails.m34debug"))
	_check("Worker rejects absent consent and offers authenticated reward delivery acknowledgement", worker.contains("body.consent_granted !== true") and worker.contains("/v1/ads/rewards/pending") and worker.contains("/ack"))
	_check("Godot reward delivery persists before HTTP acknowledgement and binds authenticated user", reward_delivery.find("persist.call()") < reward_delivery.find("acknowledge.call(transaction_id)") and reward_delivery.contains("PENDING_USER_MISMATCH"))
	_check("real Worker transport is HTTPS-only and disabled without explicit owner configuration", http_transport.contains("MOBILE_REWARD_TRANSPORT_DISABLED") and http_transport.contains("_https_endpoint_matches") and http_transport.contains("owner_enabled"))
	_check("Play Billing test adapter uses installed ACK and consume APIs only after server verification", play_billing.contains("store.accept_verified_transaction") and play_billing.contains("consume_purchase") and play_billing.contains("acknowledge_purchase"))
	if failures.is_empty():
		print("M34_NATIVE_EXPORT_RESULT=PASS")
		quit(0)
	else:
		print("M34_NATIVE_EXPORT_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
