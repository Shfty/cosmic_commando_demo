extends Node2D

func get_alien_soldier() -> AlienSoldier:
	return find_parent("AlienSoldier") as AlienSoldier

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	var alien_soldier = get_alien_soldier()
	if not alien_soldier:
		return

	var jump_timer = alien_soldier.get_jump_timer()
	if not jump_timer:
		return

	var dash_timer = alien_soldier.get_dash_timer()
	if not dash_timer:
		return

	# Velocity
	draw_line(Vector2.DOWN * 32.0, Vector2.DOWN * 32.0 + alien_soldier._velocity * 0.2, Color.cyan)

	# Facing
	draw_line(Vector2.DOWN * 16.0, Vector2.DOWN * 16.0 + Vector2.RIGHT * 20.0 * alien_soldier.facing, Color.purple)

	# Gravity Direction
	draw_line(Vector2.DOWN * 16.0, Vector2.DOWN * 16.0 + Vector2.DOWN * 20.0 * alien_soldier._gravity_direction, Color.purple)

	# Aim
	draw_line(Vector2.UP * 16.0, Vector2.UP * 16.0 + Vector2.RIGHT.rotated(alien_soldier._aim * PI * 0.25 * alien_soldier.facing) * alien_soldier.facing * 20.0, Color.pink)

	# Wish Vector
	draw_line(Vector2.ZERO, alien_soldier._wish_vector * 20.0, Color.red)

	# Jump Timer
	draw_line(
		Vector2(32.0, 32.0),
		Vector2(32.0, 32.0) + Vector2.UP * jump_timer.time_left * (64.0 / jump_timer.wait_time),
		Color.white
	)

	# Dash Timer
	draw_line(
		Vector2(-32.0, 32.0),
		Vector2(-32.0, 32.0) + Vector2.UP * dash_timer.time_left * (64.0 / dash_timer.wait_time),
		Color.white
	)
