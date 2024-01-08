class_name CapsuleSprite
extends Node2D
tool

func get_alien_soldier() -> AlienSoldier:
	return find_parent("AlienSoldier") as AlienSoldier

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var alien_soldier = get_alien_soldier()
	if not alien_soldier:
		return

	var invulnerability_timer = alien_soldier.get_invulnerability_timer()
	if not invulnerability_timer:
		return

	if invulnerability_timer.is_stopped():
		visible = true
	else:
		visible = !visible

	update()

func _draw() -> void:
	var alien_soldier = get_alien_soldier()
	if not alien_soldier:
		return

	var collision_shape = alien_soldier.get_collision_shape()
	if not collision_shape:
		return

	# Draw capsule
	var angle = alien_soldier._tuck_roll_factor * alien_soldier.facing * TAU
	var half_length = round(collision_shape.shape.height * 0.5)
	var torso_position = Vector2.UP.rotated(angle) * half_length
	var legs_position = Vector2.DOWN.rotated(angle) * half_length
	var torso_color = Color.white if alien_soldier._fire_mode == 0 else (Color.gold + Color.white) * 0.5
	draw_circle(torso_position, collision_shape.shape.radius, Color.steelblue)
	draw_circle(legs_position, collision_shape.shape.radius, Color.steelblue)
	draw_polygon(
		[
			Vector2(-alien_soldier.collider_radius, -half_length).rotated(angle),
			Vector2(alien_soldier.collider_radius, -half_length).rotated(angle),
			Vector2(alien_soldier.collider_radius, half_length).rotated(angle),
			Vector2(-alien_soldier.collider_radius, half_length).rotated(angle)
		],
		PoolColorArray(
			[
				torso_color,
				torso_color,
				torso_color,
				torso_color
			]
		)
	)
