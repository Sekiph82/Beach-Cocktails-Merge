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
	_check("ATS keeps Google's media and in-app web-content exceptions", admob_export.contains("NSAllowsArbitraryLoadsForMedia") and admob_export.contains("NSAllowsArbitraryLoadsInWebContent"))
	_check("ATS removes the broad global arbitrary-load exception", not admob_export.contains("<key>NSAllowsArbitraryLoads</key>"))
	_check("AdMob SDK exposes rewarded and UMP consent callbacks used by the adapter contract", admob_api.contains("signal rewarded_ad_loaded") and admob_api.contains("signal rewarded_ad_user_earned_reward") and admob_api.contains("signal consent_info_updated"))
	_check("local Android export is Gradle-enabled, test-only and uses a distinct debug package", android_script.contains("gradle_build/use_gradle_build=true") and android_script.contains("m34_nonshipping") and android_script.contains("com.sekiph82.beachcocktails.m34debug"))
	_check("Worker rejects absent consent and offers authenticated reward delivery acknowledgement", worker.contains("body.consent_granted !== true") and worker.contains("/v1/ads/rewards/pending") and worker.contains("/ack"))
	if failures.is_empty():
		print("M34_NATIVE_EXPORT_RESULT=PASS")
		quit(0)
	else:
		print("M34_NATIVE_EXPORT_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
