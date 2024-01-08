class_name ProjectileNoForce
extends Projectile

export(PackedScene) var fire_effect

onready var _sprite_circle := $PhysicsInterpolator2D/PixelSnap/SpriteCircle as SpriteCircle

func fire() -> void:
	var _effect = DragonflyUtil.spawn_effect(get_parent(), fire_effect, global_transform, 0.0)
	.fire()

func _physics_process(_delta: float) -> void:
	_shape.radius = (_timer / duration) * 5.0

func _process(_delta: float) -> void:
	_sprite_circle.radius = (_timer / duration) * 5.0
