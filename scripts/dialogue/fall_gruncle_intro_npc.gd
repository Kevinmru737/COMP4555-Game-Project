extends Node2D

# This node loads the necessary dialogue text into the handler
# All NPC interaction behaviour is handled by the handler

@onready var dialog_handler = $NPCHandlerDefault
@onready var npc_sprite = $AnimatableBody2D

func _ready() -> void:
	dialog_handler.target_dialogue = "fall_gruncle_intro.json"
	npc_sprite.play("idle")
	
