extends Node

const SERVER_PORT = 8080
const SERVER_IP = "10.0.0.33" #local host

var multiplayer_scene1 = preload("res://scenes/multiplayer_player1.tscn")
var multiplayer_scene2 = preload("res://scenes/multiplayer_player2.tscn")

var _player_spawn_node
var host_mode_enabled = false
var multiplayer_mode_enabled = false
var respawn_point = Vector2(187, -350)


func become_host():
	print("Starting Host!")
	
	_player_spawn_node = get_tree().get_current_scene().get_node("Players")
	multiplayer_mode_enabled = true
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game.bind(2))
	multiplayer.peer_disconnected.connect(_del_player)
	
	#Removes the host single player entity and adds a multiplayer player entity
	_remove_single_player()
	_add_player_to_game(1, 1)
	
func join_as_player_2():
	print("Player 2 joining")
	multiplayer_mode_enabled = true
	var client_peer =  ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	#Removes client single player entity
	_remove_single_player()
	
	# character = 1 = tater_po, character = 2 = della_daisy
func _add_player_to_game(id: int, character: int):
	print("Player %s joined the game." % id)
	var player_to_add
	if character == 1:
		player_to_add = multiplayer_scene1.instantiate()
	elif character == 2:
		player_to_add = multiplayer_scene2.instantiate()
	else:
		return
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_player_spawn_node.add_child(player_to_add, true)
	
func _del_player(id: int):
	print("Player %s has left the game." % id)
	if not _player_spawn_node.has_node(str(id)):
		return
	_player_spawn_node.get_node(str(id)).queue_free()
	
func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("player_tater_po")
	player_to_remove.queue_free()
	
