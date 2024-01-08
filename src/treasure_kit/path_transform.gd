class_name PathTransform
extends Node2D
tool

""" Positions itself at a given point along a Path2D. Like PathFollow2D, but without the parent dependency. """

enum SampleMode {
	Distance,
	Scalar
}

enum TransformComponents {
	Position = 1,
	Rotation = 2
}

var source_path: NodePath setget set_source_path
var target_paths: Array setget set_target_paths
var sample_mode: int = SampleMode.Distance
var sample_alpha: float = 0.0
var look_ahead: float = 1.0
var transform_flags: int = TransformComponents.Position | TransformComponents.Rotation

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
	var source = get_source() as Path2D
	if not source:
		return

	var curve = source.curve
	if not curve:
		return

	var targets = get_targets()
	if targets.empty():
		return

	var alpha
	match sample_mode:
		SampleMode.Distance:
			alpha = sample_alpha
		SampleMode.Scalar:
			alpha = sample_alpha * curve.get_baked_length()

	var alpha_a
	var alpha_b

	if alpha < curve.get_baked_length() - look_ahead:
		alpha_a = alpha
		alpha_b = alpha_a + look_ahead
	elif alpha > look_ahead:
		alpha_a = alpha - look_ahead
		alpha_b = alpha
	else:
		alpha_a = alpha
		alpha_b = alpha

	var a = curve.interpolate_baked(alpha_a)
	var b = curve.interpolate_baked(alpha_b)
	var tangent = b - a
	var angle = atan2(tangent.y, tangent.x)

	var trx = Transform2D.IDENTITY

	if TransformComponents.Rotation & transform_flags:
		trx = trx.rotated(angle)

	if TransformComponents.Position & transform_flags:
		trx.origin = a if alpha < curve.get_baked_length() - look_ahead else b

	for target in targets:
		target.global_transform = source.global_transform * trx

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
		"name": "sample_mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(SampleMode.keys()).join(',')
	})

	property_list.append({
		"name": "sample_alpha",
		"type": TYPE_REAL
	})

	property_list.append({
		"name": "look_ahead",
		"type": TYPE_REAL
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
		return "Invalid source path."

	if target_paths.empty():
		return "No target paths set."

	var targets = get_targets()
	if targets.empty():
		return "No valid targets."

	return ""
