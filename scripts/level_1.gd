extends Node

var spawn_point = Vector2(400, -350)

func _ready():
	print("level 1 started")
	print(spawn_point)
	MultiplayerManager.respawn_point = spawn_point
	
	
	
