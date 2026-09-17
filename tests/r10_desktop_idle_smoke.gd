extends SceneTree

## R10 desktop no-input smoke. It loads only the configured production scene;
## it does not invoke a probe or call spawn_drink().

const OBSERVATION_SECONDS := 10.0
var failures: Array[String] = []
var max_total := 0
var max_held := 0
var max_nonheld := 0
var max_score := 0


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var project_file := FileAccess.open("res://project.godot", FileAccess.READ)
    var project_text := project_file.get_as_text() if project_file != null else ""
    _check("desktop smoke uses production main scene", 'run/main_scene="res://scenes/main.tscn"' in project_text)
    _check("desktop smoke has no test startup path", not project_text.to_lower().contains("tests/"))
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("desktop smoke production scene loads", packed != null)
    if packed == null:
        _finish()
        return
    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    var deadline := Time.get_ticks_msec() + int(OBSERVATION_SECONDS * 1000.0)
    while Time.get_ticks_msec() < deadline:
        await create_timer(0.25).timeout
        _sample(manager)
    _check("desktop idle score remains zero", manager.score == 0 and max_score == 0)
    _check("desktop idle has exactly one held preview", _held_count(manager) == 1 and max_held == 1)
    _check("desktop idle has zero non-held drinks", _nonheld_count(manager) == 0 and max_nonheld == 0)
    _check("desktop idle has one total drink only", _total_count(manager) == 1 and max_total == 1)
    print("R10_DESKTOP_IDLE_OBSERVATION_SECONDS=%.1f" % OBSERVATION_SECONDS)
    print("R10_DESKTOP_IDLE_FINAL score=%d held=%d nonheld=%d total=%d" % [manager.score, _held_count(manager), _nonheld_count(manager), _total_count(manager)])
    manager.queue_free()
    await process_frame
    _finish()


func _sample(manager: GameManager) -> void:
    max_total = maxi(max_total, _total_count(manager))
    max_held = maxi(max_held, _held_count(manager))
    max_nonheld = maxi(max_nonheld, _nonheld_count(manager))
    max_score = maxi(max_score, manager.score)


func _total_count(manager: GameManager) -> int:
    var count := 0
    for child in manager.world.get_children():
        if child is Drink and not child.is_queued_for_deletion():
            count += 1
    return count


func _held_count(manager: GameManager) -> int:
    var count := 0
    for child in manager.world.get_children():
        if child is Drink and not child.is_queued_for_deletion() and child.motion_state == Drink.MotionState.HELD:
            count += 1
    return count


func _nonheld_count(manager: GameManager) -> int:
    var count := 0
    for child in manager.world.get_children():
        if child is Drink and not child.is_queued_for_deletion() and child.motion_state != Drink.MotionState.HELD:
            count += 1
    return count


func _check(label: String, condition: bool) -> void:
    if condition:
        print("R10_DESKTOP_IDLE PASS: %s" % label)
    else:
        failures.append(label)
        print("R10_DESKTOP_IDLE FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R10_DESKTOP_IDLE_RESULT=PASS")
        quit(0)
    else:
        print("R10_DESKTOP_IDLE_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
