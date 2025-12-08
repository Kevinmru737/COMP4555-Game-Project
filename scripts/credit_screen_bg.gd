extends Node

# Fake players
@onready var fake_po_scene = preload("res://scenes/player_tater_po.tscn")
@onready var fake_daisy_scene = preload("res://scenes/player_della_daisy.tscn")

func _ready():
	$player_della_daisy/AnimatedSprite2D.play("back_idle_1")
	$player_tater_po/AnimatedSprite2D.play("back_idle")
	$player_della_daisy/AnimatedSprite2D.scale = Vector2(1.4, 1.4)
	$player_tater_po/AnimatedSprite2D.scale = Vector2(1.4, 1.4)




	
