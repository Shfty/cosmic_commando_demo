class_name Spring2D
extends Node2D
tool

""" Applies spring forces to a Node2D over time. Like SpringJoint2D, but without the PhysicsBody dependency. """

export(Array, NodePath) var source_node_paths setget set_source_node_paths
export(NodePath) var target_node_path setget set_target_node_path
export(float) var spring_tension := 4.0
export(Vector2) var rest_offset := Vector2.ZERO
export(float) var length_limit := -1.0

func set_source_node_paths(new_source_node_paths: Array) -> void:
	if source_node_paths != new_source_node_paths:
		source_node_paths = new_source_node_paths
		update_configuration_warning()

func set_target_node_path(new_target_node_path: NodePath) -> void:
	if target_node_path != new_target_node_path:
		target_node_path = new_target_node_path
		update_configuration_warning()

func get_source_nodes() -> Array:
	var source_nodes := []

	for source_node_path in source_node_paths:
		var candidate = self
		var node
		while true:
			node = candidate.get_node_or_null(source_node_path)
			if node:
				break
			else:
				candidate = candidate.get_parent()
				if not candidate:
					break
		if node:
			source_nodes.append(node)

	return source_nodes

func get_target_node() -> Node:
	return get_node(target_node_path) if has_node(target_node_path) else null

func has_source_nodes() -> bool:
	var source_nodes = get_source_nodes()
	if source_nodes.empty():
		return false
	return true

func get_target_position() -> Vector2:
	if not has_source_nodes():
		return Vector2.ZERO

	var source_nodes = get_source_nodes()

	var target_position = Vector2.ZERO
	for source_node in source_nodes:
		target_position += source_node.global_transform.origin
	target_position /= source_nodes.size()
	target_position += rest_offset
	return target_position

func _physics_process(delta: float) -> void:
	if not has_source_nodes():
		return

	var target_node = get_target_node()
	if not target_node:
		return

	var target_position = get_target_position()

	var delta_pos = target_position - target_node.global_transform.origin
	if length_limit >= 0.0 and delta_pos.length() >= length_limit:
		target_node.global_transform.origin = target_position - delta_pos.normalized() * length_limit

	target_node.global_transform.origin = lerp(target_node.global_transform.origin, target_position, spring_tension * delta)

	if Engine.is_editor_hint():
		update()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var target_node = get_target_node()
	if not target_node:
		return

	var target_position = get_target_position()

	var from = target_node.global_transform.origin - global_transform.origin
	var to = target_position - global_transform.origin
	draw_line(from, to, Color.yellow)
	draw_circle(from, 1.0, Color.green)
	draw_circle(to, 1.0, Color.red)

func _get_configuration_warning() -> String:
	if source_node_paths.empty():
		return "No source nodes set."

	if get_source_nodes().empty():
		return "No valid source nodes."

	if not has_node(target_node_path):
		return "No target node set."

	var target_node = get_target_node()
	if not target_node:
		return "Target node not valid"

	return ""
