extends Node


@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

#Main UI Buttons
@onready var host_button = $"Multiplayer HUD/Panel/VBoxContainer/HostGame"
@onready var join_button = $"Multiplayer HUD/Panel/VBoxContainer/JoinAsPlayer2"

#Join UI Buttons
@onready var join_ui = $"Multiplayer HUD/Panel/JoinUI"
@onready var host_ip_input = $"Multiplayer HUD/Panel/JoinUI/IPLineEdit"
@onready var join_host = $"Multiplayer HUD/Panel/JoinUI/JoinButton"
func _ready():
	join_ui.visible = false
	join_ui.focus_mode = Control.FOCUS_NONE
	
	if game_manager:
		#chat gpt stuff - i think the problem was something else but this fixed some stuf?
		var host_method = Callable(game_manager, "become_host")
		if not host_button.is_connected("pressed", host_method):
			host_button.pressed.connect(host_method)
		var join_method = Callable(self, "join_enter_ip")
		if not join_button.is_connected("pressed", join_method):
			join_button.pressed.connect(join_method)
			
		host_button.focus_mode = Control.FOCUS_NONE
		join_button.focus_mode = Control.FOCUS_NONE
		
	
func join_enter_ip():
	print("client entering ip...")
	join_ui.visible = true
	join_host.focus_mode = Control.FOCUS_NONE
	var main_ui = $"Multiplayer HUD/Panel/VBoxContainer"
	main_ui.hide()
		
func _on_join_button_pressed() -> void:
	var ip = host_ip_input.text.strip_edges()
	if ip != "":
		print(ip)
		var game_manager = get_tree().get_first_node_in_group("GameManager")
		game_manager.join_as_player_2(ip)
	else:
		print("Invalid IP Address")
