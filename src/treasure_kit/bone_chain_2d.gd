class_name BoneChain2D
extends Bone2D
tool

""" Procedurally creates and manages a nested chain of Bone2D nodes """

export(int, 1, 1000, 1) var chain_length := 1 setget set_chain_length
export(float) var bone_length := 16.0 setget set_bone_length

func set_chain_length(new_chain_length: int) -> void:
	if chain_length != new_chain_length:
		chain_length = new_chain_length
		if is_inside_tree():
			update_chain()

func set_bone_length(new_bone_length: float) -> void:
	if bone_length != new_bone_length:
		bone_length = new_bone_length
		if is_inside_tree():
			update_chain()

func _enter_tree() -> void:
	update_chain()

func update_chain() -> void:
	for child in get_children():
		if child.has_meta("bone_chain_child"):
			remove_child(child)
			child.queue_free()

	var candidate = null
	for i in range(1, chain_length):
		var child_bone = Bone2D.new()
		child_bone.name = "Joint%s" % [i]
		child_bone.set_meta("bone_chain_child", true)
		child_bone.default_length = bone_length
		child_bone.transform.origin = Vector2.RIGHT * bone_length
		child_bone.rest = child_bone.transform
		if candidate == null:
			add_child(child_bone, true)
		else:
			candidate.add_child(child_bone)
		child_bone.set_owner(get_tree().get_edited_scene_root())
		candidate = child_bone
