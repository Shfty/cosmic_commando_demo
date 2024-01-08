class_name NodeProxy
extends Node
tool

"""
Redirects all property get / set / list calls to the target node.
Useful for AnimationPlayer setups that use the root_node property to create reusable / modular sets of animations.
"""

var proxy_target: NodePath setget set_proxy_target

func set_proxy_target(new_proxy_target: NodePath) -> void:
	if proxy_target != new_proxy_target:
		proxy_target = new_proxy_target
		property_list_changed_notify()

func get_target_node() -> Node:
	return get_node_or_null(proxy_target)

func _get(property: String):
	if property in PROPERTY_BLACKLIST:
		match property:
			"script":
				return get_script()
			"editor_description":
				return editor_description
			"process_priority":
				return get_process_priority()
			"pause_mode":
				return get_pause_mode()

	var target_node = get_target_node()
	if not target_node:
		return null

	#print("Getting %s on %s" % [property, target_node.get_name()])

	return target_node.get(property)

func _set(property: String, value) -> bool:
	if property in PROPERTY_BLACKLIST:
		match property:
			"script":
				set_script(value)
			"editor_description":
				editor_description = value
			"process_priority":
				set_process_priority(value)
			"pause_mode":
				set_pause_mode(value)
		return true

	var target_node = get_target_node()
	if not target_node:
		return false

	#print("Setting %s on %s to %s" % [property, target_node.get_name(), value])

	if value is NodePath:
		var node = get_node_or_null(value)
		if node:
			value = target_node.get_path_to(node)
	elif value is Array:
		for i in range(0, value.size()):
			if value[i] is NodePath:
				var node = get_node_or_null(value[i])
				if node:
					value[i] = target_node.get_path_to(node)


	target_node.set(property, value)
	return true

const PROPERTY_BLACKLIST := [
	"script",
	"editor_description",
	"process_priority",
	"pause_mode",
]

func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "NodeProxy",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})

	property_list.append({
		"name": "proxy_target",
		"type": TYPE_NODE_PATH
	})

	var target_node = get_target_node()
	if target_node:
		var target_properties = target_node.get_property_list()
		var candidate_properties := []
		for property in target_properties:
			if not property.name in PROPERTY_BLACKLIST and not property.name.empty():
				candidate_properties.append(property)

		property_list += candidate_properties

	return property_list
