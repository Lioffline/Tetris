extends Node

@onready var transition = $transition

# Переход на сцену
func _ready():
	transition.play("fade_in")
	await get_tree().create_timer(10).timeout
	$Label2.hide()
	$Instructions.hide()

