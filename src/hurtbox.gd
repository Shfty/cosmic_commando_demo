class_name Hurtbox
extends Area2D

signal take_damage(amount, normal, force)

export(bool) var active := true setget set_active

func get_collision_shape() -> CollisionShape2D:
	return $CollisionShape2D as CollisionShape2D

func set_active(new_active: bool) -> void:
	if active != new_active:
		active = new_active
		get_collision_shape().disabled = not active

func take_damage(amount: int, normal: Vector2, force: float) -> bool:
	emit_signal("take_damage", amount, normal, force)
	return true

func parried(damage: int, normal: Vector2, force: float) -> void:
	TimeManager.hitstop(0.1)
	var _damage_result = take_damage(damage, normal, force)
