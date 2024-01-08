class_name ProjectileBuster
extends Projectile

export(PackedScene) var child_projectile

func fire() -> void:
	.fire()
	var _effect = DragonflyUtil.spawn_effect(_cached_parent, DragonflyEffects.Hitspark, global_transform, 0.0)


func destroy(spawn_hitspark: bool = true) -> void:
	if _destroyed:
		return

	assert(is_inside_tree())
	var _effect = DragonflyUtil.spawn_projectile(_cached_source, _cached_parent.get_parent(), child_projectile, global_transform, orientation)
	.destroy(spawn_hitspark)
