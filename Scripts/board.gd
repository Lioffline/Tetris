extends Node

class_name Board

signal tetromino_locked
signal game_over

@onready var panel_container = $"../PanelContainer"

@onready var line_scene = preload("res://Scenes/line.tscn")


const ROW_COUNT = 20
const COLUMN_COUNT = 10
var next_tetromino
var tetrominos: Array[Tetromino] = []
var lines_destroyed = 0
@export var tetromino_scene: PackedScene

# Тряска камеры
@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake(): 
	shake_strength = randomStrength

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		get_parent().get_node("Camera2D").offset = randomOffset()

func randomOffset() -> Vector2: 
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
# Конец тряски

# Спавн тетромино на игровом поле
func spawn_tetromino(type: Shared.Tetromino, is_next_piece, spawn_position):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino
	
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	
	if is_next_piece == false:
		var other_pieces = get_all_pieces()
		tetromino.position = tetromino_data.spawn_position
		tetromino.other_tetrominoes_pieces = other_pieces
		add_child(tetromino)
		tetromino.lock_tetromino.connect(on_tetromino_locked)
	else: 
		tetromino.scale = Vector2(0.5, 0.5)
		panel_container.add_child(tetromino)
		tetromino.set_position(spawn_position)
		next_tetromino = tetromino

# Блокировка тетромино на игровом поле
func on_tetromino_locked(tetromino: Tetromino):
	next_tetromino.queue_free()
	tetrominos.append(tetromino)
	add_tetromino_to_lines(tetromino)
	remove_full_lines()
	tetromino_locked.emit()
	if Global.is_game_in_proccess == true:
		Global.score += 4 + (lines_destroyed * 100)
	lines_destroyed = 0 # Сбрасываем счётчик после каждой операции
	check_game_over()

# Тряска для текста счета
func shake(node:CanvasItem, rand_offset:int=4,vec:Vector2=Vector2.ZERO):
	if vec==Vector2.ZERO:
		vec=Vector2(randi_range(-rand_offset,rand_offset),randi_range(-rand_offset,rand_offset))
	var anim_player:AnimationPlayer= get_parent().get_node("AnimationPlayer")
	var path=str(get_tree().current_scene.get_path_to(node))
	anim_player.get_animation("label_shake").track_set_key_value(0,1,node.position+vec)
	anim_player.play("label_shake")

# Проверка на завершение игры
func check_game_over():
		for piece in get_all_pieces():
			var y_location = piece.global_position.y
			if y_location == -456:
				game_over.emit()

func add_tetromino_to_lines(tetromino: Tetromino):
	var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
	
	for piece in tetromino_pieces:
		var y_position = piece.global_position.y
		var does_line_for_piece_exists = false
		
		for line in get_lines():
			
			if line.global_position.y == y_position:
				piece.reparent(line)
				does_line_for_piece_exists = true
		
		if !does_line_for_piece_exists:
			var piece_line = line_scene.instantiate() as Line
			piece_line.global_position = Vector2(0, y_position)
			add_child(piece_line)
			piece.reparent(piece_line)

# Получение линий на игрвоом поле
func get_lines():
	return get_children().filter(func (c): return c is Line)

# Очистка полных линий, дополнительные очки за кол-во уничтоженных линий за раз
func remove_full_lines():
	var destroyed_lines_count = 0
	for line in get_lines():
		if line.is_line_full(COLUMN_COUNT):
			move_lines_down(line.global_position.y)
			line.free()
			destroyed_lines_count += 1
			lines_destroyed += 1
	
	var bonus_points = 0
	if destroyed_lines_count == 1:
		bonus_points += 0
		$"../SoundEffects/L1".play()
	if destroyed_lines_count == 2:
		bonus_points += 100
		apply_shake()
		$"../SoundEffects/L2".play()
		$"../labels/LabelTetris".text = "x2"
		$"../labels/LabelTetris".show()
		await get_tree().create_timer(.5).timeout
		$"../labels/LabelTetris".hide()
	if destroyed_lines_count == 3:
		bonus_points += 200
		apply_shake()
		$"../SoundEffects/L3".play()
		$"../labels/LabelTetris".text = "x3"
		$"../labels/LabelTetris".show()
		await get_tree().create_timer(.5).timeout
		$"../labels/LabelTetris".hide()
	if destroyed_lines_count == 4:
		bonus_points += 300
		apply_shake()
		$"../SoundEffects/L4".play()
		$"../labels/LabelTetris".text = "TETRIS!"
		$"../labels/LabelTetris".show()
		await get_tree().create_timer(.5).timeout
		$"../labels/LabelTetris".hide()
	
	shake(get_parent().get_node("VBoxContainer/score"), 20)
	#apply_shake()
	Global.score += bonus_points

# Сдвиг линий вниз
func move_lines_down(y_position):
	for line in get_lines():
		if line.global_position.y < y_position:
			line.global_position.y += 48

# Получение тетромино на поле
func get_all_pieces():
	var pieces = []
	for line in get_lines():
		pieces.append_array(line.get_children())
	return pieces
