extends MultiplayerSynchronizer

@onready var player = $".."
var input_direction
func _ready():
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	input_direction = Input.get_axis("a_move_left", "d_move_right") 
	
func _physics_process(delta):
	input_direction = Input.get_axis("a_move_left", "d_move_right") 
	
func _process(delta):
	if Input.is_action_just_pressed("space_jump"):
		jump.rpc()

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true
