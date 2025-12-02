extends Node

@onready var spawn_point = get_tree().get_first_node_in_group("SpawnPoint").position
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var curr_bg = "Backgrounds"
var tilemap_original_state = {}

func _ready():
	print("level 1 started")
	MultiplayerManager.respawn_point = spawn_point
	get_tree().create_timer(0.1).timeout.connect(init_player_after_load) #fix race condition
	SceneTransitionAnimation.fade_out()
	switch_backgrounds("Backgrounds", "GruncHouse")
	game_manager.save_spec_tiles()
		
func init_player_after_load():
	get_tree().call_group("Players", "change_camera_limit", 0, -1080, 0, 11750)


func switch_backgrounds(old_bg: String, new_bg: String):
	print("switching backgrounds:", old_bg, " to ", new_bg)
	var old_bg_node = get_node(old_bg)
	var new_bg_node = get_node(new_bg)
	
	curr_bg = new_bg
	old_bg_node.fade_out()
	new_bg_node.fade_in()

func _on_bg_switch_body_entered(body: Node2D) -> void:
	if multiplayer.get_unique_id() == body.player_id:
		if curr_bg == "GruncHouse":
			switch_backgrounds(curr_bg, "Backgrounds")
	


func _on_bg_switch_2_body_entered(body: Node2D) -> void:
	if multiplayer.get_unique_id() == body.player_id:
		if curr_bg == "Backgrounds":
			switch_backgrounds(curr_bg, "GruncHouse")
