extends Node

@onready var spawn_point = get_tree().get_first_node_in_group("SpawnPoint").position
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var curr_bg = "Backgrounds"

func _ready():
	print("level 3 started")
	MultiplayerManager.respawn_point = spawn_point
	print(PlayerRef.player_ref)
	SceneTransitionAnimation.fade_out()
	init_player_after_load()
	$"BelowGroundBG".fade_in()
	$"AboveGroundBG".fade_in()

func init_player_after_load():
	get_tree().call_group("Players", "change_camera_limit", 0, -1080, 0, 3060)


func switch_backgrounds(old_bg: String, new_bg: String):
	print("switching backgrounds:", old_bg, " to ", new_bg)
	var old_bg_node = get_node(old_bg)
	var new_bg_node = get_node(new_bg)
	
	curr_bg = new_bg
	old_bg_node.fade_out()
	new_bg_node.fade_in()

func _on_bg_switch_body_entered(body: Node2D) -> void:
	var new_bg = ""
	if curr_bg == "Backgrounds":
		new_bg = "GruncHouse"
	else:
		new_bg = "Backgrounds"
	switch_backgrounds(curr_bg, new_bg)	
