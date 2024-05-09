extends Node

var current_tetromino
var next_tetromino 

@onready var board = $"../Board" as Board
@onready var ui = $"../UI" as UI
var is_game_over = false

func _ready():
	current_tetromino = Shared.Tetromino.values().pick_random()	
	next_tetromino = Shared.Tetromino.values().pick_random()	
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(100, 50))
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)

# При установке тетромино
func on_tetromino_locked():
	if is_game_over:
		return
	current_tetromino = next_tetromino
	next_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(100, 50))

# Сохранение результатов при завершении игры
func on_game_over():
	is_game_over = true
	ui.show_game_over()
	Global.is_game_in_proccess = false
	#Global.save_game.merge({Global.current_player : {"score" : 0, "time" : 0}},true)
	if Global.save_game[Global.current_player].score < Global.score:
		Global.save_game[Global.current_player].score = Global.score
		Global.save_game[Global.current_player].time = round(Global.time)
		Global.save_data("data.json", Global.save_game)
