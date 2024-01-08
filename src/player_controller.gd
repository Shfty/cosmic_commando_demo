class_name PlayerController
extends Node

export(int) var device_id := -1
export(bool) var filter_echo := true

func _unhandled_input(event: InputEvent) -> void:
	var parent = get_parent()
	assert(parent)
	assert(parent.has_method("handle_input"))

	if device_id > -1 and event.device != device_id:
		return

	if filter_echo and event.is_echo():
		return

	if not event is InputEventKey:
		return

	parent.handle_input(event)
