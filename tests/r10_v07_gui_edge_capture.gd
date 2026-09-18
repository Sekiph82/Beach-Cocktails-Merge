extends SceneTree

## Normal-display runtime capture for owner-verifiable V07 side contacts.
## This script is run without --headless; it uses the production main scene and
## only places representative drinks at the measured side-contact limits.

const OUTPUT_PATH := "res://docs/evidence/r10/v07_gui_edge_contacts_720x1280.png"
const SAMPLE_Y := 620.0


func _init() -> void:
    call_deferred("_capture")


func _capture() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        print("R10_V07_GUI_CAPTURE_RESULT=FAIL reason=main_scene")
        quit(1)
        return
    var manager := packed.instantiate() as GameManager
    root.add_child(manager)
    await process_frame
    await process_frame
    await process_frame

    for level in [1, 6, 12]:
        var bounds := manager.get_horizontal_edge_contact_bounds_at_y(SAMPLE_Y, level)
        manager.spawn_drink(level, Vector2(bounds.x, SAMPLE_Y), false)
        manager.spawn_drink(level, Vector2(bounds.y, SAMPLE_Y), false)
    await process_frame
    await process_frame
    await process_frame

    var image := root.get_viewport().get_texture().get_image()
    if image == null:
        print("R10_V07_GUI_CAPTURE_RESULT=FAIL reason=no_runtime_image")
        quit(1)
        return
    var error := image.save_png(OUTPUT_PATH)
    print("R10_V07_GUI_CAPTURE label=edge_contacts dimensions=%dx%d error=%s path=%s" % [image.get_width(), image.get_height(), error, OUTPUT_PATH])
    if error == OK:
        print("R10_V07_GUI_CAPTURE_RESULT=PASS")
        quit(0)
    else:
        print("R10_V07_GUI_CAPTURE_RESULT=FAIL reason=save error=%s" % error)
        quit(1)
