extends CanvasLayer

class_name UI

@onready var transition = $transition

# Отображение экрана поражения
func show_game_over():
	$Panel2.show()
	$Panel.show()

# Перезагрузка сцены
func _on_button_pressed():
	get_tree().reload_current_scene()
	Global.is_game_in_proccess = true
	Global.game_over_reset_score()

# Выход в главное меню
func _on_button_2_pressed():
	transition.play("fade_out")
	await get_tree().create_timer(.25).timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	Global.game_over_reset_score() 

# Отображение счета
func _process(delta):
	$Panel/Label2.text = str(Global.score)
