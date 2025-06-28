extends Node
@onready var enemy_count: Label = %EnemyCount

func _process(delta: float) -> void:
	enemy_count.text = "%s / %s" % [Enemy.enemy_killed,Enemy.enemy_count]
	if Enemy.enemy_killed == Enemy.enemy_count:
		get_tree().change_scene_to_file("res://youwinend.tscn")
