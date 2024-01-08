class_name Vector2PropertyIntegrator
extends Node
tool

""" Integrates a Vector2 property toward a target value over time. """

signal target_reached()

enum ProcessMode {
	Idle,
	Physics,
	Manual
}

enum TargetMode {
	Value,
	Property
}

var process_mode: int = ProcessMode.Idle setget set_process_mode
var source_path: NodePath setget set_source_path
var source_subname: String
var target_mode: int = TargetMode.Value setget set_target_mode
var target_value: Vector2
var target_path: NodePath
var target_subname: String
var speed: float

func set_process_mode(new_process_mode: int) -> void:
	if process_mode != new_process_mode:
		process_mode = new_process_mode
		if is_inside_tree():
			update_process_mode()

func set_target_mode(new_target_mode: int) -> void:
	if target_mode != new_target_mode:
		target_mode = new_target_mode
		property_list_changed_notify()

func set_source_path(new_source_path: NodePath) -> void:
	if source_path != new_source_path:
		source_path = new_source_path
		update_configuration_warning()

func get_source() -> Node:
	return get_node_or_null(source_path)

func update_process_mode() -> void:
	match process_mode:
		ProcessMode.Idle:
			set_process(true)
			set_physics_process(false)
		ProcessMode.Physics:
			set_process(false)
			set_physics_process(true)
		ProcessMode.Manual:
			set_process(false)
			set_physics_process(false)

func _ready() -> void:
	update_process_mode()

func _process(delta: float) -> void:
	integrate_property(delta)

func _physics_process(delta: float) -> void:
	integrate_property(delta)

func integrate_property(delta: float) -> void:
	var source = get_source()
	if not source:
		return

	var path = ":" + source_subname
	var value = source.get_indexed(path)
	if not value is Vector2:
		return

	var target: Vector2
	match target_mode:
		TargetMode.Value:
			target = target_value
		TargetMode.Property:
			var target_node = get_node_or_null(target_path)
			if target_node:
				target = target_node.get_indexed(":" + target_subname)

	var delta_pos = target - value
	var delta_norm = delta_pos.normalized()
	var delta_mag = delta_pos.length()
	var mag = min(speed * delta, delta_mag)

	var d = value + delta_norm * mag
	if d == target_value:
		emit_signal("target_reached")

	source.set_indexed(path, d)

func _get_configuration_warning() -> String:
	if not has_node(source_path):
		return "No source path set"

	var source = get_source()
	if not source:
		return "Invalid source node"

	return ""

func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "process_mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(ProcessMode.keys()).join(',')
	})

	property_list.append({
		"name": "source_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "source_subname",
		"type": TYPE_STRING
	})

	property_list.append({
		"name": "target_mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(TargetMode.keys()).join(',')
	})

	match target_mode:
		TargetMode.Value:
			property_list.append({
				"name": "target_value",
				"type": TYPE_VECTOR2
			})
		TargetMode.Property:
			property_list.append({
				"name": "target_path",
				"type": TYPE_NODE_PATH
			})
			property_list.append({
				"name": "target_subname",
				"type": TYPE_STRING
			})

	property_list.append({
		"name": "speed",
		"type": TYPE_REAL
	})

	return property_list
