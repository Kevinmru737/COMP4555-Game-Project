extends Node

@onready var obstacle_tiles = $SpecialInteract
func _on_stone_activator_stone_activated() -> void:
	
	
	if obstacle_tiles:
		var fade_tween = create_tween()
		fade_tween.tween_property(obstacle_tiles, "modulate:a", 0.0, 1)
		fade_tween.tween_callback(obstacle_tiles.queue_free)  # Remove after fading
