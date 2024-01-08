extends Effect

onready var _sprite_line := $PixelSnap/SpriteLine

func _process(_delta: float) -> void:
	_sprite_line.rotation = orientation
	_sprite_line.length = int((_timer / duration) * 8.0)
