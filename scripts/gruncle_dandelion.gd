extends AnimatableBody2D

@onready var sprite = $AnimatableBody2D

var player_in_area = false
var target_dialogue = "GruncleIntro"
func _ready():
	sprite.play("idle")
	$TextEdit.hide()

func _process(_delta):
	pass


func _on_dialogue_detection_body_entered(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		print(body.player_id)
		player_in_area = true
		run_dialogue(target_dialogue)
		$TextEdit.show()

func _on_dialogue_detection_body_exited(body: Node2D) -> void:
	if body.has_method("spawn_player"):
		print(body.player_id)
		player_in_area = false
		Dialogic.end_timeline()
		$TextEdit.hide()
		
func run_dialogue(dialogue: String):
	var layout := Dialogic.start(dialogue)
	if dialogue == "GruncleIntro":
		Dialogic.timeline_ended.connect(_on_timeline_ended)
	layout.register_character("res://dialogue/characters/GruncleDandelion.dch", $BubbleMarker)
	
func _on_timeline_ended():
	if target_dialogue == "GruncleIntro":
		target_dialogue = "GruncleIdle"
	
