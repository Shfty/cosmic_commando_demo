class_name SpriteLine
extends Node2D
tool

export(float) var length = 8.0 setget set_length
export(float) var width = 1.0 setget set_width
export(Color) var color = Color.white setget set_color
export(bool) var antialiased = false setget set_antialiased

func set_length(new_length: float) -> void:
	if length != new_length:
		length = new_length
		update()

func set_width(new_width: float) -> void:
	if width != new_width:
		width = new_width
		update()

func set_color(new_color: Color) -> void:
	if color != new_color:
		color = new_color
		update()

func set_antialiased(new_antialiased: bool) -> void:
	if antialiased != new_antialiased:
		antialiased = new_antialiased
		update()

func _draw() -> void:
	draw_line(Vector2(-length, 0.0), Vector2(length, 0.0), color, width, antialiased)
