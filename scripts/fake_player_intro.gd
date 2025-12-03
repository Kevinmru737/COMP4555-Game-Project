extends CharacterBody2D

const INTRO_WALK_SPEED = 300
const gravity = 2000
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	print("fake position", position)
	velocity.y = gravity
	animated_sprite.play("idle")
	
func _physics_process(_delta):
	move_and_slide()


func walk_right():
	animated_sprite.play("right_walk")
	print("running")
	velocity.x = INTRO_WALK_SPEED
	
