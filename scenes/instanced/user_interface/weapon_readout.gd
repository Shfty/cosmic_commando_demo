extends HBoxContainer
tool

export(int) var active_weapon := 0 setget set_active_weapon

func set_active_weapon(new_active_weapon: int) -> void:
	if active_weapon != new_active_weapon:
		active_weapon = new_active_weapon

		if is_inside_tree():
			update_active_icon()

func _ready() -> void:
	update_active_icon()

func update_active_icon() -> void:
	for i in range(0, get_child_count()):
		var child = get_child(i)
		assert(child is WeaponIcon)
		child.set_active(i == active_weapon)
