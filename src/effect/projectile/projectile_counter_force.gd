extends Projectile

var _parried_areas := []

onready var _sprite_circle := $PhysicsInterpolator2D/PixelSnap/SpriteCircle as SpriteCircle

func collision() -> void:
	pass

func _ready() -> void:
	_parried_areas = []

func destroy(spawn_hitspark: bool = true) -> void:
	_parried_areas = []
	.destroy(spawn_hitspark)

func _physics_process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if not area in _parried_areas and area.has_method('parried'):
			area.parried(damage, Vector2.RIGHT.rotated(orientation), 0.0)
			_parried_areas.append(area)

func _process(_delta: float) -> void:
	_sprite_circle.radius = 8.0 + 16.0 * (_timer / duration)
