extends CharacterBody2D

const MOVEMENT_SPEED = 300.0
const JUMP_VELOCITY = -800.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

#multiplayer variables
var direction = 1
var do_jump = false
var _is_on_floor = true
var alive = true

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
		
func _ready():
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false
	add_to_group("players")
	
func _physics_process(delta):
	if multiplayer.is_server():
		if not alive && is_on_floor():
			_set_alive()
		_is_on_floor = is_on_floor()
		_movement(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)
	
func _apply_animations(delta):
	if direction > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("side_walk")
	elif direction < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("side_walk")
	else:
		animated_sprite.flip_h = false
		animated_sprite.play("idle")
		
func _movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if do_jump and _is_on_floor:
		velocity.y = JUMP_VELOCITY
		do_jump = false
	
	direction = %InputSynchronizer.input_direction
	# play animations based on direction
	if direction:
		velocity.x = direction * MOVEMENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
	#var x_mov = Input.get_action_strength("d_move_right") -  Input.get_action_strength("a_move_left")
	#var y_mov = Input.get_action_strength("s_move_down") - Input.get_action_strength("w_move_up")
	#var mov = Vector2(x_mov, y_mov)
	#velocity = mov.normalized() * MOVEMENT_SPEED
	move_and_slide()

func mark_dead():
	print("Mark player dead!")
	alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathTimer.start()

func _respawn():
	print("respawned!")
	position = MultiplayerManager.respawn_point
	$CollisionShape2D.set_deferred("disabled", false)
	
func _set_alive():
	print("actually alive")
	alive = true
