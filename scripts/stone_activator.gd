extends Area2D

@onready var sprite = $Sprite2D

@export var stone_brighten = 0.3 # Duration to brighten the stone
@export var stone_return = 0.7 # Duration to return the stone back to og colours

signal stone_activated
var player_in_range: int = 0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_in_range = player_in_range + 1
		print("Player in range, press interact!")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_in_range = player_in_range - 1

func _physics_process(delta: float) -> void:
	if player_in_range > 0 and Input.is_action_just_pressed("interact_object"):
		print("interacted with")
		_on_interaction()

func _on_interaction() -> void:
	stone_activated.emit()
	
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate", Color(2.0, 2.0, 2.0, 1.0), stone_brighten)
	tween.tween_property(sprite, "self_modulate", Color.WHITE, stone_return)
