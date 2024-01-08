extends Container
tool

func _enter_tree() -> void:
	for child in get_children():
		if child is BaseButton:
			if not child.is_connected("mouse_entered", child, "grab_focus"):
				child.connect("mouse_entered", child, "grab_focus", [], CONNECT_PERSIST)
