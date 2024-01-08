class_name ScrollBoxContainer
extends BoxContainer
tool

enum ScrollAxis {
	Horizontal,
	Vertical
}

export(ScrollAxis) var scroll_axis: int = ScrollAxis.Horizontal
export(int) var active_pane: int = 0 setget set_active_pane
export(float) var pane_transition_speed := 8.0

func set_active_pane(new_active_pane: int) -> void:
	if active_pane != new_active_pane:
		active_pane = new_active_pane
		if is_inside_tree():
			grab_focus()

func _process(delta: float) -> void:
	match scroll_axis:
		ScrollAxis.Horizontal:
			var offset = -get_parent().rect_size.x * active_pane
			rect_position.x = lerp(rect_position.x, offset, pane_transition_speed * delta)
		ScrollAxis.Vertical:
			var offset = -get_parent().rect_size.y * active_pane
			rect_position.y = lerp(rect_position.y, offset, pane_transition_speed * delta)

func grab_focus() -> void:
	var active_child = get_child(active_pane)
	if active_child:
		active_child.grab_focus()
