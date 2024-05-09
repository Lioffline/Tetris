extends Node

# Глобальные переменные сохранения результатов
var score = 0
var is_game_in_proccess = false
var save_game = {}
var current_player 
var time = 0

signal reset_score

# Сброс счета
func game_over_reset_score():
	score = 0
	emit_signal("reset_score")

# Сохранение данных
func save_data(path:String,data:Dictionary):
	var save_game := FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(data))
	save_game.close()

# Загрузка данных
func load_data(path:String):
	if (FileAccess.file_exists(path)):
		var save_game := FileAccess.open(path, FileAccess.READ)
		save_game.open(path, FileAccess.READ)
		if save_game.get_length()!=0:
			return JSON.parse_string(save_game.get_line())
		else:
			print("save is clear")
		save_game.close()
	else:
		print("save isn't exists")
	return {}
