class_name DebugChildStrip
extends Node2D
tool

enum Mode {
	Lines,
	LineStrip
}

export(Mode) var mode: int = Mode.Lines
export(Color) var color := Color.white
export(float) var width := 1.0
export(bool) var start_from_parent := true
export(bool) var close_strip := false
export(bool) var antialiased := true

func _ready() -> void:
	set_process(Engine.is_editor_hint())

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var points := []

	match mode:
		Mode.Lines:
			for child in get_children():
				points.append(Vector2.ZERO)
				points.append(child.global_transform.origin - global_transform.origin)
		Mode.LineStrip:
			if start_from_parent:
				points.append(Vector2.ZERO)

			for child in get_children():
				points.append(child.global_transform.origin - global_transform.origin)

			if close_strip:
				points.append(points[0])

	draw_polyline(points, color, width, antialiased)
