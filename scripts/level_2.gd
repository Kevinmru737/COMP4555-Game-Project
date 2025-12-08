extends Node

signal win_condition

@onready var spawn_point = get_tree().get_first_node_in_group("SpawnPoint").global_position
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")


var stone_bg1_activated = false
var stone_ag1_activated = false

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
	win_condition.connect(_remove_cup_1)
	
	# To prevent the timeline_ending move player rpc from triggering
	await get_tree().create_timer(1).timeout
	PlayerRef.player_in_transit = false

func init_player_after_load():
	get_tree().call_group("Players", "change_camera_limit", 0, -1080, 0, 3060)
	get_tree().call_group("Players", "spawn_player")




func _on_stone_activator_bg_stone_activated_2() -> void:
	rpc_id(1, "set_bg1_activated", true)  # 1 = server peer ID

	await get_tree().create_timer(1).timeout
	rpc_id(1, "set_bg1_activated", false)  # 1 = server peer ID



func _on_stone_activator_stone_activated_1() -> void:
	rpc("set_ag1_activated", true)  # 1 = server peer ID
	await get_tree().create_timer(1).timeout
	rpc("set_ag1_activated", false)  # 1 = server peer ID

	
@rpc("authority", "call_local", "reliable")
func set_bg1_activated(value: bool):
	stone_bg1_activated = value
	if multiplayer.is_server():
		print(stone_bg1_activated)
	_check_win()

@rpc("any_peer", "reliable")
func set_ag1_activated(value: bool):
	stone_ag1_activated = value
	if multiplayer.is_server():
		print(stone_ag1_activated)
	_check_win()


func _remove_cup_1():
	print("wincondition?")
	$Activators/Garlic1._remove_cup_1()

func _check_win():
	if stone_bg1_activated and stone_ag1_activated:
		rpc_id(1, "met_win_condition")

@rpc("authority", "call_local", "reliable")
func met_win_condition():
	win_condition.emit()
