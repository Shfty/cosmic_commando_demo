class_name ChildPath2D
extends Path2D
tool

export(bool) var start_from_self := false
export(bool) var close_path := false

func _physics_process(_delta: float) -> void:
	if not curve:
		return

	curve.clear_points()

	if start_from_self:
		curve.add_point(Vector2.ZERO)

	var points: Array = get_children()
	for i in range(0, points.size()):
		var child = points[i]
		var handles = child.get_children()

		var local_point = child.global_transform.origin - global_transform.origin
		curve.add_point(local_point)

		var idx_offset = 0
		if start_from_self:
			idx_offset = 1

		if handles.size() >= 1:
			var local_in_handle = handles[0].global_transform.origin - global_transform.origin
			curve.set_point_in(i + idx_offset, local_in_handle - local_point)
		if handles.size() >= 2:
			var local_out_handle = handles[1].global_transform.origin - global_transform.origin
			curve.set_point_out(i + idx_offset, local_out_handle - local_point)

	if close_path:
		curve.add_point(curve.get_point_position(0))
		curve.set_point_in(points.size(), curve.get_point_in(0))
		curve.set_point_out(points.size(), curve.get_point_out(0))

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var points: Array = get_children()
	for i in range(0, points.size()):
		var child = points[i]
		var handles = child.get_children()

		if handles.size() >= 1:
			var in_handle = handles[0]
			draw_line(
				child.global_transform.origin - global_transform.origin,
				in_handle.global_transform.origin - global_transform.origin,
				Color.white
			)
		if handles.size() >= 2:
			var out_handle = handles[1]
			draw_line(
				child.global_transform.origin - global_transform.origin,
				out_handle.global_transform.origin - global_transform.origin,
				Color.white
			)
