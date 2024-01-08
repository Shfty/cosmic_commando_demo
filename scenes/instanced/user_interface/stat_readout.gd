extends Control
tool

export(int) var value_player := 512 setget set_value_player
export(int) var value_force := 1000 setget set_value_force
export(int) var value_enemy := 3584 setget set_value_enemy

export(int) var total_player := 512 setget set_total_player
export(int) var total_force := 1000 setget set_total_force
export(int) var total_enemy := 3584 setget set_total_enemy

func get_node_checked(path: String) -> Node:
	return get_node(path) if has_node(path) else null

func get_value_player() -> Control:
	return get_node_checked("HBoxLabel/VBoxValue/ValuePlayer") as Control

func get_value_force() -> Control:
	return get_node_checked("HBoxLabel/VBoxValue/ValueForce") as Control

func get_value_enemy() -> Control:
	return get_node_checked("HBoxLabel/VBoxValue/ValueEnemy") as Control

func get_total_player() -> Control:
	return get_node_checked("HBoxLabel/VBoxTotal/TotalPlayer") as Control

func get_total_force() -> Control:
	return get_node_checked("HBoxLabel/VBoxTotal/TotalForce") as Control

func get_total_enemy() -> Control:
	return get_node_checked("HBoxLabel/VBoxTotal/TotalEnemy") as Control

func get_flash_timer() -> Timer:
	return get_node_checked("FlashTimer") as Timer

func get_flash_player() -> Control:
	return get_node_checked("HBoxFlash/VBoxLabel/FlashPlayer") as Control

func set_value_player(new_value_player: int) -> void:
	if value_player != new_value_player:
		value_player = new_value_player
		update_value_player()

func set_value_force(new_value_force: int) -> void:
	if value_force != new_value_force:
		value_force = new_value_force
		update_value_force()

func set_value_enemy(new_value_enemy: int) -> void:
	if value_enemy != new_value_enemy:
		value_enemy = new_value_enemy
		update_value_enemy()

func set_total_player(new_total_player: int) -> void:
	if total_player != new_total_player:
		total_player = new_total_player
		update_total_player()

func set_total_force(new_total_force: int) -> void:
	if total_force != new_total_force:
		total_force = new_total_force
		update_total_force()

func set_total_enemy(new_total_enemy: int) -> void:
	if total_enemy != new_total_enemy:
		total_enemy = new_total_enemy
		update_total_enemy()

func update_value_player() -> void:
	var _value_player = get_value_player()
	assert(_value_player)
	_value_player.value = value_player

func update_value_force() -> void:
	var _value_force = get_value_force()
	assert(_value_force)
	_value_force.value = value_force

func update_value_enemy() -> void:
	var _value_enemy = get_value_enemy()
	assert(_value_enemy)
	_value_enemy.value = value_enemy

func update_total_player() -> void:
	var _total_player = get_total_player()
	assert(_total_player)
	_total_player.value = total_player

func update_total_force() -> void:
	var _total_force = get_total_force()
	assert(_total_force)
	_total_force.value = total_force

func update_total_enemy() -> void:
	var _total_enemy = get_total_enemy()
	assert(_total_enemy)
	_total_enemy.value = total_enemy

func ready_deferred() -> void:
	update_value_player()
	update_value_force()
	update_value_enemy()
	update_total_player()
	update_total_force()
	update_total_enemy()

	var flash_timer = get_flash_timer()
	assert(flash_timer)
	flash_timer.connect("timeout", self, "flash_timeout")
	flash_timer.wait_time = 1.0 / 30.0
	flash_timer.start()

func flash_timeout() -> void:
	var _value_player = get_value_player()
	var _total_player = get_total_player()
	var _flash_player = get_flash_player()

	if _value_player.value == _total_player.value:
		if _flash_player.modulate == Color.white:
			_flash_player.modulate = Color.transparent
		else:
			_flash_player.modulate = Color.white
	else:
		_flash_player.modulate = Color.transparent
