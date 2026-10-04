class_name LevelDatabase
extends RefCounted

## Read-only campaign definition loader and validator for M10.
##
## Static campaign definitions belong to JSON. This service owns loading,
## validation, and lookup only; it does not own player progression or saves.

enum ValidationMode {
    SEED,
    FULL,
}

const DEFAULT_ISLANDS_PATH := "res://data/campaign/islands.json"
const DEFAULT_LEVELS_PATH := "res://data/campaign/levels/sunny_cove.json"
const MIN_COCKTAIL_LEVEL := 1
const MAX_COCKTAIL_LEVEL := 12
const REQUIRED_THEME_KEYS := [
    "gameplay_surface",
    "playable_geometry_profile",
    "island_map_background",
]

var validation_mode: ValidationMode = ValidationMode.SEED
var last_error := ""
var _islands_by_id: Dictionary = {}
var _levels_by_key: Dictionary = {}
var _levels_by_island: Dictionary = {}
var _loaded := false


func load_canonical(
        islands_path: String = DEFAULT_ISLANDS_PATH,
        levels_path: Variant = DEFAULT_LEVELS_PATH,
        mode: ValidationMode = ValidationMode.SEED
    ) -> bool:
    validation_mode = mode
    _reset()

    var islands_root = _read_json(islands_path, "islands")
    if islands_root == null:
        return false
    var level_roots := _read_json_roots(levels_path, "levels")
    if level_roots.is_empty():
        return false

    if not _validate_island_root(islands_root):
        return false
    if not _validate_level_roots(level_roots):
        return false
    _loaded = true
    return true


func load_from_data(islands_root: Variant, levels_roots: Variant, mode: ValidationMode = ValidationMode.SEED) -> bool:
    validation_mode = mode
    _reset()
    if not _validate_island_root(islands_root):
        return false
    var normalized_level_roots := _normalize_level_roots(levels_roots)
    if normalized_level_roots.is_empty():
        return _fail("level roots must contain at least one object")
    if not _validate_level_roots(normalized_level_roots):
        return false
    _loaded = true
    return true


func is_loaded() -> bool:
    return _loaded


func get_island(island_id: String) -> Dictionary:
    if not _islands_by_id.has(island_id):
        return {}
    return _copy_read_only(_islands_by_id[island_id])


func get_level(island_id: String, level_id: int) -> Dictionary:
    var key := _level_key(island_id, level_id)
    if not _levels_by_key.has(key):
        return {}
    return _copy_read_only(_levels_by_key[key])


func get_levels_for_island(island_id: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for level in _levels_by_island.get(island_id, []):
        result.append(_copy_read_only(level))
    return result


func get_island_theme(island_id: String) -> Dictionary:
    var island := get_island(island_id)
    var theme: Variant = island.get("theme", {})
    if not theme is Dictionary:
        return {}
    return _copy_read_only(theme)


func get_island_ids() -> Array[String]:
    var ids: Array[String] = []
    for island_id in _islands_by_id.keys():
        ids.append(str(island_id))
    ids.sort()
    return ids


func get_island_ids_in_order() -> Array[String]:
    var islands: Array[Dictionary] = []
    for island_id in _islands_by_id:
        islands.append(_islands_by_id[island_id])
    islands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return int(a.get("order_index", 0)) < int(b.get("order_index", 0))
    )
    var ids: Array[String] = []
    for island in islands:
        ids.append(str(island.get("id", "")))
    return ids


func get_last_error() -> String:
    return last_error


func _reset() -> void:
    last_error = ""
    _islands_by_id.clear()
    _levels_by_key.clear()
    _levels_by_island.clear()
    _loaded = false


func _read_json(path: String, label: String):
    if not FileAccess.file_exists(path):
        _fail("missing %s file: %s" % [label, path])
        return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        _fail("could not open %s file: %s" % [label, path])
        return null
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed == null or not parsed is Dictionary:
        _fail("malformed %s JSON: %s" % [label, path])
        return null
    return parsed


func _read_json_roots(paths: Variant, label: String) -> Array:
    var path_list: Array = [paths] if paths is String else paths if paths is Array else []
    if path_list.is_empty():
        _fail("%s paths must contain at least one path" % label)
        return []
    var roots: Array = []
    for raw_path in path_list:
        if not raw_path is String or str(raw_path).is_empty():
            _fail("%s path must be a non-empty string" % label)
            return []
        var parsed = _read_json(str(raw_path), label)
        if parsed == null:
            return []
        roots.append(parsed)
    return roots


func _normalize_level_roots(level_roots: Variant) -> Array:
    if level_roots is Dictionary:
        return [level_roots]
    if level_roots is Array:
        return level_roots
    return []


func _validate_island_root(root: Variant) -> bool:
    if not root is Dictionary:
        return _fail("island root must be an object")
    if not root.has("schema_version") or int(root["schema_version"]) != 1:
        return _fail("island schema_version must be 1")
    if not root.has("islands") or not root["islands"] is Array:
        return _fail("island root must contain an islands array")

    for raw_island in root["islands"]:
        if not raw_island is Dictionary:
            return _fail("island entry must be an object")
        if not _has_required(raw_island, ["id", "display_name", "order_index", "level_count", "unlock_rule", "next_island_id", "reward_track"]):
            return false
        var island_id := str(raw_island["id"])
        if island_id.is_empty():
            return _fail("island id must not be empty")
        if _islands_by_id.has(island_id):
            return _fail("duplicate island id: %s" % island_id)
        if str(raw_island["display_name"]).is_empty():
            return _fail("island display_name must not be empty: %s" % island_id)
        if int(raw_island["order_index"]) <= 0:
            return _fail("island order_index must be positive: %s" % island_id)
        if int(raw_island["level_count"]) < 0:
            return _fail("island level_count must not be negative: %s" % island_id)
        if not raw_island["unlock_rule"] is Dictionary:
            return _fail("island unlock_rule must be an object: %s" % island_id)
        if not raw_island["reward_track"] is Dictionary:
            return _fail("island reward_track must be an object: %s" % island_id)
        if raw_island.has("target_policy") and not _validate_target_policy(raw_island["target_policy"], island_id):
            return false
        if raw_island.has("theme"):
            if not _validate_theme(raw_island["theme"], island_id):
                return false
            var profile_path := str(raw_island["theme"].get("playable_geometry_profile", ""))
            var profile: Variant = _read_json(profile_path, "R04 playable geometry profile")
            if profile == null or not profile is Dictionary or not _validate_surface_profile(profile, island_id, str(raw_island["theme"]["gameplay_surface"])):
                return false
            raw_island["playable_geometry"] = profile["geometry"].duplicate(true)
            if not _validate_playable_geometry(raw_island["playable_geometry"], island_id):
                return false
        elif raw_island.has("playable_geometry") and not _validate_playable_geometry(raw_island["playable_geometry"], island_id):
            return false
        _islands_by_id[island_id] = raw_island.duplicate(true)

    for island_id in _islands_by_id:
        if not _validate_unlock_rule(island_id, _islands_by_id[island_id]["unlock_rule"]):
            return false
        var next_id := str(_islands_by_id[island_id]["next_island_id"])
        if not next_id.is_empty() and not _islands_by_id.has(next_id):
            return _fail("unresolved next_island_id %s from %s" % [next_id, island_id])
    return true


func _validate_level_roots(roots: Array) -> bool:
    var loaded_root_ids: Dictionary = {}
    for root in roots:
        if not root is Dictionary:
            return _fail("level root must be an object")
        if not root.has("schema_version") or int(root["schema_version"]) != 1:
            return _fail("level schema_version must be 1")
        if not root.has("island_id") or not root.has("levels") or not root["levels"] is Array:
            return _fail("level root must contain island_id and levels array")
        var root_island_id := str(root["island_id"])
        if root_island_id.is_empty() or loaded_root_ids.has(root_island_id):
            return _fail("duplicate level root island id: %s" % root_island_id)
        loaded_root_ids[root_island_id] = true
        if not _islands_by_id.has(root_island_id):
            return _fail("level root references unknown island: %s" % root_island_id)

        for raw_level in root["levels"]:
            if not raw_level is Dictionary:
                return _fail("level entry must be an object")
            if not _has_required(raw_level, ["island_id", "level_id", "time_limit_sec", "orders", "vip", "rewards", "score_star_thresholds", "feature_flags"]):
                return false
            var island_id := str(raw_level["island_id"])
            var level_id := int(raw_level["level_id"])
            if island_id != root_island_id:
                return _fail("level island_id does not match file root: L%d" % level_id)
            if not _islands_by_id.has(island_id):
                return _fail("level references unknown island: %s" % island_id)
            if level_id <= 0:
                return _fail("level_id must be positive: %s/%d" % [island_id, level_id])
            var key := _level_key(island_id, level_id)
            if _levels_by_key.has(key):
                return _fail("duplicate level id: %s/%d" % [island_id, level_id])
            if float(raw_level["time_limit_sec"]) < 0.0:
                return _fail("time_limit_sec cannot be negative: %s/%d" % [island_id, level_id])
            if not _validate_orders(raw_level["orders"], island_id, level_id):
                return false
            if raw_level["vip"] != null and not raw_level["vip"] is Dictionary:
                return _fail("vip must be null or an object: %s/%d" % [island_id, level_id])
            if raw_level["vip"] is Dictionary and not _validate_vip(raw_level["vip"], island_id, level_id):
                return false
            if not raw_level["rewards"] is Dictionary:
                return _fail("rewards must be an object: %s/%d" % [island_id, level_id])
            if not raw_level["score_star_thresholds"] is Dictionary:
                return _fail("score_star_thresholds must be an object: %s/%d" % [island_id, level_id])
            if not raw_level["feature_flags"] is Dictionary:
                return _fail("feature_flags must be an object: %s/%d" % [island_id, level_id])
            var copy: Dictionary = raw_level.duplicate(true)
            _levels_by_key[key] = copy
            if not _levels_by_island.has(island_id):
                _levels_by_island[island_id] = []
            _levels_by_island[island_id].append(copy)

    for island_id in _islands_by_id:
        var loaded_levels: Array = _levels_by_island.get(island_id, [])
        loaded_levels.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["level_id"]) < int(b["level_id"]))
        if validation_mode == ValidationMode.FULL and loaded_levels.size() != int(_islands_by_id[island_id]["level_count"]):
            return _fail("declared island level_count mismatch: %s" % island_id)
    return true


func _validate_unlock_rule(island_id: String, rule: Variant) -> bool:
    if not rule is Dictionary or not rule.has("type") or typeof(rule["type"]) != TYPE_STRING:
        return _fail("island unlock_rule must contain a string type: %s" % island_id)
    var rule_type := str(rule["type"])
    if rule_type == "default_open":
        return true
    if rule_type != "requires_island_completion":
        return _fail("unsupported island unlock_rule type %s: %s" % [rule_type, island_id])
    if not rule.has("island_id") or typeof(rule["island_id"]) != TYPE_STRING or str(rule["island_id"]).is_empty():
        return _fail("completion unlock_rule requires a non-empty island_id: %s" % island_id)
    var required_island_id := str(rule["island_id"])
    if not _islands_by_id.has(required_island_id):
        return _fail("unresolved unlock_rule island_id %s from %s" % [required_island_id, island_id])
    if not rule.has("level_id") or (typeof(rule["level_id"]) != TYPE_INT and typeof(rule["level_id"]) != TYPE_FLOAT):
        return _fail("completion unlock_rule level_id must be a positive integer: %s" % island_id)
    var required_level_value := float(rule["level_id"])
    if required_level_value <= 0.0 or not is_equal_approx(required_level_value, float(int(required_level_value))):
        return _fail("completion unlock_rule level_id must be a positive integer: %s" % island_id)
    var required_level_id := int(rule["level_id"])
    var required_level_count := int(_islands_by_id[required_island_id]["level_count"])
    if required_level_count > 0 and required_level_id > required_level_count:
        return _fail("unlock_rule level_id exceeds declared source island range: %s" % island_id)
    return true


func _validate_orders(orders: Variant, island_id: String, level_id: int) -> bool:
    if not orders is Array or orders.is_empty():
        return _fail("orders must be a non-empty array: %s/%d" % [island_id, level_id])
    for order in orders:
        if not order is Dictionary or not _has_required(order, ["cocktail_level", "quantity"]):
            return _fail("order requires cocktail_level and quantity: %s/%d" % [island_id, level_id])
        var cocktail_level := int(order["cocktail_level"])
        var quantity := int(order["quantity"])
        if not is_campaign_target_level_eligible(island_id, cocktail_level):
            return _fail("cocktail target outside campaign policy: %s/%d" % [island_id, level_id])
        if quantity <= 0:
            return _fail("order quantity must be positive: %s/%d" % [island_id, level_id])
    return true


func _validate_vip(vip: Dictionary, island_id: String, level_id: int) -> bool:
    # Disabled VIP metadata is permitted so fixtures and future content can
    # carry an explicitly disabled optional objective without a target.
    if vip.has("enabled") and not bool(vip["enabled"]):
        return true
    if not vip.has("cocktail_level") or (typeof(vip["cocktail_level"]) != TYPE_INT and typeof(vip["cocktail_level"]) != TYPE_FLOAT) or not is_equal_approx(float(vip["cocktail_level"]), float(int(vip["cocktail_level"]))):
        return _fail("enabled VIP cocktail_level must be an integer campaign target: %s/%d" % [island_id, level_id])
    var cocktail_level := int(vip["cocktail_level"])
    if not is_campaign_target_level_eligible(island_id, cocktail_level):
        return _fail("enabled VIP cocktail target outside campaign policy: %s/%d" % [island_id, level_id])
    if not vip.has("quantity") or (typeof(vip["quantity"]) != TYPE_INT and typeof(vip["quantity"]) != TYPE_FLOAT) or not is_equal_approx(float(vip["quantity"]), float(int(vip["quantity"]))) or int(vip["quantity"]) <= 0:
        return _fail("enabled VIP quantity must be a positive integer: %s/%d" % [island_id, level_id])
    return true


func is_campaign_target_level_eligible(island_id: String, cocktail_level: int) -> bool:
    if cocktail_level < MIN_COCKTAIL_LEVEL or cocktail_level > MAX_COCKTAIL_LEVEL:
        return false
    var island: Variant = _islands_by_id.get(island_id, {})
    if not island is Dictionary or not island.has("target_policy"):
        # Test fixtures and future islands without a declared campaign policy
        # retain the generic drink-level guard until their normal content pass
        # supplies the policy. VIP never owns a separate fallback range.
        return true
    var policy: Dictionary = island["target_policy"]
    return cocktail_level >= int(policy["min_level"]) and cocktail_level <= int(policy["max_level"])


func _validate_target_policy(policy: Variant, island_id: String) -> bool:
    if not policy is Dictionary or not policy.has_all(["min_level", "max_level"]):
        return _fail("target_policy requires min_level and max_level: %s" % island_id)
    if (typeof(policy["min_level"]) != TYPE_INT and typeof(policy["min_level"]) != TYPE_FLOAT) or (typeof(policy["max_level"]) != TYPE_INT and typeof(policy["max_level"]) != TYPE_FLOAT):
        return _fail("target_policy bounds must be integers: %s" % island_id)
    if not is_equal_approx(float(policy["min_level"]), float(int(policy["min_level"]))) or not is_equal_approx(float(policy["max_level"]), float(int(policy["max_level"]))):
        return _fail("target_policy bounds must be integers: %s" % island_id)
    var min_level := int(policy["min_level"])
    var max_level := int(policy["max_level"])
    if min_level < MIN_COCKTAIL_LEVEL or max_level > MAX_COCKTAIL_LEVEL or min_level > max_level:
        return _fail("target_policy bounds are invalid: %s" % island_id)
    return true


func _validate_theme(theme: Variant, island_id: String) -> bool:
    if not theme is Dictionary:
        return _fail("theme must be an object: %s" % island_id)
    var family_prefix := "res://assets/ui_assets/campaign/islands/%s/" % island_id
    for key in REQUIRED_THEME_KEYS:
        if not theme.has(key) or typeof(theme[key]) != TYPE_STRING or str(theme[key]).is_empty():
            return _fail("theme missing required path %s: %s" % [key, island_id])
        var path := str(theme[key])
        if not path.begins_with(family_prefix):
            return _fail("theme path is outside island asset family: %s/%s" % [island_id, key])
        if not FileAccess.file_exists(path):
            return _fail("theme asset does not exist: %s" % path)
    var surface_path := str(theme["gameplay_surface"])
    if not surface_path.begins_with(family_prefix) or not FileAccess.file_exists(surface_path):
        return _fail("gameplay_surface asset is missing or outside island asset family: %s" % island_id)
    return true


func _validate_surface_profile(profile: Dictionary, island_id: String, expected_surface_path: String) -> bool:
    if not profile.has_all(["schema_version", "island_id", "surface_path", "surface_sha256", "r04_source_path", "r04_source_sha256", "viewport_px", "geometry"]):
        return _fail("R04 surface profile is incomplete: %s" % island_id)
    if int(profile["schema_version"]) != 1 or str(profile["island_id"]) != island_id:
        return _fail("R04 surface profile identity mismatch: %s" % island_id)
    if str(profile["surface_path"]) != expected_surface_path:
        return _fail("R04 profile surface path mismatch: %s" % island_id)
    if not profile["viewport_px"] is Array or profile["viewport_px"].size() != 2 or int(profile["viewport_px"][0]) != 720 or int(profile["viewport_px"][1]) != 1280:
        return _fail("R04 surface viewport must be 720x1280: %s" % island_id)
    var source_path := str(profile["r04_source_path"])
    if not source_path.begins_with("assets/ui_assets/campaign/islands/%s/" % island_id) or not source_path.ends_with("/gameplay_surface_v07_r04.png"):
        return _fail("R04 source path is outside its island family: %s" % island_id)
    var source_res_path := "res://" + source_path
    if not FileAccess.file_exists(source_res_path):
        return _fail("R04 source asset is missing: %s" % island_id)
    var surface_bytes := FileAccess.get_file_as_bytes(expected_surface_path)
    var source_bytes := FileAccess.get_file_as_bytes(source_res_path)
    if surface_bytes.is_empty() or source_bytes.is_empty():
        return _fail("R04 source or runtime surface is unreadable: %s" % island_id)
    var surface_hash := _sha256(surface_bytes)
    if surface_hash != str(profile["surface_sha256"]) or surface_hash != str(profile["r04_source_sha256"]):
        return _fail("R04 surface/profile SHA-256 mismatch: %s" % island_id)
    if surface_bytes != source_bytes:
        return _fail("runtime surface is not byte-identical to the island R04 source: %s" % island_id)
    var surface_texture := load(expected_surface_path) as Texture2D
    if surface_texture == null or surface_texture.get_width() != 720 or surface_texture.get_height() != 1280:
        return _fail("R04 runtime surface must decode at 720x1280: %s" % island_id)
    return _validate_playable_geometry(profile["geometry"], island_id)


func _sha256(bytes: PackedByteArray) -> String:
    var context := HashingContext.new()
    if context.start(HashingContext.HASH_SHA256) != OK or context.update(bytes) != OK:
        return ""
    return context.finish().hex_encode()


func _validate_playable_geometry(geometry: Variant, island_id: String) -> bool:
    if not geometry is Dictionary or not geometry.has_all(["playable_polygon", "launch_y", "spawn_y", "death_y"]):
        return _fail("playable_geometry requires polygon and launch/spawn/death y: %s" % island_id)
    var polygon: Variant = geometry["playable_polygon"]
    if not polygon is Array or polygon.size() < 3:
        return _fail("playable_polygon requires at least three points: %s" % island_id)
    for point in polygon:
        if not point is Array or point.size() != 2:
            return _fail("playable_polygon points must be canonical pixel pairs: %s" % island_id)
        for index in range(point.size()):
            var coordinate: Variant = point[index]
            if typeof(coordinate) != TYPE_INT and typeof(coordinate) != TYPE_FLOAT:
                return _fail("playable_polygon coordinates must be numeric: %s" % island_id)
            var maximum := 720.0 if index == 0 else 1280.0
            if float(coordinate) < 0.0 or float(coordinate) > maximum:
                return _fail("playable_polygon coordinate is outside canonical viewport: %s" % island_id)
    for key in ["launch_y", "spawn_y", "death_y"]:
        if (typeof(geometry[key]) != TYPE_INT and typeof(geometry[key]) != TYPE_FLOAT) or float(geometry[key]) < 0.0 or float(geometry[key]) > 1280.0:
            return _fail("playable_geometry %s is outside canonical viewport: %s" % [key, island_id])
    return true


func _has_required(value: Dictionary, keys: Array) -> bool:
    for key in keys:
        if not value.has(key):
            return _fail("missing required key: %s" % key)
    return true


func _level_key(island_id: String, level_id: int) -> String:
    return "%s/%d" % [island_id, level_id]


func _copy_read_only(value: Dictionary) -> Dictionary:
    var copy := value.duplicate(true)
    copy.make_read_only()
    return copy


func _fail(message: String) -> bool:
    last_error = message
    return false
