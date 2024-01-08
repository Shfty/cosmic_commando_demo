class_name EnemyMob
extends Enemy
tool

var sprint_acceleration := 800.0

func _init() -> void:
	deceleration = 400.0
	_max_velocity = Vector2(200, 200)

func ready_deferred() -> void:
	$EnemyStateMachineMob.initialize()

func choose_sprint_direction() -> void:
	var player = Game.get_player()
	assert(player)

	var delta = player.global_transform.origin - global_transform.origin
	facing = int(sign(delta.x))

func integrate_sprint(delta: float) -> void:
	var normal = Vector2.RIGHT * facing
	var accel = sprint_acceleration * delta
	_add_velocity(normal * accel)

func take_damage(amount: int, normal: Vector2, force: float) -> void:
	.take_damage(amount, normal, force)
	if health <= 0:
		facing = int(sign(-normal.x))

func give_damage(_amount: int, normal: Vector2, _force: float) -> void:
	facing = int(sign(normal.x))
	die()

func die() -> void:
	.die()
	collision_mask = 0
	_velocity = Vector2(-facing * 1000, -1000)

func spawn_death_effect(_delta: float) -> void:
	var trx = global_transform
	trx.origin += Vector2(16, 32) * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0)
	var _effect = DragonflyUtil.spawn_effect(get_parent(), DragonflyEffects.Hitspark, trx, 0.0)
