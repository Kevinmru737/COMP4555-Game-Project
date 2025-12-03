extends Node


@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

#Main UI Buttons
@onready var host_button = $"Multiplayer HUD/Panel/HBoxContainer/HostGame"
@onready var join_button = $"Multiplayer HUD/Panel/HBoxContainer/JoinAsPlayer2"
@onready var quit_button = $"Multiplayer HUD/Panel/HBoxContainer/QuitGame"

#Title (img)
@onready var title = $TitleScreenBG/Title

#Join UI Buttons
@onready var join_ui = $"Multiplayer HUD/Panel/JoinUI"
@onready var host_ip_input = $"Multiplayer HUD/Panel/JoinUI/IPLineEdit"
@onready var join_host = $"Multiplayer HUD/Panel/JoinUI/JoinButton"

# button animating
var original_scale: Vector2
var tween: Tween
@export var hover_scale: float = 1.2  # Scale multiplier on hover (20% larger)
@export var animation_speed: float = 0.2  # Duration of scale animation in seconds

# Fake players
@onready var fake_po_scene = preload("res://scenes/player_tater_po.tscn")
@onready var fake_daisy_scene = preload("res://scenes/player_della_daisy.tscn")


func _ready():
	join_ui.visible = false
	join_ui.focus_mode = Control.FOCUS_NONE
	
	if game_manager:
		#chat gpt stuff - i think the problem was something else but this fixed some stuf?
		var host_method = Callable(self, "waiting_for_player_2")
		if not host_button.is_connected("pressed", host_method):
			host_button.pressed.connect(host_method)
		var join_method = Callable(self, "join_enter_ip")
		if not join_button.is_connected("pressed", join_method):
			join_button.pressed.connect(join_method)
		#var quit_method = Callable(self, "join_enter_ip")
		#if not join_button.is_connected("pressed", join_method):
		#	join_button.pressed.connect(join_method)
		host_button.focus_mode = Control.FOCUS_NONE
		join_button.focus_mode = Control.FOCUS_NONE
		add_fake_players()
	
func waiting_for_player_2():
	var main_ui = $"Multiplayer HUD/Panel/HBoxContainer"
	main_ui.hide()
	#$"Multiplayer HUD/Panel/HostWaiting".show()
	title.hide()
	make_run()
	
func make_run():
	var tween = create_tween()
	var current_cam = get_viewport().get_camera_2d()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(current_cam, "global_position", current_cam.global_position + Vector2(372, 0), 1)
	await get_tree().create_timer(3).timeout
	
	var new_cam = get_tree().get_first_node_in_group("FakePlayers").get_node("Camera2D")
	new_cam.make_current()
	for player in get_tree().get_nodes_in_group("FakePlayers"):
		player.walk_right()
		
			
	
			
func join_enter_ip():
	print("client entering ip...")
	join_ui.visible = true
	join_host.focus_mode = Control.FOCUS_NONE
	var main_ui = $"Multiplayer HUD/Panel/HBoxContainer"
	main_ui.hide()
	title.hide()
		
func _on_join_button_pressed() -> void:
	var ip = host_ip_input.text.strip_edges()
	if ip != "":
		print(ip)
		var game_manager = get_tree().get_first_node_in_group("GameManager")
		game_manager.join_as_player_2(ip)
	else:
		print("Invalid IP Address")
		
func add_fake_players():
	var fake_po = fake_po_scene.instantiate()
	var fake_daisy = fake_daisy_scene.instantiate()
	get_tree().get_current_scene().get_node("Players").add_child(fake_po)
	get_tree().get_current_scene().get_node("Players").add_child(fake_daisy)
	fake_po.add_to_group("FakePlayers")
	fake_daisy.add_to_group("FakePlayers")
	
	var fake_po_spawn = $FakePlayerSpawn/Spawn.global_position
	fake_po.global_position = fake_po_spawn
	print(fake_po_spawn)
	fake_daisy.global_position = fake_po_spawn + Vector2(200, 0)
	
