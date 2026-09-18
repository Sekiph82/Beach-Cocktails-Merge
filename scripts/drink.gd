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
var _cocktail_sprite: Sprite2D
var _held_body_anchor_active := false

static var drinks_data: Array = []
static var _texture_cache: Dictionary = {}

const COCKTAIL_TEXTURE_PATHS := [
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
]

# These are retained MANUAL_VISUAL_MEASUREMENT_GLASS_BODY measurements from
# the M05 evidence pass. Each width is the selected glass/container body bbox;
# straw, fruit, leaves, flowers, and other garnish extremes are excluded.
const VISIBLE_BODY_WIDTH_PX := [690.0, 725.0, 627.0, 759.0, 545.0, 700.0, 575.0, 615.0, 650.0, 625.0, 610.0, 710.0]

# R10-V09 source-space convex hulls of the visible glass/container body.
# Points are relative to each canonical texture center, measured from alpha
# pixels inside the independent M05 body boxes. Garnish/straw extremes and
# transparent margins are excluded; these hulls are not collider geometry.
static var BOUNDARY_CONTACT_HULL_SOURCE_PX := [
	PackedVector2Array([Vector2(-342.0, -199.0), Vector2(279.0, 322.0), Vector2(270.0, 372.0), Vector2(256.0, 405.0), Vector2(244.0, 422.0), Vector2(209.0, 450.0), Vector2(184.0, 461.0), Vector2(-216.0, 451.0), Vector2(-235.0, 439.0), Vector2(-261.0, 411.0), Vector2(-280.0, 365.0), Vector2(-288.0, 311.0)]),
	PackedVector2Array([Vector2(-324.0, -170.0), Vector2(-316.0, -188.0), Vector2(304.0, -207.0), Vector2(326.0, -177.0), Vector2(273.0, 355.0), Vector2(268.0, 388.0), Vector2(255.0, 423.0), Vector2(232.0, 449.0), Vector2(194.0, 472.0), Vector2(-218.0, 459.0), Vector2(-249.0, 431.0), Vector2(-267.0, 390.0)]),
	PackedVector2Array([Vector2(-306.0, -267.0), Vector2(318.0, -90.0), Vector2(216.0, 493.0), Vector2(213.0, 502.0), Vector2(-252.0, 503.0), Vector2(-256.0, 490.0), Vector2(-258.0, 474.0)]),
	PackedVector2Array([Vector2(-381.0, -257.0), Vector2(-354.0, -290.0), Vector2(-347.0, -297.0), Vector2(378.0, -297.0), Vector2(378.0, -35.0), Vector2(218.0, 493.0), Vector2(-253.0, 493.0), Vector2(-381.0, -169.0)]),
	PackedVector2Array([Vector2(-272.0, -207.0), Vector2(273.0, -18.0), Vector2(172.0, 507.0), Vector2(166.0, 518.0), Vector2(-184.0, 511.0), Vector2(-186.0, 504.0), Vector2(-272.0, -186.0)]),
	PackedVector2Array([Vector2(-347.0, -227.0), Vector2(353.0, -227.0), Vector2(353.0, -204.0), Vector2(234.0, 483.0), Vector2(-201.0, 483.0), Vector2(-347.0, -225.0)]),
	PackedVector2Array([Vector2(-287.0, -277.0), Vector2(181.0, 473.0), Vector2(173.0, 494.0), Vector2(158.0, 507.0), Vector2(138.0, 517.0), Vector2(-111.0, 523.0), Vector2(-149.0, 505.0), Vector2(-160.0, 496.0), Vector2(-169.0, 479.0)]),
	PackedVector2Array([Vector2(-250.0, 86.0), Vector2(209.0, -222.0), Vector2(256.0, 52.0), Vector2(259.0, 85.0), Vector2(258.0, 112.0), Vector2(208.0, 493.0), Vector2(-249.0, 122.0)]),
	PackedVector2Array([Vector2(-322.0, -207.0), Vector2(318.0, -176.0), Vector2(317.0, 374.0), Vector2(185.0, 464.0), Vector2(102.0, 490.0), Vector2(69.0, 497.0), Vector2(-53.0, 497.0), Vector2(-73.0, 493.0), Vector2(-116.0, 481.0), Vector2(-219.0, 432.0)]),
	PackedVector2Array([Vector2(-302.0, -17.0), Vector2(-282.0, -236.0), Vector2(323.0, -237.0), Vector2(198.0, 493.0), Vector2(195.0, 501.0), Vector2(189.0, 511.0), Vector2(-227.0, 518.0), Vector2(-234.0, 510.0), Vector2(-240.0, 499.0), Vector2(-242.0, 491.0)]),
	PackedVector2Array([Vector2(-251.0, -242.0), Vector2(190.0, 465.0), Vector2(183.0, 481.0), Vector2(166.0, 498.0), Vector2(141.0, 512.0), Vector2(-158.0, 513.0), Vector2(-187.0, 497.0), Vector2(-203.0, 481.0), Vector2(-208.0, 471.0), Vector2(-211.0, 448.0)]),
	PackedVector2Array([Vector2(-357.0, -227.0), Vector2(332.0, -206.0), Vector2(353.0, 315.0), Vector2(320.0, 406.0), Vector2(239.0, 477.0), Vector2(188.0, 504.0), Vector2(173.0, 511.0), Vector2(-111.0, 513.0), Vector2(-122.0, 509.0), Vector2(-266.0, 403.0), Vector2(-332.0, 163.0)]),
]
const VISIBLE_BODY_CENTER_OFFSET_PX := [
	Vector2(-25.0, 131.0),
	Vector2(-14.5, 133.0),
	Vector2(4.5, 118.0),
	Vector2(-1.5, 98.0),
	Vector2(0.5, 155.5),
	Vector2(3.0, 128.0),
	Vector2(0.5, 123.0),
	Vector2(5.5, 135.5),
	Vector2(3.0, 145.5),
	Vector2(10.5, 140.5),
	Vector2(8.0, 138.0),
	Vector2(-2.0, 143.0),
]

# M07-R04 visual-only body-foot measurements, in source-texture pixels from
# each texture center. Garnish extremes are excluded.
const HELD_BODY_FOOT_SOURCE_PX := [476.0, 495.5, 431.5, 477.5, 428.0, 478.0, 410.5, 443.0, 470.5, 453.0, 443.0, 498.0]
# The launch PNG's visible gold oval is vertically offset inside its square
# texture. Put the measured glass/container foot on that rendered oval center,
# rather than on the old node center, so every held level sits on the artwork.
const HELD_BODY_BASELINE_OFFSET_PX := 3.0

# Runtime body diameters are deliberately bounded and monotonic. The sprite
# scale is derived from the measured body width, not from the full garnish
# bounds, so the physical footprint follows the visible glass body.
const COLLIDER_RADII := [20.0, 23.0, 27.0, 31.0, 36.0, 42.0, 49.0, 56.0, 64.0, 72.0, 80.0, 90.0]

# R11 table-footprint model. The rails are lines drawn on the table PLANE, so
# only the part of a glass that actually stands on that plane may be
# constrained by them. Body, rim, straw and garnish are ABOVE the plane and are
# expected to overhang the drawn edge, exactly as a real glass at a table edge
# does. Constraining the full silhouette instead made the required clearance
# grow with glass height, which is what produced the level-scaled edge gap.


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


static func texture_path_for_level(p_level: int) -> String:
	if p_level < 1 or p_level > COCKTAIL_TEXTURE_PATHS.size():
		return ""
	return COCKTAIL_TEXTURE_PATHS[p_level - 1]


static func texture_for_level(p_level: int) -> Texture2D:
	var path := texture_path_for_level(p_level)
	if path.is_empty():
		return null
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	var texture := load(path) as Texture2D
	if texture == null:
		push_error("Cocktail texture bulunamadi: %s" % path)
		return null
	_texture_cache[path] = texture
	return texture


static func collider_radius_for_level(p_level: int) -> float:
	if p_level < 1 or p_level > COLLIDER_RADII.size():
		return 0.0
	return COLLIDER_RADII[p_level - 1]


static func visual_scale_for_level(p_level: int) -> float:
	if p_level < 1 or p_level > VISIBLE_BODY_WIDTH_PX.size():
		return 0.0
	return (collider_radius_for_level(p_level) * 2.0) / VISIBLE_BODY_WIDTH_PX[p_level - 1]


static func boundary_contact_hull_source_for_level(p_level: int) -> PackedVector2Array:
	if p_level < 1 or p_level > BOUNDARY_CONTACT_HULL_SOURCE_PX.size():
		return PackedVector2Array()
	return BOUNDARY_CONTACT_HULL_SOURCE_PX[p_level - 1]


static func visual_offset_for_level(p_level: int) -> Vector2:
	if p_level < 1 or p_level > VISIBLE_BODY_CENTER_OFFSET_PX.size():
		return Vector2.ZERO
	return -VISIBLE_BODY_CENTER_OFFSET_PX[p_level - 1] * visual_scale_for_level(p_level)


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
	d.radius = collider_radius_for_level(p_level)
	d.base_score = int(info.get("score", 0))

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = d.radius
	shape.shape = circle
	d.add_child(shape)

	# Keep a small procedural shadow under the physical body. The drink itself
	# is rendered by the canonical V7 Sprite2D below.
	d._shadow = Polygon2D.new()
	d._shadow.polygon = _circle_points(d.radius * 1.03)
	d._shadow.color = Color(0.0, 0.0, 0.0, 0.25)
	d._shadow.position = Vector2(6.0, d.radius * 0.38 + 5.0)
	d._shadow.scale = Vector2(1.0, 0.38)
	d.add_child(d._shadow)

	d._visual_root = Node2D.new()
	d._visual_root.name = "Visual"
	d.add_child(d._visual_root)

	d._cocktail_sprite = Sprite2D.new()
	d._cocktail_sprite.name = "CocktailSprite"
	d._cocktail_sprite.texture = texture_for_level(p_level)
	d._cocktail_sprite.position = visual_offset_for_level(p_level)
	d._cocktail_sprite.scale = Vector2.ONE * visual_scale_for_level(p_level)
	d._cocktail_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	d._visual_root.add_child(d._cocktail_sprite)

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


func get_table_footprint_local() -> PackedVector2Array:
	## Where this glass actually meets the table plane: the horizontal segment
	## along the BOTTOM of the measured body hull, spanning its full X extent.
	##
	## The segment has zero height on purpose. Any height would sit the glass
	## that much in front of a rail, and since the hull grows with level that
	## clearance would grow with level too -- the original defect. With zero
	## height the lowest visible pixel of the glass lands exactly on the rail
	## at every level, and asymmetric artwork is handled because x_min and
	## x_max are read from the hull rather than assumed symmetric.
	var hull := get_boundary_contact_hull_local()
	if hull.is_empty():
		return PackedVector2Array([Vector2(-radius, radius), Vector2(radius, radius)])

	var foot_y := -INF
	var x_min := INF
	var x_max := -INF
	for point in hull:
		foot_y = maxf(foot_y, point.y)
		x_min = minf(x_min, point.x)
		x_max = maxf(x_max, point.x)
	return PackedVector2Array([Vector2(x_min, foot_y), Vector2(x_max, foot_y)])


func get_boundary_contact_hull_local() -> PackedVector2Array:
	return _source_points_to_visual_local(boundary_contact_hull_source_for_level(level))


func _source_points_to_visual_local(source_points: PackedVector2Array) -> PackedVector2Array:
	var local_hull := PackedVector2Array()
	if source_points.is_empty():
		return local_hull

	# The rendered hierarchy is RigidBody2D -> Visual -> CocktailSprite.
	# Compose the actual child transforms instead of applying root scale only
	# to source points while leaving the Sprite2D origin unscaled.
	var visual_to_body := Transform2D.IDENTITY
	if _visual_root != null:
		visual_to_body = _visual_root.transform
	if _cocktail_sprite != null:
		visual_to_body = visual_to_body * _cocktail_sprite.transform
	for source_point in source_points:
		local_hull.append(visual_to_body * source_point)
	return local_hull


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
		if _held_body_anchor_active:
			_apply_held_body_anchor()
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
	_held_body_anchor_active = true
	_apply_held_body_anchor()


func _apply_held_body_anchor() -> void:
	if _cocktail_sprite == null or level < 1 or level > HELD_BODY_FOOT_SOURCE_PX.size():
		return
	var root_scale: float = _visual_root.scale.y if _visual_root != null else 1.0
	# The M05 visible-body measurement, not the full garnish silhouette, also
	# defines the held glass center. Keep that center on the launch halo.
	_cocktail_sprite.position.x = -VISIBLE_BODY_CENTER_OFFSET_PX[level - 1].x * visual_scale_for_level(level)
	var body_foot_source: float = float(HELD_BODY_FOOT_SOURCE_PX[level - 1])
	_cocktail_sprite.position.y = HELD_BODY_BASELINE_OFFSET_PX / root_scale - body_foot_source * visual_scale_for_level(level)


func launch_up(speed: float) -> void:
	start_sliding(Vector2(0.0, -absf(speed)))


func start_sliding(velocity: Vector2) -> void:
	_held_body_anchor_active = false
	if _cocktail_sprite != null:
		_cocktail_sprite.position = visual_offset_for_level(level)
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
	_held_body_anchor_active = false
	if _cocktail_sprite != null:
		_cocktail_sprite.position = visual_offset_for_level(level)
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
	# _integrate_forces is never called on a sleeping body, so a glass pushed
	# out of bounds during the same step it settles would stay there. Close
	# that window with one projection before the body goes to sleep.
	if GameManager.instance != null:
		var settle_projection := GameManager.instance.project_footprint_inside_table(
			Transform2D(rotation, position),
			get_table_footprint_local(),
			Vector2.ZERO
		)
		position = settle_projection["transform"].origin
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
	if motion_state == MotionState.MERGING \
	or motion_state == MotionState.TARGET_CAPTURE \
	or motion_state == MotionState.HELD:
		return

	# The table boundary is a geometric invariant, not a sliding-only behaviour.
	# Applying it in every remaining state and at EVERY speed is what removes the
	# old inconsistency: a nudge below the 8 px/s promotion threshold used to
	# escape the constraint completely, while a harder hit was snapped inward.
	if GameManager.instance != null:
		var projection := GameManager.instance.project_footprint_inside_table(
			state.transform,
			get_table_footprint_local(),
			state.linear_velocity
		)
		state.transform = projection["transform"]
		state.linear_velocity = _forward_only(projection["velocity"])

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
			# body_entered runs while Godot is flushing physics queries. Defer
			# the signal dispatch so MergeQueue can safely change body state
			# and schedule replacement outside that callback.
			call_deferred("_emit_merge_request", other, level + 1)


func _forward_only(velocity: Vector2) -> Vector2:
	# Godot +Y points toward the player/bottom of the screen. Gameplay never
	# allows a collision to send a glass backward. Downward energy is absorbed;
	# lateral and forward (-Y) motion remain intact.
	if velocity.y > 0.0:
		velocity.y = 0.0
	return velocity


func _emit_merge_request(other: Drink, new_level: int) -> void:
	if not is_instance_valid(other) or other.is_queued_for_deletion():
		return
	if motion_state != MotionState.SLIDING or already_merged:
		return
	if other.motion_state == MotionState.HELD or other.motion_state == MotionState.MERGING or other.motion_state == MotionState.TARGET_CAPTURE:
		return
	if other.level != level or level >= Drink.max_level():
		return
	merged.emit(self, other, new_level)


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
