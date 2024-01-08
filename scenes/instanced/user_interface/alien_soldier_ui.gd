class_name AlienSoldierUI
extends Control

signal load_game_scene(game_scene_path, ui_scene_path)
signal quit_game()

func get_node_checked(node_path: String) -> Node:
	return get_node(node_path) if has_node(node_path) else null

func get_stat_readout() -> Control:
	return get_node_checked("Header/HBoxContainer/StatReadout") as Control

func get_weapon_readout() -> Control:
	return get_node_checked("Header/HBoxContainer/VBoxContainer/WeaponReadout") as Control

func get_pause_menu_container() -> Control:
	return get_node_checked("Viewport/PauseMenuContainer") as Control

func get_menu_switch_container() -> Control:
	return get_node_checked("Viewport/PauseMenuContainer/MenuSwitchContainer") as Control

func ready_deferred() -> void:
	Game.register_game_ui(self)

func _exit_tree() -> void:
	Game.unregister_game_ui(self)

func player_health_changed(new_health: int) -> void:
	var stat_readout = get_stat_readout()
	assert(stat_readout)
	stat_readout.set_value_player(new_health)

func player_max_health_changed(new_max_health: int) -> void:
	var stat_readout = get_stat_readout()
	assert(stat_readout)
	stat_readout.set_total_player(new_max_health)

func player_ammo_changed(new_ammo: int) -> void:
	var stat_readout = get_stat_readout()
	assert(stat_readout)
	stat_readout.set_value_force(new_ammo)

func player_max_ammo_changed(new_max_ammo: int) -> void:
	var stat_readout = get_stat_readout()
	assert(stat_readout)
	stat_readout.set_total_force(new_max_ammo)

func player_weapon_changed(new_weapon: int) -> void:
	var weapon_readout = get_weapon_readout()
	assert(weapon_readout)
	weapon_readout.set_active_weapon(new_weapon)

func boss_health_changed(new_health: int) -> void:
	var stat_readout = get_stat_readout()
	assert(stat_readout)
	stat_readout.set_value_enemy(new_health)

func boss_max_health_changed(new_max_health: int) -> void:
	var stat_readout = get_stat_readout()
	assert(stat_readout)
	stat_readout.set_total_enemy(new_max_health)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	if event.is_action_pressed("ui_menu"):
		toggle_pause_menu()


func toggle_pause_menu() -> void:
	if pause_menu_visible():
		hide_pause_menu()
	else:
		show_pause_menu()

func pause_menu_visible() -> bool:
	var pause_menu = get_pause_menu_container()
	assert(pause_menu)
	return pause_menu.visible

func show_pause_menu() -> void:
	var pause_menu = get_pause_menu_container()
	var menu_switch_container = get_menu_switch_container()
	assert(pause_menu)
	assert(menu_switch_container)
	pause_menu.visible = true
	menu_switch_container.set_active_control("PauseMenu")
	menu_switch_container.grab_focus()
	TimeManager.pause()

func hide_pause_menu() -> void:
	var pause_menu = get_pause_menu_container()
	assert(pause_menu)
	pause_menu.visible = false
	TimeManager.unpause()

func main_menu() -> void:
	hide_pause_menu()
	emit_signal("load_game_scene", "", DragonflyConstants.get_ui_scene_path(DragonflyConstants.UIScenes.TitleScreen), true)

func quit_game() -> void:
	emit_signal("quit_game")

func scene_selected(game_scene_path: String, ui_scene_path: String) -> void:
	hide_pause_menu()
	emit_signal("load_game_scene", game_scene_path, ui_scene_path, false, true)
