extends Path2D
tool

""" Positions a bone chain along a Path2D. """

var start_bone_path: NodePath setget set_start_bone_path
var end_bone_path: NodePath setget set_end_bone_path
var endpoint_path: NodePath setget set_endpoint_path
var out_handle_path: NodePath setget set_out_handle_path
var in_handle_path: NodePath setget set_in_handle_path
var max_length: float = -1.0 setget set_max_length

var _cached_start_bone_position := Vector2.ZERO
var _cached_endpoint_position := Vector2.ZERO
var _cached_in_handle_position := Vector2.ZERO
var _cached_out_handle_position := Vector2.ZERO

func set_start_bone_path(new_start_bone_path: NodePath) -> void:
	if start_bone_path != new_start_bone_path:
		start_bone_path = new_start_bone_path

		var start_bone = get_start_bone()
		if start_bone:
			_cached_start_bone_position = start_bone.global_transform

		update_curve()
	update_configuration_warning()

func set_end_bone_path(new_end_bone_path: NodePath) -> void:
	if end_bone_path != new_end_bone_path:
		end_bone_path = new_end_bone_path
		update_curve()
	update_configuration_warning()

func set_endpoint_path(new_endpoint_path: NodePath) -> void:
	if endpoint_path != new_endpoint_path:
		endpoint_path = new_endpoint_path

		var endpoint = get_endpoint()
		if endpoint:
			_cached_endpoint_position = endpoint.global_transform

		update_curve()
	update_configuration_warning()

func set_in_handle_path(new_handle_path: NodePath) -> void:
	if in_handle_path != new_handle_path:
		in_handle_path = new_handle_path

		var in_handle = get_in_handle()
		if in_handle:
			_cached_in_handle_position = in_handle.global_transform

		update_curve()

func set_out_handle_path(new_handle_path: NodePath) -> void:
	if out_handle_path != new_handle_path:
		out_handle_path = new_handle_path

		var out_handle = get_out_handle()
		if out_handle:
			_cached_out_handle_position = out_handle.global_transform

		update_curve()

func set_max_length(new_max_length: float) -> void:
	if max_length != new_max_length:
		max_length = new_max_length
		update_curve()

func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "start_bone_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "end_bone_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "endpoint_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "out_handle_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "in_handle_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "max_length",
		"type": TYPE_REAL
	})

	property_list.append({
		"name": "_cached_endpoint_position",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	property_list.append({
		"name": "_cached_handle_position",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	return property_list

func get_node_checked(path: NodePath) -> Node:
	return get_node(path) if has_node(path) else null

func get_start_bone() -> Node:
	return get_node_checked(start_bone_path)

func get_end_bone() -> Node:
	return get_node_checked(end_bone_path)

func get_endpoint() -> Node:
	return get_node_checked(endpoint_path)

func get_in_handle() -> Node:
	return get_node_checked(in_handle_path)

func get_out_handle() -> Node:
	return get_node_checked(out_handle_path)

func _ready() -> void:
	var start_bone = get_start_bone()

	var endpoint = get_endpoint()
	if not endpoint:
		return

	var out_handle = get_out_handle()
	if out_handle:
		_cached_in_handle_position = out_handle.global_transform.origin

	var in_handle = get_out_handle()
	if in_handle:
		_cached_out_handle_position = in_handle.global_transform.origin

	_cached_start_bone_position = start_bone.global_transform.origin
	_cached_endpoint_position = endpoint.global_transform.origin
	update_curve()

func _process(_delta: float) -> void:
	var start_bone = get_start_bone()
	if not start_bone:
		return

	var endpoint = get_endpoint()
	if not endpoint:
		return

	var wants_update := false

	if _cached_start_bone_position != start_bone.global_transform.origin:
		_cached_start_bone_position = start_bone.global_transform.origin
		wants_update = true

	if _cached_endpoint_position != endpoint.global_transform.origin:
		_cached_endpoint_position = endpoint.global_transform.origin
		wants_update = true

	var out_handle = get_out_handle()
	if out_handle:
		if _cached_out_handle_position != out_handle.global_transform.origin:
			_cached_out_handle_position = out_handle.global_transform.origin
			wants_update = true

	var in_handle = get_in_handle()
	if in_handle:
		if _cached_in_handle_position != in_handle.global_transform.origin:
			_cached_in_handle_position = in_handle.global_transform.origin
			wants_update = true

	if wants_update:
		update_curve()
		if Engine.is_editor_hint():
			update()

func _draw():
	if not Engine.is_editor_hint():
		return

	draw_circle(Vector2.ZERO, 3.0, Color.white)

	var endpoint = get_endpoint()
	if endpoint:
		draw_circle(endpoint.global_transform.origin - global_transform.origin, 3.0, Color.white)

	var out_handle = get_out_handle()
	if out_handle:
		draw_line(Vector2.ZERO, out_handle.global_transform.origin - global_transform.origin, Color.white, 1.0, true)

	var in_handle = get_in_handle()
	if in_handle:
		draw_line(endpoint.global_transform.origin - global_transform.origin, in_handle.global_transform.origin - global_transform.origin, Color.white, 1.0, true)

func _get_configuration_warning() -> String:
	if not has_node(start_bone_path):
		return "No start bone set."

	var start_bone = get_start_bone()
	if not start_bone:
		return "Start bone not valid"

	if not has_node(end_bone_path):
		return "No end bone set."

	var end_bone = get_end_bone()
	if not end_bone:
		return "End bone not valid"

	if not has_node(endpoint_path):
		return "No endpoint set."

	var endpoint = get_endpoint()
	if not endpoint:
		return "Endpoint not valid"

	return ""

func update_curve() -> void:
	var start_bone = get_start_bone()
	if not start_bone:
		return

	var end_bone = get_end_bone()
	if not end_bone:
		return

	var endpoint = get_endpoint()
	if not endpoint:
		return

	curve.clear_points()
	curve.add_point(Vector2.ZERO)

	curve.add_point(endpoint.global_transform.origin - start_bone.global_transform.origin)

	var out_handle = get_out_handle()
	if out_handle:
		curve.set_point_out(0, out_handle.global_transform.origin - start_bone.global_transform.origin)

	var in_handle = get_in_handle()
	if in_handle:
		curve.set_point_in(1, in_handle.global_transform.origin - endpoint.global_transform.origin)

	var relative_path = start_bone.get_path_to(end_bone)

	var candidate = start_bone
	global_transform = Transform2D.IDENTITY.translated(start_bone.global_transform.origin)

	var bone_count = relative_path.get_name_count()
	var length = curve.get_baked_length()
	if max_length > 0:
		length = min(length, max_length)
	var step = length / bone_count
	var dist = step

	for i in range(0, bone_count):
		var name = relative_path.get_name(i)
		if name == "..":
			return

	var prev_pos = Vector2.ZERO
	var prev_rotation = 0.0
	for i in range(0, bone_count):
		var position = curve.interpolate_baked(dist)
		var delta = position - prev_pos
		prev_pos = position
		var rotation = atan2(delta.y, delta.x)
		candidate.rotation = atan2(delta.y, delta.x) - prev_rotation
		prev_rotation = rotation
		var name = relative_path.get_name(i)
		candidate = candidate.get_node(name)
		candidate.global_transform.origin = global_transform.origin + position
		dist += step
