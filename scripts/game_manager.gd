extends Node

func become_host():
	print("Become host pressed")
	%"Multiplayer HUD".hide()
	MultiplayerManager.become_host()
	
func join_as_player_2():
	print("Join as player 2 pressed")
	%"Multiplayer HUD".hide()
	MultiplayerManager.join_as_player_2()
