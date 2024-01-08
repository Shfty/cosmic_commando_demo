class_name SpriteCircle
extends Node2D
tool

export(float) var radius := 5.0 setget set_radius
export(Color) var color := Color.white setget set_color

func set_radius(new_radius: float) -> void:
	if radius != new_radius:
		radius = new_radius
		update()

func set_color(new_color: Color) -> void:
	if color != new_color:
		color = new_color
		update()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
