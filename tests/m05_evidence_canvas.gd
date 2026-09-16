extends Node2D

## Non-production evidence renderer. It receives actual Drink nodes from the
## M05 probe and only draws inspection annotations around their live geometry.

var drinks: Array[Drink] = []
var annotated := false
var title := ""


func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1600.0, 760.0)), Color("#14212b"))
    draw_string(ThemeDB.fallback_font, Vector2(28.0, 38.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 28, Color("#fff0bd"))
    for drink in drinks:
        if not is_instance_valid(drink) or drink.is_queued_for_deletion():
            continue
        var sprite := drink.get_node_or_null("Visual/CocktailSprite") as Sprite2D
        if sprite == null:
            continue
        var world_position := drink.position
        var body_color := Color("#ffdc58") if annotated else Color("#fff0bd")
        if annotated:
            draw_arc(world_position, drink.radius, 0.0, TAU, 64, Color("#ff6565"), 4.0, true)
            draw_line(world_position - Vector2(14.0, 0.0), world_position + Vector2(14.0, 0.0), Color("#70e8ff"), 2.0)
            draw_line(world_position - Vector2(0.0, 14.0), world_position + Vector2(0.0, 14.0), Color("#70e8ff"), 2.0)
        draw_string(ThemeDB.fallback_font, world_position + Vector2(-28.0, drink.radius + 32.0), "L%d" % drink.level, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, body_color)

