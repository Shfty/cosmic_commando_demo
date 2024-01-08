class_name ProjectileSpread
extends Projectile

export(float) var spread := 0.125
export(PackedScene) var fire_effect
export(PackedScene) var child_projectile
export(int) var spread_min := -2
export(int) var spread_max := 2

func fire() -> void:
	.fire()
	var _effect = DragonflyUtil.spawn_effect(_cached_parent, fire_effect, global_transform, 0.0)


func destroy(spawn_hitspark: bool = true) -> void:
	for i in range(spread_min, spread_max + 1):
		var _effect = DragonflyUtil.spawn_projectile(_cached_source, _cached_parent, child_projectile, global_transform, orientation + ((i * PI * spread) + PI * spread * 0.5))

	.destroy(spawn_hitspark)
