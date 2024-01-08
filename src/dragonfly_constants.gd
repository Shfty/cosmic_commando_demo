class_name DragonflyConstants

enum CollisionLayers {
	Environment = 1,
	PlayerHurtbox = 4,
	PlayerItembox = 8,
	EnemyHurtbox = 32,
	CameraEnvironment = 128
	CameraAggro = 256
}

enum UIScenes {
	TitleScreen,
	Game
}

const UI_SCENE_PATHS := {
	UIScenes.TitleScreen: "res://scenes/instanced/user_interface/title_screen.tscn",
	UIScenes.Game: "res://scenes/instanced/user_interface/alien_soldier_ui.tscn"
}

static func get_ui_scene_path(ui_scene: int) -> String:
	return UI_SCENE_PATHS[ui_scene]
