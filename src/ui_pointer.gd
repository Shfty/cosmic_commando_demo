class_name UIPointer
extends TextureRect

export(float) var speed := 24.0
export(Vector2) var offset := Vector2.LEFT * 2.0

func _process(delta: float) -> void:
	var focused_control = get_focus_owner()

	if not focused_control:
		visible = false
		return

	var target_position = focused_control.rect_global_position + Vector2(-rect_size.x, -rect_size.y * 0.5 + focused_control.rect_size.y * 0.5) + offset
	if not visible:
		visible = true
		rect_global_position = target_position
	else:
		rect_global_position = rect_global_position.linear_interpolate(target_position, clamp(speed * delta, 0.0, 1.0))
