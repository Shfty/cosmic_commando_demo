class_name CameraController
extends Node2D

export(NodePath) var camera_path
onready var _camera: Node = get_node(camera_path) if has_node(camera_path) else null

var speed = 4.0
var trace_length = Vector2(200, 112)
var scroll_offset := Vector2(64, 0)

var _target_position := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	var parent = get_parent()
	assert(parent)
	if parent is AlienSoldier:
		transform.origin = Vector2(0, -parent._crouch_factor * parent.crouch_height * 0.5)
		scroll_offset = Vector2(64 * parent.facing, 0.0)
	update_camera()

func ready_deferred() -> void:
	var from = global_transform.origin
	var parent = get_parent()
	if parent is AlienSoldier:
		from = parent.get_node("EpsilonSpritePhysicsInterpolator/EpsilonSpritePixelSnap/EpsilonEagleSprite").global_transform.origin
	from += scroll_offset
	global_transform.origin = from
	_target_position = from

func _process(delta: float) -> void:
	assert(_camera)
	_camera.global_position = lerp(_camera.global_position, _target_position, 4.0 * delta)

func update_camera():
	assert(_camera)
	var direct_space_state = get_world_2d().direct_space_state
	assert(direct_space_state)

	var camera_rect = _camera.get_viewport_rect()
	camera_rect.position += global_transform.origin
	camera_rect.position -= camera_rect.size * 0.5

	var from = global_transform.origin
	var parent = get_parent()
	if parent is AlienSoldier:
		from = parent.get_node("EpsilonSpritePhysicsInterpolator/EpsilonSpritePixelSnap/EpsilonEagleSprite").global_transform.origin

	var positions := PoolVector2Array()

	var offset_r = 0.0
	var offset_l = 0.0
	var offset_t = 0.0
	var offset_b = 0.0

	for i in range(0, 4):
		var angle = PI * 0.5 * i
		var to_norm = Vector2.RIGHT.rotated(angle)
		var to = from + to_norm * trace_length.dot(to_norm.abs())
		to += to_norm * scroll_offset.dot(to_norm)
		var result = direct_space_state.intersect_ray(from, to, [], DragonflyConstants.CollisionLayers.CameraEnvironment)
		var result_pos = to if result.empty() else result.position
		positions.append(result_pos)
		var dist = (result_pos - from).dot(to_norm)
		var t = trace_length.dot(to_norm.abs())

		var offset = 0.0
		if not result.empty():
			offset = t - dist
			offset += scroll_offset.dot(to_norm)
		match i:
			0: offset_r = offset
			1: offset_b = offset
			2: offset_l = offset
			3: offset_t = offset

	if offset_t > 0 and offset_b > 0:
		offset_t = min(offset_t, offset_b)
		offset_b = offset_t

	if offset_l > 0 and offset_r > 0:
		offset_l = min(offset_r, offset_l)
		offset_r = offset_l

	var top_left = Vector2(positions[2].x, positions[3].y)
	var bottom_right = Vector2(positions[0].x, positions[1].y)
	var result_rect = Rect2(top_left, bottom_right - top_left)
	result_rect = result_rect.grow_individual(offset_r, offset_b, offset_l, offset_t)

	_target_position = (result_rect.position + result_rect.size * 0.5)
