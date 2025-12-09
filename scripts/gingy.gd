extends AnimatableBody2D

@onready var sprite = $AnimatableBody2D
@onready var camera_switcher = $"../CameraSwitcher"
# Dialogue Variables
var player_in_area = false
var dialogue_in_prog = false
signal dialogue_start

func _ready():
	sprite.play("idle")
	$DialogueUI.hide()
	$Ric.play("default")
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
		$InteractHint.show()

@rpc ("any_peer", "call_local")
func initiate_dialogue():
	print("dialogue initiated")
	dialogue_in_prog = true
	dialogue_start.emit()
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
		player_in_area = false
		$InteractHint.hide()
