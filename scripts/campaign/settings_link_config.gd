class_name SettingsLinkConfig
extends RefCounted

const DEFAULT_PATH := "res://data/ui/settings_links.json"
const ALLOWED_KEYS := ["schema_version", "privacy_policy_url", "support_url"]


static func load_from_path(path: String = DEFAULT_PATH) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _empty()
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or int(parsed.get("schema_version", 0)) != 1:
		return _empty()
	for key in parsed:
		if not ALLOWED_KEYS.has(str(key)):
			return _empty()
	var privacy := str(parsed.get("privacy_policy_url", ""))
	var support := str(parsed.get("support_url", ""))
	if (not privacy.is_empty() and not is_public_https_url(privacy)) or (not support.is_empty() and not is_public_https_url(support)):
		return _empty()
	return {"privacy_policy_url": privacy, "support_url": support}


static func is_public_https_url(value: String) -> bool:
	if value.is_empty() or value.contains("\\") or value.contains(" ") or value.contains("\n") or value.contains("\r") or value.contains("\t"):
		return false
	var regex := RegEx.new()
	regex.compile("^https://([^/?#:@]+)(?::([0-9]{1,5}))?(/[^?#]*)?(\\?[^#]*)?(#[^ ]*)?$")
	var result := regex.search(value)
	if result == null:
		return false
	var host := result.get_string(1).to_lower()
	if host == "localhost" or host.ends_with(".localhost") or host.ends_with(".local") or host.ends_with(".internal"):
		return false
	if host.is_valid_ip_address():
		return false
	var host_regex := RegEx.new()
	host_regex.compile("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$")
	if host_regex.search(host) == null:
		return false
	var port := result.get_string(2)
	return port.is_empty() or (int(port) > 0 and int(port) <= 65535)


static func _empty() -> Dictionary:
	return {"privacy_policy_url": "", "support_url": ""}
