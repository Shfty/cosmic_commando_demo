class_name Effect
extends Area2D

export(float) var duration = 0.15
export(float) var orientation := 0.0

var _timer = 0.0
var _destroyed := false

func _process(delta: float) -> void:
	if not is_inside_tree():
		return

	if duration >= 0:
		_timer -= min(delta, _timer)

func _physics_process(_delta: float) -> void:
	if _timer == 0:
		destroy()

func _ready() -> void:
	_timer = duration
	_destroyed = false
	orientation = 0.0

func destroy() -> void:
	if _destroyed:
		return

	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	PackedScenePool.finalize_instance(self)

	_destroyed = true
