extends CharacterBody2D
#was 300
const MOVEMENT_SPEED = 300.0
const JUMP_VELOCITY = -1000.0
var gravity = 2 * ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D


#multiplayer variables
var direction = 1
var do_jump = false
var _is_on_floor = true
var alive = true
var input_allowed = true

#jumping logic
var is_jumping = false
var can_move_during_jump = false
var jump_velocity_applied = false
var prev_y = 0

# Jump animation frame ranges
const JUMP_WINDUP_START = 0
const JUMP_WINDUP_END = 3
const JUMP_ACTIVE_START = 4
const JUMP_ACTIVE_END = 6
const JUMP_LANDING_START = 7
const JUMP_LANDING_END = 10


@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
		
func _ready():
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false
	add_to_group("Players")
	
func _physics_process(delta):
	if multiplayer.is_server():
		if not alive && is_on_floor():
			_set_alive()
		_is_on_floor = is_on_floor()
		prev_y = velocity.y
		_movement(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_anim_handler(prev_y)
	
func _anim_handler(prev_y_vel):
	#handle walk animations
	if _is_on_floor and not is_jumping:
		_apply_walk_anim(prev_y_vel)
	else:
		_apply_jump_anim(prev_y_vel)
		
func _apply_walk_anim(delta):
	if direction > 0:
		animated_sprite.play("right_walk")
	elif direction < 0:
		animated_sprite.play("left_walk")
	else:
		animated_sprite.play("idle")
		
"""
	_apply_jump_anime deals with having to repeatedly play certain animations
	based on stage of the jump.
	
	There are 4 stages:
		1) Pre-jump (still on the floor and should not be allowed to move)
		2) Upwards-jump (character takes flight and movements are now allowed)
		3) Downwards-jump (i.e., falling, movement is still allowed)
		4) Landing-jump (movement is restricted and animation for landing now must play)

"""
func _apply_jump_anim(prev_velocity):
	var anim_suffix = "right" if direction >= 0 else "left"
	var curr_anim = animated_sprite.animation
	
	# Pre-jump phase (windup on ground before launch)
	if _is_on_floor and curr_anim != "jump_" + anim_suffix + "_land" and is_jumping:
		can_move_during_jump = false
		var target_anim = "jump_" + anim_suffix + "_pre"
		if curr_anim != target_anim:
			animated_sprite.play(target_anim)
	
	# Rising phase (going up)
	elif velocity.y < 0:
		can_move_during_jump = true
		var target_anim = "jump_" + anim_suffix + "_up"
		if curr_anim != target_anim:
			animated_sprite.play(target_anim)
	
	# Falling phase (going down, not on floor yet)
	elif velocity.y > 0 and not _is_on_floor:
		can_move_during_jump = true
		var target_anim = "jump_" + anim_suffix + "_down"
		if curr_anim != target_anim:
			animated_sprite.play(target_anim)
	
	# Landing phase (touching ground)
	elif prev_velocity > 0 and is_jumping:
		can_move_during_jump = false
		var target_anim = "jump_" + anim_suffix + "_land"
		if curr_anim != target_anim:
			animated_sprite.play(target_anim)
		

func _movement(delta):
	if input_allowed:
		direction = %InputSynchronizer.input_direction
	
	#Only start a jump if not already jumping
	if do_jump and _is_on_floor and not is_jumping:
		do_jump = false
		is_jumping = true
		jump_velocity_applied = false  # Reset flag
		velocity.x = 0 #Stop the player from moving if they start a jump
		
	#Landing animation is playing
	if  _is_on_floor and is_jumping:
		velocity.x = 0 #Stop the player from moving when they land
		
	#process jump every frame while jumping
	if is_jumping:
		_process_jump(delta)
		
	if can_move_during_jump or not is_jumping:
		if direction:
			velocity.x = direction * MOVEMENT_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
			
	#Gravity is always applied
	if not _is_on_floor:
		velocity.y += gravity * delta
	
	move_and_slide()

func _process_jump(delta):
	var curr_anim = animated_sprite.animation
	var curr_frame = animated_sprite.frame
	
	#print("Process jump - anim:", curr_anim, "frame:", curr_frame, "is_jumping:", is_jumping)  # DEBUG
	
	if curr_anim in ["jump_right_pre", "jump_left_pre"]:
		if curr_frame == 3 and not jump_velocity_applied:  # Only apply once
			velocity.y = JUMP_VELOCITY
			jump_velocity_applied = true
			print("Applied jump velocity")
	elif curr_anim in ["jump_right_land", "jump_left_land"]:
		input_allowed = false
		if curr_frame == 3:  # Last frame of landing
			print("jump landing end")
			is_jumping = false
			input_allowed = true

func change_camera_limit(left, top, bottom, right):
	print("Changing camera limits...")
	$Camera2D.limit_left = left
	$Camera2D.limit_top = top
	$Camera2D.limit_right = right
	$Camera2D.limit_bottom = bottom

func mark_dead():
	print("Mark player dead!")
	alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathTimer.start()

func spawn_player():
	print("spawning player")
	position = MultiplayerManager.respawn_point

func _respawn():
	print("respawned!")
	position = MultiplayerManager.respawn_point
	$CollisionShape2D.set_deferred("disabled", false)
	
func _set_alive():
	print("actually alive")
	alive = true
