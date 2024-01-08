class_name Actor
extends KinematicBody2D

enum Facing {
	Left = -1,
	Right = 1
}

var gravity := 1500
var snap_ground_distance := 20.0
var deceleration := 1800.0

var facing: int = 1 setget set_facing

var _velocity := Vector2.ZERO
var _max_velocity := Vector2(0, 0)
var _snap_vector := Vector2.ZERO

var _on_floor := true
var _floor_normal := Vector2.UP
var _on_ceiling := false
var _ceiling_normal := Vector2.ZERO

# Setters
func set_facing(new_facing: int) -> void:
	assert(new_facing != 0)
	if facing != new_facing:
		facing = new_facing
		facing_changed()

# Getters
func _get_up_vector() -> Vector2:
	return Vector2.UP

func _get_right_vector() -> Vector2:
	return Vector2.RIGHT

func _get_property_list() -> Array:
	return _get_property_list_internal()

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "facing",
			"type": TYPE_INT
		}
	]

func get_collision_shape() -> CollisionShape2D:
	return $CollisionShape2D as CollisionShape2D

# Update Functions
func facing_changed() -> void:
	pass

# Business Logic
func apply_gravity(delta: float) -> void:
	var gravity_force = -_get_up_vector() * gravity * delta
	_add_velocity(gravity_force)

func decelerate(delta: float) -> void:
	var ground_right = _get_right_vector()
	_add_velocity(ground_right * -sign(_velocity.dot(ground_right)) * min(deceleration * delta, abs(_velocity.dot(ground_right))))

func _add_velocity(force: Vector2) -> void:
	_velocity += force
	_clamp_velocity()

func _clamp_velocity() -> void:
	var local_up = _get_up_vector()
	var dot_up = _velocity.dot(local_up)
	var mag_up = abs(dot_up)
	var sign_up = sign(dot_up)

	var local_right = _get_right_vector()
	var dot_right = _velocity.dot(local_right)
	var mag_right = abs(dot_right)
	var sign_right = sign(dot_right)

	_velocity = local_right * min(mag_right, _max_velocity.x) * sign_right + local_up * min(mag_up, _max_velocity.y) * sign_up

func apply_ground_snap(_delta: float) -> void:
	_snap_vector = -_get_up_vector() * snap_ground_distance

func reset_ground_snap() -> void:
	_snap_vector = Vector2.ZERO


func integrate_movement(_delta: float) -> void:
	if _velocity.length() > 0:
		_velocity = move_and_slide(_velocity)

	if _snap_vector.length() > 0:
		if test_move(global_transform, _snap_vector):
			var _kinematic_collision = move_and_collide(_snap_vector)
		reset_ground_snap()

func check_on_floor() -> bool:
	return _on_floor and _floor_normal.dot(Vector2.UP) > 0.75

func check_on_ceiling() -> bool:
	return _on_ceiling and _ceiling_normal.dot(Vector2.DOWN) > 0.75

func update_grounded() -> void:
	var direct_space_state = get_world_2d().direct_space_state
	var collision_shape = get_collision_shape()

	var query = Physics2DShapeQueryParameters.new()
	var result
	query.set_shape(collision_shape.shape)

	query.transform = collision_shape.global_transform.translated(Vector2.DOWN)
	query.collision_layer = DragonflyConstants.CollisionLayers.Environment
	result = direct_space_state.get_rest_info(query)

	if result.empty():
		_on_floor = false
		_floor_normal = Vector2.ZERO
	else:
		_on_floor = true
		_floor_normal = result.normal

	query.transform = collision_shape.global_transform.translated(Vector2.UP)
	query.collision_layer = DragonflyConstants.CollisionLayers.Environment
	result = direct_space_state.get_rest_info(query)

	if result.empty():
		_on_ceiling = false
		_ceiling_normal = Vector2.ZERO
	else:
		_on_ceiling = true
		_ceiling_normal = result.normal
