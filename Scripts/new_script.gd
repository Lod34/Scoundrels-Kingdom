extends Node2D

@export var noise_height_text : NoiseTexture2D
var noise : Noise

var width : int = 200
var height : int = 200

@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D

var source_id = 0
var water_atlas = Vector2i(6, 13)
var hill_atlas = Vector2i(6, 0)
var grass_atlas = Vector2i(1, 1)

var grass_layer = 0
var water_layer = 1
var hill_layer = 2

var grass_tiles_arr = []
var terrain_grass_int = 1

var water_tiles_arr = []
var terrain_water_int = 2

var hill_tiles_arr = []
var terrain_hill_int = 3

var noise_val_arr = []

# Funzione di salvataggio già definita sopra
const MAX_DRAWABLE_CHUNK_SIZE = Vector2i(512, 512)

func _ready():
	noise = noise_height_text.noise
	generate_world()
	save_large_tilemap_as_image("res://tilemap_output.png")  # Salva la mappa dopo la generazione


# Funzione per generare il livello e piazzare i tile
func generate_level(base_tiles_arr, base_layer, terrain_base_int, base_noise_value: float,
					roof_tiles_arr, roof_layer, terrain_roof_int, roof_noise_value: float, reverse: bool):
	
	if reverse:
		for x in range(-width/2, width/2):
			for y in range(-height/2, height/2):
				var noise_val = noise.get_noise_2d(x, y)
				
				if noise_val <= base_noise_value:
					base_tiles_arr.append(Vector2i(x, y))

					if noise_val <= roof_noise_value:
						roof_tiles_arr.append(Vector2i(x, y))

				noise_val_arr.append(noise_val)
	else:
		for x in range(-width/2, width/2):
			for y in range(-height/2, height/2):
				var noise_val = noise.get_noise_2d(x, y)
				
				if noise_val >= base_noise_value:
					base_tiles_arr.append(Vector2i(x, y))

					if noise_val >= roof_noise_value:
						roof_tiles_arr.append(Vector2i(x, y))

				noise_val_arr.append(noise_val)

	tile_map.set_cells_terrain_connect(base_layer, base_tiles_arr, terrain_base_int, 0)
	tile_map.set_cells_terrain_connect(roof_layer, roof_tiles_arr, terrain_roof_int, 0)

# Funzione per generare l'intero mondo
func generate_world():
	# Generazione dell'acqua e dell'erba
	generate_level(grass_tiles_arr, grass_layer, terrain_grass_int, -0.6,
				   water_tiles_arr, water_layer, terrain_water_int, 0.3, false)
	
	# Generazione delle montagne
	generate_level(hill_tiles_arr,  hill_layer,  terrain_hill_int,  -0.3,
				   grass_tiles_arr, grass_layer, terrain_grass_int, -0.6, true)
	
	print("Noise value ++ : ", noise_val_arr.max())
	print("Noise value -- : ", noise_val_arr.min())

# Funzione per salvare la tilemap come immagine
func save_large_tilemap_as_image(output_path: String):
	var used_rect = tile_map.get_used_rect()
	var tile_size = Vector2i(512,512)
	var total_pixel_size = used_rect.size * tile_size

	var result_image = Image.new()
	result_image.create(total_pixel_size.x, total_pixel_size.y, false, Image.FORMAT_RGBA8)

	var viewport = SubViewport.new()
	viewport.size = MAX_DRAWABLE_CHUNK_SIZE

	var camera = Camera2D.new()
	viewport.add_child(camera)
	camera.make_current()
	camera.position = Vector2i(tile_map.position)

	add_child(viewport)

	for chunk_x in range(ceil(float(total_pixel_size.x) / MAX_DRAWABLE_CHUNK_SIZE.x)):
		for chunk_y in range(ceil(float(total_pixel_size.y) / MAX_DRAWABLE_CHUNK_SIZE.y)):
			var chunk_position = Vector2(chunk_x * MAX_DRAWABLE_CHUNK_SIZE.x, chunk_y * MAX_DRAWABLE_CHUNK_SIZE.y)
			camera.position = tile_map.position + chunk_position + (MAX_DRAWABLE_CHUNK_SIZE / 2)
			await RenderingServer.frame_post_draw
			var viewport_texture = viewport.get_texture()
			var chunk_image = viewport_texture.get_data()
			chunk_image.flip_y()
			result_image.blit_rect(chunk_image, Rect2(Vector2(0, 0), chunk_image.get_size()), chunk_position)

	result_image.save_png(output_path)
	print("Tilemap saved to: ", output_path)
