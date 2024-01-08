extends Node2D

var _destroyed := false

func get_trip_ray_cast() -> RayCast2D:
	return $TripRayCast as RayCast2D if has_node("TripRayCast") else null

func _physics_process(_delta: float) -> void:
	var trip_ray_cast = get_trip_ray_cast()
	if trip_ray_cast.get_collider().collision_layer != DragonflyConstants.CollisionLayers.Environment:
		destroy()


func destroy() -> void:
	if not _destroyed:
		_destroyed = true
		var _effect = DragonflyUtil.spawn_effect(get_parent(), DragonflyEffects.Hitspark, global_transform, 0.0)
		get_parent().call_deferred("remove_child", self)
		call_deferred("queue_free")


func hitbox_give_damage(_amount: int, _normal: Vector2, _force: float) -> void:
	destroy()
