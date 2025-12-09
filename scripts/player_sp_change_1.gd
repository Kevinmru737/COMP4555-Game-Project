extends Area2D

@onready var new_spawn_point = $SPChangePosition


func _on_body_entered(_body: Node2D) -> void:
	print("Spawn Point changed to:",new_spawn_point.position)
	MultiplayerManager.respawn_point = new_spawn_point.global_position
