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
    "res://assets/effects/merge_glow.png",
    "res://assets/effects/sparkle.png",
    "res://assets/effects/splash.png",
    "res://assets/effects/to_go_trail.png",
]

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    var cocktail_count := _png_count("res://assets/cocktails")
    var environment_count := _png_count("res://assets/environment")
    var ui_count := _png_count("res://assets/ui")
    var effects_count := _png_count("res://assets/effects")
    var observed_required := cocktail_count + environment_count + ui_count + effects_count
    print("M04_GODOT_ASSET_COUNT expected=25 observed=%d cocktails=%d environment=%d ui=%d effects=%d" % [observed_required, cocktail_count, environment_count, ui_count, effects_count])
    _check("repository PNG directory counts match canonical scopes", cocktail_count == 12 and environment_count == 1 and ui_count == 8 and effects_count == 4)
    _check("effects PNG directory exact set has four approved assets", _png_names("res://assets/effects") == ["merge_glow.png", "sparkle.png", "splash.png", "to_go_trail.png"])
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


func _png_count(path: String) -> int:
    var directory := DirAccess.open(path)
    if directory == null:
        return 0
    var count := 0
    directory.list_dir_begin()
    while true:
        var entry := directory.get_next()
        if entry.is_empty():
            break
        if not directory.current_is_dir() and entry.to_lower().ends_with(".png"):
            count += 1
    directory.list_dir_end()
    return count


func _png_names(path: String) -> Array[String]:
    var directory := DirAccess.open(path)
    var names: Array[String] = []
    if directory == null:
        return names
    directory.list_dir_begin()
    while true:
        var entry := directory.get_next()
        if entry.is_empty():
            break
        if not directory.current_is_dir() and entry.to_lower().ends_with(".png"):
            names.append(entry)
    directory.list_dir_end()
    names.sort()
    return names


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M04_GODOT_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M04_GODOT_PROBE FAIL: %s" % label)
