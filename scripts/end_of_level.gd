extends Area2D


@export var in_transit = false


func _on_body_entered(_body: CharacterBody2D) -> void:
	PlayerRef.player_in_transit = true
	SceneTransitionAnimation.fade_in()
	get_tree().call_group("SpawnPoint", "queue_free")
	await get_tree().create_timer(1).timeout
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.next_scene()
	
