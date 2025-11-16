extends Area2D




func _on_body_entered(body: CharacterBody2D) -> void:
	SceneTransitionAnimation.fade_in()
	await get_tree().create_timer(1).timeout
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.next_scene()
	get_tree().call_group("Players", "spawn_player")
