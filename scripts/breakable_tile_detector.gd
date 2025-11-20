extends Area2D


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("Breakable Detected")
	# Check if the body is a TileMap
	if body is TileMapLayer:
		var tilemap = body as TileMapLayer
		# Get the tile data at the collision shape
		var tile_data = tilemap.get_cell_tile_data(tilemap.get_coords_for_body_rid(body_rid))
		print(tile_data)
		if tile_data:
			# Check the tile's custom data or source_id to identify tile type
			var tile_type = tile_data.get_custom_data("tile_type")  # or however you identify tiles
			print(tile_type)
			if tile_type == "1":
				# Now modify the collision shape
				# The collision shape is part of the TileMap's physics layer
				# You can't directly modify individual tile collision shapes,
				# but you can react to them being collided with
				print("Specific tile type collided!")
