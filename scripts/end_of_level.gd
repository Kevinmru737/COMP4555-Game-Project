extends Area2D


@export var in_transit = false


func _on_body_entered(body: CharacterBody2D) -> void:
	PlayerRef.player_in_transit = true
	Dialogic.end_timeline()
	SceneTransitionAnimation.fade_in()
	await get_tree().create_timer(1).timeout
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.next_scene()
	get_tree().call_group("Players", "spawn_player")
