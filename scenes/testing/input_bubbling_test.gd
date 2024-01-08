extends Node

func _unhandled_input(event: InputEvent) -> void:
	print_debug("%s unhandled input: %s" % [get_name(), event])
	get_tree().set_input_as_handled()
