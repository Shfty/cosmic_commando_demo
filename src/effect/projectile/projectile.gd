class_name Projectile
extends Effect

export(float) var speed := 800.0
export(int) var damage := 10
export(PackedScene) var hitspark

var _cached_parent: Node
var _cached_source: Node

var _speed := 0.0

onready var _collision_shape := $CollisionShape2D as CollisionShape2D
onready var _shape := _collision_shape.get_shape()

func set_parent(parent: Node) -> void:
	_cached_parent = parent

func set_source(source: Node) -> void:
	_cached_source = source

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return

	_collision_shape.rotation = orientation + PI * 0.5

	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(_shape)
	query.transform = _collision_shape.global_transform
	query.motion = Vector2.RIGHT.rotated(orientation) * _speed * delta
	query.collision_layer = collision_mask
	query.collide_with_areas = false
	var result = get_world_2d().direct_space_state.cast_motion(query)

	if result.empty():
		collision()
	if not result.empty():
		global_transform.origin += query.motion * result[0]
		if result[0] < 1 or result[1] < 1:
			collision()

func fire() -> void:
	_speed = speed

func area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage, Vector2.RIGHT.rotated(orientation), 0.0)
	_speed = 0.0
	call_deferred("collision")

func collision() -> void:
	transform.origin += Vector2.RIGHT.rotated(orientation) * (_shape.radius + _shape.height * 0.5)
	destroy()

func destroy(spawn_hitspark: bool = true) -> void:
	if _destroyed:
		return

	var parent = get_parent()
	if parent and spawn_hitspark and hitspark:
		var _effect = DragonflyUtil.spawn_effect(get_parent(), hitspark, global_transform, orientation)

	.destroy()

func parried(_damage: int, _normal: Vector2, _force: float) -> void:
	destroy()
