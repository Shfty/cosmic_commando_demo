extends Node

var _pooled_scenes := {}

func instance_scene(scene: PackedScene) -> Node:
	if not scene in _pooled_scenes:
		_pooled_scenes[scene] = []
	var instance_pool = _pooled_scenes[scene]

	var instance = null
	if instance_pool.size() > 0:
		instance = instance_pool.pop_front()
	else:
		instance = scene.instance()

	if instance is Node2D:
		instance.transform = Transform2D.IDENTITY
	elif instance is Spatial:
		instance.transform = Transform.IDENTITY

	request_ready_recursive(instance)

	return instance

func request_ready_recursive(target: Node) -> void:
	target.request_ready()
	for child in target.get_children():
		request_ready_recursive(child)

func finalize_instance(instance: Node) -> void:
	for key in _pooled_scenes:
		if instance.get_filename() == key.get_path():
			_pooled_scenes[key].append(instance)
			return

	assert(false)
