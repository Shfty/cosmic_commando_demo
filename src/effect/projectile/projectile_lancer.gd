class_name ProjectileLancer
extends Projectile

var _visual_length := 0.0
var _physics_length := 0.0
var _vel := 400.0

onready var _left_circle := $PixelSnapLeftCircle/LeftCircle as SpriteCircle
onready var _right_circle := $PixelSnapRightCircle/RightCircle as SpriteCircle
onready var _line := $PixelSnapLine/Line as SpriteLine

onready var _left_circle_snap := $PixelSnapLeftCircle as PixelSnap
onready var _right_circle_snap := $PixelSnapRightCircle as PixelSnap
onready var _line_snap := $PixelSnapLine as PixelSnap

func _ready() -> void:
	_visual_length = 0.0
	_physics_length = 0.0
	_vel = 400.0
	update_physics_nodes()
	update_visual_nodes()

func collision() -> void:
	_vel = 0.0

func _physics_process(delta: float) -> void:
	_physics_length += _vel * delta * 2.0
	update_physics_nodes()

func _process(delta: float) -> void:
	_visual_length += _vel * delta * 2.0
	update_visual_nodes()

func update_physics_nodes() -> void:
	var progress = _timer / duration

	_shape.radius = 4.0 * progress
	_shape.height = _physics_length

	_collision_shape.transform.origin = _line_snap.transform.origin


func update_visual_nodes() -> void:
	var left = Vector2.LEFT.rotated(orientation) * _visual_length * 0.5
	var right = Vector2.RIGHT.rotated(orientation) * _visual_length * 0.5
	var progress = _timer / duration
	var radius = 4.0 * progress
	var color = lerp(Color.white, Color.orange, progress)

	_left_circle_snap.transform.origin = left + right
	_left_circle.radius = radius
	_left_circle.color = color

	_right_circle_snap.transform.origin = right + right
	_right_circle.radius = radius
	_right_circle.color = color

	_line_snap.transform.origin = right + (left + right) * 0.5
	_line.rotation = orientation
	_line.length = _visual_length * 0.5
	_line.width = radius * 2.0
	_line.color = color
