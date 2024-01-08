class_name BurstFireWeapon
extends AlienSoldierWeapon

export(float) var burst_fire_rate = 5
export(int) var burst_count = 2

var _burst_count := 0

func start_refire_timer() -> void:
	var refire_timer = get_refire_timer()
	assert(refire_timer)
	_burst_count = burst_count - 1
	refire_timer.wait_time = burst_fire_rate / 60.0
	.start_refire_timer()

func refire() -> void:
	.refire()

	var refire_timer = get_refire_timer()
	assert(refire_timer)

	if _burst_count == 0:
		refire_timer.wait_time = fire_rate / 60.0
		refire_timer.start()
		_burst_count = burst_count - 1
	else:
		refire_timer.wait_time = burst_fire_rate / 60.0
		refire_timer.start()
		_burst_count -= 1
