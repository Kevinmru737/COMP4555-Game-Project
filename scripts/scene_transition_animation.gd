extends CanvasLayer

@onready var scene_transition_animation = $ColorRect
@onready var scene_transition_animation_player = $AnimationPlayer


func fade_in():
	scene_transition_animation_player.play("fade_in")
	await scene_transition_animation_player.animation_finished
	
func fade_out():
	scene_transition_animation_player.play("fade_out")
	await scene_transition_animation_player.animation_finished
