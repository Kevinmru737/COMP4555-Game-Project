extends Marker2D

@onready var level = $".."
func _ready():
	self.add_to_group("SpawnPoint")
	MultiplayerManager.respawn_point = self.global_position
