extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body):
	#Restart scene in single player if you die
	if not MultiplayerManager.multiplayer_mode_enabled:
		print("no good dead")
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	# Only the Server handles death
	if MultiplayerManager.multiplayer_mode_enabled and not multiplayer.is_server():
		return
	else:
		_multiplayer_dead(body)
	
func _multiplayer_dead(body):
	print("in mult dead")
	if multiplayer.is_server() && body.alive:
		body.mark_dead()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
#@rpc("authority")
#func mark_dead():
#	print("I died on peer", multiplayer.get_unique_id())
#	get_node("CollisionShape2D").queue_free()
	# Optional: respawn logic or scene reload here
