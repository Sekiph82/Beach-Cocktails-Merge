extends Node

var _admob: Admob
var _request_button: Button

func _ready() -> void:
    print("BCM_R09_ADMOB_TEST_ONLY=true")
    print("BCM_R09_ADMOB_REAL=false")
    print("BCM_R09_REWARD_CURRENCY_GRANT=false")
    if not Engine.has_singleton("AdmobPlugin"):
        print("BCM_R09_NATIVE_PLUGIN_PRESENT=false")
        get_tree().quit()
        return
    print("BCM_R09_NATIVE_PLUGIN_PRESENT=true")
    _configure_test_ui()
    _admob = Admob.new()
    _admob.is_real = false
    _admob.android_debug_application_id = "ca-app-pub-3940256099942544~3347511713"
    _admob.debug_geography = ConsentRequestParameters.DebugGeography.EEA
    add_child(_admob)
    _admob.consent_info_updated.connect(_on_consent_info_updated)
    _admob.consent_info_update_failed.connect(_on_consent_info_update_failed)
    _admob.consent_form_loaded.connect(_on_consent_form_loaded)
    _admob.consent_form_dismissed.connect(_on_consent_form_dismissed)
    _admob.initialization_completed.connect(_on_initialization_completed)
    _admob.rewarded_ad_loaded.connect(_on_rewarded_ad_loaded)
    _admob.rewarded_ad_failed_to_load.connect(_on_rewarded_ad_failed_to_load)
    _admob.rewarded_ad_user_earned_reward.connect(_on_rewarded_ad_user_earned_reward)
    _admob.update_consent_info()

func _configure_test_ui() -> void:
    _request_button = Button.new()
    _request_button.text = "Load Google test rewarded ad"
    _request_button.position = Vector2(24, 330)
    _request_button.size = Vector2(432, 88)
    _request_button.disabled = true
    _request_button.pressed.connect(_on_test_ad_pressed)
    add_child(_request_button)

func _on_consent_info_updated() -> void:
    print("BCM_R09_CONSENT_INFO_UPDATED=true")
    if _admob.is_consent_form_available():
        _admob.load_consent_form()
    else:
        _initialize_only_with_valid_consent()

func _on_consent_info_update_failed(error_data: FormError) -> void:
    print("BCM_R09_CONSENT_INFO_UPDATE_FAILED=true error=", error_data.get_message())
    print("BCM_R09_AD_REQUESTS_BLOCKED=true")

func _on_consent_form_loaded() -> void:
    _admob.show_consent_form()

func _on_consent_form_dismissed(error_data: FormError) -> void:
    print("BCM_R09_CONSENT_FORM_DISMISSED error=", error_data.get_message())
    _initialize_only_with_valid_consent()

func _initialize_only_with_valid_consent() -> void:
    var consent := _admob.get_consent_status()
    if consent == null or (consent.status != UserConsent.Status.NOT_REQUIRED and consent.status != UserConsent.Status.OBTAINED):
        print("BCM_R09_CONSENT_NOT_GRANTED; ads remain disabled")
        return
    print("BCM_R09_CONSENT_GATE_PASSED status=", consent.to_status_string())
    _admob.initialize()

func _on_initialization_completed(_status_data: InitializationStatus) -> void:
    print("BCM_R09_ADMOB_INITIALIZATION_COMPLETED=true test_ids_only=true")
    _request_button.disabled = false

func _on_test_ad_pressed() -> void:
    print("BCM_R09_REQUESTING_GOOGLE_TEST_REWARDED_AD=true")
    _admob.load_rewarded_ad()

func _on_rewarded_ad_loaded(ad_info: AdInfo, _response_info: ResponseInfo) -> void:
    _admob.show_rewarded_ad(ad_info.get_ad_id())

func _on_rewarded_ad_failed_to_load(_ad_info: AdInfo, error_data: LoadAdError) -> void:
    print("BCM_R09_TEST_AD_LOAD_FAILED error=", error_data.get_message())

func _on_rewarded_ad_user_earned_reward(_ad_info: AdInfo, reward_data: RewardItem) -> void:
    print("BCM_R09_TEST_REWARD_CALLBACK_ONLY type=", reward_data.get_type(), " amount=", reward_data.get_amount())
    print("BCM_R09_PRODUCT_CURRENCY_GRANTED=false")
