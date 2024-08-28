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

func _ready():
	noise = noise_height_text.noise
	generate_world()
	
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

	print("Noise value ++ : ", noise_val_arr.max())
	print("Noise value -- : ", noise_val_arr.min())

	tile_map.set_cells_terrain_connect(base_layer, base_tiles_arr, terrain_base_int, 0)
	tile_map.set_cells_terrain_connect(roof_layer, roof_tiles_arr, terrain_roof_int, 0)

	
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val = noise.get_noise_2d(x, y)
			
			if noise_val <= base_noise_value:
				base_tiles_arr.append(Vector2i(x, y))

				if noise_val <= roof_noise_value:
					roof_tiles_arr.append(Vector2i(x, y))

			noise_val_arr.append(noise_val)

	print("Noise value ++ : ", noise_val_arr.max())
	print("Noise value -- : ", noise_val_arr.min())

	tile_map.set_cells_terrain_connect(base_layer, base_tiles_arr, terrain_base_int, 0)
	tile_map.set_cells_terrain_connect(roof_layer, roof_tiles_arr, terrain_roof_int, 0)
	
func generate_world():
	
	#water
	generate_level(grass_tiles_arr, grass_layer, terrain_grass_int, -0.6,
				water_tiles_arr, water_layer, terrain_water_int, 0.3, false)
	
	#hill
	generate_level(hill_tiles_arr,  hill_layer,  terrain_hill_int,  -0.3,
						grass_tiles_arr, grass_layer, terrain_grass_int, -0.6, true)
	
func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x - 0.1
		if zoom_val == 0:
			zoom_val = camera_2d.zoom.x - 0.2
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
