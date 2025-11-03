extends Node

@onready var title_scene = preload("res://scenes/title_screen.tscn")
@onready var tutorial_scene = preload("res://scenes/tutorial.tscn")
@onready var scene_container = $"Scene Container"
@onready var title_node = title_scene.instantiate()

func _ready():
	add_to_group("GameManager")
	load_scene(title_scene)

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
