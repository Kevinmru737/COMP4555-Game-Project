extends StaticBody2D

@onready var sprite = $Ric
@onready var camera_switcher = $"../../CameraSwitcher"
# Dialogue Variables
var player_in_area = false
var dialogue_in_prog = false
var is_freed = false
func _ready():
	sprite.play("idle")
	$DialogueUI.hide()

func _process(_delta: float) -> void:
	if player_in_area and not dialogue_in_prog:
		if Input.is_action_just_pressed("interact_object"):
			rpc("initiate_dialogue")
		
	if dialogue_in_prog:
		$InteractHint.hide()

func _on_dialogue_detection_body_entered(body: Node2D) -> void:
	if body.has_method("spawn_player") and is_freed:
		print("npc range entered")
		player_in_area = true
		$InteractHint.show()
		

@rpc ("any_peer", "call_local", "reliable")
func initiate_dialogue():
	print("dialogue initiated")
	dialogue_in_prog = true
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	camera_switcher.cut_to($Camera2D)
	
	#Moving Players
	for player in get_tree().get_nodes_in_group("Players"):
		player.teleport_player(self.position)
		player.input_allowed = false
		player.hide()
	SceneTransitionAnimation.fade_out()
	$DialogueUI.show()
	
	
func _remove_cup_1():
	rpc("_remove_cups")
	
	
@rpc("any_peer", "call_local", "reliable")
func _remove_cups():
	is_freed = true
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property($CupTrap, "position:y", $CupTrap.position.y - 100, 0.5)
	tween.tween_property($CupTrap, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): $CupTrap.queue_free())
	
func _on_dialogue_detection_body_exited(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		player_in_area = false
		$InteractHint.hide()
