class_name Enemy
extends Actor
tool

signal dying()

var health := 60
var hit_flash_speed = 10.0
var dying_speed = 3.0

var _hit_flash_factor := 0.0

var _dying := false
var _dying_factor := 0.0

func get_hitbox() -> Area2D:
	return $Hitbox as Area2D

func get_hurtbox() -> Area2D:
	return $Hurtbox as Area2D

func get_aggro_box() -> Area2D:
	return $AggroBox as Area2D

func get_dying_timer() -> Timer:
	return $DyingTimer as Timer

func _process(delta: float) -> void:
	if _hit_flash_factor > 0:
		_hit_flash_factor -= min(hit_flash_speed * delta, _hit_flash_factor)
		update()

func can_see_player() -> bool:
	var player = Game.get_player()
	assert(player)

	var direct_space_state = get_world_2d().direct_space_state
	var result = direct_space_state.intersect_ray(global_transform.origin, player.global_transform.origin, [], DragonflyConstants.CollisionLayers.Environment, true, true)
	if result.empty():
		return true

	return false


func take_damage(amount: int, _normal: Vector2, _force: float) -> void:
	health -= amount
	_hit_flash_factor = 1.0
	if health < 0 and not _dying:
		die()

func die() -> void:
	get_hitbox().collision_mask = 0
	get_hurtbox().collision_layer = 0
	emit_signal("dying")
	_dying = true


func state_machine_custom_event(_args: Array) -> void:
	pass

func start_dying_timer() -> void:
	get_dying_timer().start()

func spawn_health_pickup() -> void:
	var health_pickup_scene = DragonflyItems.HealthPickup
	var health_pickup = health_pickup_scene.instance()
	health_pickup.type = HealthPickup.Type.Small
	get_parent().call_deferred("add_child", health_pickup)
	var trx = Transform2D()
	trx.origin = global_transform.origin
	health_pickup.set_deferred("global_transform", trx)

func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()
