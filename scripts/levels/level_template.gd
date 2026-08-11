extends Node

@onready var spec_tiles: TileMapLayer = $SpecialInteract
@onready var po_cam: Camera2D = $MultiPlayerPlayer1/Camera2D
var tilemap_original_state = {}


func _ready() -> void:
	
	# Initialize the saved special interact tiles state
	spec_tiles.add_to_group("SpecialInteract")
	save_spec_tiles()
	po_cam.enabled = true
	po_cam
	
	
	
	
	
	
# Save the tilemap states of the SpecialInteract TileMapLayer
func save_spec_tiles():
	var tilemap = get_tree().get_first_node_in_group("SpecialInteract")
	tilemap_original_state.clear()
	
	# Get all cells in the tilemap
	for cell in tilemap.get_used_cells():
		var source_id = tilemap.get_cell_source_id(cell)
		var atlas_coords = tilemap.get_cell_atlas_coords(cell)
		tilemap_original_state[cell] = {"source": source_id, "atlas": atlas_coords}


# Reset the SpecialInteract tilemap to it's original state.
func reset_tilemap():
	var tilemap = get_tree().get_first_node_in_group("SpecialInteract")
	tilemap.clear()
	
	# Restore all tiles from the saved state
	for cell in tilemap_original_state:
		var data = tilemap_original_state[cell]
		tilemap.set_cell(cell, data["source"], data["atlas"])
	
