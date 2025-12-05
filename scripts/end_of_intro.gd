extends Area2D


func _on_body_entered(body: Node2D) -> void:
	PlayerRef.player_in_transit = true
	SceneTransitionAnimation.fade_in()
	await get_tree().create_timer(1).timeout
	
	#removing fake players
	var fake_players = get_tree().get_nodes_in_group("FakePlayers")
	for player in fake_players:
		player.queue_free()
		
		
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.next_scene()
