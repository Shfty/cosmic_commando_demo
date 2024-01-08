class_name WeaponWheelSprite
extends Node2D
tool

const WEAPON_COLORS := {
	AlienSoldier.WeaponType.Buster: Color.yellow,
	AlienSoldier.WeaponType.Ranger: Color.orange,
	AlienSoldier.WeaponType.Flame: Color.red,
	AlienSoldier.WeaponType.Homing: Color.darkorange,
	AlienSoldier.WeaponType.Sword: Color.blue,
	AlienSoldier.WeaponType.Lancer: Color.cyan
}

func get_alien_soldier() -> AlienSoldier:
	return find_parent("AlienSoldier") as AlienSoldier

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
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

	# Draw weapon wheel
	if alien_soldier._weapon_wheel_factor > 0.0:
		for i in range(0, WEAPON_COLORS.size()):
			i = WEAPON_COLORS.size() - 1 - i
			var segment = TAU / WEAPON_COLORS.size()
			var position = torso_position + (
				alien_soldier.weapon_wheel_inner_offset +
				alien_soldier.weapon_wheel_outer_offset * (
					1.0 - alien_soldier._weapon_wheel_factor
					)
			) * Vector2.UP.rotated(
				i * segment + PI + alien_soldier._weapon_wheel_factor * PI + alien_soldier._weapon_wheel_offset * -segment
			)

			draw_circle(position.round(), 8.0, Color.gray)
			draw_circle(position.round(), 6.0, WEAPON_COLORS[AlienSoldier.WeaponType.values()[i]])
