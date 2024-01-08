class_name UIUtil

static func has_focused_child(control: Control) -> bool:
	var focused_child = false

	for child in control.get_children():
		if child.has_focus():
			focused_child = true
		else:
			focused_child = focused_child or has_focused_child(child)

	return focused_child
