extends Node2D

@onready var scene_transition_animation = $ColorRect
@onready var scene_transition_animation_player = $AnimationPlayer

func fade_in():
	scene_transition_animation.z_index = 6
	scene_transition_animation_player.play("fade in")
	await get_tree().create_timer(1).timeout
	
