extends Camera2D

@onready var player: Player = $"../Player"

const camera_move_speed := 5.0

func _process(delta):
	var diff = player.position - position
	
	position += diff * camera_move_speed * delta
	
