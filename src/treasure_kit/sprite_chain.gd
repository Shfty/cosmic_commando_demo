extends Node2D
tool

""" Instances a set of PackedScene nodes and positions them along the joins of a bone chain. """

enum TransformComponents {
	Position = 1,
	Rotation = 2,
	Scale = 4,
	All = 1 | 2 | 4
}

var packed_scene: PackedScene setget set_packed_scene
var start_bone_path: NodePath setget set_start_bone_path
var end_bone_path: NodePath setget set_end_bone_path
var transform_flags: int = TransformComponents.All setget set_transform_flags

var _scene_instances := []

func set_packed_scene(new_packed_scene: PackedScene) -> void:
	if packed_scene != new_packed_scene:
		packed_scene = new_packed_scene
		if is_inside_tree():
			update_chain()

func set_start_bone_path(new_start_bone_path: NodePath) -> void:
	if start_bone_path != new_start_bone_path:
		start_bone_path = new_start_bone_path
		if is_inside_tree():
			update_chain()
			position_instances()

func set_end_bone_path(new_end_bone_path: NodePath) -> void:
	if end_bone_path != new_end_bone_path:
		end_bone_path = new_end_bone_path
		if is_inside_tree():
			update_chain()
			position_instances()

func set_transform_flags(new_transform_flags: int) -> void:
	if transform_flags != new_transform_flags:
		transform_flags = new_transform_flags
		if is_inside_tree():
			position_instances()

func _enter_tree() -> void:
	update_chain()
	position_instances()

func update_chain() -> void:
	for child in get_children():
		if child.has_meta("bone_chain_2d_child"):
			remove_child(child)
			child.queue_free()

	_scene_instances.clear()

	var start_bone = get_node(start_bone_path)
	assert(start_bone)

	var end_bone = get_node(end_bone_path)
	assert(end_bone)

	var relative_path = start_bone.get_path_to(end_bone)

	var candidate = start_bone
	_scene_instances.append(spawn_instance())

	for i in range(0, relative_path.get_name_count()):
		var name = relative_path.get_name(i)
		candidate = candidate.get_node(name)
		_scene_instances.append(spawn_instance())

func spawn_instance() -> Node:
	var instance = packed_scene.instance()
	instance.set_meta("bone_chain_2d_child", true)
	add_child(instance)
	return instance

func _process(_delta: float) -> void:
	position_instances()

func position_instances() -> void:
	var start_bone = get_node(start_bone_path)
	assert(start_bone)

	var end_bone = get_node(end_bone_path)
	assert(end_bone)

	var relative_path = start_bone.get_path_to(end_bone)

	var candidate = start_bone
	for i in range(0, _scene_instances.size()):
		if TransformComponents.Position & transform_flags:
			_scene_instances[i].global_position = candidate.global_position

		if TransformComponents.Rotation & transform_flags:
			_scene_instances[i].global_rotation = candidate.global_rotation
		else:
			_scene_instances[i].global_rotation = 0.0

		if TransformComponents.Scale & transform_flags:
			_scene_instances[i].scale = candidate.scale
		else:
			_scene_instances[i].scale = Vector2.ONE

		if i < relative_path.get_name_count():
			var name = relative_path.get_name(i)
			if candidate.has_node(name):
				candidate = candidate.get_node(name)
			else:
				break

func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "packed_scene",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "PackedScene"
	})

	property_list.append({
		"name": "start_bone_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "end_bone_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "transform_flags",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": "Position,Rotation,Scale"
	})

	return property_list
