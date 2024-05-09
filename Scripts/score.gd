extends Label

var Party_Time = 0
var minutes = 0
var seconds = 0

# Вычисление времени и оторбажение счета игрока
func _process(delta):
	self.text = str(Global.score)
	if Global.is_game_in_proccess: 

		Global.time += delta
		Party_Time += delta
		seconds = int(Party_Time)

		if seconds >= 60:
			Party_Time = 0
			seconds = 0
			minutes += 1

		var timeLabel = get_parent().get_node("time")
		timeLabel.text = "%02d:%02d" % [minutes, seconds]
