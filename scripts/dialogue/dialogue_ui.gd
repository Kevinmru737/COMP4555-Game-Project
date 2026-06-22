extends CanvasLayer
@onready var dialog_box = $Anchor/Sprite2D/DialogBox
@onready var name_box = $Anchor/Sprite2D/NameBox
#@onready var curr_npc = $".."
@onready var textbox_sound = $TextAdvance
@onready var camera_switcher = $CameraSwitcher
#const GRUNC_DIALOG1 = [
#	"Gruncle:Welcome!",
#	"Gruncle:I see you've been on a long journey... I've been meaning to set out on one myself actually.",
#	"Gruncle:Strange things have been happening in these parts... The forest seems to be dyin' cause of it.",
#	"Gruncle:But I've heard a rumor y'see... of a land where these strange objects can't reach...",
 #   "Gruncle:That's where I'm headed once I finish packing. You best be headed that way too, now off you go!"
#]
var speaker_name
var dialog_line
var dialog_index = 0
var dialog_done = false

var dialogue_in_prog = false
var dialogue = []

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
	
	print("dialogue initiated")
	dialogue_in_prog = true
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	camera_switcher.cut_to($"../GruncleCamera")
	
	# Moving Players
	for player in get_tree().get_nodes_in_group("Players"):
		if player.player_id == 1:
			player.teleport_player($"../TaterSP".global_position)
		else:
			player.teleport_player($"../DellaSP".global_position)
		#player.input_allowed = false
		#player.hide()
	
	SceneTransitionAnimation.fade_out()
	self.show()

	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_line") and dialogue_in_prog and not dialog_done:
		#REMOVE HARDCODED VALUE
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

func process_line():
	print(dialog_index)
	if dialog_index > 0:
		textbox_sound.play()
	var line = dialogue[dialog_index]
	var line_info = parse_line(line)
	name_box.text = line_info["speaker_name"]
	dialog_box.text = line_info["dialog_line"]
	dialog_index += 1

func end_dialogue():
	dialog_done = true
	print("dialogue ended")
	SceneTransitionAnimation.fade_in()
	await SceneTransitionAnimation.scene_transition_animation_player.animation_finished
	#Moving Players
	for player in get_tree().get_nodes_in_group("Players"):
		#player.input_allowed = true
		player.show()
		if multiplayer.get_unique_id() == player.player_id:
			camera_switcher.cut_to(player.get_node("Camera2D"))
	SceneTransitionAnimation.fade_out()
	self.hide()
