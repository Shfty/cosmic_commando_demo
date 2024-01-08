class_name DragonflyUtil

static func spawn_effect(parent: Node, scene: PackedScene, transform: Transform2D, orientation: float) -> Node:
	var effect = PackedScenePool.instance_scene(scene)
	assert(effect)

	parent.add_child(effect, true)
	effect.global_transform = transform
	effect.orientation = orientation

	return effect

static func spawn_projectile(source: Node, parent: Node, scene: PackedScene, transform: Transform2D, orientation: float) -> Node:
	var projectile := spawn_effect(parent, scene, transform, orientation)

	projectile.set_parent(parent)
	projectile.set_source(source)
	projectile.fire()

	return projectile
