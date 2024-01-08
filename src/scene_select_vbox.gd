class_name SceneSelectVBox
extends Control
tool

signal scene_selected(game_scene_path, ui_scene_path)

const SCENE_DIRECTORY := "res://scenes/level_select"
const SCENE_EXTENSIONS := [
	"tscn",
	"scn",
	"tres"
]

func _ready() -> void:
	var dir = Directory.new()
	var open_err = dir.open(SCENE_DIRECTORY)
	if open_err:
		printerr("Error opening %s: %s" % [SCENE_DIRECTORY, open_err])
		return

	var list_dir_begin_err = dir.list_dir_begin(true, true)
	if list_dir_begin_err:
		printerr("Error beginning list dir: %s" % [list_dir_begin_err])
		return

	while true:
		var next_item = dir.get_next()
		if not next_item:
			break

		var comps = next_item.split(".")
		if comps[-1] in SCENE_EXTENSIONS:
			var button = Button.new()
			button.text = comps[0]
			button.size_flags_horizontal = SIZE_EXPAND_FILL
			button.focus_mode = Control.FOCUS_ALL
			button.action_mode = Button.ACTION_MODE_BUTTON_PRESS
			button.connect("mouse_entered", button, "grab_focus")
			button.connect("pressed", self, "_scene_selected", [SCENE_DIRECTORY + "/" + next_item])
			add_child(button)

func _scene_selected(scene_path: String) -> void:
	emit_signal("scene_selected", scene_path, DragonflyConstants.get_ui_scene_path(DragonflyConstants.UIScenes.Game))

func grab_focus() -> void:
	if get_child_count() > 0:
		get_child(0).grab_focus()
