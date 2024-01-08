class_name SpriteHomingForce
extends Node2D
tool

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	for x in range(-5, 6):
		for y in range(-5, 6):
			draw_circle(Vector2(randf() * x * 2.0, randf() * y * 2.0), 3.0 + randf() * 3.0, lerp(Color.yellow, Color.red, randf()))
