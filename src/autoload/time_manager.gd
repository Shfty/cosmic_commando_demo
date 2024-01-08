extends Node
tool

func pause() -> void:
	get_tree().paused = true

func unpause() -> void:
	get_tree().paused = false

func hitstop(duration: float) -> void:
	Engine.time_scale = 0.0
	var timestamp = OS.get_ticks_usec()
	while true:
		yield(get_tree(), "idle_frame")
		var new_ts = OS.get_ticks_usec()
		if not get_tree().paused:
			var delta = new_ts - timestamp
			duration -= delta * 0.000001
			if duration <= 0.0:
				break
		timestamp = new_ts
	Engine.time_scale = 1.0
