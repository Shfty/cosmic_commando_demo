class_name SpriteEpsilonEagle
extends Node2D
tool

var aim = 0

func get_alien_soldier() -> AlienSoldier:
	var candidate = self
	while true:
		candidate = candidate.get_parent()
		if not candidate:
			break
		if candidate is AlienSoldier:
			return candidate
	return null

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var alien_soldier = get_alien_soldier()
	if not alien_soldier:
		return

	if alien_soldier.get_invulnerability_timer().is_stopped():
		visible = true
	else:
		visible = !visible
	update()

func set_aim(new_aim: int) -> void:
	if aim != new_aim:
		aim = new_aim
		update_torso_aim_frame()

func update_torso_aim_frame() -> void:
	$Torso.frame = aim + 2

func reset_torso_frame() -> void:
	$Torso.frame = 0

func set_torso_animation(new_animation: String) -> void:
	$Torso.visible = true
	$Legs.visible = true
	$Composite.visible = false

	$Torso.animation = new_animation

	if new_animation == "shooting_fixed" or new_animation == "shooting_free":
		update_torso_aim_frame()
	elif new_animation == "running":
		$Torso.frame = $Legs.frame
	else:
		reset_torso_frame()

func set_legs_animation(new_animation: String) -> void:
	$Torso.visible = true
	$Legs.visible = true
	$Composite.visible = false

	$Legs.animation = new_animation

func set_composite_animation(new_animation: String) -> void:
	$Torso.visible = false
	$Legs.visible = false
	$Composite.visible = true

	if $Composite.animation != new_animation:
		$Composite.transform = Transform.IDENTITY

	$Composite.animation = new_animation


func composite_frame_changed() -> void:
	if $Composite.animation == "tuck_roll" and $Composite.frame == 0:
		$Composite.rotation += PI * 0.5
