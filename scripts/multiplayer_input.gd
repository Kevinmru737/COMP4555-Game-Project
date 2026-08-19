extends MultiplayerSynchronizer

@onready var player = $".."
var input_direction

func _ready():
	
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	if player.movement_allowed:
		input_direction = Input.get_axis("move_left", "move_right") 
	
func _physics_process(_delta):
	if player.movement_allowed:
		input_direction = Input.get_axis("move_left", "move_right")
	else:
		# If we turn movement off we want the player to stop moving
		input_direction = 0
	
	
func _process(_delta):
	
	# Controls used by both players
	if Input.is_action_just_pressed("jump") and player.movement_allowed:
		jump.rpc()
		
	# Controls used by Della
	if player.player_id != 1:
		#if player.is_multiplayer_authority():
		if Input.is_action_pressed("up"):
			glide.rpc()
		if Input.is_action_just_released("up"):
			reset_glide.rpc()

	
@rpc("call_local")
func glide():
	if multiplayer.is_server() and player.velocity.y > 0:
		player.gravity = player.GLIDE_GRAVITY
		
@rpc("call_local")
func reset_glide():
	if multiplayer.is_server():
		player.gravity = player.DEFAULT_GRAVITY

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		if not player.is_jumping and player.gravity != 0:
			player.do_jump = true
