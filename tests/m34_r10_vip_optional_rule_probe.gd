extends SceneTree

const DATABASE_SCRIPT = preload("res://scripts/campaign/level_database.gd")
const BRIDGE_SCRIPT = preload("res://scripts/campaign/gameplay_session_bridge.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var database = DATABASE_SCRIPT.new()
	if not database.load_canonical(
		DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH,
		DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS,
		DATABASE_SCRIPT.ValidationMode.FULL
	):
		push_error("VIP optionality probe failed to load the canonical campaign")
		quit(1)
		return
	var selected_island := ""
	var selected_level := -1
	var selected_cost := 2147483647
	var selected_definition: Dictionary = {}
	for island_id in database.get_island_ids_in_order():
		for definition: Dictionary in database.get_levels_for_island(island_id):
			var vip: Variant = definition.get("vip", null)
			if not vip is Dictionary or not bool(vip.get("enabled", true)):
				continue
			var normal_cost := 0
			for order in definition.get("orders", []):
				normal_cost += (1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"])
			if normal_cost < selected_cost:
				selected_island = str(island_id)
				selected_level = int(definition["level_id"])
				selected_cost = normal_cost
				selected_definition = definition
	if selected_definition.is_empty():
		push_error("No canonical VIP-enabled level exists")
		quit(1)
		return
	var bridge = BRIDGE_SCRIPT.new()
	if not bridge.configure(database) or bridge.start_session(selected_island, selected_level).is_empty() or not bridge.mark_gameplay_ready():
		push_error("Unable to start the canonical VIP rule session")
		quit(1)
		return
	for order in selected_definition.get("orders", []):
		bridge.record_to_go_delivery(int(order["cocktail_level"]), int(order["quantity"]))
		if bridge.is_terminal():
			break
	var terminal: Dictionary = bridge.get_terminal_result()
	var vip_state: Dictionary = bridge.get_vip_state()
	var passed := (
		bridge.is_terminal()
		and str(terminal.get("outcome", "")) == "WIN"
		and bool(vip_state.get("enabled", false))
		and not bool(vip_state.get("completed", true))
		and int(vip_state.get("remaining", 0)) > 0
		and float(selected_definition.get("time_limit_sec", 0.0)) == 0.0
		and not bool(selected_definition.get("feature_flags", {}).get("timed", false))
	)
	print("M34_R10_VIP_RULE level=%s/%d normal_T=%d vip_remaining=%d outcome=%s" % [
		selected_island,
		selected_level,
		selected_cost,
		int(vip_state.get("remaining", 0)),
		str(terminal.get("outcome", "NONE")),
	])
	if passed:
		print("M34_R10_VIP_OPTIONAL_RULE_RESULT=PASS")
		quit(0)
		return
	push_error("Normal completion incorrectly depended on optional VIP fulfillment")
	print("M34_R10_VIP_OPTIONAL_RULE_RESULT=FAIL")
	quit(1)
