extends CharacterBody2D

const MOVEMENT_SPEED = 300.0
const JUMP_VELOCITY = -1000.0
var gravity = 2 * ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

# Multiplayer variables
var direction = 1
var do_jump = false
var _is_on_floor = true
var alive = true
var input_allowed = true

# Jumping logic
var is_jumping = false
var can_move_during_jump = false
var jump_velocity_applied = false
var prev_y = 0
var target_anim = ""
var last_anim = ""

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
	MultiplayerManager._sync_animation.rpc("idle", player_id)
func _physics_process(delta):
	_is_on_floor = is_on_floor()
	prev_y = velocity.y

	if is_multiplayer_authority():
		_movement(delta)
		_anim_handler(prev_y)

func _anim_handler(prev_y_vel):
	var new_anim = ""

	# Walk animation
	if _is_on_floor and not is_jumping:
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
	var anim_suffix = "right" if direction >= 0 else "left"
	var curr_anim = animated_sprite.animation

	# Pre-jump
	if _is_on_floor and curr_anim != "jump_" + anim_suffix + "_land" and is_jumping:
		can_move_during_jump = false
		return "jump_" + anim_suffix + "_pre"

	# Rising
	elif velocity.y < 0:
		can_move_during_jump = true
		return "jump_" + anim_suffix + "_up"

	# Falling
	elif velocity.y > 0 and not _is_on_floor:
		can_move_during_jump = true
		return "jump_" + anim_suffix + "_down"

	# Landing
	elif prev_velocity > 0 and is_jumping:
		can_move_during_jump = false
		return "jump_" + anim_suffix + "_land"

	return curr_anim  # fallback, keep current animation

func _movement(delta):
	if input_allowed:
		direction = %InputSynchronizer.input_direction

	# Start jump
	if do_jump and _is_on_floor and not is_jumping:
		do_jump = false
		is_jumping = true
		jump_velocity_applied = false
		velocity.x = 0

	# Stop horizontal movement on landing
	if _is_on_floor and is_jumping:
		velocity.x = 0

	# Jump processing
	if is_jumping:
		_process_jump(delta)

	if can_move_during_jump or not is_jumping:
		if direction != 0:
			velocity.x = direction * MOVEMENT_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)

	# Apply gravity
	if not _is_on_floor:
		velocity.y += gravity * delta

	move_and_slide()

func _process_jump(delta):
	var curr_anim = animated_sprite.animation
	var curr_frame = animated_sprite.frame

	# Apply jump velocity during pre-jump
	if curr_anim in ["jump_right_pre", "jump_left_pre"]:
		if curr_frame == 1 and not jump_velocity_applied:
			velocity.y = JUMP_VELOCITY
			jump_velocity_applied = true

	# Landing completed
	elif curr_anim in ["jump_right_land", "jump_left_land"]:
		input_allowed = false
		if curr_frame == 1:
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
	position = MultiplayerManager.respawn_point
	print("respawned at:", position)
	$CollisionShape2D.set_deferred("disabled", false)
	
func _set_alive():
	print("actually alive")
	alive = true
