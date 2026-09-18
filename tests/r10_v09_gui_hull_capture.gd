extends SceneTree

## Normal-display production capture for V09 hull/rail/normal owner review.

const OUTPUT_PATH := "res://docs/evidence/r10/v09_gui_hull_contacts_720x1280.png"


func _init() -> void:
    call_deferred("_capture")


func _capture() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        print("R10_V09_GUI_CAPTURE_RESULT=FAIL reason=main_scene")
        quit(1)
        return
    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    await process_frame

    var edges := manager.get_playable_boundary_edges()
    var representatives: Array[Drink] = []
    var left_edge: Dictionary = edges[1]
    var right_edge: Dictionary = edges[7]
    for level in [1, 6, 12]:
        var left_point: Vector2 = (left_edge["a"] + left_edge["b"]) * 0.5
        var right_point: Vector2 = (right_edge["a"] + right_edge["b"]) * 0.5
        var left_drink := manager.spawn_drink(level, left_point, false)
        var right_drink := manager.spawn_drink(level, right_point, false)
        if is_instance_valid(left_drink):
            representatives.append(left_drink)
        if is_instance_valid(right_drink):
            representatives.append(right_drink)

    var overlay := Node2D.new()
    overlay.set_script(load("res://tests/r10_v09_hull_overlay.gd"))
    manager.add_child(overlay)
    overlay.manager = manager
    overlay.representative_drinks = representatives
    await process_frame
    await process_frame
    await process_frame

    var image := root.get_viewport().get_texture().get_image()
    if image == null:
        print("R10_V09_GUI_CAPTURE_RESULT=FAIL reason=no_runtime_image")
        quit(1)
        return
    var error := image.save_png(OUTPUT_PATH)
    print("R10_V09_GUI_CAPTURE label=hull_rails_normals_circle_comparison dimensions=%dx%d error=%s path=%s" % [image.get_width(), image.get_height(), error, OUTPUT_PATH])
    if error == OK:
        print("R10_V09_GUI_CAPTURE_RESULT=PASS")
        quit(0)
    else:
        print("R10_V09_GUI_CAPTURE_RESULT=FAIL reason=save error=%s" % error)
        quit(1)
