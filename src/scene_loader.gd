class_name SceneLoader
extends CanvasItem
tool

signal free_scene_started()
signal free_scene_finished()

signal load_scene_started()
signal load_progress(progress)
signal load_scene_finished(packed_scene)

signal instance_scene_started()
signal instance_scene_progress(progress)
signal instance_scene_finished(instance)

signal populate_tree_started()
signal populate_tree_progress(progress)
signal populate_tree_finished()

enum PopulateMode {
	Sync,
	Async
}

export(PackedScene) var default_scene: PackedScene setget set_default_scene
export(PopulateMode) var populate_mode: int = PopulateMode.Sync

var _scene_instance: Node = null setget ,get_scene_instance

const DEBUG_PRINT := false

func set_default_scene(new_default_scene: PackedScene) -> void:
	if default_scene != new_default_scene:
		default_scene = new_default_scene
		if is_inside_tree():
			var _free_result = try_free_scene()
			instance_scene(default_scene)

func get_scene_instance() -> Node:
	return _scene_instance

func _init() -> void:
	var _connect_result = connect("load_scene_finished", self, "instance_scene")

func _enter_tree() -> void:
	for child in get_children():
		if child.has_meta("scene_loader_child"):
			remove_child(child)
			child.queue_free()

	if default_scene:
		instance_scene(default_scene)

func try_free_scene() -> bool:
	if _scene_instance:
		free_scene()
		return true
	return false

func free_scene() -> void:
	if DEBUG_PRINT:
		print_debug("Freeing scene")
	emit_signal("free_scene_started")

	remove_child(_scene_instance)
	_scene_instance.queue_free()

	if DEBUG_PRINT:
		print_debug("Free scene completed")
	emit_signal("free_scene_finished")

func load_scene(scene_path: String) -> void:
	var _free_result = try_free_scene()

	if scene_path.empty():
		return

	yield(get_tree(), "idle_frame")

	var timestamp := 0.0
	var took = 0.0

	emit_signal("load_scene_started")

	yield(get_tree(), "idle_frame")

	if DEBUG_PRINT:
		print_debug("Loading scene %s" % [scene_path])
	timestamp = OS.get_ticks_msec()
	var packed_scene_loader := ResourceLoader.load_interactive(scene_path)

	yield(get_tree(), "idle_frame")

	while true:
		var result = packed_scene_loader.poll()
		emit_signal("load_progress", float(packed_scene_loader.get_stage()) / float(packed_scene_loader.get_stage_count()))
		match result:
			OK:
				pass
			ERR_FILE_EOF:
				break
			_:
				printerr("Error loading scene: %s" % [result])
				return
		yield(get_tree(), "idle_frame")

	emit_signal("load_progress", 1.0)

	took = OS.get_ticks_msec() - timestamp
	if DEBUG_PRINT:
		print_debug("Scene %s loaded. Took %s" % [scene_path, took])

	yield(get_tree(), "idle_frame")

	var packed_scene = packed_scene_loader.get_resource() as PackedScene
	emit_signal("load_scene_finished", packed_scene)

func instance_scene(packed_scene: PackedScene) -> void:
	emit_signal("instance_scene_started")

	yield(get_tree(), "idle_frame")

	if DEBUG_PRINT:
		print_debug("Instancing scene %s" % [packed_scene.get_path()])
	var timestamp = OS.get_ticks_msec()
	_scene_instance = packed_scene.instance()
	emit_signal("instance_scene_progress", 1.0)
	var took = OS.get_ticks_msec() - timestamp
	if DEBUG_PRINT:
		print_debug("Scene %s instancing complete. Took %s" % [packed_scene.get_path(), took])

	yield(get_tree(), "idle_frame")

	emit_signal("instance_scene_finished", _scene_instance)

	yield(get_tree(), "idle_frame")

	emit_signal("populate_tree_started")

	yield(get_tree(), "idle_frame")

	if DEBUG_PRINT:
		print_debug("Adding scene %s to tree" % [packed_scene.get_path()])
	timestamp = OS.get_ticks_msec()
	_scene_instance.set_meta("scene_loader_child", true)

	yield(get_tree(), "idle_frame")

	match populate_mode:
		PopulateMode.Sync:
			add_child(_scene_instance)
			_scene_instance.propagate_call("ready_deferred")
		PopulateMode.Async:
			var populate_list = generate_populate_list(_scene_instance)
			add_child(_scene_instance)
			var i := 0
			while i < populate_list.size():
				var entry = populate_list[i]
				entry.parent.add_child(entry.child)
				emit_signal("populate_tree_progress", float(i) / float(populate_list.size()))
				i += 1

				var delta = OS.get_ticks_usec() - timestamp
				if delta > 6000:
					timestamp = OS.get_ticks_usec()
					yield(get_tree(), "idle_frame")
			_scene_instance.propagate_call("ready_deferred")

	yield(get_tree(), "idle_frame")

	emit_signal("populate_tree_progress", 1.0)

	took = OS.get_ticks_msec() - timestamp
	if DEBUG_PRINT:
		print_debug("Finished adding scene %s to tree. Took %s" % [packed_scene.get_path(), took])

	yield(get_tree(), "idle_frame")

	emit_signal("populate_tree_finished")

func generate_populate_list(root: Node) -> Array:
	var populate_list := []

	var children = root.get_children()
	for child in children:
		root.remove_child(child)
		populate_list.append({
			"parent": root,
			"child": child
		})

	for child in children:
		populate_list += generate_populate_list(child)

	return populate_list
