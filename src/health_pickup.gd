class_name HealthPickup
extends Area2D
tool

enum Type {
	Small,
	Large
}

const HEALTH_VALUES := {
	Type.Small: 30,
	Type.Large: 100
}

const SPRITE_SIZES := {
	Type.Small: 5.5,
	Type.Large: 7.5
}

export(Type) var type: int = Type.Small setget set_type

func set_type(new_type: int) -> void:
	if type != new_type:
		type = new_type

		if has_node("CollisionShape2D"):
			var _collision_shape := $CollisionShape2D as CollisionShape2D
			var size = SPRITE_SIZES[type]
			_collision_shape.shape.extents = Vector2(size, size)

		if has_node("PixelSnap/HealthPickupSprite"):
			var _sprite := $PixelSnap/HealthPickupSprite as HealthPickupSprite
			_sprite.size = SPRITE_SIZES[type]

func area_entered(area: Area2D) -> void:
	if area.has_method("take_healing"):
		area.take_healing(HEALTH_VALUES[type])

	get_parent().call_deferred("remove_child", self)
	call_deferred("queue_free")
