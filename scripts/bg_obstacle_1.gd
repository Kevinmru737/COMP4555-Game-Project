extends TileMapLayer


func _on_stone_activator_2_stone_activated() -> void:
	self.position.y -= 500
