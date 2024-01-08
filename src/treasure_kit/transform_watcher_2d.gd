class_name TransformWatcher2D
extends Node2D
tool

""" Follows a target transform. Like an inverse RemoteTransform2D. """

enum TransformComponents {
	Position = 1,
	Rotation = 2,
	Scale = 4
}

var source_path: NodePath setget set_source_path
var target_paths: Array setget set_target_paths
var transform_flags: int = TransformComponents.Position | TransformComponents.Rotation | TransformComponents.Scale

func set_source_path(new_source_path: NodePath) -> void:
	if source_path != new_source_path:
		source_path = new_source_path
		update_configuration_warning()

func set_target_paths(new_target_paths: Array) -> void:
	if target_paths != new_target_paths:
		target_paths = new_target_paths
		update_configuration_warning()

func get_source() -> Node:
	return get_node(source_path) if has_node(source_path) else null

func get_targets() -> Array:
	var targets := []
	for target_path in target_paths:
		if has_node(target_path):
			targets.append(get_node(target_path))

	return targets

func _process(_delta: float) -> void:
	update_transform()

func update_transform() -> void:
	var source = get_source()
	if not source:
		return

	var targets = get_targets()
	if targets.empty():
		return

	for target in targets:
		if TransformComponents.Scale & transform_flags:
			target.scale = source.transform.get_scale()

		if TransformComponents.Rotation & transform_flags:
			target.global_rotation = source.global_transform.get_rotation()

		if TransformComponents.Position & transform_flags:
			target.global_transform.origin = source.global_transform.origin

func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "source_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "target_paths",
		"type": TYPE_ARRAY,
		"hint": PropertyUtil.PROPERTY_HINT_TYPE_STRING,
		"hint_string": PropertyUtil.array_hint_string(TYPE_NODE_PATH, TYPE_NIL, "")
	})

	property_list.append({
		"name": "transform_flags",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": PoolStringArray(TransformComponents.keys()).join(',')
	})

	return property_list

func _get_configuration_warning() -> String:
	if not has_node(source_path):
		return "No source path set."

	var source = get_source()
	if not source:
		return "Source not valid"

	if target_paths.empty():
		return "No target paths set."

	var targets = get_targets()
	if targets.empty():
		return "No valid targets."

	return ""
