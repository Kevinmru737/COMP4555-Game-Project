extends Node


@onready var game_manager = get_tree().get_first_node_in_group("GameManager")


func _ready():
	if game_manager:
		var host_button = $"Multiplayer HUD/Panel/VBoxContainer/HostGame"
		var join_button = $"Multiplayer HUD/Panel/VBoxContainer/JoinAsPlayer2"
		#chat gpt stuff - i think the problem was something else but this fixed some stuf?
		var host_method = Callable(game_manager, "become_host")
		if not host_button.is_connected("pressed", host_method):
			host_button.pressed.connect(host_method)
		var join_method = Callable(game_manager, "join_as_player_2")
		if not join_button.is_connected("pressed", join_method):
			join_button.pressed.connect(join_method)

		host_button.focus_mode = Control.FOCUS_NONE
		join_button.focus_mode = Control.FOCUS_NONE
