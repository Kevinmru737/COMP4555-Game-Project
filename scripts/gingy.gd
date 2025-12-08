extends AnimatableBody2D

@onready var sprite = $AnimatableBody2D
@onready var camera_switcher = $"../CameraSwitcher"
# Dialogue Variables
var player_in_area = false
var target_dialogue = "GruncleIntro"
var gruncle_layout
var dialogue_in_prog = false

func _ready():
	sprite.play("idle")
	#Dialogic.timeline_ended.connect(_on_timeline_ended)
	$DialogueUI.hide()
	#gruncle_layout = Dialogic.start(gruncle_intro_timeline)
	#gruncle_layout.hide()

func _process(_delta: float) -> void:
	if player_in_area and not dialogue_in_prog:
		if Input.is_action_just_pressed("interact_object"):
			rpc("initiate_dialogue")
		
	if dialogue_in_prog:
		$InteractHint.hide()

func _on_dialogue_detection_body_entered(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		print("npc range entered")
		player_in_area = true
		#run_dialogue(target_dialogue)
		$InteractHint.show()

@rpc ("any_peer", "call_local")
func initiate_dialogue():
	print("dialogue initiated")
	dialogue_in_prog = true
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	camera_switcher.cut_to($Camera2D)
	
	#Moving Players
	for player in get_tree().get_nodes_in_group("Players"):
		if player.player_id == 1:
			player.teleport_player($TaterSP.global_position)
		else:
			player.teleport_player($DellaSP.global_position)
		player.input_allowed = false
		player.hide()
	SceneTransitionAnimation.fade_out()
	$DialogueUI.show()
	
	
	
func _on_dialogue_detection_body_exited(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		if gruncle_layout:
			gruncle_layout.hide()
		player_in_area = false
		Dialogic.end_timeline()
		$InteractHint.hide()
		
func run_dialogue(dialogue: String):
	Dialogic.start(dialogue)
	var target_timeline
	if target_dialogue == "GruncleIntro":
		target_timeline = gruncle_intro_timeline
	else:
		target_timeline = gruncle_idle_timeline
	
	#var layout := Dialogic.start(target_dialogue)
	#layout.register_character(gruncle_resource, $BubbleMarker)
	
func _on_timeline_ended():
	if target_dialogue == "GruncleIntro":
		target_dialogue = "GruncleIdle"
	
