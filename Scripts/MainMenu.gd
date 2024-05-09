extends Control

@onready var transition = $transition

var save_game_array = [] # Массив для сортировки

# Активируемая при старте функция, загружает данные из файла 
func _ready(): 
	$MarginContainer/VBoxContainer/Play.disabled = true
	transition.play("fade_in")
	$transition/ColorRect.hide()
	Global.save_game = Global.load_data("data.json")

	for key in Global.save_game.keys():
		var player_data = {
		"name": key,
		"score": Global.save_game[key].score,
		"time": Global.save_game[key].time
		}
		save_game_array.append(player_data)
	save_game_array.sort_custom(Callable(func(x,y):return x.score>y.score))
	var size = 0

	if Global.save_game.size() < 10:
		size = Global.save_game.size()
	else:
		size = 10
	
	for i in range(size):
		var k2 = save_game_array[i]
		var item = preload("res://Scenes/leader_item.tscn").instantiate()
		item.get_node("L_name").text = k2.name
		item.get_node("L_Score").text = str(k2.score)
		var formatted_time = format_time_in_seconds(k2.time)
		item.get_node("L_time").text = formatted_time
		$leaders.add_child(item)

# Форматирование времени рекордов 
func format_time_in_seconds(seconds): 
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

# Запуск игры, сохранение имени, переход на другую сцену
func _on_play_pressed():
	$transition.play("fade_out")
	Global.is_game_in_proccess = true
	Global.current_player = $MarginContainer/VBoxContainer/PlayerName.text
	if Global.save_game.keys().find(Global.current_player) == -1:
		Global.save_game.merge({$MarginContainer/VBoxContainer/PlayerName.text : {"score" : 0, "time" : 0}},true)
		Global.save_data("data.json", Global.save_game)
	await get_tree().create_timer(.25).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# Отображение рекордов
func _on_records_pressed():
	$ShadowDrop.visible = !$ShadowDrop.visible
	$HBoxContainer.visible =!$HBoxContainer.visible
	$leaders.visible = !$leaders.visible
	$Record_back.visible = !$Record_back.visible

# Диалоговое меню выхода
func _on_exit_ask_pressed():
	$Panel.show()
	$ShadowDrop.show()

# Отмена выхожа
func _on_back_pressed():
	$Panel.hide()
	$ShadowDrop.hide()

# Истинный выход
func _on_exit_pressed():
	get_tree().quit()

# Ввод имени
func _on_line_edit_text_changed(new_text):
	
	if $MarginContainer/VBoxContainer/PlayerName.text!= "":
		$MarginContainer/VBoxContainer/Play.disabled = false
	else:
		$MarginContainer/VBoxContainer/Play.disabled = true
