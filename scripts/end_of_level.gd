extends Area2D

@onready var scene_transition_animation = $SceneTransitionAnimation/ColorRect
@onready var scene_transition_animation_player = $SceneTransitionAnimation/AnimationPlayer



func _on_body_entered(body: CharacterBody2D) -> void:
	scene_transition_animation.z_index = 6
	scene_transition_animation_player.play("fade in")
	await get_tree().create_timer(1).timeout
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.next_scene()
	
	for player in PlayerRef.player_ref:
		player.spawn_player()
