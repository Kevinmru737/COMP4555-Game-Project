extends Node

@onready var spawn_point = get_tree().get_first_node_in_group("SpawnPoint").position
@onready var camera1 = $Cameras/Camera1
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")
@onready var players = get_node
func _ready():
	print("level 3 started")
	MultiplayerManager.respawn_point = spawn_point
	var players = PlayerRef.player_ref
	for player in players:
		if player not in get_tree().get_nodes_in_group("Players"):
			player.add_to_group("Players")
	print("players:", get_tree().get_nodes_in_group("Players"))
	print("gm:", get_tree().get_nodes_in_group("GameManager"))
	get_tree().call_group("Players", "change_camera_limit", 0, -4000, 4000, 15000)
	
	
