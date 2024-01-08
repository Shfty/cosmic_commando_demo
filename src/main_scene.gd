extends Control
tool

export(PackedScene) var default_game_scene: PackedScene
export(PackedScene) var default_ui_scene: PackedScene

var base_size := Vector2(400, 224)
var ui_height := 28
var time_scale := 1.0

onready var _viewport_container := $ViewportContainer as ViewportContainer
onready var _game_viewport := $ViewportContainer/GameViewport as Viewport
onready var _game_scene_loader := $ViewportContainer/GameViewport/GameSceneLoader as SceneLoader
onready var _ui_scene_loader := $ViewportContainer/GameViewport/UILayer/UISceneLoader as SceneLoader
onready var _loading_screen = $ViewportContainer/GameViewport/UILayer/LoadingScreen
onready var _ui_focus_audio := $UIFocusAudio as AudioStreamPlayer

func _init() -> void:
	var connect_result = connect("resized", self, "resized")
	assert(connect_result == OK)
	OS.min_window_size = base_size
	Engine.time_scale = time_scale

func _ready() -> void:
	resized()

	var game_scene_path: String
	var ui_scene_path: String

	if default_game_scene:
		game_scene_path = default_game_scene.get_path()

	if default_ui_scene:
		ui_scene_path = default_ui_scene.get_path()

	load_scenes(game_scene_path, ui_scene_path, true)

func resized() -> void:
	if not _viewport_container:
		return

	if not _game_viewport:
		return

	var scale_factor = (rect_size / base_size).floor()
	var shortest_scale = min(scale_factor.x, scale_factor.y)
	var new_size = shortest_scale * base_size

	_viewport_container.rect_scale = Vector2(shortest_scale, shortest_scale)
	_viewport_container.rect_position.x = (rect_size.x - new_size.x) * 0.5
	_viewport_container.rect_position.y = (rect_size.y - new_size.y) * 0.5

	_game_viewport.size = base_size

func show_loading_screen() -> void:
	_loading_screen.reset_progress()
	_loading_screen.show()

func hide_loading_screen() -> void:
	_loading_screen.hide()

func quit_game() -> void:
	get_tree().quit()

var _game_scene_loaded := false
var _ui_scene_loaded := false
var _wait_for_input := false
var _waiting_for_input := false

func load_scenes(game_scene_path: String, ui_scene_path: String, hide_loading_bars: bool = false, wait_for_input: bool = false) -> void:
	_game_scene_loaded = false
	_ui_scene_loaded = false
	_loading_screen.hide_loading_bars = hide_loading_bars
	_loading_screen.corner_widget = LoadingScreen.CornerWidget.Spinner
	_wait_for_input = wait_for_input
	_waiting_for_input = false

	TimeManager.pause()
	show_loading_screen()

	yield(_loading_screen, "transition_finished")

	if game_scene_path.empty():
		_game_load_progress = 1.0
		_game_instance_scene_progress = 1.0
		_game_populate_tree_progress = 1.0
		_game_scene_loaded = true
	else:
		_game_load_progress = 0.0
		_game_instance_scene_progress = 0.0
		_game_populate_tree_progress = 0.0
		var connect_result = _game_scene_loader.connect("populate_tree_finished", self, "game_scene_loaded", [], CONNECT_ONESHOT)
		assert(connect_result == OK)
		_game_scene_loader.load_scene(game_scene_path)

	if ui_scene_path.empty():
		_ui_load_progress = 1.0
		_ui_instance_scene_progress = 1.0
		_ui_populate_tree_progress = 1.0
		_ui_scene_loaded = true
	else:
		_ui_load_progress = 0.0
		_ui_instance_scene_progress = 0.0
		_ui_populate_tree_progress = 0.0
		var connect_result = _ui_scene_loader.connect("populate_tree_finished", self, "ui_scene_loaded", [], CONNECT_ONESHOT)
		assert(connect_result == OK)
		_ui_scene_loader.load_scene(ui_scene_path)

	check_scenes_loaded()


func game_scene_loaded() -> void:
	_game_scene_loaded = true
	check_scenes_loaded()

func ui_scene_loaded() -> void:
	_ui_scene_loaded = true
	check_scenes_loaded()

func check_scenes_loaded() -> void:
	if _game_scene_loaded and _ui_scene_loaded:
		scenes_loaded()

func scenes_loaded() -> void:
	var ui_instance = _ui_scene_loader.get_scene_instance()

	if ui_instance.has_signal("load_game_scene"):
		var connect_result = ui_instance.connect("load_game_scene", self, "load_scenes", [], CONNECT_PERSIST)
		assert(connect_result == OK)

	if ui_instance.has_signal("quit_game"):
		var connect_result = ui_instance.connect("quit_game", self, "quit_game", [], CONNECT_PERSIST)
		assert(connect_result == OK)

	if _wait_for_input:
		_waiting_for_input = true
		_loading_screen.corner_widget = LoadingScreen.CornerWidget.PressButtonArrow
	else:
		start_scene()

func start_scene() -> void:
	hide_loading_screen()
	TimeManager.unpause()

func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_for_input:
		return

	if event is InputEventKey or event is InputEventJoypadButton and event.pressed:
		start_scene()
		_waiting_for_input = false

var _game_load_progress := 0.0
var _ui_load_progress := 0.0

var _game_instance_scene_progress := 0.0
var _ui_instance_scene_progress := 0.0

var _game_populate_tree_progress := 0.0
var _ui_populate_tree_progress := 0.0

func set_game_load_progress(progress: float) -> void:
	_game_load_progress = progress
	update_load_progress()

func set_ui_load_progress(progress: float) -> void:
	_ui_load_progress = progress
	update_load_progress()

func update_load_progress() -> void:
	_loading_screen.set_loading_progress((_game_load_progress + _ui_load_progress) * 0.5)

func set_game_instance_scene_progress(progress: float) -> void:
	_game_instance_scene_progress = progress
	update_instance_scene_progress()

func set_ui_instance_scene_progress(progress: float) -> void:
	_ui_instance_scene_progress = progress
	update_instance_scene_progress()

func update_instance_scene_progress() -> void:
	_loading_screen.set_instancing_progress((_game_instance_scene_progress + _ui_instance_scene_progress) * 0.5)

func set_game_populate_tree_progress(progress: float) -> void:
	_game_populate_tree_progress = progress
	update_populate_tree_progress()

func set_ui_populate_tree_progress(progress: float) -> void:
	_ui_populate_tree_progress = progress
	update_populate_tree_progress()

func update_populate_tree_progress() -> void:
	_loading_screen.set_populating_progress((_game_populate_tree_progress + _ui_populate_tree_progress) * 0.5)
