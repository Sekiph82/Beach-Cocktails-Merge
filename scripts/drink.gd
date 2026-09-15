class_name Drink
extends RigidBody2D

## One piece in the 12-level merge chain.
## Gameplay model:
## held -> glides forward -> collisions redistribute momentum -> slows -> sleeps.
## Important rule: gameplay pieces never rebound toward the player (+Y).

signal merged(a: Drink, b: Drink, new_level: int)
signal resolved(drink: Drink)

enum MotionState {
    HELD,
    SLIDING,
    SETTLED,
    MERGING,
    TARGET_CAPTURE,
}

var level: int = 1
var radius: float = 14.0
var base_score: int = 0
var motion_state: MotionState = MotionState.SETTLED
var already_merged: bool = false

var slide_deceleration: float = 180.0
var settle_speed: float = 30.0
var settle_delay: float = 0.28

var _low_speed_time := 0.0
var _settle_queued := false
var _pre_collision_velocity := Vector2.ZERO
var _last_meaningful_velocity := Vector2.ZERO
var _visual_root: Node2D
var _shadow: Polygon2D

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


static func merge_score(p_level: int) -> int:
    if not load_data() or p_level < 1 or p_level > drinks_data.size():
        return 0
    return int(drinks_data[p_level - 1].get("score", 0))


static func order_reward(p_level: int) -> int:
    if not load_data() or p_level < 1 or p_level > drinks_data.size():
        return 0
    return int(drinks_data[p_level - 1].get("order_reward", 0))


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

    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = d.radius
    shape.shape = circle
    d.add_child(shape)

    # Temporary 2.5D placeholder presentation. v7 replaces this with real art.
    d._shadow = Polygon2D.new()
    d._shadow.polygon = _circle_points(d.radius * 1.03)
    d._shadow.color = Color(0.0, 0.0, 0.0, 0.25)
    d._shadow.position = Vector2(6.0, d.radius * 0.38 + 5.0)
    d._shadow.scale = Vector2(1.0, 0.38)
    d.add_child(d._shadow)

    d._visual_root = Node2D.new()
    d._visual_root.name = "Visual"
    d.add_child(d._visual_root)

    var rim := Polygon2D.new()
    rim.polygon = _circle_points(d.radius + 3.0)
    rim.color = Color(0.055, 0.06, 0.075, 1.0)
    d._visual_root.add_child(rim)

    var body_visual := Polygon2D.new()
    body_visual.polygon = _circle_points(d.radius)
    body_visual.color = Color.from_hsv(float(p_level - 1) / maxf(float(drinks_data.size()), 1.0) * 0.82, 0.72, 0.95)
    d._visual_root.add_child(body_visual)

    var shine := Polygon2D.new()
    shine.polygon = _circle_points(maxf(d.radius * 0.22, 3.0), 16)
    shine.position = Vector2(-d.radius * 0.28, -d.radius * 0.30)
    shine.color = Color(1.0, 1.0, 1.0, 0.40)
    d._visual_root.add_child(shine)

    var level_label := Label.new()
    level_label.text = str(p_level)
    level_label.position = Vector2(-d.radius, -12.0)
    level_label.size = Vector2(d.radius * 2.0, 24.0)
    level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    level_label.add_theme_font_size_override("font_size", int(clampf(d.radius * 0.58, 12.0, 28.0)))
    level_label.add_theme_color_override("font_color", Color.WHITE)
    level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.72))
    level_label.add_theme_constant_override("shadow_offset_x", 1)
    level_label.add_theme_constant_override("shadow_offset_y", 1)
    d._visual_root.add_child(level_label)

    # The JSON progression mass doubles every level and is useful as design data,
    # but using it literally in the 2D solver makes high-level drinks behave like
    # concrete blocks (L5=16x L1, L12=2048x L1). Keep higher levels heavier while
    # compressing the physical range so impacts continue to propagate through the table.
    d.mass = 1.0 + float(p_level - 1) * 0.30
    d.gravity_scale = 0.0
    d.linear_damp = 0.0
    d.angular_damp = 3.0
    d.lock_rotation = true
    d.can_sleep = true
    d.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
    d.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC

    # Zero restitution: collisions transfer/redirect momentum, but do not
    # produce pinball-style backward rebounds.
    var mat := PhysicsMaterial.new()
    mat.friction = 0.08
    mat.bounce = 0.0
    d.physics_material_override = mat

    d.contact_monitor = true
    d.max_contacts_reported = 12
    d.body_entered.connect(d._on_body_entered)

    d.set_settled()
    return d


static func _circle_points(p_radius: float, segments: int = 32) -> PackedVector2Array:
    var points := PackedVector2Array()
    for i in range(segments):
        var angle := TAU * float(i) / float(segments)
        points.append(Vector2(cos(angle), sin(angle)) * p_radius)
    return points


func _process(_delta: float) -> void:
    z_index = clampi(int(position.y), 0, 4096)

    if _visual_root != null:
        var depth := clampf(position.y / 1280.0, 0.0, 1.0)
        # Keep a very mild depth scale only. The old strong Y squash made the
        # circular collider larger than the visible drink vertically, creating
        # an ugly apparent gap between pieces that were actually touching.
        var scale_xy := lerpf(0.96, 1.0, depth)
        _visual_root.scale = Vector2(scale_xy, scale_xy)
    if _shadow != null:
        var shadow_depth := clampf(position.y / 1280.0, 0.0, 1.0)
        _shadow.modulate.a = lerpf(0.60, 1.0, shadow_depth)


func set_held() -> void:
    motion_state = MotionState.HELD
    already_merged = false
    _low_speed_time = 0.0
    _settle_queued = false
    _pre_collision_velocity = Vector2.ZERO
    _last_meaningful_velocity = Vector2.ZERO
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    freeze = true
    collision_layer = 0
    collision_mask = 0


func launch_up(speed: float) -> void:
    start_sliding(Vector2(0.0, -absf(speed)))


func start_sliding(velocity: Vector2) -> void:
    velocity = _forward_only(velocity)
    if velocity.length() <= settle_speed:
        set_settled()
        return

    motion_state = MotionState.SLIDING
    already_merged = false
    _low_speed_time = 0.0
    _settle_queued = false
    _pre_collision_velocity = velocity
    _last_meaningful_velocity = velocity
    collision_layer = 1
    collision_mask = 1
    freeze = false
    sleeping = false
    linear_velocity = velocity
    angular_velocity = 0.0


func set_settled() -> void:
    var was_sliding := motion_state == MotionState.SLIDING
    motion_state = MotionState.SETTLED
    already_merged = false
    _low_speed_time = 0.0
    _settle_queued = false
    _pre_collision_velocity = Vector2.ZERO
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    freeze = false
    collision_layer = 1
    collision_mask = 1
    sleeping = true

    if was_sliding:
        resolved.emit(self)
        if GameManager.instance != null:
            GameManager.instance.call_deferred("try_chain_merge", self)


func begin_merge() -> void:
    if motion_state == MotionState.MERGING or motion_state == MotionState.TARGET_CAPTURE:
        return

    var was_sliding := motion_state == MotionState.SLIDING
    motion_state = MotionState.MERGING
    already_merged = true
    _low_speed_time = 0.0
    _settle_queued = false
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    freeze = true
    collision_layer = 0
    collision_mask = 0

    if was_sliding:
        resolved.emit(self)


func begin_target_capture() -> void:
    var was_sliding := motion_state == MotionState.SLIDING
    motion_state = MotionState.TARGET_CAPTURE
    already_merged = true
    _low_speed_time = 0.0
    _settle_queued = false
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    freeze = true
    collision_layer = 0
    collision_mask = 0
    sleeping = false

    if was_sliding:
        resolved.emit(self)


func is_settled() -> bool:
    return motion_state == MotionState.SETTLED


func is_sliding() -> bool:
    return motion_state == MotionState.SLIDING


func get_merge_velocity() -> Vector2:
    if motion_state == MotionState.SLIDING:
        if _last_meaningful_velocity.length() > 0.0:
            return _last_meaningful_velocity
        if _pre_collision_velocity.length() > 0.0:
            return _pre_collision_velocity
        return linear_velocity
    return Vector2.ZERO


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    # A sleeping settled glass stays physically dynamic. A later impact wakes it
    # and it becomes SLIDING again so momentum can propagate through the cluster.
    if motion_state == MotionState.SETTLED:
        if state.linear_velocity.length() > 8.0:
            motion_state = MotionState.SLIDING
            _low_speed_time = 0.0
            _settle_queued = false
            sleeping = false
        else:
            return

    if motion_state != MotionState.SLIDING:
        return

    var velocity := _forward_only(state.linear_velocity)
    var speed := velocity.length()

    if speed > 0.0:
        var new_speed := maxf(speed - slide_deceleration * state.step, 0.0)
        if new_speed > 0.0:
            velocity = velocity.normalized() * new_speed
        else:
            velocity = Vector2.ZERO

    velocity = _forward_only(velocity)
    state.linear_velocity = velocity
    _pre_collision_velocity = velocity

    if velocity.length() > settle_speed:
        _last_meaningful_velocity = velocity

    if velocity.length() <= settle_speed:
        _low_speed_time += state.step
    else:
        _low_speed_time = 0.0

    if _low_speed_time >= settle_delay and not _settle_queued:
        _settle_queued = true
        call_deferred("_settle_after_physics")


func _settle_after_physics() -> void:
    _settle_queued = false
    if motion_state != MotionState.SLIDING:
        return

    _enforce_forward_only()
    if linear_velocity.length() <= settle_speed * 1.35:
        set_settled()
    else:
        _low_speed_time = 0.0


func _on_body_entered(body: Node) -> void:
    if motion_state != MotionState.SLIDING or already_merged:
        return

    # The solver is allowed to redirect sideways and forward, but any +Y
    # component created by a collision is removed immediately after solving.
    call_deferred("_enforce_forward_only")

    if body.name == "TopRail":
        call_deferred("_stop_at_top_if_needed")
        return

    if body is Drink:
        var other := body as Drink
        if other.motion_state == MotionState.HELD or other.motion_state == MotionState.MERGING or other.motion_state == MotionState.TARGET_CAPTURE:
            return

        other.call_deferred("_enforce_forward_only")

        if other.level == level and level < Drink.max_level():
            merged.emit(self, other, level + 1)


func _forward_only(velocity: Vector2) -> Vector2:
    # Godot +Y points toward the player/bottom of the screen. Gameplay never
    # allows a collision to send a glass backward. Downward energy is absorbed;
    # lateral and forward (-Y) motion remain intact.
    if velocity.y > 0.0:
        velocity.y = 0.0
    return velocity


func _enforce_forward_only() -> void:
    if motion_state != MotionState.SLIDING:
        return
    linear_velocity = _forward_only(linear_velocity)


func _stop_at_top_if_needed() -> void:
    if motion_state != MotionState.SLIDING:
        return

    # Top rail is the end of the table, not a rebound surface.
    linear_velocity.y = 0.0
    if absf(linear_velocity.x) <= settle_speed * 1.35:
        set_settled()
