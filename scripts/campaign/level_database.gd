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

var validation_mode: ValidationMode = ValidationMode.SEED
var last_error := ""
var _islands_by_id: Dictionary = {}
var _levels_by_key: Dictionary = {}
var _levels_by_island: Dictionary = {}
var _loaded := false


func load_canonical(
        islands_path: String = DEFAULT_ISLANDS_PATH,
        levels_path: String = DEFAULT_LEVELS_PATH,
        mode: ValidationMode = ValidationMode.SEED
    ) -> bool:
    validation_mode = mode
    _reset()

    var islands_root = _read_json(islands_path, "islands")
    if islands_root == null:
        return false
    var levels_root = _read_json(levels_path, "levels")
    if levels_root == null:
        return false

    if not _validate_island_root(islands_root):
        return false
    if not _validate_level_root(levels_root):
        return false
    _loaded = true
    return true


func load_from_data(islands_root: Variant, levels_root: Variant, mode: ValidationMode = ValidationMode.SEED) -> bool:
    validation_mode = mode
    _reset()
    if not _validate_island_root(islands_root):
        return false
    if not _validate_level_root(levels_root):
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


func get_island_ids() -> Array[String]:
    var ids: Array[String] = []
    for island_id in _islands_by_id.keys():
        ids.append(str(island_id))
    ids.sort()
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
        if not _has_required(raw_island, ["id", "display_name", "order_index", "level_count", "unlock_rule", "next_island_id", "map_background", "reward_track"]):
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
        _islands_by_id[island_id] = raw_island.duplicate(true)

    for island_id in _islands_by_id:
        var next_id := str(_islands_by_id[island_id]["next_island_id"])
        if not next_id.is_empty() and not _islands_by_id.has(next_id):
            return _fail("unresolved next_island_id %s from %s" % [next_id, island_id])
    return true


func _validate_level_root(root: Variant) -> bool:
    if not root is Dictionary:
        return _fail("level root must be an object")
    if not root.has("schema_version") or int(root["schema_version"]) != 1:
        return _fail("level schema_version must be 1")
    if not root.has("island_id") or not root.has("levels") or not root["levels"] is Array:
        return _fail("level root must contain island_id and levels array")
    var root_island_id := str(root["island_id"])
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
        if float(raw_level["time_limit_sec"]) <= 0.0:
            return _fail("time_limit_sec must be positive: %s/%d" % [island_id, level_id])
        if not _validate_orders(raw_level["orders"], island_id, level_id):
            return false
        if raw_level["vip"] != null and not raw_level["vip"] is Dictionary:
            return _fail("vip must be null or an object: %s/%d" % [island_id, level_id])
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

    for island_id in _levels_by_island:
        _levels_by_island[island_id].sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["level_id"]) < int(b["level_id"]))
        if validation_mode == ValidationMode.FULL and _levels_by_island[island_id].size() != int(_islands_by_id[island_id]["level_count"]):
            return _fail("declared island level_count mismatch: %s" % island_id)
    return true


func _validate_orders(orders: Variant, island_id: String, level_id: int) -> bool:
    if not orders is Array or orders.is_empty():
        return _fail("orders must be a non-empty array: %s/%d" % [island_id, level_id])
    for order in orders:
        if not order is Dictionary or not _has_required(order, ["cocktail_level", "quantity"]):
            return _fail("order requires cocktail_level and quantity: %s/%d" % [island_id, level_id])
        var cocktail_level := int(order["cocktail_level"])
        var quantity := int(order["quantity"])
        if cocktail_level < MIN_COCKTAIL_LEVEL or cocktail_level > MAX_COCKTAIL_LEVEL:
            return _fail("cocktail target outside L1-L12: %s/%d" % [island_id, level_id])
        if quantity <= 0:
            return _fail("order quantity must be positive: %s/%d" % [island_id, level_id])
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
