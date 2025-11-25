extends Area2D

@onready var sprite = $AnimatedSprite2D

@export var spring_force: float = 800.0  # How high the bounce is
#@export var bounce_cooldown: float = 0.2  # Prevent multiple bounces
@export var visual_squash: float = 0.95  # How much to compress visually (0.8 = 20% compression)
@export var animation_speed: float = 0.5  # How fast to bounce back

var can_bounce: bool = true
var original_scale: Vector2


var SPRING_VEL = -1500


func _ready() -> void:
	original_scale = scale

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		# Check if the body is above the spring and moving downward
		if body.global_position.y < global_position.y and body.velocity.y > 0:
			body.velocity.y = SPRING_VEL
			bounce_animation()


func bounce_animation() -> void:
	sprite.play("spring")
	# Squash down
	'''
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", original_scale * Vector2(1.0, visual_squash),
						 animation_speed * 0.5)
	
	# Bounce back up
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", original_scale, animation_speed)
	'''


func _on_stone_activator_3_stone_activated() -> void:
	print(self.name)
	if self.name == "SpringJumpAG1":
		print("Parent position: ", position)
		print("Child sprite position: ", $AnimatedSprite2D.global_position)
		self.position.x = self.position.x - 500


func _on_stone_activator_2_stone_activated() -> void:
	if self.name == "SpringJumpAG1":
		print("Parent position before: ", position)
		self.position = Vector2(self.position.x - 500, self.position.y)
		print("Parent position after: ", position)
