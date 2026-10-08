class_name PresentationEffectPolicy
extends RefCounted

## Single executable authority for later presentation tiers. This policy does
## not enable production dispatch; M22 keeps that disabled in the bridge.

const MODES := ["FULL", "REDUCED"]
const SEMANTIC_KINDS := [
	"cocktail_launch", "table_contact", "merge", "order_progress", "order_complete",
	"vip_delivery", "vip_complete", "score_mastery", "game_success", "game_fail",
	"level_unlock", "island_milestone", "island_complete", "island_unlock",
	"reward_granted", "ui_primary",
]
const ALWAYS_FORBIDDEN_GFF := ["impulse", "velocity", "freeze_frame", "time_scale", "camera_flash", "camera_shake"]
const SAFE_SPARK_OPTIONS := [
	"amount", "lifetime", "speed", "speed_min", "lifetime_rand", "size", "size_end",
	"gravity", "damping", "spread", "direction", "color", "color2",
]
const MOBILE_CEILINGS := {
	"MICRO": {"amount": 5, "lifetime": 0.16},
	"MERGE": {"amount": 10, "lifetime": 0.30},
	"MERGE_PEAK": {"amount": 18, "lifetime": 0.35},
	"ORDER": {"amount": 16, "lifetime": 0.45},
	"VIP": {"amount": 24, "lifetime": 0.65},
	"WIN": {"amount": 48, "lifetime": 1.20},
	"MASTERY": {"amount": 64, "lifetime": 1.50},
	"ISLAND_UNLOCK": {"amount": 72, "lifetime": 1.60},
	"FAIL": {"amount": 0, "lifetime": 0.0},
	"gameplay_live": 48,
	"result_meta_live": 96,
	"large_celebrations": 1,
}

const POLICY := {
	"cocktail_launch": {
		"tier": "MICRO", "target": "Drink/Visual or CocktailSprite",
		"full": {"style": "one brief local scale or alpha/color emphasis", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 5, "max_lifetime": 0.16, "max_speed": 45.0, "presets": ["hit", "spark"]}},
		"reduced": {"style": "immediate state plus low-contrast alpha/color only", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 0, "max_lifetime": 0.0, "max_speed": 0.0, "presets": []}},
		"overlap_cancel": "coalesce by shot event; cancel on visual target or session exit",
	},
	"table_contact": {
		"tier": "MICRO", "target": "Drink/Visual or CocktailSprite",
		"full": {"style": "brief local alpha/color emphasis; no contact particle required", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 5, "max_lifetime": 0.16, "max_speed": 40.0, "presets": ["hit", "dust"]}},
		"reduced": {"style": "immediate state plus low-contrast alpha/color only", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 0, "max_lifetime": 0.0, "max_speed": 0.0, "presets": []}},
		"overlap_cancel": "coalesce repeated contact on the same visual target; cancel on target/session exit",
	},
	"merge": {
		"tier": "MERGE", "target": "merged Drink/Visual",
		"full": {"style": "local scale punch and alpha/color; BASE 1-2, SURGE 3-4, PEAK 5+ hard cap", "gff_effects": ["punch_scale", "color", "alpha"], "spark_bands": [
			{"name": "BASE", "min_chain": 1, "max_chain": 2, "budget": {"max_amount": 10, "max_lifetime": 0.30, "max_speed": 90.0, "presets": ["hit", "spark"]}},
			{"name": "SURGE", "min_chain": 3, "max_chain": 4, "budget": {"max_amount": 10, "max_lifetime": 0.30, "max_speed": 90.0, "presets": ["hit", "spark"]}},
			{"name": "PEAK", "min_chain": 5, "max_chain": 0, "budget": {"max_amount": 18, "max_lifetime": 0.35, "max_speed": 105.0, "presets": ["hit", "spark"]}},
		]},
		"reduced": {"style": "immediate merge state plus low-contrast alpha/color; no scale, travel, or particles", "gff_effects": ["color", "alpha"], "spark_bands": [
			{"name": "BASE", "min_chain": 1, "max_chain": 2, "budget": {"max_amount": 2, "max_lifetime": 0.12, "max_speed": 30.0, "presets": ["dust"]}},
			{"name": "SURGE", "min_chain": 3, "max_chain": 4, "budget": {"max_amount": 2, "max_lifetime": 0.12, "max_speed": 30.0, "presets": ["dust"]}},
			{"name": "PEAK", "min_chain": 5, "max_chain": 0, "budget": {"max_amount": 4, "max_lifetime": 0.14, "max_speed": 32.0, "presets": ["dust"]}},
		]},
		"overlap_cancel": "retain one local emphasis per merged visual; newer merge replaces prior; PEAK never escalates past PEAK",
	},
	"order_progress": {
		"tier": "ORDER", "target": "To-Go order visual panel",
		"full": {"style": "short local alpha/color emphasis; restrained reveal only", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 16, "max_lifetime": 0.45, "max_speed": 100.0, "presets": ["pickup", "spark"]}},
		"reduced": {"style": "immediate progress state plus brief low-contrast alpha/color", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 4, "max_lifetime": 0.20, "max_speed": 38.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by order event ID; retain latest authoritative progress; cancel on panel/session exit",
	},
	"order_complete": {
		"tier": "ORDER", "target": "To-Go order visual panel",
		"full": {"style": "short local scale punch or alpha/color; restrained reveal sequence", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 16, "max_lifetime": 0.45, "max_speed": 100.0, "presets": ["pickup", "spark"]}},
		"reduced": {"style": "immediate completed state plus brief low-contrast alpha/color", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 4, "max_lifetime": 0.20, "max_speed": 38.0, "presets": ["dust"]}},
		"overlap_cancel": "one completion emphasis per stable token; cancel on panel/session exit",
	},
	"vip_delivery": {
		"tier": "VIP", "target": "VIP target visual or VIP progress label",
		"full": {"style": "local scale punch and color emphasis; one bounded burst", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 24, "max_lifetime": 0.65, "max_speed": 110.0, "presets": ["pickup", "spark"]}},
		"reduced": {"style": "immediate VIP delivery state plus low-contrast alpha/color; no scale or particles", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 6, "max_lifetime": 0.28, "max_speed": 40.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by stable VIP delivery token; cancel on target/session exit",
	},
	"vip_complete": {
		"tier": "VIP", "target": "VIP target visual or VIP completion label",
		"full": {"style": "local scale punch and color emphasis; one bounded burst", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 24, "max_lifetime": 0.65, "max_speed": 110.0, "presets": ["pickup", "spark"]}},
		"reduced": {"style": "immediate VIP completion state plus low-contrast alpha/color; no scale or particles", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 6, "max_lifetime": 0.28, "max_speed": 40.0, "presets": ["dust"]}},
		"overlap_cancel": "one completion emphasis per stable token; cancel on target/session exit",
	},
	"score_mastery": {
		"tier": "MASTERY", "target": "score/result visual child",
		"full": {"style": "brief local scale/color emphasis and restrained reveal; at most one celebration", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 64, "max_lifetime": 1.50, "max_speed": 120.0, "presets": ["confetti", "spark"]}},
		"reduced": {"style": "immediate mastery/result state plus brief low-contrast alpha/color; no confetti or motion", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 16, "max_lifetime": 0.60, "max_speed": 45.0, "presets": ["dust"]}},
		"overlap_cancel": "share the single large-celebration slot with WIN/ISLAND_UNLOCK; cancel on result/session exit",
	},
	"game_success": {
		"tier": "WIN", "target": "result visual controls or result visual child",
		"full": {"style": "brief local color/scale emphasis with a bounded confetti or spark burst; reveal result data only", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 48, "max_lifetime": 1.20, "max_speed": 115.0, "presets": ["confetti", "spark"]}},
		"reduced": {"style": "immediate WIN/result state plus low-contrast alpha/color; no confetti, scale, travel, or sequence", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 12, "max_lifetime": 0.48, "max_speed": 42.0, "presets": ["dust"]}},
		"overlap_cancel": "share one large-celebration slot; cancel on result/session exit; result actions stay immediately available",
	},
	"game_fail": {
		"tier": "FAIL", "target": "result visual controls or fail-result visual child",
		"full": {"style": "subdued non-celebratory alpha/color emphasis; never WIN/confetti language", "gff_effects": ["alpha", "color"], "spark": {"max_amount": 0, "max_lifetime": 0.0, "max_speed": 0.0, "presets": []}},
		"reduced": {"style": "immediate FAIL/result state; optional brief low-contrast alpha/color only", "gff_effects": ["alpha", "color"], "spark": {"max_amount": 0, "max_lifetime": 0.0, "max_speed": 0.0, "presets": []}},
		"overlap_cancel": "cancel all transient result emphasis on result/session exit; never share WIN celebration mapping",
	},
	"level_unlock": {
		"tier": "ISLAND_UNLOCK", "target": "unlocked LevelButton visual child",
		"full": {"style": "brief local alpha/color emphasis with one bounded reveal; no root/button travel", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 72, "max_lifetime": 1.60, "max_speed": 120.0, "presets": ["confetti", "pickup", "spark"]}},
		"reduced": {"style": "immediate unlocked state plus low-contrast alpha/color; no confetti or motion", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 18, "max_lifetime": 0.64, "max_speed": 45.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by unlock ID; share one large-celebration slot; cancel on map/session exit",
	},
	"island_milestone": {
		"tier": "ISLAND_UNLOCK", "target": "island milestone visual child",
		"full": {"style": "brief local alpha/color emphasis with one bounded reveal", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 72, "max_lifetime": 1.60, "max_speed": 120.0, "presets": ["confetti", "pickup", "spark"]}},
		"reduced": {"style": "immediate milestone state plus low-contrast alpha/color; no confetti or motion", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 18, "max_lifetime": 0.64, "max_speed": 45.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by milestone ID; share one large-celebration slot; cancel on map/session exit",
	},
	"island_complete": {
		"tier": "ISLAND_UNLOCK", "target": "island completion visual child",
		"full": {"style": "brief local alpha/color emphasis with one bounded reveal", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 72, "max_lifetime": 1.60, "max_speed": 120.0, "presets": ["confetti", "pickup", "spark"]}},
		"reduced": {"style": "immediate completion state plus low-contrast alpha/color; no confetti or motion", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 18, "max_lifetime": 0.64, "max_speed": 45.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by island ID; share one large-celebration slot; cancel on map/session exit",
	},
	"island_unlock": {
		"tier": "ISLAND_UNLOCK", "target": "unlocked island map visual entry",
		"full": {"style": "brief local alpha/color emphasis with one bounded reveal", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 72, "max_lifetime": 1.60, "max_speed": 120.0, "presets": ["confetti", "pickup", "spark"]}},
		"reduced": {"style": "immediate unlocked state plus low-contrast alpha/color; no confetti or motion", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 18, "max_lifetime": 0.64, "max_speed": 45.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by island ID; share one large-celebration slot; cancel on map/session exit",
	},
	"reward_granted": {
		"tier": "ISLAND_UNLOCK", "target": "reward/result visual child",
		"full": {"style": "brief local alpha/color emphasis; restrained reward reveal", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 16, "max_lifetime": 0.45, "max_speed": 80.0, "presets": ["pickup", "spark"]}},
		"reduced": {"style": "immediate granted reward state plus low-contrast alpha/color; no travel or confetti", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 4, "max_lifetime": 0.20, "max_speed": 32.0, "presets": ["dust"]}},
		"overlap_cancel": "coalesce by reward ID; preserve the visible reward and action; cancel on result/session exit",
	},
	"ui_primary": {
		"tier": "MICRO", "target": "approved CTA visual child only; never arbitrary generic-button feedback",
		"full": {"style": "one brief local scale or alpha/color emphasis on the approved CTA child", "gff_effects": ["punch_scale", "color", "alpha"], "spark": {"max_amount": 5, "max_lifetime": 0.16, "max_speed": 40.0, "presets": ["hit", "spark"]}},
		"reduced": {"style": "immediate action state plus brief low-contrast alpha/color only", "gff_effects": ["color", "alpha"], "spark": {"max_amount": 0, "max_lifetime": 0.0, "max_speed": 0.0, "presets": []}},
		"overlap_cancel": "one emphasis per semantic action; do not replay on settings/view changes; cancel on target/session exit",
	},
}


func get_policy(kind: String, mode: String = "FULL") -> Dictionary:
	if not POLICY.has(kind) or not MODES.has(mode):
		return {}
	var result: Dictionary = POLICY[kind].duplicate(true)
	result["mode"] = mode
	result["mode_policy"] = POLICY[kind][mode.to_lower()].duplicate(true)
	result["production_enabled_in_m22"] = false
	return result


func get_spark_budget(kind: String, mode: String = "FULL", chain: int = 1) -> Dictionary:
	var row := get_policy(kind, mode)
	if row.is_empty():
		return {}
	var mode_policy: Dictionary = row["mode_policy"]
	if mode_policy.has("spark"):
		return mode_policy.spark.duplicate(true)
	for band in mode_policy.get("spark_bands", []):
		var max_chain := int(band.get("max_chain", 0))
		if chain >= int(band.get("min_chain", 1)) and (max_chain == 0 or chain <= max_chain):
			var budget: Dictionary = band.get("budget", {}).duplicate(true)
			budget["band"] = str(band.get("name", ""))
			return budget.duplicate(true)
	return {}


func validate_dispatch(request: Dictionary, mode: String, plan: Dictionary) -> Dictionary:
	var kind := str(request.get("kind", ""))
	var row := get_policy(kind, mode)
	if row.is_empty():
		return {"ok": false, "reason": "unknown_kind_or_mode"}
	var payload_value: Variant = request.get("payload", {})
	if not payload_value is Dictionary:
		return {"ok": false, "reason": "payload_invalid"}
	var payload: Dictionary = payload_value
	if plan.has("gff_combo") and not str(plan.get("gff_combo", "")).is_empty():
		return {"ok": false, "reason": "stock_combos_blocked"}
	var effect_name := str(plan.get("gff_effect", ""))
	var spark_preset := str(plan.get("spark_preset", ""))
	var has_effect := not effect_name.is_empty()
	var has_spark := not spark_preset.is_empty()
	if not has_effect and not has_spark:
		return {"ok": false, "reason": "unknown_mapping"}
	if is_large_celebration(kind) and not can_start_large_celebration(int(plan.get("active_large_celebrations", 0))):
		return {"ok": false, "reason": "large_celebration_slot_busy"}
	if has_effect:
		if ALWAYS_FORBIDDEN_GFF.has(effect_name):
			return {"ok": false, "reason": "forbidden_gff_effect:%s" % effect_name}
		if not row.mode_policy.gff_effects.has(effect_name):
			return {"ok": false, "reason": "gff_effect_not_allowed:%s" % effect_name}
	if has_spark:
		var budget := get_spark_budget(kind, mode, int(payload.get("chain", 1)))
		if not budget.get("presets", []).has(spark_preset):
			return {"ok": false, "reason": "spark_preset_not_allowed:%s" % spark_preset}
		var overrides: Variant = plan.get("spark_overrides", {})
		if not overrides is Dictionary:
			return {"ok": false, "reason": "spark_overrides_invalid"}
		for required in ["amount", "lifetime", "speed"]:
			if not overrides.has(required):
				return {"ok": false, "reason": "spark_override_missing:%s" % required}
		for key in overrides:
			if not SAFE_SPARK_OPTIONS.has(str(key)):
				return {"ok": false, "reason": "spark_option_unknown:%s" % str(key)}
		var amount: Variant = overrides.amount
		var lifetime: Variant = overrides.lifetime
		var speed: Variant = overrides.speed
		if not _is_finite_number(amount) or not is_equal_approx(float(amount), float(int(amount))) or int(amount) < 0 or int(amount) > int(budget.max_amount):
			return {"ok": false, "reason": "spark_amount_over_budget"}
		if not _is_finite_number(lifetime) or float(lifetime) < 0.0 or float(lifetime) > float(budget.max_lifetime):
			return {"ok": false, "reason": "spark_lifetime_over_budget"}
		if not _is_finite_number(speed) or float(speed) < 0.0 or float(speed) > float(budget.max_speed):
			return {"ok": false, "reason": "spark_speed_over_budget"}
		var live_check := validate_live_particle_count(kind, int(plan.get("active_live_particles", 0)), int(amount))
		if not bool(live_check.get("ok", false)):
			return live_check
	return {"ok": true, "kind": kind, "mode": mode, "tier": str(row.tier), "budget": get_spark_budget(kind, mode, int(payload.get("chain", 1)))}


func validate_policy() -> Dictionary:
	var failures: Array[String] = []
	for kind in SEMANTIC_KINDS:
		if not POLICY.has(kind):
			failures.append("missing_kind:%s" % kind)
			continue
		var row: Dictionary = POLICY[kind]
		if str(row.get("tier", "")).is_empty() or str(row.get("target", "")).is_empty() or str(row.get("overlap_cancel", "")).is_empty():
			failures.append("incomplete_row:%s" % kind)
		for mode in MODES:
			var mode_policy: Dictionary = row.get(mode.to_lower(), {})
			if mode_policy.is_empty() or str(mode_policy.get("style", "")).is_empty() or not mode_policy.has("gff_effects"):
				failures.append("incomplete_mode:%s:%s" % [kind, mode])
				continue
			for effect_name in mode_policy.gff_effects:
				if ALWAYS_FORBIDDEN_GFF.has(str(effect_name)) or not ["punch_scale", "color", "alpha"].has(str(effect_name)):
					failures.append("unsafe_gff_effect:%s:%s:%s" % [kind, mode, effect_name])
			var budgets_to_check: Array[Dictionary] = []
			if mode_policy.has("spark_bands"):
				for band in mode_policy.spark_bands:
					var band_budget: Dictionary = band.budget.duplicate(true)
					band_budget["band"] = str(band.name)
					budgets_to_check.append(band_budget)
			else:
				budgets_to_check.append(get_spark_budget(kind, mode))
			for budget in budgets_to_check:
				var ceiling_key := "MERGE_PEAK" if str(row.tier) == "MERGE" and str(budget.get("band", "")) == "PEAK" else str(row.tier)
				var ceiling: Dictionary = MOBILE_CEILINGS.get(ceiling_key, {})
				if budget.is_empty() or ceiling.is_empty():
					failures.append("missing_budget:%s:%s" % [kind, mode])
					continue
				if int(budget.max_amount) > int(ceiling.amount) or float(budget.max_lifetime) > float(ceiling.lifetime):
					failures.append("over_mobile_ceiling:%s:%s:%s" % [kind, mode, str(budget.get("band", ""))])
				if int(budget.max_amount) > int(MOBILE_CEILINGS.result_meta_live):
					failures.append("over_result_meta_live:%s:%s" % [kind, mode])
				if mode == "REDUCED":
					var chain := 1
					if str(row.tier) == "MERGE":
						chain = 5 if str(budget.get("band", "")) == "PEAK" else (3 if str(budget.get("band", "")) == "SURGE" else 1)
					var full_budget := get_spark_budget(kind, "FULL", chain)
					if str(row.tier) == "MICRO" and int(budget.max_amount) != 0:
						failures.append("reduced_micro_particles:%s" % kind)
					if kind == "table_contact" and int(budget.max_amount) != 0:
						failures.append("reduced_contact_particles")
					if str(row.tier) in ["MERGE", "ORDER", "VIP", "WIN", "MASTERY", "ISLAND_UNLOCK"] and int(budget.max_amount) > floor(float(full_budget.max_amount) * 0.25):
						failures.append("reduced_over_quarter:%s:%s" % [kind, str(budget.get("band", ""))])
					if str(row.tier) != "FAIL" and (float(budget.max_speed) >= float(full_budget.max_speed) or float(budget.max_lifetime) >= float(full_budget.max_lifetime)):
						failures.append("reduced_motion_not_lower:%s" % kind)
				if mode == "REDUCED" and mode_policy.get("spark", {}).get("presets", []).has("confetti"):
					failures.append("reduced_confetti:%s" % kind)
	if POLICY.size() != SEMANTIC_KINDS.size():
		failures.append("catalog_policy_count_mismatch")
	if POLICY.game_fail.tier == POLICY.game_success.tier or not POLICY.game_fail.full.spark.presets.is_empty() or not POLICY.game_fail.reduced.spark.presets.is_empty():
		failures.append("game_fail_not_subdued")
	return {"ok": failures.is_empty(), "failures": failures, "kind_count": POLICY.size(), "mode_rows": POLICY.size() * MODES.size()}


func can_start_large_celebration(active_count: int) -> bool:
	return active_count < int(MOBILE_CEILINGS.large_celebrations)


func is_large_celebration(kind: String) -> bool:
	var row: Dictionary = POLICY.get(kind, {})
	return ["WIN", "MASTERY", "ISLAND_UNLOCK"].has(str(row.get("tier", "")))


func validate_live_particle_count(kind: String, active_count: int, requested_count: int) -> Dictionary:
	if not POLICY.has(kind) or active_count < 0 or requested_count < 0:
		return {"ok": false, "reason": "particle_count_invalid"}
	var row: Dictionary = POLICY[kind]
	var ceiling := int(MOBILE_CEILINGS.result_meta_live) if ["WIN", "MASTERY", "ISLAND_UNLOCK", "FAIL"].has(str(row.tier)) else int(MOBILE_CEILINGS.gameplay_live)
	if active_count + requested_count > ceiling:
		return {"ok": false, "reason": "live_particle_ceiling_exceeded", "ceiling": ceiling}
	return {"ok": true, "live_particles_after": active_count + requested_count, "ceiling": ceiling}


func render_markdown_matrix() -> String:
	var lines := [
		"# BCM-M22 Effect Language Matrix — Owner Review V01",
		"",
		"Status: **BUILDER PROPOSAL — OWNER APPROVAL REQUIRED BEFORE M23**",
		"",
		"This matrix is rendered from `scripts/presentation_effect_policy.gd`. It defines later FULL/REDUCED policy only. Production dispatch and visible particles remain disabled in M22.",
		"",
		"## Global limits and exclusions",
		"",
		"- GFF forbidden: `impulse`, `velocity`, `freeze_frame`, `time_scale`, `camera_flash`, and camera/screen shake.",
		"- No stock GFF combo execution. Only explicit safe single-effect names are allowed by policy: `punch_scale`, `color`, `alpha`.",
		"- No authority root, physics body, collider, table, rail, or camera transforms. Spark always requires explicit `amount`, `lifetime`, and `speed` overrides.",
		"- Gameplay live-particle ceiling: 48. Result/meta ceiling: 96. Large celebrations active at once: 1.",
		"- Mobile ceilings: MICRO 5/0.16 s; MERGE 10/0.30 s; MERGE PEAK 18/0.35 s; ORDER 16/0.45 s; VIP 24/0.65 s; WIN 48/1.20 s; MASTERY 64/1.50 s; ISLAND_UNLOCK 72/1.60 s.",
		"- REDUCED removes shake, camera motion, squash/stretch, spring/position travel, large confetti, and rapid sequencing. Important tiers use at most 25% of FULL particle count with lower speed/lifetime. MICRO and table-contact use zero particles.",
		"",
		"## Per-kind policy",
		"",
		"| Semantic kind | Tier / target | FULL language, GFF, Spark | REDUCED language, GFF, Spark | Overlap / cancellation |",
		"|---|---|---|---|---|",
	]
	for kind in SEMANTIC_KINDS:
		var row: Dictionary = POLICY[kind]
		var full: Dictionary = row.full
		var reduced: Dictionary = row.reduced
		lines.append("| `%s` | %s; %s | %s; GFF `%s`; Spark ≤%d / %.2fs / %.0fpx/s `%s` | %s; GFF `%s`; Spark ≤%d / %.2fs / %.0fpx/s `%s` | %s |" % [
			kind, row.tier, row.target,
			full.style, ", ".join(PackedStringArray(full.gff_effects)), _table_amount(kind, "FULL"), _table_lifetime(kind, "FULL"), _table_speed(kind, "FULL"), ", ".join(PackedStringArray(_table_presets(kind, "FULL"))),
			reduced.style, ", ".join(PackedStringArray(reduced.gff_effects)), _table_amount(kind, "REDUCED"), _table_lifetime(kind, "REDUCED"), _table_speed(kind, "REDUCED"), ", ".join(PackedStringArray(_table_presets(kind, "REDUCED"))),
			row.overlap_cancel,
		])
	lines.append_array([
		"",
		"## Review notes",
		"",
		"- Every row has `production_enabled_in_m22 = false`; no policy row activates production effects or particles.",
		"- `game_fail` is a subdued FAIL result and has no Spark budget. It never reuses WIN/MASTERY celebration mapping.",
		"- MERGE bands are BASE chain 1–2, SURGE 3–4, and PEAK 5+; PEAK is hard-capped with no escalation beyond its budget.",
		"- This artifact is not owner acceptance. M23 remains blocked until independent M22 audit PASS and owner approval.",
	])
	return "\n".join(lines) + "\n"


func get_catalog_report() -> Dictionary:
	return {
		"modes": MODES.duplicate(),
		"semantic_kinds": SEMANTIC_KINDS.duplicate(),
		"mobile_ceilings": MOBILE_CEILINGS.duplicate(true),
		"policy": POLICY.duplicate(true),
		"production_enabled_in_m22": false,
		"large_celebrations_active_at_once": int(MOBILE_CEILINGS.large_celebrations),
	}


func _table_amount(kind: String, mode: String) -> int:
	return int(get_spark_budget(kind, mode, 5 if kind == "merge" else 1).get("max_amount", 0))


func _table_lifetime(kind: String, mode: String) -> float:
	return float(get_spark_budget(kind, mode, 5 if kind == "merge" else 1).get("max_lifetime", 0.0))


func _table_speed(kind: String, mode: String) -> float:
	return float(get_spark_budget(kind, mode, 5 if kind == "merge" else 1).get("max_speed", 0.0))


func _table_presets(kind: String, mode: String) -> Array:
	return get_spark_budget(kind, mode, 5 if kind == "merge" else 1).get("presets", [])


func _is_finite_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))
