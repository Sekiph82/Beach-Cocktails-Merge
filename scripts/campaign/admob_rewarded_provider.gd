extends RefCounted

## Rewarded-ad provider over the godot-admob plugin v7.0 (addons/AdmobPlugin, native
## singleton "AdmobPlugin"). Ported from ScrubBots scripts/economy/admob_ad_provider.gd
## (owner 2026-11-19: same decisions as ScrubBots), reduced to rewarded video because BCM
## shows no banner / interstitial.
##
## Order: Google UMP consent first, then the iOS ATT prompt, then the SDK. Nothing loads
## before. Test builds keep is_real = false (Google TEST units, AdMob invalid-traffic
## policy); real units come from data/campaign/ads_provider_policy.json only when
## use_real_units is true (a release export with test_ads_until_release = false).
##
## AdsService contract (adapter): request_rewarded_with_session / show_rewarded_with_session /
## cancel_rewarded. A reward counts only when the SDK reported "user earned reward" before
## the ad closed (no own server: the ScrubBots client-earned rule); the provider then calls
## AdsService.accept_client_earned_reward(). Every other close ends without a reward.

const NATIVE := "AdmobPlugin"
const NODE_SCRIPT := "res://addons/AdmobPlugin/Admob.gd"
const RETRY_DELAYS := [5.0, 15.0, 45.0]

var _n
var _ads
var _ios := false
var _sdk_ready := false
var _rewarded := "none"   ## none | loading | retry | ready
var _retries := 0
var _session := {}        ## active AdsService session: {tx, sid, earned, showing}
## schedule.call(delay_s, callback): one deferred call (tests inject a fake).
var schedule := func(delay: float, cb: Callable) -> void:
	(Engine.get_main_loop() as SceneTree).create_timer(delay).timeout.connect(cb)


## node: an Admob node (not yet in the tree); ads: the AdsService to report to.
func _init(node, ads, ios: bool = OS.has_feature("ios"), real_rewarded_unit: String = "") -> void:
	_n = node
	_ads = ads
	_ios = ios
	if not real_rewarded_unit.is_empty():
		_n.set("is_real", true)
		_n.set("%s_real_rewarded_id" % ("ios" if ios else "android"), real_rewarded_unit)
	_n.set("auto_show_on_resume", false)
	_n.connect("consent_info_updated", _on_consent_info)
	_n.connect("consent_info_update_failed", _on_consent_failed.bind("info"))
	_n.connect("consent_form_loaded", func(): _n.show_consent_form())
	_n.connect("consent_form_failed_to_load", _on_consent_failed.bind("form"))
	_n.connect("consent_form_dismissed", _on_consent_dismissed)
	_n.connect("tracking_authorization_granted", _init_sdk)
	_n.connect("tracking_authorization_denied", _on_att_denied)
	_n.connect("initialization_completed", _on_initialized.unbind(1))
	_n.connect("rewarded_ad_loaded", func(_a, _r): _on_loaded())
	_n.connect("rewarded_ad_failed_to_load", func(_a, e): _on_load_failed(e))
	_n.connect("rewarded_ad_user_earned_reward", func(_a, _r): if not _session.is_empty(): _session["earned"] = true)
	_n.connect("rewarded_ad_dismissed_full_screen_content", _on_closed.bind("").unbind(1))
	_n.connect("rewarded_ad_failed_to_show_full_screen_content", _on_closed.bind("failed").unbind(2))


## Call once the node is in the tree (its _ready picks the ad unit ids).
func start() -> void:
	_n.update_consent_info()


func is_ready() -> bool:
	return _sdk_ready


# ------------------------------------------------------------ consent / init ----

func _on_consent_info() -> void:
	var status = _n.get_consent_status()
	if status != null and status.to_status_string() == "REQUIRED" and _n.is_consent_form_available():
		_n.load_consent_form()
	else:
		_after_consent()


func _on_consent_failed(e, step: String) -> void:
	print("ADS_CONSENT_FAILED step=%s %s" % [step, _err(e)])
	_after_consent()


## The plugin always passes a FormError; an empty message = a normal close.
func _on_consent_dismissed(e) -> void:
	if e != null and e.has_method("get_message") and not String(e.get_message()).is_empty():
		_on_consent_failed(e, "dismissed")
	else:
		_after_consent()


func _after_consent() -> void:
	if _ios:
		_n.request_tracking_authorization()
	else:
		_init_sdk()


func _on_att_denied() -> void:
	print("ADS_ATT_DENIED")
	_init_sdk()


func _init_sdk() -> void:
	if not _sdk_ready:
		_n.initialize()


func _on_initialized() -> void:
	_sdk_ready = true
	print("ADS_INIT_DONE test_units=%s" % str(not bool(_n.get("is_real"))))
	_load()


# ------------------------------------------------------- AdsService adapter ----

func is_test_provider() -> bool:
	return not bool(_n.get("is_real"))


func request_rewarded_with_session(_placement_id: String, transaction_id: String, session_id: String) -> Dictionary:
	if not _sdk_ready:
		return {"ok": false, "reason": "ADS_SDK_NOT_READY", "retryable": true}
	if not _session.is_empty():
		return {"ok": false, "reason": "REWARDED_BUSY"}
	_session = {"tx": transaction_id, "sid": session_id, "earned": false, "showing": false}
	if _rewarded == "ready":
		return {"ok": true, "ready": true}
	if _rewarded == "none":
		_load()
	return {"ok": true, "pending": true}


func show_rewarded_with_session(transaction_id: String, session_id: String) -> Dictionary:
	if _session.is_empty() or _session["tx"] != transaction_id or _session["sid"] != session_id or _rewarded != "ready":
		return {"ok": false, "reason": "REWARDED_NOT_READY"}
	_session["showing"] = true
	_rewarded = "none"
	_n.show_rewarded_ad()
	return {"ok": true}


## AdsService checks for these names; it always calls the *_with_session forms.
func request_rewarded(placement_id: String, transaction_id: String) -> Dictionary:
	return request_rewarded_with_session(placement_id, transaction_id, transaction_id)


func show_rewarded(transaction_id: String) -> Dictionary:
	return show_rewarded_with_session(transaction_id, transaction_id)


func cancel_rewarded(_transaction_id: String, _session_id: String) -> void:
	if not _session.is_empty() and not bool(_session["showing"]):
		_session = {}


func _on_closed(failure: String) -> void:
	if _session.is_empty() or not bool(_session["showing"]):
		return
	var s := _session
	_session = {}
	_load()
	if not failure.is_empty():
		_ads.notify_provider_show_failed(s["tx"], s["sid"], "ADMOB_SHOW_FAILED")
	elif bool(s["earned"]):
		_ads.accept_client_earned_reward(s["tx"], s["sid"])
	else:
		_ads.notify_provider_closed_without_reward(s["tx"], s["sid"])


# ------------------------------------------------------------- load / retry ----

func _load() -> void:
	_rewarded = "loading"
	_n.load_rewarded_ad()


func _on_loaded() -> void:
	_retries = 0
	_rewarded = "ready"
	if not _session.is_empty() and not bool(_session["showing"]):
		_ads.notify_provider_loaded(_session["tx"], _session["sid"])


func _on_load_failed(e) -> void:
	print("ADS_LOAD_FAILED kind=rewarded %s" % _err(e))
	if not _session.is_empty() and not bool(_session["showing"]):
		var s := _session
		_session = {}
		_ads.notify_provider_load_failed(s["tx"], s["sid"], "ADMOB_LOAD_FAILED", false)
	if _retries >= RETRY_DELAYS.size():
		_rewarded = "none"
		return
	_rewarded = "retry"
	schedule.call(RETRY_DELAYS[_retries], _retry)
	_retries += 1


func _retry() -> void:
	if _rewarded == "retry":
		_load()


## "code=<n> msg=<text>" of a godot-admob AdError / LoadAdError / FormError (null-safe).
static func _err(e) -> String:
	if e == null or not e.has_method("get_code"):
		return "code=? msg=?"
	return "code=%s msg=%s" % [str(e.get_code()), String(e.get_message())]
