extends CanvasLayer

@onready var dialog_box = $Anchor/DialogBox
@onready var name_box = $Anchor/NameBox
@onready var curr_npc = $".."
@onready var textbox_sound = $TextAdvance
@onready var camera_switcher = $CameraSwitcher

#all speakers
@onready var speaker_ginger = $Anchor/Speakers/Ginger
@onready var speaker_della = $Anchor/Speakers/DellaDaisy
@onready var speaker_garlic = $Anchor/Speakers/Garlic
@onready var speaker_po = $Anchor/Speakers/TaterPo

const GINGER_DIALOG1 = [
	"Gingy:Hey, you there! Halt!",
	"Gingy:What's your business here!",
	"TaterPo:We're just trying to pass through.",
	"Gingy:I see...",
	"Ric:(Psst... hey Gingy... maybe... maybe they can help us?)",
	"Gingy:(I don't know Ric... They don't seem like they're from here...)",
	"Ric:(That might be a good thing... maybe it means they'll know what to do!)",
	"Ric:Please help us, our fellow Garlics have been trapped in these weird contraptions...",
	"Ric:...no matter what we do, we can't get them out. There are 5 missing Garlics in total, will you help us?",
	"DellaDaisy:Of course!",
	"TaterPo: We'll do what we can!"
]

enum Name {
	GINGY,
	RIC,
	TATERPO,
	DELLADAISY
}



var speaker_name
var dialog_line
var dialog_index = 0
var dialog_done = false
func _ready():
	$Anchor/TaterAnim.play("idle")
	$Anchor/DellaAnim.play("idle")
	for speaker in $Anchor/Speakers.get_children():
		speaker.add_to_group("Speakers")
	process_line()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_line") and curr_npc.dialogue_in_prog and not dialog_done:
		if dialog_index == len(GINGER_DIALOG1):
			rpc("end_dialogue")
		
		if dialog_index < len(GINGER_DIALOG1):
			rpc("process_line")
			
		
			
			

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}
	
@rpc("any_peer", "call_local","reliable")
func process_line():
	if dialog_index > 0:
		textbox_sound.play()
	var line = GINGER_DIALOG1[dialog_index]
	var line_info = parse_line(line)
	change_speaker(line_info["speaker_name"])
	name_box.text = line_info["speaker_name"]
	dialog_box.text = line_info["dialog_line"]
	dialog_index += 1
	
	
func change_speaker(speaker_name: String):
	get_tree().call_group("Speakers", "hide")
	match speaker_name:
		"Gingy":
				speaker_ginger.show()
		"Ric":
				speaker_garlic.show()
		"TaterPo":
				speaker_po.show()
		"DellaDaisy":
				speaker_della.show()
	
@rpc ("any_peer", "call_local", "reliable")
func end_dialogue():
	dialog_done = true
	print("dialogue ended")
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	
	# Moving Players - teleport ALL of them
	for player in get_tree().get_nodes_in_group("Players"):
		player.input_allowed = true
		player.show()
		if player.player_id == 1:
			player.change_camera_limit(-2000, 460, 1540, 15000)
			player.teleport_player(Vector2(-940, 1480))
		else:
			player.change_camera_limit(-2000, -2540, -1460, 15000)
			player.teleport_player(Vector2(-940, -2000))
	
	self.hide()
	SceneTransitionAnimation.fade_out()
	
	# Switch camera to current player
	for player in get_tree().get_nodes_in_group("Players"):
		if multiplayer.get_unique_id() == player.player_id:
			camera_switcher.cut_to(player.get_node("Camera2D"))
