extends Node2D
tool

var orientation := 0.0

var _animation_timer: Timer

func _enter_tree() -> void:
	_animation_timer = Timer.new()
	_animation_timer.wait_time = 1.0 / 30.0
	var connect_result = _animation_timer.connect("timeout", self, "tick_animation")
	assert(connect_result == OK)
	add_child(_animation_timer)
	_animation_timer.start()

func _exit_tree() -> void:
	_animation_timer.disconnect("timeout", self, "tick_animation")
	remove_child(_animation_timer)
	_animation_timer.queue_free()

func tick_animation() -> void:
	orientation += PI * 0.25
	update()

func _draw() -> void:
	draw_diamond(Vector2.ZERO, orientation, Vector2(2, 16), Color.yellow)
	draw_diamond(Vector2.ZERO, orientation + PI * 0.5, Vector2(2, 16), Color.yellow)
	draw_diamond(Vector2.ZERO, orientation + PI * 0.25, Vector2(2, 10), Color.lightyellow)
	draw_diamond(Vector2.ZERO, orientation + PI * 0.75, Vector2(2, 10), Color.lightyellow)

func draw_diamond(position: Vector2, rotation: float, size: Vector2, color: Color) -> void:
	draw_polygon(
		PoolVector2Array([
			position + Vector2.UP.rotated(rotation) * size.y,
			position + Vector2.RIGHT.rotated(rotation) * size.x,
			position + Vector2.DOWN.rotated(rotation) * size.y,
			position + Vector2.LEFT.rotated(rotation) * size.x
		]),
		PoolColorArray([
			color
		])
	)
