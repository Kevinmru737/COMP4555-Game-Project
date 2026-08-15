extends CanvasLayer

@onready var animation_player = $AnimationPlayer

var step = 0

func _ready():
	hide()

func start_tutorial():
	step = 0
	show()
	animation_player.play("d_prompt")

func _process(_delta):
	if not visible:
		return

	if step == 0 and Input.is_action_just_pressed("move_right"):
		step = 1
		animation_player.play("a_prompt")

	elif step == 1 and Input.is_action_just_pressed("move_left"):
		step = 2
		animation_player.play("space_prompt")

	elif step == 2 and Input.is_action_just_pressed("jump"):
		animation_player.stop()
		hide()
