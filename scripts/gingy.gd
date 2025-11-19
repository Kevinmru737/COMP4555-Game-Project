extends AnimatableBody2D

@onready var sprite = $AnimatableBody2D
@onready var gingy_intro_timeline = Dialogic.preload_timeline("GingyIntro")
@onready var gingy_resource= load("res://dialogue/characters/Gingy.dch")
# Dialogue Variables
var player_in_area = false
var gingy_layout
var target_dialogue = "GingyIntro"

func _ready():
	sprite.play("idle")
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	gingy_layout = Dialogic.start(gingy_intro_timeline)
	gingy_layout.hide()

func _on_dialogue_detection_body_entered(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		if gingy_layout:
			gingy_layout.show()
		player_in_area = true
		run_dialogue()

func _on_dialogue_detection_body_exited(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		if gingy_layout:
			gingy_layout.hide()
		player_in_area = false
		
		
func run_dialogue():
	var layout := Dialogic.start(target_dialogue)
	layout.register_character(gingy_resource, $BubbleMarker)
	
	
func _on_timeline_ended():
	print("Go Save Garlic")
	
	rpc("move_players")
	
@rpc("any_peer", "call_local")
func move_players():
	var players = get_tree().get_nodes_in_group("Players")
	
	players[0].position = Vector2(-800, 1200)
	players[0].change_camera_limit(-1670, -1080, 1670, 11750)
	
	
	players[1].position = Vector2(-1000, -1670)
	players[1].change_camera_limit(-1670, -3000, -1330, 11750)
