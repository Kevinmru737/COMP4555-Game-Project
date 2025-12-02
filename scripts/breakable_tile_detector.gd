extends Area2D
@onready var player = $".."

var CHARACTER_COLLISION_TILE_OFFSET = 40
var SHAKE_TIMER = 30
var in_death = false

# Track the last detected tile to avoid duplicate triggers
var last_detected_tile_pos: Vector2i = Vector2i.ZERO
var last_detected_tilemap: TileMapLayer = null

func _ready():
	pass

func _physics_process(delta):
	# Cast downward to detect tiles beneath the player
	check_tiles_below()

func check_tiles_below():
	# Create a raycast query
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0, CHARACTER_COLLISION_TILE_OFFSET)
	)
	query.collide_with_areas = false
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		if collider is TileMapLayer:
			var tile_map = collider as TileMapLayer
			var collision_point = result.position
			
			# Convert collision point to tile coordinates
			var local_pos = tile_map.to_local(collision_point)
			var tile_pos = tile_map.local_to_map(local_pos)
			
			# Only process if it's a new tile (avoid repeated triggers)
			if tile_pos != last_detected_tile_pos or tile_map != last_detected_tilemap:
				var tile_data = tile_map.get_cell_tile_data(tile_pos)
				
				if tile_data:
					if tile_data.get_custom_data("Breakable"):
						print("Detected breakable tile at: ", tile_pos)
						sync_break_tile.rpc(tile_map.get_path(), tile_pos)
					
					if tile_data.get_custom_data("Poison") and player.alive and not in_death:
						print("Detected poison tile at: ", tile_pos)
						sync_poison_tile.rpc(tile_map.get_path(), tile_pos)
				
				last_detected_tile_pos = tile_pos
				last_detected_tilemap = tile_map

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
	if tilemap and player.alive:
		var tile_data = tilemap.get_cell_tile_data(tile_pos)
		if tile_data:
			tile_poison(tilemap, tile_data, tile_pos)
	else:
		print("Tilemap not found at path or maybe dead: ", tilemap_path)

func tile_poison(tilemap: TileMapLayer, tile_data: TileData, tile_pos: Vector2i):
	player.modulate = Color.WHITE
	in_death = true
	
	var tween = create_tween()
	tween.tween_property(player, "modulate", Color.PURPLE, 0.3)
	for i in range(10):
		tween.tween_interval(0.05)
	tween.tween_property(player, "modulate", Color.TRANSPARENT, 0.4)
	tween.tween_callback(func(): get_tree().call_group("Players", "mark_dead"))
	
	tween.tween_interval(1.0)
	tween.tween_callback(func(): 
		player.modulate = Color.WHITE
		player.scale = Vector2.ONE
		player.rotation = 0
	)
	
	await tween.finished
	in_death = false
	get_tree().get_first_node_in_group("GameManager").reset_tilemap()

func tile_break(tilemap: TileMapLayer, tile_data: TileData, tile_pos: Vector2i):
	var source_id = tilemap.get_cell_source_id(tile_pos)
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	var tileset = tilemap.tile_set
	var source = tileset.get_source(source_id)
	var texture = source.texture
	var region = source.get_tile_texture_region(atlas_coords)
	
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = true
	sprite.position = tilemap.map_to_local(tile_pos)
	
	tilemap.add_child(sprite)
	
	var tween = create_tween()
	var original_pos = sprite.position
	
	for i in range(SHAKE_TIMER):
		var shake_offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		tween.tween_callback(func(): sprite.position = original_pos + shake_offset)
		tween.tween_interval(0.02)
	
	tween.tween_callback(func(): sprite.position = original_pos)
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(func(): tilemap.erase_cell(tile_pos))
	tween.tween_callback(func(): sprite.queue_free())
	
