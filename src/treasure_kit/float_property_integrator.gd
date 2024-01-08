class_name FloatPropertyIntegrator
extends Node
tool

""" Integrates a target float property over time, either by a constant value or toward a target. """

signal target_reached()

enum ProcessMode {
	Idle,
	Physics,
	Manual
}

enum IntegratorMode {
	Constant,
	Target
}

var process_mode: int = ProcessMode.Idle setget set_process_mode
var target_path: NodePath setget set_target_path
var target_subname: String
var mode: int = IntegratorMode.Constant setget set_mode
var delta_value: float
var target_value: float
var acceleration: float
var deceleration: float
var use_modulo := false setget set_use_modulo
var modulo := 1.0

func set_process_mode(new_process_mode: int) -> void:
	if process_mode != new_process_mode:
		process_mode = new_process_mode
		if is_inside_tree():
			update_process_mode()

func set_target_path(new_target_path: NodePath) -> void:
	if target_path != new_target_path:
		target_path = new_target_path
		update_configuration_warning()

func set_mode(new_mode: int) -> void:
	if mode != new_mode:
		mode = new_mode
		property_list_changed_notify()

func set_use_modulo(new_use_modulo: bool) -> void:
	if use_modulo != new_use_modulo:
		use_modulo = new_use_modulo
		property_list_changed_notify()

func get_target() -> Node:
	return get_node(target_path) if has_node(target_path) else null

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
	var target = get_target()
	if not target:
		return

	var path = ":" + target_subname
	var value = target.get_indexed(path)

	var d = value
	match mode:
		IntegratorMode.Constant:
			d += delta_value * delta
		IntegratorMode.Target:
			if d < target_value:
				d += min(acceleration * delta, target_value - d)
				if d == target_value:
					emit_signal("target_reached")
			elif d > target_value:
				d -= min(deceleration * delta, d - target_value)
				if d == target_value:
					emit_signal("target_reached")

	if use_modulo:
		d = fmod(d, modulo)
	target.set_indexed(path, d)

func _get_configuration_warning() -> String:
	if not has_node(target_path):
		return "No target path set"

	var target = get_target()
	if not target:
		return "Invalid target node"

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
		"name": "target_path",
		"type": TYPE_NODE_PATH
	})

	property_list.append({
		"name": "target_subname",
		"type": TYPE_STRING
	})

	property_list.append({
		"name": "mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(IntegratorMode.keys()).join(',')
	})

	match mode:
		IntegratorMode.Constant:
			property_list.append({
				"name": "delta_value",
				"type": TYPE_REAL
			})
		IntegratorMode.Target:
			property_list.append({
				"name": "target_value",
				"type": TYPE_REAL
			})

			property_list.append({
				"name": "acceleration",
				"type": TYPE_REAL
			})

			property_list.append({
				"name": "deceleration",
				"type": TYPE_REAL
			})

	property_list.append({
		"name": "use_modulo",
		"type": TYPE_BOOL
	})

	if use_modulo:
		property_list.append({
			"name": "modulo",
			"type": TYPE_REAL
		})

	return property_list
