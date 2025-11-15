extends Node

@onready var spawn_point = get_tree().get_first_node_in_group("SpawnPoint").position
@onready var camera1 = $Cameras/Camera1
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

func _ready():
	print("level 1 started")
	MultiplayerManager.respawn_point = spawn_point
	print(PlayerRef.player_ref)
	get_tree().create_timer(0.1).timeout.connect(init_player_after_load) #fix race condition
	

func init_player_after_load():
	print(get_tree().get_nodes_in_group("Players"))
	get_tree().call_group("Players", "change_camera_limit", 0, -1080, 0, 15000)
