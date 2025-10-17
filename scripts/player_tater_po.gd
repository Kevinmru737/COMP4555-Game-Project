extends CharacterBody2D

class_name player_tater_po
const MOVEMENT_SPEED = 300.0
const JUMP_VELOCITY = -800.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	movement(delta)
	
	
	
func movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("space_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	var direction = Input.get_axis("a_move_left", "d_move_right")	
	
	# play animations based on direction
	if direction > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("side_walk")
	elif direction < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("side_walk")
	else:
		animated_sprite.play("idle")
		
	
	if direction:
		velocity.x = direction * MOVEMENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
	#var x_mov = Input.get_action_strength("d_move_right") -  Input.get_action_strength("a_move_left")
	#var y_mov = Input.get_action_strength("s_move_down") - Input.get_action_strength("w_move_up")
	#var mov = Vector2(x_mov, y_mov)
	#velocity = mov.normalized() * MOVEMENT_SPEED
	move_and_slide()
