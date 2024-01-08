extends Area2D

func _init() -> void:
	var connect_result_entered = connect("area_entered", self, "area_entered")
	assert(connect_result_entered == OK)

	var connect_result_exited = connect("area_exited", self, "area_exited")
	assert(connect_result_exited == OK)

func area_entered(area: Area2D) -> void:
	var enemy := area.get_parent()
	assert(enemy is Enemy)
	Game.register_onscreen_enemy(enemy)

func area_exited(area: Area2D) -> void:
	var enemy := area.get_parent()
	assert(enemy is Enemy)
	Game.unregister_onscreen_enemy(enemy)
