extends Node


@onready var ambient_sound_1 = AudioStreamPlayer.new()
@onready var ambient_sound_2 = AudioStreamPlayer.new()
@export var ambient_audio_path_1: String = "res://sound/ambiance/grass3.wav"
@export var ambient_audio_path_2: String = "res://sound/ambiance/spring.wav"
@export var min_interval: float = 5.0
@export var max_interval: float = 15.0

var time_since_last_sound: float = 0.0
var next_sound_time: float = 0.0
#from claude.ai
func _ready():

	# Setup ambient sounds
	ambient_sound_1.stream = load(ambient_audio_path_1)
	ambient_sound_2.stream = load(ambient_audio_path_2)
	ambient_sound_1.volume_db = -15.0
	ambient_sound_2.volume_db = -25.0
	add_child(ambient_sound_1)
	add_child(ambient_sound_2)
	
	next_sound_time = randf_range(min_interval, max_interval)

func _process(delta: float) -> void:
	# ... existing code ...
	
	# Play ambient sounds intermittently
	time_since_last_sound += delta
	if time_since_last_sound >= next_sound_time:
		# Randomly pick one of the two sounds
		var sound = [ambient_sound_1, ambient_sound_2].pick_random()
		sound.play()
		time_since_last_sound = 0.0
		next_sound_time = randf_range(min_interval, max_interval)
		
