extends Node2D
@onready var camera_switcher = $"DialogueUI/CameraSwitcher"
@onready var dialogue = $DialogueUI

# Dialogue Variables
var players_in_area = {}  # Track which players are in the area
var target_dialogue = "fall_gruncle_intro.json" # as named in dialogue_text folder


func _process(_delta: float) -> void:
	if not dialogue.dialogue_in_prog and players_in_area.size() > 0:
		if Input.is_action_just_pressed("interact_object"):
			dialogue.initiate_dialogue.rpc(target_dialogue)
			
	
	if dialogue.dialogue_in_prog:
		$InteractHint.hide()

func _on_dialogue_detection_body_entered(body: Node2D) -> void:
	print("npc range entered - not a player tho")
	if body.has_method("spawn_player"):
		print("npc range entered")
		$InteractHint.show()
		# Sync to all clients
		_sync_player_in_area.rpc(body.player_id, true)

func _on_dialogue_detection_body_exited(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		# Sync to all clients
		_sync_player_in_area.rpc(body.player_id, false)
		if players_in_area.size() == 0:
			$InteractHint.hide()

@rpc("any_peer", "call_local", "reliable")
func _sync_player_in_area(player_id: int, in_area: bool):
	if in_area:
		players_in_area[player_id] = true
	else:
		players_in_area.erase(player_id)
