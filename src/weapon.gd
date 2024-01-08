class_name AlienSoldierWeapon
extends Node2D

signal ready_deferred()

signal ammo_changed(new_ammo)
signal ammo_depleted()

enum FireMode {
	Free,
	Fixed
}

export(NodePath) var attach_parent_path: NodePath
export(String) var attach_offset_path: String = ".."
export(float) var fire_rate := 4
export(float) var max_ammo := 1000.0
export(int) var ammo_cost_free := 1
export(int) var ammo_cost_fixed := 3
export(float) var ammo_regen_rate := 2.0
export(PackedScene) var projectile
export(AudioStream) var fire_sound setget set_fire_sound

var recharge_locked := true setget set_recharge_locked

var fire_mode: int = FireMode.Free
onready var _ammo := max_ammo setget set_ammo

func get_node_checked(path: String) -> Node:
	return get_node(path) if has_node(path) else null

func get_refire_timer() -> Timer:
	return get_node_checked("RefireTimer") as Timer

func get_recharge_timer() -> Timer:
	return get_node_checked("RechargeTimer") as Timer

func get_fire_sound() -> AudioStreamPlayer2D:
	return get_node_checked("FireSound") as AudioStreamPlayer2D

var debug_print := false

func set_ammo(new_ammo: float) -> void:
	if _ammo != new_ammo:
		_ammo = new_ammo
		emit_signal("ammo_changed", _ammo)

func set_recharge_locked(new_recharge_locked: bool) -> void:
	if recharge_locked != new_recharge_locked:
		recharge_locked = new_recharge_locked
		var recharge_timer = get_recharge_timer()
		if recharge_timer:
			if recharge_locked:
				recharge_timer.stop()
			else:
				recharge_timer.start()

func set_fire_sound(new_fire_sound: AudioStream) -> void:
	if fire_sound != new_fire_sound:
		fire_sound = new_fire_sound
		if is_inside_tree():
			update_fire_sound()

func update_fire_sound() -> void:
	var _fire_sound = get_fire_sound()
	if _fire_sound:
		_fire_sound.stream = fire_sound

func ready_deferred() -> void:
	var refire_timer = get_refire_timer()
	refire_timer.wait_time = fire_rate / 60.0
	update_fire_sound()
	emit_signal("ready_deferred")

func _physics_process(_delta: float) -> void:
	var recharge_timer = get_recharge_timer()
	assert(recharge_timer)
	if not recharge_locked and recharge_timer.is_stopped():
		set_ammo(_ammo + min(ammo_regen_rate, max_ammo - _ammo))

func start_refire_timer() -> void:
	var refire_timer = get_refire_timer()
	assert(refire_timer)

	if debug_print:
		DebugOverlay.print_log("%s start_refire_timer" % [get_name()])

	if refire_timer.is_stopped():
		refire()
		var connect_result = refire_timer.connect("timeout", self, "refire")
		assert(connect_result == OK)
		refire_timer.start()
	elif not refire_timer.is_connected("timeout", self, "start_refire_timer"):
		var connect_result = refire_timer.connect("timeout", self, "call_deferred", ["start_refire_timer"], CONNECT_ONESHOT)
		assert(connect_result == OK)

func stop_refire_timer() -> void:
	var refire_timer = get_refire_timer()
	assert(refire_timer)

	if debug_print:
		DebugOverlay.print_log("%s stop_refire_timer" % [get_name()])

	if refire_timer.is_connected("timeout", self, "refire"):
		refire_timer.disconnect("timeout", self, "refire")
		var connect_result = refire_timer.connect("timeout", refire_timer, "stop", [], CONNECT_ONESHOT)
		assert(connect_result == OK)

	if refire_timer.is_connected("timeout", self, "call_deferred"):
		refire_timer.disconnect("timeout", self, "call_deferred")

func start_recharge_timer() -> void:
	var recharge_timer = get_recharge_timer()
	assert(recharge_timer)

	if debug_print:
		DebugOverlay.print_log("%s start_recharge_timer" % [get_name()])
	recharge_timer.start()

func refire() -> void:
	if debug_print:
		DebugOverlay.print_log("%s refire" % [get_name()])

	if has_ammo():
		consume_ammo(get_ammo_cost())
		_fire()
	else:
		emit_signal("ammo_depleted")

func _fire() -> void:
	var _fire_sound = get_fire_sound()
	assert(_fire_sound)

	if debug_print:
		DebugOverlay.print_log("%s _fire" % [get_name()])

	var trx = Transform2D()
	trx.origin = global_transform.origin
	var source = get_node_or_null(attach_parent_path)
	if not source:
		source = get_parent()
	var attach_parent = source.get_node_or_null(attach_offset_path)
	var _projectile = DragonflyUtil.spawn_projectile(source, attach_parent, projectile, trx, global_rotation)

	_fire_sound.play()

func get_ammo_cost() -> int:
	return ammo_cost_fixed if fire_mode == FireMode.Fixed else ammo_cost_free

func has_ammo() -> bool:
	return _ammo >= get_ammo_cost()


func consume_ammo(amount: int) -> void:
	set_ammo(_ammo - amount)
