extends TextureButton

@export var hover_scale: float = 1.1
@export var animation_speed: float = 0.4

var original_scale: Vector2
var tween: Tween

func _ready() -> void:
	original_scale = scale
	await get_tree().process_frame
	# Calculate pivot based on the actual visual center
	var button_size = get_rect().size
	pivot_offset = button_size / 2
	
func _on_mouse_entered() -> void:
	# Kill previous tween if it exists
	if tween:
		tween.kill()
	
	# Create new tween to scale up
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * hover_scale, animation_speed)

func _on_mouse_exited() -> void:
	# Kill previous tween if it exists
	if tween:
		tween.kill()
	
	# Create new tween to scale down
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale, animation_speed)
	
