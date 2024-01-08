class_name SpritePath
extends Node2D
tool

""" Instances a set of PackedScene nodes and positions them along a Path2D spline. """

enum AnchorMode {
	Start,
	End
}

enum SpritePathMode {
	Stretch,
	Anchor
}

enum TransformComponents {
	Position = 1,
	Rotation = 2,
	Scale = 4,
	All = 1 | 2 | 4
}

var packed_scene: PackedScene setget set_packed_scene
var target_path: NodePath setget set_target_path
var instance_count: int setget set_instance_count
var transform_flags: int = TransformComponents.All setget set_transform_flags
var sprite_path_mode: int = SpritePathMode.Stretch setget set_sprite_path_mode
var anchor_mode: int = AnchorMode.Start setget set_anchor_mode
var anchor_step: float = 8.0 setget set_anchor_step
var rotation_offset: float = 0.0 setget set_rotation_offset

var _scene_instances := []

func set_packed_scene(new_packed_scene: PackedScene) -> void:
	if packed_scene != new_packed_scene:
		packed_scene = new_packed_scene
		if is_inside_tree():
			update_chain()

func set_target_path(new_target_path: NodePath) -> void:
	if target_path != new_target_path:
		target_path = new_target_path
		if is_inside_tree():
			position_instances()

func set_instance_count(new_instance_count: int) -> void:
	if instance_count != new_instance_count:
		instance_count = new_instance_count
		if is_inside_tree():
			update_chain()

func set_transform_flags(new_transform_flags: int) -> void:
	if transform_flags != new_transform_flags:
		transform_flags = new_transform_flags
		if is_inside_tree():
			position_instances()

func set_sprite_path_mode(new_sprite_path_mode: int) -> void:
	if sprite_path_mode != new_sprite_path_mode:
		sprite_path_mode = new_sprite_path_mode
		if is_inside_tree():
			position_instances()
		property_list_changed_notify()

func set_anchor_mode(new_anchor_mode: int) -> void:
	if anchor_mode != new_anchor_mode:
		anchor_mode = new_anchor_mode
		if is_inside_tree():
			position_instances()

func set_anchor_step(new_anchor_step: float) -> void:
	if anchor_step != new_anchor_step:
		anchor_step = new_anchor_step
		if is_inside_tree():
			position_instances()

func set_rotation_offset(new_rotation_offset: float) -> void:
	if rotation_offset != new_rotation_offset:
		rotation_offset = new_rotation_offset
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

	for _i in range(0, instance_count):
		_scene_instances.append(spawn_instance())

func spawn_instance() -> Node:
	var instance = packed_scene.instance()
	instance.set_meta("bone_chain_2d_child", true)
	add_child(instance)
	return instance

func _process(_delta: float) -> void:
	position_instances()

func get_target_path() -> Path2D:
	return get_node(target_path) as Path2D if has_node(target_path) else null

func position_instances() -> void:
	var path = get_target_path()
	if not path:
		return

	var curve = path.curve
	if not curve:
		return

	var length = curve.get_baked_length()

	global_transform.origin = path.global_transform.origin

	var step
	match sprite_path_mode:
		SpritePathMode.Stretch:
			 step = length / (instance_count - 1)
		SpritePathMode.Anchor:
			step = anchor_step

	var dist = 0.0

	for i in range(0, instance_count):
		var sample_point
		match anchor_mode:
			AnchorMode.Start:
				sample_point = dist
			AnchorMode.End:
				sample_point = length - dist

		var position = curve.interpolate_baked(min(max(sample_point, 0.0), length))
		dist += step
		var instance
		instance = _scene_instances[i]

		instance.global_transform.origin = global_transform.origin + position
		instance.global_rotation = deg2rad(rotation_offset)


func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "packed_scene",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "PackedScene"
	})

	property_list.append({
		"name": "target_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "instance_count",
		"type": TYPE_INT
	})

	property_list.append({
		"name": "transform_flags",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": "Position,Rotation,Scale"
	})

	property_list.append({
		"name": "rotation_offset",
		"type": TYPE_REAL
	})

	property_list.append({
		"name": "sprite_path_mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(SpritePathMode.keys()).join(',')
	})

	if sprite_path_mode == SpritePathMode.Anchor:
		property_list.append({
			"name": "anchor_mode",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(AnchorMode.keys()).join(',')
		})

		property_list.append({
			"name": "anchor_step",
			"type": TYPE_REAL
		})

	return property_list

func _get_configuration_warning() -> String:
	if not has_node(target_path):
		return "No target path set."

	var path = get_target_path()
	if not path:
		return "Invalid target path."

	if not path.curve:
		return "Target path has no curve resource."

	return ""
