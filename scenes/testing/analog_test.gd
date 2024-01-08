extends Node2D

var axis_values: Dictionary
var axis_pressed: Dictionary

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		axis_values[event.axis] = event.axis_value
		axis_pressed[event.axis] = event.is_pressed()
		update()
	elif event is InputEventJoypadButton:
		print_debug(event.button_index, event.pressed, ', ', event.pressure, ',', event.is_action_pressed("move_up"))

func _draw() -> void:
	var font = preload("res://resources/themes/alien_soldier.tres").get_font("", "font")
	for key in axis_values:
		draw_string(font, Vector2(64, 64 + 16 * key), "%s %s" % [axis_values[key], axis_pressed[key]])
