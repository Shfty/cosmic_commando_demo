class_name PhysicsInterpolator2D
extends Node2D
tool

export(bool) var active := true setget set_active
export(bool) var debug_draw := false

func set_active(new_active: bool) -> void:
	if active != new_active:
		active = new_active
		update_active()

var _seconds_per_frame := 0.0

var _initial_update := false

var _from_transform := Transform2D.IDENTITY
var _to_transform := Transform2D.IDENTITY

var _timestamp := 0.0

func _init() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	_seconds_per_frame = 1.0 / float(Engine.iterations_per_second)

func update_active() -> void:
	set_process(active)
	set_physics_process(active)

func _ready() -> void:
	_timestamp = 0.0
	_initial_update = true
	visible = false

	for child in get_children():
		child.global_transform = Transform.IDENTITY

	update_active()
	set_notify_transform(true)

func _notification(what: int) -> void:
	if _initial_update:
		if what == NOTIFICATION_TRANSFORM_CHANGED:
			_from_transform = global_transform
			_to_transform = global_transform
			set_notify_transform(false)
			_initial_update = false


func _physics_process(_delta: float) -> void:
	_timestamp = OS.get_ticks_usec()

	if _initial_update:
		return

	_from_transform = _to_transform
	_to_transform = global_transform

func _process(_delta: float) -> void:
	if _initial_update:
		return

	update_transform()

	if debug_draw:
		update()

func _draw() -> void:
	if not debug_draw:
		return

	if _initial_update:
		return

	var from = global_transform.xform_inv(_from_transform.origin)
	var to = global_transform.xform_inv(_to_transform.origin)
	draw_circle(from, 2.0, Color.green)
	draw_circle(to, 2.0, Color.red)
	draw_line(from, to, Color.yellow, 1.0, true)

func update_transform() -> void:
	var delta = OS.get_ticks_usec() - _timestamp
	var delta_ms = delta * 0.001
	var delta_sec = delta_ms * 0.001
	if delta_sec == 0.0:
		return

	for child in get_children():
		child.global_transform = _from_transform.interpolate_with(_to_transform,  delta_sec / _seconds_per_frame)
	visible = true
