class_name ControlSettingsVBox
extends VBoxContainer
tool

var action_blacklist := PoolStringArray([
	"ui_focus_next",
	"ui_focus_prev",
	"ui_select",
	"ui_up",
	"ui_down",
	"ui_page_down",
	"ui_end",
	"ui_cancel",
	"ui_home",
	"ui_left",
	"ui_right",
	"ui_accept",
	"ui_page_up",
	"ui_menu"
])

func _ready() -> void:
	for child in get_children():
		if child.has_meta("control_settings_vbox_child"):
			remove_child(child)
			child.queue_free()

	var input_map_actions = InputMap.get_actions()
	input_map_actions.sort()
	for action in input_map_actions:
		if action in action_blacklist:
			continue

		var label = Label.new()
		label.text = action
		label.set_meta("control_settings_vbox_child", true)
		add_child(label)
