extends Node2D
tool

func get_target_mob() -> EnemyMob:
	return get_node("../../../") as EnemyMob

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	var target_mob = get_target_mob()
	if not target_mob:
		return

	var size = Vector2(16, 32)
	var quarter_size = size * 0.25

	draw_polygon(
		PoolVector2Array([
			Vector2(-1, -1) * size,
			Vector2(1, -1) * size,
			Vector2(1, 0.8) * size,
			Vector2(-1, 0.8) * size,
		]),
		PoolColorArray([
			Color.gray,
		])
	)

	draw_circle(Vector2(0, size.y) + Vector2(-0.75, -0.5) * size.x, quarter_size.y, Color.darkgray)
	draw_circle(Vector2(0, size.y) + Vector2(0.75, -0.5) * size.x, quarter_size.y, Color.darkgray)
	draw_circle(Vector2(0, size.y) + Vector2(-0.25, -0.5) * size.x, quarter_size.y, Color.darkgray)
	draw_circle(Vector2(0, size.y) + Vector2(0.25, -0.5) * size.x, quarter_size.y, Color.darkgray)

	var shortest = min(quarter_size.x, quarter_size.y)
	draw_circle(Vector2.UP * shortest, shortest * 2.0, Color.darkred)
	draw_circle(Vector2.UP * shortest, shortest * 1.5, Color.black)
	draw_circle(Vector2.UP * shortest + Vector2.RIGHT * shortest * 0.5 * target_mob.facing, shortest * 0.5, Color.white)
