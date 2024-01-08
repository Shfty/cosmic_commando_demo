class_name ProjectileSword
extends Projectile

onready var _sprite_line = $PhysicsInterpolator2D/PixelSnap/SpriteLine

func _process(_delta: float) -> void:
	_sprite_line.rotation = orientation
