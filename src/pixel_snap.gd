class_name PixelSnap
extends Node2D
tool

enum ProcessMode {
	Process,
	PhysicsProcess
}

enum Mode {
	Round,
	Floor,
	Ceil
}

export(Mode) var mode = Mode.Round
export(ProcessMode) var process_mode = ProcessMode.Process setget set_process_mode

func set_process_mode(new_process_mode: int) -> void:
	if process_mode != new_process_mode:
		process_mode = new_process_mode
		_update_process_mode()

func _ready() -> void:
	_update_process_mode()

func _update_process_mode() -> void:
	match process_mode:
		ProcessMode.Process:
			set_process(true)
			set_physics_process(false)
		ProcessMode.PhysicsProcess:
			set_process(false)
			set_physics_process(true)

func _process(_delta: float) -> void:
	_update_snap()

func _physics_process(_delta: float) -> void:
	_update_snap()

func _update_snap() -> void:
	for child in get_children():
		match mode:
			Mode.Floor:
				child.global_transform.origin = global_transform.origin.floor()
			Mode.Round:
				child.global_transform.origin = global_transform.origin.round()
			Mode.Ceil:
				child.global_transform.origin = global_transform.origin.ceil()
