extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body):
	print("why")
	if not MultiplayerManager.multiplayer_mode_enabled:
		print("you died")
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	else:
		_multiplayer_dead(body)
	

	
func _multiplayer_dead(body):
	print("in mult dead")
	if multiplayer.is_server():
		body.mark_dead()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
