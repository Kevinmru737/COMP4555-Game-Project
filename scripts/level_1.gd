extends Node

var spawn_point: Vector2
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")
var curr_bg = "Backgrounds"
var tilemap_original_state = {}

func _ready():
	var spawn_node = get_tree().get_first_node_in_group("SpawnPoint")
	if spawn_node:
		spawn_point = spawn_node.position
	else:
		push_error("SpawnPoint not found!")
	print("level 1 started")
	
	MultiplayerManager.respawn_point = spawn_point
	
	switch_backgrounds("Backgrounds", "GruncHouse")
	game_manager.save_spec_tiles()
	MultiplayerManager.create_players()
	PlayerRef.player_in_transit = false
	
	MultiplayerManager.players_ready.connect(func(): rpc("notify_ready"))
	# 2nd player notifies when all players should be initialized
	#if not multiplayer.is_server() and multiplayer.get_unique_id() != 1:
#		print(multiplayer.get_unique_id(), "notifying ready")
#		print("clients player list", get_tree().get_nodes_in_group("Players"))
#		init_player_after_load()
#		rpc("notify_ready")
		
# Call when all players have loaded their scenes		
@rpc("any_peer", "reliable", "call_local")
func notify_ready():
	
	if not multiplayer.is_server() :
		var players = PlayerRef.player_ref
		var _player_spawn_node = get_tree().get_current_scene().get_node("Players")
		for player_data in players:
			if _player_spawn_node.has_node(str(player_data["id"])):
				var player_node = _player_spawn_node.get_node(str(player_data["id"]))
				player_node.add_to_group("Players")
	# We want to reposition the players before the screen reveals itself
	for player in get_tree().get_nodes_in_group("Players"):
		if player.player_id == 1:
			# offsetting tater po's spawn
			player.spawn_player(spawn_point - Vector2(150,0))
		else:
			player.spawn_player()
	init_player_after_load()


func init_player_after_load():
	
	print(multiplayer.get_unique_id(), get_tree().get_nodes_in_group("Players"))
	# If changing level size you must change these hardcoded camera limits.
	get_tree().call_group("Players", "change_camera_limit", 0, -1080, 0, 12300)
	
	
			
	SceneTransitionAnimation.fade_out()

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
