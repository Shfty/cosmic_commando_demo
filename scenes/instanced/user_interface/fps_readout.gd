extends Label

var rolling_window := PoolRealArray()
var window_size := 3

func _init() -> void:
	rolling_window.resize(window_size)

func _process(delta: float) -> void:
	rolling_window.append(delta)
	if rolling_window.size() > window_size:
		rolling_window.remove(0)

	var smooth_delta = 0
	for i in range(0, window_size):
		smooth_delta += rolling_window[i]
	if smooth_delta > 0:
		smooth_delta /= window_size

		var fps = String(round(1.0 / smooth_delta)).pad_zeros(3)

		text = "FPS:%s" % [fps]
