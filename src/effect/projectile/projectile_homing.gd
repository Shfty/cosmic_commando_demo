class_name ProjectileHoming
extends Projectile

export(float) var jitter_range = 10.0
export(float) var homing_range = 10.0

func _physics_process(delta: float) -> void:
	if not _cached_source:
		return

	orientation += (randf() * 2.0 - 1.0) * jitter_range * PI * delta

	if not "_closest_enemy" in _cached_source:
		return

	var closest_enemy = _cached_source._closest_enemy
	if closest_enemy:
		var to_enemy = (closest_enemy.global_transform.origin - global_transform.origin).normalized().rotated(-orientation)
		var delta_angle = atan2(to_enemy.y, to_enemy.x)
		orientation += delta_angle * homing_range * delta
