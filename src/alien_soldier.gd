class_name AlienSoldier
extends Actor
tool

signal health_changed(new_health)
signal max_health_changed(new_max_health)
signal ammo_changed(new_ammo)
# warning-ignore:unused_signal
signal max_ammo_changed(new_max_ammo) # TODO: Emit this when max ammo is implemented
signal weapon_changed(new_weapon)

# TODO: Implement test enemies
#		Basic walking enemies
#			Turn around when hitting wall
#			'Jump at player' behavior
#			'Shoot at player' behavior
#		Basic flying enemies
#			Bomb droppers
#			Parryable bombs

# TODO: Implement fixed-fire leg animations
# TODO: Implement screen shake / directional impact
# TODO: Implement impact effects for phoenix force
# TODO: Implement weapon variance based on current ammo
# TODO: Implement damage types, values
# TODO: Implement lancer drill effect
# TODO: Implement jetpack visual effect
# TODO: Implement one-way platforms, dismount

# TODO: Snap to ground after dashing over the lip of a slope
# TODO: Fix camera follow jitter

# TODO: Tidy collision layers

enum WeaponType {
	Buster,
	Ranger,
	Flame,
	Homing,
	Sword,
	Lancer
}

var max_horizontal_velocity_ground = 275.0
var max_horizontal_velocity_air = 200.0
var max_horizontal_velocity_hover = 0.0

var max_vertical_velocity = 275.0

var base_acceleration := 1800.0
var turn_acceleration := 1800.0

var tuck_roll_speed = 4.0

var dash_velocity = 1300.0

var collider_radius = 20.0
var crouch_height = 14.0
var standing_height = 16.0
var crouch_speed = 15.0

var weapon_type: int = WeaponType.Buster
var weapon_wheel_speed := 4.0
var weapon_wheel_inner_offset := 32.0
var weapon_wheel_outer_offset := 128.0
var weapon_wheel_offset_speed := 8.0

var knockback_velocity := 100.0

var max_health := 512

var weapon_recharge_delay := 10.0

var phoenix_force_cost := 50

var counter_force_input_window = 0.25
var counter_force_duration = 0.15
var counter_force_recoil_ground = Vector2(-100, 0)
var counter_force_recoil_air = Vector2(-250, -20)

var take_damage_hitstop = 6.0 / 60.0
var give_damage_hitstop = 6.0 / 60.0

var hurtbox_size_offset = -5.0

var _wish_vector := Vector2.ZERO
var _gravity_direction: int = 1
var _aim: int = 0.0

var _crouch_factor := 0.0 setget _set_crouch_factor

var _cached_up_vector := Vector2.ZERO

var _refire_rate := 0.0

var _tuck_roll_factor := 0.0

var _weapon_wheel_factor := 0.0
var _weapon_wheel_offset := 0.0

var _fire_mode = AlienSoldierWeapon.FireMode.Free setget set_fire_mode

var _knockback_normal := Vector2.ZERO

var _health := max_health setget _set_health

var _closest_enemy: Node = null

var _has_cached_fixed_aim := false
var _cached_facing := 0
var _cached_aim := 0

# Setters
func set_horizontal_wish_direction(new_horizontal_wish_direction: float) -> void:
	if _wish_vector.x != new_horizontal_wish_direction:
		_wish_vector.x = new_horizontal_wish_direction

func set_vertical_wish_direction(new_vertical_wish_direction: float) -> void:
	if _wish_vector.y != new_vertical_wish_direction:
		_wish_vector.y = new_vertical_wish_direction

func facing_changed() -> void:
	get_epsilon_eagle_sprite().transform.x = Vector2.RIGHT * facing
	_update_weapon_anchor()

func set_gravity_direction(new_gravity_direction: int) -> void:
	assert(new_gravity_direction != 0)
	if _gravity_direction != new_gravity_direction:
		_gravity_direction = new_gravity_direction
		get_epsilon_eagle_sprite().transform.y = Vector2.DOWN * _gravity_direction
		_update_sprite_aim()
		_update_weapon_anchor()

func set_gravity_up() -> void:
	set_gravity_direction(-1)

func set_gravity_down() -> void:
	set_gravity_direction(1)

func set_aim(new_aim: int) -> void:
	assert(new_aim >= -2 and new_aim <= 2)
	if _aim != new_aim:
		_aim = new_aim

		_update_sprite_aim()
		_update_weapon_anchor()

func set_fire_mode(new_fire_mode: int) -> void:
	assert(new_fire_mode >= 0 and new_fire_mode <= 1)
	if _fire_mode != new_fire_mode:
		_fire_mode = new_fire_mode
		var weapons = _get_weapons()
		for weapon in weapons:
			weapon.fire_mode = _fire_mode

func _set_crouch_factor(new_crouch_factor: float) -> void:
	if _crouch_factor != new_crouch_factor:
		var crouch_delta = new_crouch_factor - _crouch_factor
		global_transform.origin.y += 0.5 * crouch_delta * standing_height * _gravity_direction
		_crouch_factor = new_crouch_factor
		get_epsilon_sprite_wrapper().transform.origin.y = 8.0 * _gravity_direction * _crouch_factor
		_update_collider()
		_update_weapon_anchor()

func _set_health(new_health: int) -> void:
	if _health != new_health:
		_health = new_health
		emit_signal("health_changed", _health)

func set_max_health(new_max_health: int) -> void:
	if max_health != new_max_health:
		max_health = new_max_health
		emit_signal("max_health_changed", new_max_health)

func set_torso_animation(new_torso_animation: String) -> void:
	get_epsilon_eagle_sprite().set_torso_animation(new_torso_animation)

func set_legs_animation(new_legs_animation: String) -> void:
	get_epsilon_eagle_sprite().set_legs_animation(new_legs_animation)

func set_composite_animation(new_composite_animation: String) -> void:
	get_epsilon_eagle_sprite().set_composite_animation(new_composite_animation)

# Getters
func _get_weapons() -> Array:
	return $WeaponAnchor/WeaponSlots.get_children()

func get_dash_effect_timer() -> Timer:
	return $DashEffectTimer as Timer

func get_counter_force_timer() -> Timer:
	return $CounterForceTimer as Timer

func get_invulnerability_timer() -> Timer:
	return $InvulnerabilityTimer as Timer

func get_jump_timer() -> Timer:
	return $JumpTimer as Timer

func get_dash_timer() -> Timer:
	return $DashTimer as Timer

func get_counter_force_input_timer() -> Timer:
	return $CounterForceInputTimer as Timer

func get_weapon_anchor() -> Node2D:
	return $WeaponAnchor as Node2D

func get_hurtbox_shape() -> CollisionShape2D:
	return $Hurtbox/CollisionShape2D as CollisionShape2D

func get_itembox_shape() -> CollisionShape2D:
	return $Itembox/CollisionShape2D as CollisionShape2D

func get_state_machine() -> Root:
	return $AlienSoldierStateMachine as Root

func get_epsilon_sprite_wrapper() -> PhysicsInterpolator2D:
	return $EpsilonSpritePhysicsInterpolator as PhysicsInterpolator2D

func get_epsilon_eagle_sprite() -> Node2D:
	return $EpsilonSpritePhysicsInterpolator/EpsilonSpritePixelSnap/EpsilonEagleSprite as Node2D

func get_no_force() -> AlienSoldierWeapon:
	return $WeaponAnchor/NoForce as AlienSoldierWeapon

func get_hurtbox() -> Area2D:
	return $Hurtbox as Area2D

func get_hitbox() -> Area2D:
	return $Hitbox as Area2D

func get_itembox() -> Area2D:
	return $Itembox as Area2D

func get_tuck_roll_jump_timer() -> Timer:
	return $TuckRollJumpTimer as Timer

func get_dash_recovery_timer() -> Timer:
	return $DashRecoveryTimer as Timer

func get_damage_timer() -> Timer:
	return $DamageTimer as Timer

func get_dying_timer() -> Timer:
	return $DyingTimer as Timer

func get_zero_teleport_audio() -> AudioStreamPlayer2D:
	return $Audio/ZeroTeleportAudio as AudioStreamPlayer2D

func get_phoenix_force_audio() -> AudioStreamPlayer2D:
	return $Audio/PhoenixForceAudio as AudioStreamPlayer2D

func get_counter_force_audio() -> AudioStreamPlayer2D:
	return $Audio/CounterForceAudio as AudioStreamPlayer2D

# Update Handlers
func _update_collider() -> void:
	var collision_shape = get_collision_shape()
	collision_shape.shape.radius = collider_radius
	collision_shape.shape.height = crouch_height + (1.0 - _crouch_factor) * standing_height

	var hurtbox_shape = get_hurtbox_shape()
	hurtbox_shape.shape.radius = collision_shape.shape.radius + hurtbox_size_offset
	hurtbox_shape.shape.height = collision_shape.shape.height

	var item_box_shape = get_itembox_shape()
	item_box_shape.shape.radius = collision_shape.shape.radius
	item_box_shape.shape.height = collision_shape.shape.height

func _update_sprite_aim() -> void:
	get_epsilon_eagle_sprite().set_aim(_aim * _gravity_direction)

func _update_weapon_anchor() -> void:
	var orientation = _aim * PI * facing * 0.25
	if facing == -1.0:
		orientation += PI

	var weapon_anchor = get_weapon_anchor()
	weapon_anchor.transform.origin = Vector2.UP * (_gravity_direction * (-8.0 * _crouch_factor + 16.0)) + Vector2.RIGHT.rotated(orientation) * (48.0 if _fire_mode == AlienSoldierWeapon.FireMode.Free else 42.0)
	weapon_anchor.rotation = orientation


# Overrides
func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return

	Game.unregister_player_character(self)

func ready_deferred() -> void:
	if Engine.is_editor_hint():
		return

	_max_velocity = Vector2(max_horizontal_velocity_ground, max_vertical_velocity)

	get_dash_effect_timer().wait_time = 1 / 60.0

	var counter_force_timer = get_counter_force_timer()
	counter_force_timer.wait_time = counter_force_duration
	counter_force_timer.one_shot = true

	var counter_force_input_timer = get_counter_force_input_timer()
	counter_force_input_timer.wait_time = counter_force_input_window
	counter_force_input_timer.one_shot = true

	_update_weapon_anchor()
	_update_collider()
	select_weapon(null, 0)

	Game.register_player_character(self)

	get_state_machine().initialize()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var closest_dist := 0.0
	var closest_enemy = null
	for enemy in Game.get_onscreen_enemies():
		var dist = (enemy.global_transform.origin - global_transform.origin).length()
		if dist < closest_dist or not closest_enemy:
			closest_dist = dist
			closest_enemy = enemy
	_closest_enemy = closest_enemy

func _get_up_vector() -> Vector2:
	if _gravity_direction > 0 and check_on_floor():
		_cached_up_vector = _floor_normal
		return _floor_normal

	if _gravity_direction < 0 and check_on_ceiling():
		_cached_up_vector = _ceiling_normal
		return _ceiling_normal

	return Vector2.UP

func _get_right_vector() -> Vector2:
	return _get_up_vector().rotated(PI * 0.5) * _gravity_direction

# Utility functions
func handle_input(event: InputEvent) -> void:
	get_state_machine().fire_input_event(event)

func init_signals() -> void:
	var weapons = _get_weapons()
	var initial_signals := {
		"health_changed": _health,
		"max_health_changed": max_health,
		"ammo_changed": weapons[weapon_type]._ammo,
		"max_ammo_changed": weapons[weapon_type].max_ammo,
		"weapon_changed": weapon_type
	}

	for key in initial_signals:
		emit_signal(key, initial_signals[key])

# Guards
func check_on_ground() -> bool:
	assert(_gravity_direction != 0)
	if _gravity_direction > 0:
		return check_on_floor()
	else:
		return check_on_ceiling()

func wish_vector_against_velocity() -> bool:
	return sign(_wish_vector.x) != sign(_velocity.x)

func wants_crouch() -> bool:
	return _wish_vector.y > 0 if _gravity_direction > 0 else _wish_vector.y < 0

# Internal Transitions
func accelerate_base(delta: float) -> void:
	var acceleration = base_acceleration
	_add_velocity(_get_right_vector() * _wish_vector.x * acceleration * delta)

func accellerate_turn(delta: float) -> void:
	var acceleration = turn_acceleration
	_add_velocity(_get_right_vector() * _wish_vector.x * acceleration * delta)

func apply_gravity(delta: float) -> void:
	var gravity_force = -_get_up_vector() * gravity * _gravity_direction * delta
	_add_velocity(gravity_force)

func reset_crouch_factor() -> void:
	_set_crouch_factor(0.0)

func integrate_crouch_factor(delta: float) -> void:
	_set_crouch_factor(min(_crouch_factor + delta * crouch_speed, 1.0))


func start_dash_timer() -> void:
	get_dash_timer().start()

func play_zero_teleport_audio() -> void:
	get_zero_teleport_audio().play()

func play_phoenix_force_audio() -> void:
	get_phoenix_force_audio().play()

func apply_dash_velocity(_delta: float) -> void:
	if check_on_ground():
		_velocity = _get_right_vector() * facing * dash_velocity
	else:
		_velocity.x = facing * dash_velocity
		_velocity.y = 0.0

func apply_initial_knockback_velocity() -> void:
	_velocity = Vector2(0.0, -100.0)

func apply_horizontal_knockback_velocity(_delta: float) -> void:
	_velocity.x = sign(_knockback_normal.x) * knockback_velocity

func _start_dash_recovery_timer() -> void:
	get_dash_recovery_timer().start()

func start_jump_timer() -> void:
	get_jump_timer().start()

func stop_jump_timer() -> void:
	get_jump_timer().stop()

func start_tuck_roll_jump_timer() -> void:
	get_tuck_roll_jump_timer().start()

func is_tuck_roll_jump_finished() -> bool:
	return get_tuck_roll_jump_timer().is_stopped()

func apply_vertical_velocity_jump() -> void:
	_velocity.y = -max_vertical_velocity * _gravity_direction

func integrate_tuck_roll_factor(delta: float) -> void:
	_tuck_roll_factor += delta * tuck_roll_speed

func reset_tuck_roll_factor() -> void:
	_tuck_roll_factor = 0.0

func set_max_horizontal_velocity(new_max_horizontal_velocity: float) -> void:
	if _max_velocity.x != new_max_horizontal_velocity:
		_max_velocity.x = new_max_horizontal_velocity
	_clamp_velocity()

func set_max_vertical_velocity(new_max_vertical_velocity: float) -> void:
	if _max_velocity.y != new_max_vertical_velocity:
		_max_velocity.y = new_max_vertical_velocity
	_clamp_velocity()

func apply_max_horizontal_velocity_grounded() -> void:
	set_max_horizontal_velocity(max_horizontal_velocity_ground)

func apply_max_horizontal_velocity_crouching() -> void:
	set_max_horizontal_velocity(0.0)

func apply_max_horizontal_velocity_dying() -> void:
	set_max_horizontal_velocity(0.0)

func apply_max_horizontal_velocity_airborne() -> void:
	set_max_horizontal_velocity(max_horizontal_velocity_air)

func apply_max_horizontal_velocity_hover() -> void:
	set_max_horizontal_velocity(max_horizontal_velocity_hover)

func apply_max_vertical_velocity_grounded() -> void:
	set_max_vertical_velocity(0.0)

func apply_max_vertical_velocity_airborne() -> void:
	set_max_vertical_velocity(max_vertical_velocity)

func apply_max_vertical_velocity_hover() -> void:
	set_max_vertical_velocity(0.0)

func apply_max_vertical_velocity_dying() -> void:
	set_max_vertical_velocity(0.0)


func start_refire_timer() -> void:
	var weapons = _get_weapons()
	if weapons[weapon_type].has_ammo():
		weapons[weapon_type].start_refire_timer()
	else:
		get_no_force().start_refire_timer()

func stop_refire_timer() -> void:
	var weapons = _get_weapons()
	if weapons[weapon_type].has_ammo():
		weapons[weapon_type].stop_refire_timer()
	else:
		get_no_force().stop_refire_timer()

func start_dash_effect_timer() -> void:
	get_dash_effect_timer().start()

func stop_dash_effect_timer() -> void:
	get_dash_effect_timer().stop()

func integrate_weapon_wheel(delta: float, inward: bool) -> void:
	_weapon_wheel_factor += weapon_wheel_speed * delta * (1.0 if inward else -1.0)
	_weapon_wheel_factor = clamp(_weapon_wheel_factor, 0.0, 1.0)

func reset_weapon_wheel() -> void:
	_weapon_wheel_factor = 0.0

func select_weapon(_event: InputEvent, offset: int) -> void:
	var weapons = _get_weapons()
	if weapons[weapon_type].is_connected("ammo_changed", self, "ammo_changed"):
		weapons[weapon_type].disconnect("ammo_changed", self, "ammo_changed")

	if weapons[weapon_type].is_connected("ammo_depleted", self, "ammo_depleted"):
		weapons[weapon_type].disconnect("ammo_depleted", self, "ammo_depleted")

	weapon_type = posmod(weapon_type + offset, WeaponType.keys().size())
	emit_signal("weapon_changed", weapon_type)
	emit_signal("ammo_changed", weapons[weapon_type]._ammo)
	weapons[weapon_type].connect("ammo_changed", self, "ammo_changed")
	weapons[weapon_type].connect("ammo_depleted", self, "ammo_depleted")

func ammo_changed(new_ammo: float) -> void:
	emit_signal("ammo_changed", new_ammo)

func ammo_depleted() -> void:
	var weapons = _get_weapons()
	weapons[weapon_type].stop_refire_timer()
	get_no_force().start_refire_timer()

func integrate_weapon_wheel_offset(delta: float) -> void:
	var wheel_delta = weapon_type - _weapon_wheel_offset
	if wheel_delta > 4.0:
		_weapon_wheel_offset += 6.0
	elif wheel_delta < -4.0:
		_weapon_wheel_offset -= 6.0
	else:
		var wheel_offset_delta = sign(wheel_delta) * weapon_wheel_offset_speed * delta
		var delta_sign = sign(wheel_offset_delta)
		var delta_mag = min(abs(wheel_offset_delta), abs(wheel_delta))
		_weapon_wheel_offset = _weapon_wheel_offset + delta_mag * delta_sign

func unlock_weapon_recharge() -> void:
	var weapons = _get_weapons()
	weapons[weapon_type].recharge_locked = false

func lock_weapon_recharge() -> void:
	var weapons = _get_weapons()
	weapons[weapon_type].recharge_locked = true


func start_damage_timer() -> void:
	get_damage_timer().start()

func start_invulnerability_timer() -> void:
	get_invulnerability_timer().start()

func start_dying_timer() -> void:
	get_dying_timer().start()

func spawn_death_effect() -> void:
	var trx = global_transform
	trx.origin += collider_radius * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0)
	var _effect = DragonflyUtil.spawn_effect(get_parent(), DragonflyEffects.Hitspark, trx, 0.0)

func dead() -> void:
	get_parent().call_deferred("remove_child", self)
	call_deferred("queue_free")


func start_counter_force_input_timer() -> void:
	get_counter_force_input_timer().start()

func stop_counter_force_input_timer() -> void:
	get_counter_force_input_timer().stop()

func is_counter_force_ready() -> bool:
	return not get_counter_force_input_timer().is_stopped()


func start_counter_force_timer() -> void:
	get_counter_force_timer().start()

func stop_counter_force_timer() -> void:
	get_counter_force_timer().stop()


func fire_counter_force() -> void:
	for child in get_parent().get_children():
		if child is Projectile and child._cached_source == self:
			child.destroy(false)

	var orientation = 0.0
	if facing == -1.0:
		orientation = PI
	var trx = global_transform
	trx.origin.y += -12.0 * _gravity_direction
	trx.origin += trx.x.rotated(orientation) * 28.0
	var _projectile = DragonflyUtil.spawn_projectile(self, get_parent(), DragonflyProjectiles.CounterForce, trx, orientation)
	get_counter_force_audio().play()

func apply_counter_force_recoil_ground(_delta: float) -> void:
	_velocity = counter_force_recoil_ground * Vector2(facing, _gravity_direction)

func apply_counter_force_recoil_air(_delta: float) -> void:
	_velocity = counter_force_recoil_air * Vector2(facing, _gravity_direction)


# Business Logic
func spawn_dash_effect() -> void:
	var trx = global_transform
	trx.origin += Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0) * Vector2(collider_radius, 0.5 * crouch_height + standing_height + collider_radius)

	var effect
	if get_hitbox().active:
		effect = DragonflyEffects.Hitspark
	else:
		effect = DragonflyEffects.DashLine

	var _effect = DragonflyUtil.spawn_effect(get_parent(), effect, trx, 0.0)

func take_damage(amount: int, normal: Vector2, _force: float) -> void:
	if not get_invulnerability_timer().is_stopped():
		return

	if _health > 1 and _health - amount <= 0:
		_set_health(1)
	else:
		_set_health(_health - int(min(amount, _health)))

	TimeManager.hitstop(take_damage_hitstop)

	if _health > 0:
		_knockback_normal = normal
		$AlienSoldierStateMachine.fire_custom_event("TakeDamage")
	else:
		$AlienSoldierStateMachine.fire_custom_event("SetDying")

func give_damage(_amount: int, _normal: Vector2, _force: float) -> void:
	TimeManager.hitstop(give_damage_hitstop)

func enable_hurtbox() -> void:
	get_hurtbox().set_deferred("active", true)

func disable_hurtbox() -> void:
	get_hurtbox().set_deferred("active", false)


func enable_hitbox() -> void:
	get_hitbox().set_deferred("active", true)

func disable_hitbox() -> void:
	get_hitbox().set_deferred("active", false)


func enable_itembox() -> void:
	get_itembox().set_deferred("active", true)

func disable_itembox() -> void:
	get_itembox().set_deferred("active", false)


func is_phoenix_force_ready() -> bool:
	return _health == max_health

func consume_phoenix_force_cost() -> void:
	_set_health(_health - phoenix_force_cost)


func take_healing(amount) -> void:
	_health += int(min(amount, max_health - _health))
	emit_signal("health_changed", _health)

func reset_horizontal_velocity() -> void:
	_velocity.x = 0.0

func cache_fixed_aim() -> void:
	_cached_facing = facing
	_cached_aim = _aim
	_has_cached_fixed_aim = true

func try_restore_fixed_aim() -> void:
	if _has_cached_fixed_aim:
		set_facing(_cached_facing)
		set_aim(_cached_aim)
		clear_cached_fixed_aim()

func clear_cached_fixed_aim() -> void:
	_cached_facing = 0
	_cached_aim = 0
	_has_cached_fixed_aim = false
