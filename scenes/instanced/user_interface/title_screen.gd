class_name TitleScreen
extends Control
tool

signal load_game_scene(game_scene_path, ui_scene_path)
signal quit_game()

func open_link(path: String) -> void:
	var _result = OS.shell_open(path)

func start_demo() -> void:
	scene_selected("res://scenes/level_select/demo_scene.tscn", DragonflyConstants.get_ui_scene_path(DragonflyConstants.UIScenes.Game))

func quit_game() -> void:
	emit_signal("quit_game")

func scene_selected(game_scene_path: String, ui_scene_path: String) -> void:
	emit_signal("load_game_scene", game_scene_path, ui_scene_path, false, true)
