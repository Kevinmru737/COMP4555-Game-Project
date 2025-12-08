extends AudioStreamPlayer


func _process(_float):
	self.play()
	await get_tree().create_timer(5).timeout
