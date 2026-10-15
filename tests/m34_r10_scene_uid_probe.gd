extends SceneTree


const SCENES := [
	{"scene": "res://scenes/main.tscn", "script": "res://scripts/game_manager.gd"},
	{"scene": "res://scenes/campaign/WorldMapScene.tscn", "script": "res://scripts/campaign/world_map_controller.gd"},
]


func _initialize() -> void:
	var failures: Array[String] = []
	for expectation in SCENES:
		var packed := ResourceLoader.load(str(expectation["scene"])) as PackedScene
		if packed == null:
			failures.append("scene failed to load: %s" % expectation["scene"])
			continue
		var instance := packed.instantiate()
		if instance == null:
			failures.append("scene failed to instantiate: %s" % expectation["scene"])
			continue
		var attached := instance.get_script() as Script
		if attached == null or attached.resource_path != str(expectation["script"]):
			failures.append("%s root script resolved to %s, expected %s" % [expectation["scene"], attached.resource_path if attached != null else "NONE", expectation["script"]])
		else:
			print("PASS: %s root loaded with %s" % [expectation["scene"], attached.resource_path])
		instance.free()
	if failures.is_empty():
		print("M34_R10_SCENE_UID_RESULT=PASS")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("M34_R10_SCENE_UID_RESULT=FAIL")
	quit(1)
