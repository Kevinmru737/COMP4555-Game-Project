extends CanvasLayer

@onready var dialog_speaker = $Anchor/Sprite2D
@onready var dialog_box = $Anchor/Sprite2D/DialogBox
@onready var name_box = $Anchor/Sprite2D/NameBox
#@onready var curr_npc = $".."
@onready var textbox_sound = $TextAdvance
@onready var camera_switcher = $CameraSwitcher

var dialog_line
var dialog_index = 0
var dialog_done = false

var dialogue_in_prog = false
var dialogue = []

# Dialog Assets to be Preloaded
var gruncle_dialogue_box = preload("res://art/ui/dialogue/GruncleDialogueBox.png")
var della_dialogue_box = preload("res://art/ui/dialogue/DellaDialogueBox.png")
var po_dialogue_box = preload("res://art/ui/dialogue/PoDialogueBox.png")
var gingy_dialogue_box = preload("res://art/ui/dialogue/GingyDialogueBox.png")
var ric_dialogue_box = preload("res://art/ui/dialogue/RicDialogueBox.png")
var nick_dialogue_box = preload("res://art/ui/dialogue/NickDialogueBox.png")


func _ready():
	$Anchor/TaterAnim.play("idle")
	$Anchor/DellaAnim.play("idle")
	
	self.hide()

func parse_dialogue_json(target_dialogue):
	var file = ("res://dialogue_text/%s" % target_dialogue)
	var json = JSON.new()
	var dialogue_json = FileAccess.get_file_as_string(file)
	var error = json.parse(dialogue_json)
	
	if error == OK:
		print(json.data)
		dialogue = json.data["dialogue"]
		process_line()
	else:
		print("Bad Dialogue")
		dialogue = ["Error: Bad Dialogue"]
		return
		

@rpc("any_peer", "call_local", "reliable")
func initiate_dialogue(target_dialogue):
	
	parse_dialogue_json(target_dialogue)
	
	# Prevent dialogue from being initiated twice
	if dialogue_in_prog:
		return
		
	# Prevent player movement during dialogue
	# I have it done here so that the player can't move during the scene transition
	for player in get_tree().get_nodes_in_group("Players"):
		player.direction = 0
		player.movement_allowed = false
		
	print("dialogue initiated")
	dialogue_in_prog = true
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	
	# Positioning players for dialogue
	for player in get_tree().get_nodes_in_group("Players"):
		if player.player_id == 1:
			player.teleport_player($"../TaterSP".global_position)
		else:
			player.teleport_player($"../DellaSP".global_position)
	
	camera_switcher.cut_to($"../NPCCamera")
	
	#This allows the players to fall to the floor while it's still blacked out
	await get_tree().create_timer(0.5).timeout
	
	SceneTransitionAnimation.fade_out()
	self.show()

	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_line") and dialogue_in_prog and not dialog_done:
		if dialog_index == len(dialogue):
			end_dialogue()

		if dialog_index < len(dialogue):
			process_line()

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}

# Breaks a dialogue line into/returns a dictionary of its constituent parts
func process_line():
	print(dialog_index)
	if dialog_index > 0:
		textbox_sound.play()
	var line = dialogue[dialog_index]
	var line_info = parse_line(line)
	update_speaker_box(line_info["speaker_name"])
	name_box.text = line_info["speaker_name"]
	dialog_box.text = line_info["dialog_line"]
	dialog_index += 1

# Changes the speaker portrait depending on current speaker
func update_speaker_box(speaker_name):
	match speaker_name:
		"Gruncle": dialog_speaker = gruncle_dialogue_box
		"Della": dialog_speaker = della_dialogue_box
		"Po": dialog_speaker = po_dialogue_box
		"Gingy": dialog_speaker = gingy_dialogue_box
		"Ric": dialog_speaker = ric_dialogue_box
		"Nick": dialog_speaker = nick_dialogue_box
		
# Handles and cleans the end of a dialogue
func end_dialogue():
	dialog_done = true
	print("dialogue ended")
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	#Moving Players
	for player in get_tree().get_nodes_in_group("Players"):
		player.movement_allowed = true
		if multiplayer.get_unique_id() == player.player_id:
			camera_switcher.cut_to(player.get_node("Camera2D"))
	SceneTransitionAnimation.fade_out()
	self.hide()
