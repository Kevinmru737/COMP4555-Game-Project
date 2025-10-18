extends Node2D
@onready var scene_transition_animation = $EndOfLevel/SceneTransitionAnimation/ColorRect
@onready var scene_transition_animation_player = $EndOfLevel/SceneTransitionAnimation/AnimationPlayer
func _ready():
	print("level 1 started")
	scene_transition_animation.z_index = 6
	scene_transition_animation_player.play("fade out")
	await get_tree().create_timer(1).timeout
	
	
