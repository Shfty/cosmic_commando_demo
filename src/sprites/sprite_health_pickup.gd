class_name HealthPickupSprite
extends Node2D
tool

export(float) var size = 9.0

var color_a := Color("#f7ff9d")
var color_b := Color("#00b7ff")

var _flip_colors := false

func animation_timeout() -> void:
	_flip_colors = !_flip_colors
	update()

func _set(property: String, value) -> bool:
	match property:
		"size":
			size = value
			update()
			return true

	return false

func _draw() -> void:
	draw_polygon(PoolVector2Array([
		Vector2.ZERO,
		Vector2.UP * size,
		Vector2.RIGHT * size,
		Vector2.ZERO,
		Vector2.DOWN * size,
		Vector2.LEFT * size
	]),
	PoolColorArray([
		color_a if _flip_colors else color_b
	]))

	draw_polygon(PoolVector2Array([
		Vector2.ZERO,
		Vector2.RIGHT * size,
		Vector2.DOWN * size,
		Vector2.ZERO,
		Vector2.LEFT * size,
		Vector2.UP * size,
	]),
	PoolColorArray([
		color_b if _flip_colors else color_a
	]))
