class_name ProjectileFlame
extends Projectile

var rotation_range = 2.0

onready var _sprite_circle := $PhysicsInterpolator2D/PixelSnap/SpriteCircle as SpriteCircle

func _ready() -> void:
	_shape.radius = 8.0
	_sprite_circle.radius = _shape.radius

func destroy(spawn_hitspark: bool = true) -> void:
	_shape.radius = 8.0
	_sprite_circle.radius = _shape.radius
	.destroy(spawn_hitspark)

func _physics_process(delta: float) -> void:
	orientation += (randf() * 2.0 - 1.0) * rotation_range * PI * delta
	_shape.radius = 8.0 + 16.0 * (1.0 - (_timer / duration))

func _process(_delta: float) -> void:
	_sprite_circle.radius =  8.0 + 16.0 * (1.0 - (_timer / duration))
	_sprite_circle.color = lerp(Color.yellow, Color.red, randf())
