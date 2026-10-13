extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const MANIFEST_SCRIPT := preload("res://scripts/campaign/campaign_content_manifest.gd")

const EXPECTED_IDS := [
	"sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
	"party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
const M32_TIKI_SEED_SHA256 := "AD4AE20C26D482082E9FFD170CC5E66DDE895403FE5E6D260A5BEEC8CFFBFF53"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_CONTENT PASS: %s" % label)
	else:
		failures.append(label)
		print("M33_CONTENT FAIL: %s" % label)


func _run() -> void:
	var manifest_validator = MANIFEST_SCRIPT.new()
	var manifest_result: Dictionary = manifest_validator.validate()
	_check("read-only manifest validates before campaign save access", bool(manifest_result.get("ok", false)))
	if not bool(manifest_result.get("ok", false)):
		print("M33_MANIFEST_ERROR=%s" % str(manifest_result.get("error", "unknown")))
		quit(1)
		return
	var database = DATABASE_SCRIPT.new()
	var loaded := database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("strict canonical FULL database loads all bundled files", loaded)
	if not loaded:
		print("M33_DATABASE_ERROR=%s" % database.get_last_error())
		quit(1)
		return
	var readiness: Dictionary = database.get_campaign_readiness()
	_check("campaign readiness reports exactly 1,000 complete levels", readiness.get("status", "") == "READY" and readiness.get("complete", false) and int(readiness.get("target_total_levels", 0)) == 1000)
	_check("island order matches the manifest contract", database.get_island_ids_in_order() == EXPECTED_IDS)
	_check("M32 staged Tiki source remains byte-identical", _sha256(FileAccess.get_file_as_bytes("res://data/campaign/levels/tiki_island.json")) == M32_TIKI_SEED_SHA256)
	var m32_seed_root: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/campaign/levels/tiki_island.json"))
	var m33_tiki_root: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/campaign/levels/tiki_island_full.json"))
	var m32_tiki_preserved := true
	for level_index in 12:
		var original: Dictionary = m32_seed_root.get("levels", [])[level_index]
		var packaged: Dictionary = m33_tiki_root.get("levels", [])[level_index]
		for key in original:
			m32_tiki_preserved = m32_tiki_preserved and packaged.get(key) == original[key]
		m32_tiki_preserved = m32_tiki_preserved and int(packaged.get("global_level_id", 0)) == 101 + level_index and str(packaged.get("difficulty_tier", "")) == "PRESERVED_M32_SEED"
	_check("M32 Tiki L1-L12 gameplay rows are preserved with additive global/provenance metadata", m32_tiki_preserved)
	var all_full_signatures: Dictionary = {}
	var generated_record_count := 0
	var preserved_m32_count := 0
	var preserved_intro_collisions := 0
	var static_valid := true
	var sunny_intro: Dictionary = {}
	var sunny_levels: Array[Dictionary] = database.get_levels_for_island("sunny_cove")
	for level in sunny_levels.slice(0, 10):
		sunny_intro[_normal_signature(level)] = true
	for island_index in EXPECTED_IDS.size():
		var island_id: String = EXPECTED_IDS[island_index]
		var levels: Array[Dictionary] = database.get_levels_for_island(island_id)
		_check("%s has 100 contiguous local IDs" % island_id, levels.size() == 100)
		var policy: Dictionary = database.get_island(island_id).get("target_policy", {})
		var local_signatures: Dictionary = {}
		var local_normal_signatures: Dictionary = {}
		for level_index in levels.size():
			var level: Dictionary = levels[level_index]
			var inherited_m32 := island_id == "tiki_island" and level_index < 12
			var expected_global := island_index * 100 + level_index + 1
			var global_id := int(level.get("global_level_id", expected_global))
			var theoretical := 0
			var normal_theoretical := 0
			var max_normal_target := 0
			var min_normal_targets := 0
			var objectives: Dictionary = {}
			var target_valid := true
			for order in level.get("orders", []):
				var target := int(order.get("cocktail_level", 0))
				var quantity := int(order.get("quantity", 0))
				target_valid = target_valid and target >= int(policy.get("min_level", 1)) and target <= int(policy.get("max_level", 12)) and quantity >= 1 and quantity <= 2
				theoretical += (1 << (target - 3)) * quantity if target >= 3 else 0
				normal_theoretical += (1 << (target - 3)) * quantity if target >= 3 else 0
				max_normal_target = maxi(max_normal_target, target)
				min_normal_targets += 1 if target < 6 else 0
				objectives[target] = true
			var vip: Variant = level.get("vip", null)
			if vip is Dictionary and bool(vip.get("enabled", true)):
				var vip_target := int(vip.get("cocktail_level", 0))
				var vip_quantity := int(vip.get("quantity", 0))
				target_valid = target_valid and vip_target >= int(policy.get("min_level", 1)) and vip_target <= int(policy.get("max_level", 12)) and vip_quantity >= 1 and vip_quantity <= 2 and not objectives.has(vip_target)
				target_valid = target_valid and (inherited_m32 or vip_target > max_normal_target)
				theoretical += (1 << (vip_target - 3)) * vip_quantity if vip_target >= 3 else 0
			var new_campaign_level := island_index > 0
			var recipe_signature := _full_signature(level)
			local_signatures[recipe_signature] = int(local_signatures.get(recipe_signature, 0)) + 1
			local_normal_signatures[_normal_signature(level)] = true
			if new_campaign_level:
				all_full_signatures[recipe_signature] = true
			var easy_intro_collision := sunny_intro.has(_normal_signature(level))
			if inherited_m32 and easy_intro_collision:
				preserved_intro_collisions += 1
			var is_capstone := not inherited_m32 and int(level.get("level_id", -1)) == 100
			var difficulty_valid := true
			if new_campaign_level and not inherited_m32:
				difficulty_valid = bool(level.get("prestige_capstone", false)) == is_capstone and str(level.get("level_type", "")) == ("PRESTIGE_CAPSTONE" if is_capstone else "ORDINARY")
				if is_capstone:
					difficulty_valid = difficulty_valid and normal_theoretical > 56 and normal_theoretical <= 80 and objectives.has(9)
				else:
					difficulty_valid = difficulty_valid and normal_theoretical <= 56 and max_normal_target <= 8 and max_normal_target >= 6 and min_normal_targets <= 1
			var record_valid: bool = global_id == expected_global and float(level.get("time_limit_sec", -1.0)) == 0.0 and level.get("orders", []).size() >= 1 and (not new_campaign_level or inherited_m32 or (level.get("orders", []).size() >= 2 and target_valid)) and (not inherited_m32 or target_valid) and difficulty_valid and int(level.get("theoretical_shots_total", -1)) == theoretical and int(level.get("move_limit", -1)) == theoretical * 4 and not (new_campaign_level and not inherited_m32 and easy_intro_collision)
			if not record_valid:
				print("M33_INVALID_RECORD island=%s level=%d global=%d expected=%d target_valid=%s shots=%d expected_shots=%d move=%d expected_move=%d intro=%s" % [island_id, int(level.get("level_id", -1)), global_id, expected_global, target_valid, int(level.get("theoretical_shots_total", -1)), theoretical, int(level.get("move_limit", -1)), theoretical * 4, easy_intro_collision])
			static_valid = static_valid and record_valid
			if inherited_m32:
				preserved_m32_count += 1
			elif new_campaign_level:
				generated_record_count += 1
		if island_index > 0:
			_check("%s has 100 distinct full challenge signatures" % island_id, local_signatures.size() == 100)
			_check("%s has 100 distinct normal objective templates" % island_id, local_normal_signatures.size() == 100)
	_check("all records satisfy 4T, policy, quantity and no-timer rules", static_valid)
	_check("900 new global campaign levels are present: 12 inherited M32 Tiki plus 888 generated", generated_record_count == 888 and preserved_m32_count == 12)
	print("M33_CROSS_ISLAND_FULL_RECIPE_REPEATS=%d" % (generated_record_count + preserved_m32_count - all_full_signatures.size()))
	_check("Sunny intro-template overlap is limited to the 12 explicitly preserved M32 Tiki records", preserved_intro_collisions > 0)
	_check("final local level is global level 1000", int(database.get_level("final_island", 100).get("global_level_id", 0)) == 1000)
	_check("Sunny Cove remains 100 rows", database.get_levels_for_island("sunny_cove").size() == 100)
	if failures.is_empty():
		print("M33_CONTENT_RESULT=PASS")
		quit(0)
	else:
		print("M33_CONTENT_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)


func _normal_signature(level: Dictionary) -> String:
	var orders: Array = []
	for row in level.get("orders", []):
		orders.append({"cocktail_level": int(row.get("cocktail_level", 0)), "quantity": int(row.get("quantity", 0))})
	return JSON.stringify(orders)


func _full_signature(level: Dictionary) -> String:
	var vip: Variant = level.get("vip", null)
	var normalized_vip := {"enabled": false, "cocktail_level": 0, "quantity": 0}
	if vip is Dictionary and bool(vip.get("enabled", true)):
		normalized_vip = {"enabled": true, "cocktail_level": int(vip.get("cocktail_level", 0)), "quantity": int(vip.get("quantity", 0))}
	return JSON.stringify({"orders": JSON.parse_string(_normal_signature(level)), "time_limit_sec": float(level.get("time_limit_sec", 0)), "vip": normalized_vip})


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode().to_upper()
