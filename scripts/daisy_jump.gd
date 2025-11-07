extends Area2D



func _on_body_entered(body: Node2D) -> void:
	print("hi")
	print(body.player_id)
	if body.player_id != 1:
		body.velocity.y = -1500
	
