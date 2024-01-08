class_name Hitbox
extends Area2D
tool

signal give_damage(amount, normal, force)

export(bool) var active := false setget set_active
export(int) var contact_damage := 24
export(int) var contact_force := 0.0

func set_active(new_active: bool) -> void:
	if active != new_active:
		active = new_active
		update_active()

func update_active() -> void:
	monitorable = active
	monitoring = active
	property_list_changed_notify()

func _init() -> void:
	update_active()
	var connect_result = connect("area_entered", self, "area_entered")
	assert(connect_result == OK)

func area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		var normal = (area.global_transform.origin - global_transform.origin).normalized()
		if area.take_damage(contact_damage, normal, contact_force):
			emit_signal("give_damage", contact_damage, normal, contact_force)

func parried(_damage: int, _normal: Vector2, _force: float) -> void:
	TimeManager.hitstop(0.1)
