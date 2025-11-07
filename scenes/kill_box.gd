extends Area2D



func _on_body_entered(body: Node2D) -> void:
	body.scale.y = 0.75
	await get_tree().create_timer(0.1).timeout
	body.scale.y = 0.5
	await get_tree().create_timer(0.1).timeout
	body.scale.y = 0.25
	await get_tree().create_timer(0.1).timeout
	body.scale.y = 0.0
	
	

	body.mark_dead()
	await get_tree().create_timer(1).timeout
	body.scale.y = 1
