extends Node2D

var manager: GameManager
var representative_drinks: Array[Drink] = []


func _ready() -> void:
    z_index = 1000
    queue_redraw()


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    if not is_instance_valid(manager):
        return

    for edge in manager.get_playable_boundary_edges():
        var a: Vector2 = edge["a"]
        var b: Vector2 = edge["b"]
        var normal: Vector2 = edge["inward_normal"]
        draw_line(a, b, Color(0.2, 1.0, 0.45, 0.9), 3.0, true)
        var midpoint := (a + b) * 0.5
        draw_line(midpoint, midpoint + normal * 42.0, Color(0.2, 0.75, 1.0, 0.9), 3.0, true)
        draw_circle(midpoint + normal * 42.0, 4.0, Color(0.2, 0.75, 1.0, 0.95))

    for drink in representative_drinks:
        if not is_instance_valid(drink):
            continue
        var center := drink.global_position
        draw_circle(center, drink.radius, Color(1.0, 0.2, 0.2, 0.35), false, 3.0, true)
        var hull := drink.get_boundary_contact_hull_local()
        if hull.size() >= 2:
            for index in range(hull.size()):
                var a: Vector2 = drink.global_transform * hull[index]
                var b: Vector2 = drink.global_transform * hull[(index + 1) % hull.size()]
                draw_line(a, b, Color(1.0, 0.85, 0.1, 0.95), 3.0, true)
        draw_circle(center, 5.0, Color(1.0, 0.85, 0.1, 0.95))
