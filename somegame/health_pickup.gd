extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.current_hp = 3
		queue_free()
