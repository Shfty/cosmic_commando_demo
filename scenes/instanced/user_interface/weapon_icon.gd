class_name WeaponIcon
extends ColorRect
tool

export(Color) var active_color := Color.white setget set_active_color
export(Color) var inactive_color := Color("#252cdc") setget set_inactive_color
export(Color) var icon_color := Color.yellow setget set_icon_color
export(bool) var active setget set_active

func get_color_rect_foreground() -> ColorRect:
	return get_node("ColorRectBackground/ColorRectForeground") as ColorRect if has_node("ColorRectBackground/ColorRectForeground") else null

func set_active_color(new_active_color: Color) -> void:
	if active_color != new_active_color:
		active_color = new_active_color

		if is_inside_tree():
			update_border_color()

func set_inactive_color(new_inactive_color: Color) -> void:
	if inactive_color != new_inactive_color:
		inactive_color = new_inactive_color

		if is_inside_tree():
			update_border_color()

func set_icon_color(new_icon_color: Color) -> void:
	if icon_color != new_icon_color:
		icon_color = new_icon_color

		if is_inside_tree():
			update_icon_color()

func set_active(new_active: bool) -> void:
	if active != new_active:
		active = new_active

		if is_inside_tree():
			update_border_color()

func update_border_color() -> void:
	color = active_color if active else inactive_color

func update_icon_color() -> void:
	var color_rect_foreground = get_color_rect_foreground()
	assert(color_rect_foreground)
	color_rect_foreground.color = icon_color

func ready_deferred() -> void:
	update_border_color()
	update_icon_color()
