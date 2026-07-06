extends CharacterBody2D


# Physics Variables
const MOVEMENT_SPEED = 300.0
var jump_velocity = -1000.0
var DEFAULT_GRAVITY = 2 * ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = DEFAULT_GRAVITY

@onready var animated_sprite = $AnimatedSprite2D
@onready var walking_sound = $WalkingSound

# Multiplayer variables
var direction = 1
var do_jump = false
var _is_on_floor = true
var alive = true

# Jumping logic
var is_jumping = false
var is_landing = false
#var can_move_during_jump = false
var jump_velocity_applied = false
var prev_y = 0
var target_anim = ""
var last_anim = ""
var jump_type = "delay" #default is nothing which is the previous jump
var char_dir = 0

#walking variables
var walking_sound_cooldown: float = 0.0
var is_walking = false
var walk_sound_interval: float = 0.5  # seconds between footsteps

# Player State Variables
var movement_allowed = true

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	if multiplayer.get_unique_id() == player_id:
		print($Camera2D)
		$Camera2D.make_current()
	add_to_group("Players")
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	
	# Adjusting Tater Po's jump height
	if player_id == 1:
		jump_velocity = -900
		jump_type = "instant"
	else:
		# If we add more jump types this may be relevant, but for now its useless
		jump_type = "instant"
	
	MultiplayerManager.player_is_ready(player_id)

	


func _process(delta: float) -> void:
	# Make sure we don't try to process an player who has not yet connected
	if not multiplayer.get_unique_id():
		return
		
	# Decrease cooldown timer
	if walking_sound_cooldown > 0:
		walking_sound_cooldown -= delta
	
	# Play walking sound at intervals
	if multiplayer.get_unique_id() == player_id and is_walking:
		if walking_sound_cooldown <= 0:
			rpc("_play_walking_sound")
			walking_sound_cooldown = walk_sound_interval
	else:
		walking_sound.stop()
		walking_sound_cooldown = 0  # Reset when not walking
		
@rpc("any_peer", "call_local")
func _play_walking_sound():
	walking_sound.play()
	
	
func _physics_process(delta):
	_is_on_floor = is_on_floor()
	prev_y = velocity.y
	

	if is_multiplayer_authority():
		_movement(delta)
		_anim_handler(prev_y)
	
	if multiplayer.is_server():
		if not alive && is_on_floor():
			_set_alive()
	
func _on_animation_finished():
	var curr = animated_sprite.animation
	if curr in ["jump_right_land1", "jump_left_land1"]:
		is_landing = false
		
func _anim_handler(prev_y_vel):
	var new_anim = ""

	# Walk animation
	if _is_on_floor and not is_jumping and not is_landing:
		new_anim = _apply_walk_anim()
	else:
		new_anim = _apply_jump_anim(prev_y_vel)

	# Only play/send animation if it changed
	if new_anim != last_anim:
		animated_sprite.play(new_anim)
		last_anim = new_anim

		# Send RPC only if we are the server / authority
		if multiplayer.is_server() or is_multiplayer_authority():
			MultiplayerManager._sync_animation.rpc(new_anim, player_id)

func _apply_walk_anim():
	
	if direction > 0:
		return "right_walk"
	elif direction < 0:
		return "left_walk"
	else:
		return "idle"

func _apply_jump_anim(prev_velocity):
	var anim_suffix = "right" if direction > 0 else "left"
	
	if direction == 0:
		if char_dir < 0:
			anim_suffix = "left"
		if char_dir > 0:
			anim_suffix = "right"
	# direction is the current pressed action, char_dir is the last pressed direction

		
	
	var curr_anim = animated_sprite.animation

	# Pre-jump
	if _is_on_floor and curr_anim != "jump_" + anim_suffix + "_land1" and is_jumping:
		return "jump_" + anim_suffix + "_up"

	# Rising
	if velocity.y < 0 and not _is_on_floor and is_jumping:
		return "jump_" + anim_suffix + "_up"

	# Falling
	if velocity.y > 0 and not _is_on_floor:
		return "jump_" + anim_suffix + "_down"

	# Landing
	if prev_velocity > 0 and is_jumping:
		print("landing")
		is_landing = true
		is_jumping = false
		return "jump_" + anim_suffix + "_land1"
		
	# Interruptable landing animation
	elif is_landing:
		return "jump_" + anim_suffix + "_land1"
	#elif direction != 0:
	#	is_jumping = false

	return curr_anim  # fallback, keep current animation

func _movement(delta):
	direction = %InputSynchronizer.input_direction

	# char_dir is used to keep the correct left/right animation if controls are let go
	if direction != 0:
		char_dir = direction
		if _is_on_floor and is_landing:
			is_landing = false
	
	# Start jump
	if do_jump and _is_on_floor and not is_jumping:
		do_jump = false
		is_jumping = true
		jump_velocity_applied = false
		velocity.x = 0

	# Jump processing
	if is_jumping or is_landing:
		_process_jump(delta)

	#if not is_jumping:
	if direction != 0:
		velocity.x = direction * MOVEMENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
	
	# to determine if walking sounds should be played
	if _is_on_floor and velocity.x != 0:
		is_walking = true
	else:
		is_walking = false

	# Apply gravity
	if not _is_on_floor:
		velocity.y += gravity * delta

	move_and_slide()
	

func _process_jump(_delta):
	var curr_anim = animated_sprite.animation
	var curr_frame = animated_sprite.frame
	


	# Apply jump velocity during pre-jump
	if curr_anim in ["jump_right_pre1", "jump_left_pre1"]:
		if curr_frame == 3 and not jump_velocity_applied:
			velocity.y = jump_velocity
			jump_velocity_applied = true
	if jump_type == "instant" and curr_anim in ["jump_right_up", "jump_left_up"]:
		if curr_frame == 0 and not jump_velocity_applied:
			velocity.y = jump_velocity
			jump_velocity_applied = true
	# Landing completed
	if curr_anim in ["jump_right_land1", "jump_left_land1"]:
		is_jumping = false
		# Only set to false once at the start
		if curr_frame == 3 and _is_on_floor:
			print("landing finished")
			is_landing = false
		# Re-enable input when animation stops playing
		#if not animated_sprite.is_playing():
			
func change_camera_limit(left, top, bottom, right):
	$Camera2D.limit_left = left
	$Camera2D.limit_top = top
	$Camera2D.limit_right = right
	$Camera2D.limit_bottom = bottom

func mark_dead():
	print("Mark player dead!")
	alive = false
	SceneTransitionAnimation.fade_in()
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathTimer.start()
	gravity = 0
	
func teleport_player(new_position: Vector2):
	self.position = new_position

func spawn_player(sp: Vector2 = MultiplayerManager.respawn_point):
	position = sp

func _respawn():
	position = MultiplayerManager.respawn_point
	gravity = DEFAULT_GRAVITY
	$CollisionShape2D.set_deferred("disabled", false)
	SceneTransitionAnimation.fade_out()
	
func _set_alive():
	print("actually alive")
	alive = true
