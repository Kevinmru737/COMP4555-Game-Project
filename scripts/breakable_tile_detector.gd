extends Area2D
@onready var player = $".."

# The distance from the character global_position vs the collision hitbox for tiles
# Measured from the bottom of the collision hit box to the top of the Player positions
var CHARACTER_COLLISION_TILE_OFFSET = 40


# For Breakable Tiles
var SHAKE_TIMER = 30 # Time * 0.02 = seconds played

var in_death = false



func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var tile_map = body as TileMapLayer
		var local_pos = tile_map.to_local(global_position)
		local_pos = local_pos + Vector2(0, CHARACTER_COLLISION_TILE_OFFSET) # offset to find tile
		var tile_pos = tile_map.local_to_map(local_pos)
		if player.velocity.y > 0 or player._is_on_floor:
			# For a 1x4 horizontal tile, search left to find the start
			var tile_data = null
			for offset in range(4):  # Check up to 4 cells downwards
				var check_pos = tile_pos - Vector2i(0, offset)
				var data = tile_map.get_cell_tile_data(check_pos)
				if data:
					tile_data = data
					tile_pos = check_pos
					break
			if tile_data and tile_data.get_custom_data("Breakable"):
				print("calling break rpc")
				sync_break_tile.rpc(tile_map.get_path(), tile_pos)
			
			if tile_data and tile_data.get_custom_data("Poison") and player.alive and not in_death:
				print("Sending poison RPC with path: ", tile_map.get_path())
				sync_poison_tile.rpc(tile_map.get_path(), tile_pos)

@rpc("any_peer", "reliable", "call_local")
func sync_break_tile(tilemap_path: NodePath, tile_pos: Vector2i) -> void:
	var tilemap = get_node(tilemap_path) as TileMapLayer
	if tilemap:
		print("Found tilemap: ", tilemap.name)
		var tile_data = tilemap.get_cell_tile_data(tile_pos)
		if tile_data:
			tile_break(tilemap, tile_data, tile_pos)
	else:
		print("Tilemap not found at path: ", tilemap_path)

@rpc("any_peer", "reliable", "call_local")
func sync_poison_tile(tilemap_path: NodePath, tile_pos: Vector2i) -> void:
	var tilemap = get_node(tilemap_path) as TileMapLayer
	print(player.alive)
	if tilemap and player.alive:
		var tile_data = tilemap.get_cell_tile_data(tile_pos)
		if tile_data:
			tile_poison(tilemap, tile_data, tile_pos)
	else:
		print("Tilemap not found at path or maybe dead: ", tilemap_path)	
		
func tile_poison(tilemap: TileMapLayer, tile_data: TileData, tile_pos: Vector2i):
	# Reset modulate first
	player.modulate = Color.WHITE
	in_death = true
	
	var tween = create_tween()
	tween.tween_property(player, "modulate", Color.PURPLE, 0.3)
	for i in range(10):
		tween.tween_interval(0.05)
	tween.tween_property(player, "modulate", Color.TRANSPARENT, 0.4)
	tween.tween_callback(func(): player.mark_dead())
	
	# Wait 1 second, then reset
	tween.tween_interval(1.0)
	tween.tween_callback(func(): 
		player.modulate = Color.WHITE
		player.scale = Vector2.ONE
		player.rotation = 0
	)
	
	await tween.finished
	in_death = false
# Ref: Claude
func tile_break(tilemap: TileMapLayer, tile_data: TileData, tile_pos: Vector2i):
	# Get the tile's visual texture
	var source_id = tilemap.get_cell_source_id(tile_pos)
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	var tileset = tilemap.tile_set
	var source = tileset.get_source(source_id)
	var texture = source.texture
	var region = source.get_tile_texture_region(atlas_coords)
	
	# Create a sprite to show the shaking tile
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = true
	sprite.position = tilemap.map_to_local(tile_pos)# + Vector2(0, 45)
	
	# Add sprite to the scene
	tilemap.add_child(sprite)
	
	# Shake and fade the sprite
	var tween = create_tween()
	var original_pos = sprite.position
	
	# Shake for 0.3 seconds
	for i in range(SHAKE_TIMER):
		var shake_offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		tween.tween_callback(func(): sprite.position = original_pos + shake_offset)
		tween.tween_interval(0.02) # Speed of vibration
	
	# Reset position and fade out
	tween.tween_callback(func(): sprite.position = original_pos)
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.2)
	
	# Erase the tile when animation finishes
	tween.tween_callback(func(): tilemap.erase_cell(tile_pos))
	tween.tween_callback(func(): sprite.queue_free())
	pass


func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
