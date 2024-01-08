extends Container
tool

export(String) var active_control: String setget set_active_control

func set_active_control(new_active_control: String) -> void:
	if active_control != new_active_control:
		active_control = new_active_control
		update_active_control()

func update_active_control() -> void:
	for i in range(0, get_child_count()):
		var child = get_child(i)
		if child.get_name() == active_control:
			child.visible = true
			if child != get_focus_owner():
				child.grab_focus()
		else:
			child.visible = false

func grab_focus() -> void:
	update_active_control()
