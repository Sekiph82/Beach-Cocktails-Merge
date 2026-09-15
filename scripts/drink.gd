class_name Drink
extends RigidBody2D

## One physics body in the 12-level merge chain.
## Physics is GodotPhysics2D; visuals are intentionally simple placeholders.

signal merged(a: Drink, b: Drink, new_level: int)

var level: int = 1
var radius: float = 14.0
var base_score: int = 10
var already_merged: bool = false

static var drinks_data: Array = []


static func load_data() -> bool:
    if not drinks_data.is_empty():
        return true

    var path := "res://data/drinks.json"
    if not FileAccess.file_exists(path):
        push_error("drinks.json bulunamadi: %s" % path)
        return false

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("drinks.json acilamadi: %s" % path)
        return false

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        push_error("drinks.json gecerli bir JSON object degil.")
        return false

    var root: Dictionary = parsed
    if not root.has("levels") or not (root["levels"] is Array):
        push_error("drinks.json icinde 'levels' dizisi yok.")
        return false

    drinks_data = root["levels"]
    if drinks_data.is_empty():
        push_error("drinks.json levels dizisi bos.")
        return false

    return true


static func max_level() -> int:
    if not load_data():
        return 0
    return drinks_data.size()


static func level_name(p_level: int) -> String:
    if not load_data() or p_level < 1 or p_level > drinks_data.size():
        return "?"
    return str(drinks_data[p_level - 1].get("name", "?"))


static func create(p_level: int) -> Drink:
    if not load_data():
        return null
    if p_level < 1 or p_level > drinks_data.size():
        push_error("Gecersiz drink level: %d" % p_level)
        return null

    var info: Dictionary = drinks_data[p_level - 1]
    var d := Drink.new()
    d.name = "Drink_L%02d" % p_level
    d.level = p_level
    d.radius = float(info.get("radius", 14.0))
    d.base_score = int(info.get("score", 0))

    # Collider.
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = d.radius
    shape.shape = circle
    d.add_child(shape)

    # Placeholder visual: dark rim + colored body + level number.
    var rim := Polygon2D.new()
    rim.polygon = _circle_points(d.radius + 3.0)
    rim.color = Color(0.06, 0.07, 0.09, 1.0)
    d.add_child(rim)

    var body_visual := Polygon2D.new()
    body_visual.polygon = _circle_points(d.radius)
    body_visual.color = Color.from_hsv(float(p_level - 1) / maxf(float(drinks_data.size()), 1.0) * 0.82, 0.72, 0.95)
    d.add_child(body_visual)

    var shine := Polygon2D.new()
    shine.polygon = _circle_points(maxf(d.radius * 0.22, 3.0), 16)
    shine.position = Vector2(-d.radius * 0.28, -d.radius * 0.28)
    shine.color = Color(1.0, 1.0, 1.0, 0.38)
    d.add_child(shine)

    var level_label := Label.new()
    level_label.text = str(p_level)
    level_label.position = Vector2(-d.radius, -12.0)
    level_label.size = Vector2(d.radius * 2.0, 24.0)
    level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    level_label.add_theme_font_size_override("font_size", int(clampf(d.radius * 0.58, 12.0, 28.0)))
    level_label.add_theme_color_override("font_color", Color.WHITE)
    level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
    level_label.add_theme_constant_override("shadow_offset_x", 1)
    level_label.add_theme_constant_override("shadow_offset_y", 1)
    d.add_child(level_label)

    # Physics.
    d.mass = float(info.get("mass", 1.0))
    d.gravity_scale = 2.0
    d.linear_damp = 0.15
    d.angular_damp = 0.6
    d.can_sleep = true
    d.continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
    d.collision_layer = 1
    d.collision_mask = 1

    var mat := PhysicsMaterial.new()
    mat.friction = 0.3
    mat.bounce = 0.35
    d.physics_material_override = mat

    # Collision notifications used by the merge system.
    d.contact_monitor = true
    d.max_contacts_reported = 8
    d.body_shape_entered.connect(d._on_body_shape_entered)

    return d


static func _circle_points(p_radius: float, segments: int = 32) -> PackedVector2Array:
    var points := PackedVector2Array()
    for i in range(segments):
        var angle := TAU * float(i) / float(segments)
        points.append(Vector2(cos(angle), sin(angle)) * p_radius)
    return points


func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_idx: int, _local_shape_idx: int) -> void:
    if already_merged or not (body is Drink):
        return

    var other := body as Drink
    if other.already_merged or other.level != level:
        return

    # Max-level drinks are stable end pieces. Two of them do not disappear.
    if level >= Drink.max_level():
        return

    already_merged = true
    other.already_merged = true
    merged.emit(self, other, level + 1)
