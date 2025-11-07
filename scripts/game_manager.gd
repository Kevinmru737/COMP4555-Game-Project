extends Node

@onready var title_scene = preload("res://scenes/title_screen.tscn")
@onready var tutorial_scene = preload("res://scenes/tutorial.tscn")
@onready var scene_container = $"Scene Container"
@onready var title_node = title_scene.instantiate()
#All Scenes to be loaded in chronological order
var scene_list = ["res://scenes/level_1.tscn", "res://scenes/level_3.tscn"]


func _ready():
	add_to_group("GameManager")
	load_scene(title_scene)
	
func next_scene():
	print(scene_list)
	var scene_to_load = scene_list[0]
	if scene_to_load:
		MultiplayerManager.request_scene_change(scene_list[0])
		scene_list.remove_at(0)
		
func load_scene(scene_resource):
	# Clear previous scene
	for child in scene_container.get_children():
		child.queue_free()
	# Add new scene
	var new_node = scene_resource.instantiate()
	scene_container.add_child(new_node)
	return new_node

func become_host():
	print("Become host pressed")
	MultiplayerManager.become_host()
	# Request scene change via network
	MultiplayerManager.request_scene_change("res://scenes/tutorial.tscn")

func join_as_player_2():
	print("Join as player 2 pressed")
	MultiplayerManager.join_as_player_2()
	# Request scene change via network
	MultiplayerManager.request_scene_change("res://scenes/tutorial.tscn")
	
	
	
'''
	# Store a player node by ID or unique name
func register_player(player_id: int, player_node: Node):
	if player_id == 1:
		group_lists.player_data["tater_po"] = player_node
	else:
		group_lists.player_data["della_daisy"] = player_node
	print("Registered player:", player_id)
	print(group_lists.player_data)

# Retrieve a player node safely
func get_player(player_id: int) -> Node:
	return group_lists.player_data.get(player_id)

# Rebuild the Players group after scene reload
func restore_players_group():
	print("trying to restore player group")
	print(group_lists.player_data)
	for name in group_lists.player_data.keys():
		var node = group_lists.player_data[name]
		print(name)
		print(node)
		if is_instance_valid(node):
			node.add_to_group("Players")
			print("Restored:", name)
'''
