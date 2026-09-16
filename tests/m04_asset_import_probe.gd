extends SceneTree

## Deterministic, non-production Godot load probe for the canonical M04 PNG library.

const CANONICAL := [
    "res://assets/cocktails/L01.png",
    "res://assets/cocktails/L02.png",
    "res://assets/cocktails/L03.png",
    "res://assets/cocktails/L04.png",
    "res://assets/cocktails/L05.png",
    "res://assets/cocktails/L06.png",
    "res://assets/cocktails/L07.png",
    "res://assets/cocktails/L08.png",
    "res://assets/cocktails/L09.png",
    "res://assets/cocktails/L10.png",
    "res://assets/cocktails/L11.png",
    "res://assets/cocktails/L12.png",
    "res://assets/environment/game_board_background.png",
    "res://assets/ui/logo_beach_cocktails_merge.png",
    "res://assets/ui/panel_best_score.png",
    "res://assets/ui/panel_score.png",
    "res://assets/ui/panel_to_go_orders.png",
    "res://assets/ui/panel_next.png",
    "res://assets/ui/progression_strip.png",
    "res://assets/ui/launch_zone.png",
    "res://assets/ui/danger_line.png",
    "res://assets/effects/to_go_trail.png",
]

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    print("M04_GODOT_ASSET_COUNT expected=%d observed=%d" % [CANONICAL.size(), CANONICAL.size()])
    for path in CANONICAL:
        var texture := load(path) as Texture2D
        if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
            failures.append(path)
            print("M04_GODOT_ASSET FAIL path=%s" % path)
            continue
        var image := texture.get_image()
        print("M04_GODOT_ASSET PASS path=%s dimensions=%dx%d image_loaded=%s" % [path, texture.get_width(), texture.get_height(), image != null])
    if failures.is_empty():
        print("M04_GODOT_RESULT=PASS")
        quit(0)
    else:
        print("M04_GODOT_RESULT=FAIL failures=%s" % [", ".join(failures)])
        quit(1)
