class_name AdsProviderConfig
extends RefCounted

const CONFIG_PATH := "res://data/campaign/ads_provider_policy.json"
const REQUIRED_OWNER_FIELDS := [
	"android_app_id",
	"android_rewarded_unit_id",
	"ios_app_id",
	"ios_rewarded_unit_id",
	"privacy_policy_url",
	"age_policy",
	"ump_consent_policy",
	"ios_att_policy",
	"ssv_backend_url"
]

var values: Dictionary = {}
var valid := false
var error := "NOT_LOADED"


func load_config(path: String = CONFIG_PATH) -> bool:
	values.clear()
	valid = false
	error = "CONFIG_INVALID"
	if not FileAccess.file_exists(path):
		error = "CONFIG_MISSING"
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		error = "CONFIG_UNREADABLE"
		return false
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		error = "CONFIG_PARSE_ERROR"
		return false
	var candidate: Dictionary = parser.data
	if int(candidate.get("schema_version", 0)) != 2 or not candidate.get("configuration", {}) is Dictionary:
		return false
	var configuration: Dictionary = candidate["configuration"]
	for field in REQUIRED_OWNER_FIELDS:
		if typeof(configuration.get(field)) != TYPE_STRING:
			return false
	if typeof(configuration.get("device_tests_authorized")) != TYPE_BOOL:
		return false
	if typeof(candidate.get("default_enabled")) != TYPE_BOOL or bool(candidate["default_enabled"]):
		return false
	if not candidate.get("placements", {}) is Dictionary or candidate["placements"].is_empty():
		return false
	for placement_value in candidate["placements"].values():
		if not placement_value is Dictionary or typeof(placement_value.get("enabled")) != TYPE_BOOL or bool(placement_value["enabled"]):
			return false
	values = candidate.duplicate(true)
	valid = true
	error = ""
	return true


func production_gate_state(platform: String = OS.get_name()) -> Dictionary:
	if not valid:
		return {"ready": false, "reason": error, "provider_status": "BLOCKED_ON_OWNER_AND_SDK"}
	var configuration: Dictionary = values["configuration"]
	var platform_fields := ["android_app_id", "android_rewarded_unit_id"] if platform == "Android" else ["ios_app_id", "ios_rewarded_unit_id"] if platform == "iOS" else []
	if platform_fields.is_empty():
		return {"ready": false, "reason": "UNSUPPORTED_PLATFORM", "provider_status": "PLATFORM_DISABLED"}
	var missing: Array[String] = []
	for field in platform_fields + ["privacy_policy_url", "ssv_backend_url"]:
		if str(configuration.get(field, "")).strip_edges().is_empty():
			missing.append(field)
	for field in ["age_policy", "ump_consent_policy"]:
		if str(configuration.get(field, "")) in ["", "OWNER_DECISION_REQUIRED"]:
			missing.append(field)
	if platform == "iOS" and str(configuration.get("ios_att_policy", "")) in ["", "OWNER_DECISION_REQUIRED"]:
		missing.append("ios_att_policy")
	if not bool(configuration.get("device_tests_authorized", false)):
		missing.append("device_tests_authorized")
	if not missing.is_empty():
		return {"ready": false, "reason": "OWNER_INPUT_REQUIRED", "missing_fields": missing, "provider_status": "BLOCKED_ON_OWNER_AND_SDK"}
	return {"ready": false, "reason": "TRUSTED_SSV_ADAPTER_UNAVAILABLE", "provider_status": "BLOCKED_ON_OWNER_AND_SDK"}


## This is safe for logs: values are intentionally reduced to presence bits.
func sanitized_diagnostics(platform: String = OS.get_name()) -> Dictionary:
	if not valid:
		return {"config_valid": false, "provider_status": "BLOCKED_ON_OWNER_AND_SDK", "error": error}
	var configuration: Dictionary = values["configuration"]
	var presence: Dictionary = {}
	for field in REQUIRED_OWNER_FIELDS:
		presence[field + "_configured"] = not str(configuration.get(field, "")).strip_edges().is_empty() and str(configuration.get(field, "")) != "OWNER_DECISION_REQUIRED"
	presence["device_tests_authorized"] = bool(configuration.get("device_tests_authorized", false))
	var gate := production_gate_state(platform)
	return {"config_valid": true, "provider_status": str(gate.get("provider_status", "BLOCKED_ON_OWNER_AND_SDK")), "production_ready": false, "configured": presence}
