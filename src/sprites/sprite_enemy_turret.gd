extends Node2D
tool

func get_target_turret() -> EnemyTurret:
	return get_node("../../") as EnemyTurret

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	var target_turret = get_target_turret()
	if not target_turret:
		return

	var aim_timer = target_turret.get_aim_timer()
	if not aim_timer:
		return

	var quarter_size = target_turret.size * 0.25

	draw_polygon(
		PoolVector2Array([
			Vector2(-1, -1) * target_turret.size,
			Vector2(1, -1) * target_turret.size,
			Vector2(1, 1) * target_turret.size,
			Vector2(-1, 1) * target_turret.size,
		]),
		PoolColorArray([
			Color.gray,
		])
	)

	draw_circle(Vector2(0, quarter_size.y) + Vector2(-1, -1) * target_turret.size.x, quarter_size.y, Color.darkgray)
	draw_circle(Vector2(0, quarter_size.y) + Vector2(1, -1) * target_turret.size.x, quarter_size.y, Color.darkgray)

	var shortest = min(quarter_size.x, quarter_size.y)
	draw_circle(Vector2.UP * shortest, shortest * 2.0, Color.darkred)
	draw_circle(Vector2.UP * shortest, shortest * 1.5, Color.black)
	draw_circle(Vector2.UP * shortest + target_turret.global_transform.basis_xform_inv(target_turret._aim) * (1.0 - (aim_timer.time_left / aim_timer.wait_time)) * shortest, shortest * 0.5, Color.white)
