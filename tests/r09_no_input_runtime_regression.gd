extends SceneTree

## R09 isolated normal-game no-input runtime regression.
## This loads only the production main scene; it never loads or calls a test
## probe and never calls GameManager.spawn_drink() itself.

const OBSERVATION_SECONDS := 30.5

var failures: Array[String] = []
var max_total_drinks := 0
var max_nonheld_drinks := 0
var max_held_drinks := 0
var max_score := 0
var merge_observed := false
var delivery_observed := false


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var project_file := FileAccess.open("res://project.godot", FileAccess.READ)
    var project_text := project_file.get_as_text() if project_file != null else ""
    _check("normal project main scene is production scene", 'run/main_scene="res://scenes/main.tscn"' in project_text)
    _check("normal project has no autoload section", not project_text.contains("[autoload]"))
    _check("normal project has no test script startup path", not project_text.to_lower().contains("tests/"))

    var packed := load("res://scenes/main.tscn") as PackedScene
    _check("production main scene loads", packed != null)
    if packed == null:
        _finish()
        return

    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    await process_frame

    print("R09_NO_INPUT_ROOT_CHILDREN=%s" % _child_names(root))
    _sample(manager)
    _check("initial score is zero", manager.score == 0)
    _check("initial state has exactly one held preview", _held_count(manager) == 1 and _total_drink_count(manager) == 1)
    _check("initial state has zero non-held drinks", _nonheld_count(manager) == 0)
    _check("initial merge queue is empty", manager.merge_queue != null and manager.merge_queue._pending.is_empty())

    var deadline := Time.get_ticks_msec() + int(OBSERVATION_SECONDS * 1000.0)
    while Time.get_ticks_msec() < deadline:
        await create_timer(0.25).timeout
        _sample(manager)

    _check("30-second no-input score remains zero", manager.score == 0 and max_score == 0)
    _check("30-second no-input has exactly one held preview", _held_count(manager) == 1 and max_held_drinks == 1)
    _check("30-second no-input has zero non-held gameplay drinks", _nonheld_count(manager) == 0 and max_nonheld_drinks == 0)
    _check("30-second no-input has one total drink only", _total_drink_count(manager) == 1 and max_total_drinks == 1)
    _check("30-second no-input has no merge", not merge_observed and manager.chain == 0 and manager.merge_queue._pending.is_empty())
    _check("30-second no-input has no To-Go delivery", not delivery_observed and not manager._target_transition)
    print("R09_NO_INPUT_OBSERVATION_SECONDS=%.1f" % OBSERVATION_SECONDS)
    print("R09_NO_INPUT_FINAL score=%d held=%d nonheld=%d total=%d merge_observed=%s delivery_observed=%s target_transition=%s" % [manager.score, _held_count(manager), _nonheld_count(manager), _total_drink_count(manager), merge_observed, delivery_observed, manager._target_transition])
    manager.queue_free()
    await process_frame
    _finish()


func _sample(manager: GameManager) -> void:
    if manager == null or manager.world == null:
        return
    var total := _total_drink_count(manager)
    var held := _held_count(manager)
    var nonheld := _nonheld_count(manager)
    max_total_drinks = maxi(max_total_drinks, total)
    max_held_drinks = maxi(max_held_drinks, held)
    max_nonheld_drinks = maxi(max_nonheld_drinks, nonheld)
    max_score = maxi(max_score, manager.score)
    if manager.chain > 0 or not manager.merge_queue._pending.is_empty():
        merge_observed = true
    if not manager._target_transition and manager.score > 0:
        delivery_observed = true
    if total != 1 or nonheld != 0 or manager.score != 0 or manager.chain != 0:
        print("R09_NO_INPUT_ABNORMAL total=%d held=%d nonheld=%d score=%d chain=%d children=%s" % [total, held, nonheld, manager.score, manager.chain, _child_names(manager.world)])


func _child_names(node: Node) -> String:
    var names: Array[String] = []
    if node == null:
        return "<null>"
    for child in node.get_children():
        names.append(str(child.name))
    return ",".join(names)


func _total_drink_count(manager: GameManager) -> int:
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
        print("R09_NO_INPUT PASS: %s" % label)
    else:
        failures.append(label)
        print("R09_NO_INPUT FAIL: %s" % label)


func _finish() -> void:
    if failures.is_empty():
        print("R09_NO_INPUT_REGRESSION_RESULT=PASS")
        quit(0)
    else:
        print("R09_NO_INPUT_REGRESSION_RESULT=FAIL failures=%s" % ", ".join(failures))
        quit(1)
