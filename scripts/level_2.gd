extends Node

@onready var spawn_point = get_tree().get_first_node_in_group("SpawnPoint").global_position
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")


func _ready():
	print("level 2 started")
	print(get_tree().get_node_count_in_group("SpawnPoint"))
	print(spawn_point)
	MultiplayerManager.respawn_point = spawn_point
	print(PlayerRef.player_ref)
	SceneTransitionAnimation.fade_out()
	init_player_after_load()
	$"BelowGroundBG".fade_in()
	$"AboveGroundBG".fade_in()
	
	# To prevent the timeline_ending move player rpc from triggering
	await get_tree().create_timer(1).timeout
	PlayerRef.player_in_transit = false

func init_player_after_load():
	get_tree().call_group("Players", "change_camera_limit", 0, -1080, 0, 3060)
	get_tree().call_group("Players", "spawn_player")
