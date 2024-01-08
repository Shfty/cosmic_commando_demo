class_name EnemyAggroBox
extends Area2D

signal screen_entered()
signal screen_exited()

func _init() -> void:
	var enter_connect_result = connect("area_entered", self, "area_entered")
	assert(enter_connect_result == OK)

	var exit_connect_result = connect("area_exited", self, "area_exited")
	assert(exit_connect_result == OK)

func area_entered(_area: Area2D) -> void:
	emit_signal("screen_entered")

func area_exited(_area: Area2D) -> void:
	emit_signal("screen_exited")
