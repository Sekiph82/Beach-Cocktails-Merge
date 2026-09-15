class_name Drink
extends RigidBody2D
## Godot 4.7.2 - Jolt fizik motoru (4.6'dan beri varsayilan)
## Not: Jolt'ta physics_material_override PhysicsServer2D'ye map edilir;
## bounce/friction davranisi Godot Physics'e gore biraz daha canlidir.

signal merged(a: Drink, b: Drink, new_level: int)

var level: int = 1
var radius: float = 14.0
var base_score: int = 10
var already_merged: bool = false   # merge kuyrugu cakismasi korumasi

static var drinks_data: Array = []

static func load_data() -> void:
    if drinks_data.is_empty():
        var file := FileAccess.open("res://data/drinks.json", FileAccess.READ)
        var parsed: Variant = JSON.parse_string(file.get_as_text())
        if parsed == null or not parsed.has("levels"):
            push_error("drinks.json okunamadi!")
            return
        drinks_data = parsed["levels"]

static func create(p_level: int) -> Drink:
    load_data()
    var d := Drink.new()
    var info: Dictionary = drinks_data[p_level - 1]
    d.level = p_level
    d.radius = info["radius"]
    d.base_score = info["score"]

    # Collider (scene gerekmez, kodla uretilir)
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = d.radius
    shape.shape = circle
    d.add_child(shape)

    # Gorsel placeholder - sprite sheet ekleyince bu blok Sprite2D olacak
    var vis := Polygon2D.new()
    var points := PackedVector2Array()
    for i in 32:
        var a := TAU * i / 32.0
        points.append(Vector2(cos(a), sin(a)) * d.radius)
    vis.polygon = points
    vis.color = Color.from_hsv(float(p_level) / 12.0 * 0.8, 0.75, 0.95)
    d.add_child(vis)

    # Fizik ayarlari (Jolt: bounce biraz daha canli, 0.35 yeterli)
    d.mass = info["mass"]
    d.gravity_scale = 2.0              # agir, tok his
    d.linear_damp = 0.15
    d.angular_damp = 0.6
    var mat := PhysicsMaterial.new()
    mat.friction = 0.3
    mat.bounce = 0.35
    d.physics_material_override = mat

    # Uyku optimizasyonu - masa dolunca CPU sifirlanir (50+ body rahat)
    d.can_sleep = true

    # Cakisma izleme -> merge kuyrugu
    d.contact_monitor = true
    d.max_contacts_reported = 8
    d.body_shape_entered.connect(d._on_body_shape_entered)
    return d

func _on_body_shape_entered(_body_rid: RID, body: Node, _shape_idx: int, _other_idx: int) -> void:
    if body is Drink and not already_merged and not body.already_merged:
        if body.level == level:
            already_merged = true
            body.already_merged = true
            merged.emit(self, body, level + 1)
