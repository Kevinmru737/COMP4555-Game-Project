extends Node


func fade_out():
	$AnimationPlayer.play("fade_out")
	
func fade_in():
	$AnimationPlayer.play_backwards("fade_out")
