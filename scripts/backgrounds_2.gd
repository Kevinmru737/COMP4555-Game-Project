extends Node2D
@export var layers: Array[Sprite2D]  # Assign your layer nodes in the inspector
@export var float_speed: float = 1.2  # Speed of up/down bobbing
@export var float_amount: float = 3.0  # How far to bob (in pixels)
@export var pulse_speed: float = 1.0  # Speed of opacity pulsing
@export var pulse_amount: float = 0.15  # How much opacity changes (0-1)
@export var title_float_amount: float = 10

var elapsed_time: float = 0.0
var initial_positions: Array[Vector2] = []
var initial_modulates: Array[Color] = []
func _ready() -> void:
	# Store initial state of each layer
	for layer in layers:
		initial_positions.append(layer.position)
		initial_modulates.append(layer.modulate)
func _process(delta: float) -> void:
	elapsed_time += delta
	
	var float_offset_title = sin(elapsed_time * float_speed + 1 * 0.3) * title_float_amount
	layers[0].position = initial_positions[0] + Vector2(0, float_offset_title)
	
	for i in range(1, layers.size()):
		
		var layer = layers[i]
		var initial_pos = initial_positions[i]
		var initial_modulate = initial_modulates[i]
		
		# Gentle floating (vertical bobbing)
		var float_offset = sin(elapsed_time * float_speed + i * 0.3) * float_amount
		
		# Apply position changes
		layer.position = initial_pos + Vector2(0, float_offset)
		
		# Subtle pulsing (opacity breathing)
		var pulse = 1.0 + sin(elapsed_time * pulse_speed + i * 0.3) * pulse_amount
		var new_modulate = initial_modulate
		new_modulate.a = clamp(pulse, 0.0, 1.0)
		layer.modulate = new_modulate
