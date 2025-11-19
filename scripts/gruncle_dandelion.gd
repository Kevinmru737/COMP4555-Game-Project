extends AnimatableBody2D

@onready var sprite = $AnimatableBody2D
@onready var gruncle_intro_timeline = Dialogic.preload_timeline("GruncleIntro")
@onready var gruncle_idle_timeline = Dialogic.preload_timeline("GruncleIdle")
@onready var gruncle_resource= load("res://dialogue/characters/GruncleDandelion.dch")

# Dialogue Variables
var player_in_area = false
var target_dialogue = "GruncleIntro"
var gruncle_layout

func _ready():
	sprite.play("idle")
	$TextEdit.hide()
	Dialogic.timeline_ended.connect(_on_timeline_ended)

	gruncle_layout = Dialogic.start(gruncle_intro_timeline)
	gruncle_layout.hide()

func _on_dialogue_detection_body_entered(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		if gruncle_layout:
			gruncle_layout.show()
		player_in_area = true
		run_dialogue(target_dialogue)
		$TextEdit.show()

func _on_dialogue_detection_body_exited(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		if gruncle_layout:
			gruncle_layout.hide()
		player_in_area = false
		Dialogic.end_timeline()
		$TextEdit.hide()
		
func run_dialogue(dialogue: String):
	var target_timeline
	if target_dialogue == "GruncleIntro":
		target_timeline = gruncle_intro_timeline
	else:
		target_timeline = gruncle_idle_timeline
	
	var layout := Dialogic.start(target_dialogue)
	layout.register_character(gruncle_resource, $BubbleMarker)
	
func _on_timeline_ended():
	if target_dialogue == "GruncleIntro":
		target_dialogue = "GruncleIdle"
	
