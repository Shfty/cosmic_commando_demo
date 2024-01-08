extends Node2D

var max_log_size := 50

var _log := PoolStringArray()
var _font := preload("res://resources/fonts/type_writer/type_writer.tres") as Font

func _init() -> void:
	z_index = 100

func _draw() -> void:
	var sizes := PoolVector2Array()
	var total_size := Vector2.ZERO
	for line in _log:
		var size = _font.get_string_size(line)
		sizes.append(size)
		total_size.x = max(total_size.x, size.x)
		total_size.y += size.y

	draw_rect(Rect2(Vector2.ZERO, total_size), Color(0, 0, 0, 0.5))

	var y = 0.0
	for i in range(0, _log.size()):
		y += sizes[i].y
		draw_string(_font, Vector2(0, y), _log[i])

func print_log(string) -> void:
	var log_string = "%s - %s" % [OS.get_ticks_msec(), string]
	_log.append(log_string)
	if _log.size() > max_log_size:
		_log.remove(0)
	update()
