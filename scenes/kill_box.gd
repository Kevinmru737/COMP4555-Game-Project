extends Area2D



func _on_body_entered(body: Node2D) -> void:
	body.skew = 0.5
	body.mark_dead()
	await get_tree().create_timer(1).timeout
	body.skew = 0
