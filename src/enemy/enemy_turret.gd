class_name EnemyTurret
extends Enemy
tool

var size := Vector2(16.0, 16.0)

var _aim: Vector2

func get_aim_timer() -> Timer:
	return $AimTimer as Timer

func get_refire_timer() -> Timer:
	return $RefireTimer as Timer

func ready_deferred() -> void:
	$EnemyStateMachineTurret.initialize()

# Business Logic
func start_aim_timer() -> void:
	get_aim_timer().start()

func update_aim(_delta: float) -> void:
	var player_instance = Game.get_player()
	if player_instance:
		_aim = (player_instance.global_transform.origin - global_transform.origin).normalized()


func start_refire_timer() -> void:
	get_refire_timer().start()

func fire() -> void:
	var trx = global_transform
	trx.origin -= trx.y * 4.0
	var _projectile = DragonflyUtil.spawn_projectile(get_parent(), get_parent(), DragonflyProjectiles.EnemyProjectile, trx, atan2(_aim.y, _aim.x))


func spawn_death_effect(_delta: float) -> void:
	var trx = global_transform
	trx.origin += size * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0)
	var _effect = DragonflyUtil.spawn_effect(get_parent(), DragonflyEffects.Hitspark, trx, 0.0)
