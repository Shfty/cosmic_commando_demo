class_name HitsparkSprite
extends Node2D

func get_target() -> Effect:
	var candidate = self
	while true:
		candidate = candidate.get_parent()
		if not candidate:
			break
		if candidate is Effect:
			return candidate
	return null

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	var target = get_target()
	assert(target)
	draw_circle(Vector2.ZERO, int((target._timer / target.duration) * 12.0), Color.orange)
