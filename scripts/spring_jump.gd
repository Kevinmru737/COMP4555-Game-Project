extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.velocity.y = -1600
	print("Spring jump entered")
