extends Area2D

class_name  Piece

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

# Установка текстуры тетромино
func set_texture(texture: Texture2D):
	sprite_2d.texture = texture

# Установка размера тетромино
func get_size():
	return collision_shape_2d.shape.get_rect().size
