extends Node

@onready var spec_tiles: TileMapLayer = $SpecialInteract
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")
var tilemap_original_state = {}
var spawn_point: Vector2

func _ready():
	spec_tiles.add_to_group("SpecialInteract")
	
	
	#removing fake players
	var fake_players = get_tree().get_nodes_in_group("FakePlayers")
	for player in fake_players:
		player.queue_free()
	
	var po_spawn_node = $PoSpawn
	var della_spawn_node = $DellaSpawn
	for player in get_tree().get_nodes_in_group("Players"):
		if player.player_id == 1:
			spawn_point = po_spawn_node.position
		else:
			spawn_point = della_spawn_node.position
	
	MultiplayerManager.respawn_point = spawn_point
	
	game_manager.save_spec_tiles()
	MultiplayerManager.create_players()
	PlayerRef.player_in_transit = false
	
	MultiplayerManager.players_ready.connect(func(): rpc("notify_ready"))
		
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
	# If changing level size you must change these hardcoded camera limits.
	get_tree().call_group("Players", "change_camera_limit", -999999, -999999, 999999, 999999)
	
	SceneTransitionAnimation.fade_out()
