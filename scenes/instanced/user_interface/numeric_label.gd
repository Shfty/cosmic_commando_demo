extends HBoxContainer
tool

export(int) var value setget set_value

func get_label_leading_zeroes() -> Control:
	return $LabelLeadingZeroes as Control if has_node("LabelLeadingZeroes") else null

func get_label_number() -> Control:
	return $LabelNumber as Control if has_node("LabelNumber") else null

func set_value(new_value: int) -> void:
	if value != new_value:
		value = new_value

		if is_inside_tree():
			update_value()

func update_value() -> void:
	var label_leading_zeroes = get_label_leading_zeroes()
	var label_number = get_label_number()
	assert(label_leading_zeroes)
	assert(label_number)

	if value >= 1000:
		label_leading_zeroes.visible = false
	else:
		label_leading_zeroes.visible = true
		if value >= 100:
			label_leading_zeroes.text = '0'
		elif value >= 10:
			label_leading_zeroes.text = '00'
		else:
			label_leading_zeroes.text = '000'

	label_number.text = String(value)

func ready_deferred() -> void:
	update_value()
