class_name EnemyProjectile
extends Projectile

func parried(damage: int, normal: Vector2, force: float) -> void:
	var health_pickup = DragonflyItems.HealthPickup.instance()
	health_pickup.type = HealthPickup.Type.Small
	get_parent().add_child(health_pickup)
	health_pickup.global_transform.origin = global_transform.origin
	.parried(damage, normal, force)
