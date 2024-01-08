extends Node2D
tool

# Signals
signal health_changed(new_health)
signal max_health_changed(new_max_health)

signal set_walking()
signal set_flak_cannon_sweep()
signal set_leg_strike()
signal set_leg_swipe()

signal walk_finished()

# Enums
enum Action {
	None,
	Walk,
	FireGuns,
	LegStrike,
	LegSwipe
}

enum BarrelState {
	Idle,
	Active
}

# Public Properties
export(Action) var test: int = Action.None setget set_test

export(float) var walk_distance := 32.0
export(float) var walk_delay := 0.15
export(float) var step_speed := 20.0
export(float) var step_delay := 0.1
export(BarrelState) var barrel_state: int = BarrelState.Idle setget set_barrel_state
export(bool) var reset_walk := false

var max_health := 3584 setget set_max_health


# Private Properties
var _health := max_health setget _set_health
var _prev_action := 0

# Setters
func set_test(new_test: int) -> void:
	if test != new_test:
		match new_test:
			Action.Walk:
				walk()
			Action.FireGuns:
				flak_cannon_sweep()
			Action.LegStrike:
				leg_strike()
			Action.LegSwipe:
				leg_swipe()

func set_max_health(new_max_health: int) -> void:
	if max_health != new_max_health:
		max_health = new_max_health
		emit_signal("max_health_changed", max_health)

func _set_health(new_health: int) -> void:
	if _health != new_health:
		_health = new_health
		emit_signal("health_changed", _health)

func set_barrel_state(new_barrel_state: int) -> void:
	if barrel_state != new_barrel_state:
		barrel_state = new_barrel_state
		match barrel_state:
			BarrelState.Idle:
				$Controller/AnimationPlayers/Barrel.play("idle")
			BarrelState.Active:
				$Controller/AnimationPlayers/Barrel.play("active")

# Overrides
func _get_property_list() -> Array:
	var property_list := []

	property_list.append({
		"name": "Arachnorox",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})

	property_list.append({
		"name": "max_health",
		"type": TYPE_INT
	})

	return property_list

func _enter_tree() -> void:
	randomize()

	if Engine.is_editor_hint():
		return

	Game.register_boss_character(self)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return

	Game.unregister_boss_character(self)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var player = Game.get_player()
	if player:
		$Controller/ControlPoints/RestTargets/EyeRest.global_transform = player.global_transform

# Business Logic
func ready_deferred() -> void:
	$ArachnoroxStateMachine.initialize()
	#$Controller/AnimationPlayers.replace_by_instance()
	$Controller/AnimationPlayers.propagate_call("clear_caches")

func init_signals() -> void:
	var initial_signals := {
		"health_changed": _health,
		"max_health_changed": max_health
	}

	for key in initial_signals:
		emit_signal(key, initial_signals[key])

func take_damage(amount: int, _normal: Vector2, _force: float) -> void:
	if _health > 1 and _health - amount <= 0:
		_set_health(1)
	else:
		_set_health(_health - int(min(amount, _health)))

	if _health > 0:
		pass
		#$AlienSoldierStateMachine.fire_custom_event("TakeDamage")
	else:
		pass
		#$AlienSoldierStateMachine.fire_custom_event("SetDying")

func start_think_timer() -> void:
	$ThinkTimer.start()

func think() -> void:
	var player = Game.get_player()
	if not player:
		return

	var main_skeleton_origin = $Model/Skeletons/Main.global_transform.origin
	var to_player = player.global_transform.origin - main_skeleton_origin
	var to_player_sign = to_player.sign()

	$Model/AttackZones.global_transform.origin.x = main_skeleton_origin.x

	_prev_action = (_prev_action + 1) % 4
	match _prev_action:
		0:
			if not target_in_range():
				emit_signal("set_walking")
			else:
				think()
		1:
			emit_signal("set_flak_cannon_sweep")
		2:
			$Controller/ControlPoints/LegStrikeTargets.global_transform.origin.x = player.global_transform.origin.x
			if to_player_sign.x <= 0:
				$Controller/AnimationPlayers/LegStrikeSide.play("left")
				$Controller/AnimationPlayers/LegStrikePattern.play("left_to_right")
				$Controller/ControlPoints/LegStrikeTargets.transform.origin.x = min($Controller/ControlPoints/LegStrikeTargets.transform.origin.x, main_skeleton_origin.x - 80)
				$Controller/ControlPoints/LegStrikeTargets.transform.origin.x = max($Controller/ControlPoints/LegStrikeTargets.transform.origin.x, main_skeleton_origin.x - 170)
			else:
				$Controller/AnimationPlayers/LegStrikeSide.play("right")
				$Controller/AnimationPlayers/LegStrikePattern.play("right_to_left")
				$Controller/ControlPoints/LegStrikeTargets.transform.origin.x = max($Controller/ControlPoints/LegStrikeTargets.transform.origin.x, main_skeleton_origin.x + 80)
				$Controller/ControlPoints/LegStrikeTargets.transform.origin.x = min($Controller/ControlPoints/LegStrikeTargets.transform.origin.x, main_skeleton_origin.x + 170)

			emit_signal("set_leg_strike")
		3:
			if to_player_sign.x <= 0:
				$Controller/AnimationPlayers/LegSwipeSide.play("left")
			else:
				$Controller/AnimationPlayers/LegSwipeSide.play("right")

			emit_signal("set_leg_swipe")

func get_clamped_player_pos() -> Vector2:
	var player = Game.get_player()
	if player:
		var player_pos = player.global_transform.origin
		if player_pos.x > global_transform.origin.x + 128.0:
			player_pos.x = global_transform.origin.x + 128.0
		elif player_pos.x < global_transform.origin.x - 128.0:
			player_pos.x = global_transform.origin.x - 128.0
		return player_pos
	return Vector2.ZERO

func walk() -> void:
	if not Engine.is_editor_hint():
		var player = Game.get_player()
		if player:
			var player_pos = get_clamped_player_pos()
			var to_player = player_pos - $Model/Skeletons/Main.global_transform.origin
			var to_player_sign = to_player.sign()
			walk_distance = to_player_sign.x * min(abs(to_player.x), 192.0)

	var walk_height = abs(walk_distance)

	var walk_targets := [
		$Controller/ControlPoints/WalkTargets/UpperLeftLeg,
		$Controller/ControlPoints/WalkTargets/UpperRightLeg,
		$Controller/ControlPoints/WalkTargets/LowerLeftLeg,
		$Controller/ControlPoints/WalkTargets/LowerRightLeg
	]

	for i in range(0, 4):
		walk_targets[i].get_node("StepUp").transform.origin.x = walk_distance * 0.5
		walk_targets[i].get_node("StepUp").transform.origin.y = walk_height * sign(walk_targets[i].get_node("StepUp").transform.origin.y)
		walk_targets[i].get_node("StepDown").transform.origin.x = walk_distance

	$Controller/AnimationPlayers/Root.play("walk")
	yield($Controller/AnimationPlayers/Root, "animation_finished")

	if target_in_range():
		emit_signal("walk_finished")
	else:
		walk()

func reset_walk() -> void:
	var walk_targets := [
		$Controller/ControlPoints/WalkTargets/UpperLeftLeg,
		$Controller/ControlPoints/WalkTargets/UpperRightLeg,
		$Controller/ControlPoints/WalkTargets/LowerLeftLeg,
		$Controller/ControlPoints/WalkTargets/LowerRightLeg
	]

	var rest_targets := [
		$Controller/ControlPoints/RestTargets/UpperLeftLegRest,
		$Controller/ControlPoints/RestTargets/UpperRightLegRest,
		$Controller/ControlPoints/RestTargets/LowerLeftLegRest,
		$Controller/ControlPoints/RestTargets/LowerRightLegRest
	]

	for i in range(0, 4):
		walk_targets[i].global_transform.origin = walk_targets[i].get_node("StepDown").global_transform.origin
		rest_targets[i].global_transform.origin = walk_targets[i].global_transform.origin

func target_in_range() -> bool:
	var player = Game.get_player()
	if not player:
		return true

	var player_pos = get_clamped_player_pos()
	var to_player = player_pos - $Model/Skeletons/Main.global_transform.origin
	return abs(to_player.x) < 32.0

func flak_cannon_sweep():
	$Controller/AnimationPlayers/Root.play("flak_cannon_sweep")

func leg_strike() -> void:
	$Controller/AnimationPlayers/Root.play("leg_strike")

func leg_swipe() -> void:
	$Controller/AnimationPlayers/Root.play("leg_swipe")

func update_swipe_target() -> void:
	if not Engine.is_editor_hint():
		var player = Game.get_player()
		if player:
			$Controller/ControlPoints/LegSwipeTargets/SwipeTarget.global_transform.origin = player.global_transform.origin

func reset_swipe_targets() -> void:
	$Controller/ControlPoints/LegSwipeTargets.global_transform.origin.x = $Model/Skeletons/Main.global_transform.origin.x
