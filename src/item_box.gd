class_name Itembox
extends Area2D

signal take_healing(amount)

export(bool) var active := true setget set_active

func set_active(new_active: bool) -> void:
	if active != new_active:
		active = new_active
		monitorable = active
		if active:
			for area in get_overlapping_areas():
				area.area_entered(self)

func take_healing(amount: int) -> bool:
	emit_signal("take_healing", amount)
	return true
