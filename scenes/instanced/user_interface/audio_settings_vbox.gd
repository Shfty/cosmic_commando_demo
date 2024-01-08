class_name AudioSettingsVBox
extends VBoxContainer
tool

func _ready() -> void:
	for child in get_children():
		if child.has_meta("audio_settings_vbox_child"):
			remove_child(child)
			child.queue_free()

	for i in range(0, AudioServer.bus_count):
		var label = Label.new()
		label.text = AudioServer.get_bus_name(i)
		label.set_meta("audio_settings_vbox_child", true)
		add_child(label)
