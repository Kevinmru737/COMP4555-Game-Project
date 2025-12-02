extends Node

@onready var spec_tiles = $SpecialInteract
	
	
func _ready():
	spec_tiles.add_to_group("SpecialInteract")
