extends TileMap

@onready var is_game_over = false
@onready var loaded_chunks = []
@onready var texture_location = {
	
	"lava": [
		
		Vector2(0,2),
		Vector2(0,3),
		Vector2(1,3)
		
	],
	
	"grass": [
		
		Vector2(0,0),
		Vector2(0,1),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(1,2),

	],
	
	"sea": [
		
		Vector2(2,0),
		Vector2(2,1),
		Vector2(2,2),
		Vector2(2,3),
		
	],
	
	"rock": [
		
		Vector2(3,0),
		Vector2(3,1),
		Vector2(3,2),
		Vector2(3,3),
		
	]
	
}

@onready var probability = {
	
	"lava": 0.25,
	"grass": 0.25,
	"sea": 0.25,
	"rock": 0.25
	
}
var width = 50
var height = 35


var player_tile_pos
var myNoise = FastNoiseLite.new()
var myNoise2 = FastNoiseLite.new()
var player

func _ready():
	# Initializes the noise generators with random seeds and sets their frequency
	myNoise.seed = randi()
	myNoise2.seed = randi()
	myNoise.frequency = 0.01

func _process(_delta):
	if !is_game_over:
		player_tile_pos = local_to_map(player.position)
		generate_chunk(player_tile_pos)
		unload_distant_chunks(player_tile_pos)
		print( )
	

func mapping_noise_values_to_coordinates(noiseValueX,noiseValueY, p, texture_loc): #the range of noseValue is [-1,1]
	# Converts noise values to coordinates and picks a random texture based on defined probabilities
	var x = floor((noiseValueX + 1) * 50)
	var y = floor((noiseValueY + 1) * 50)
	var p_total = 0
	if x == 100:
		x = 99 
	if y == 100:
		y = 99
	for texture in p:
		p_total += p[texture]
		if x <= p_total * 100 - 1:

			return texture_loc[texture].pick_random()
		
func generate_chunk(pos):
	# Generates a chunk of the map around the given position
	# uses noise values to determine the type of terrain for each tile
	
	for x in range(width):
		for y in range(height):
			var myX = pos.x - width/2 + x
			var myY = pos.y - height/2 + y
			var noiseValue = myNoise.get_noise_2d(myX, myY)
			var noiseValue2 = myNoise2.get_noise_2d(myX, myY)
			var v2 = mapping_noise_values_to_coordinates(noiseValue, noiseValue2,probability, texture_location)
			set_cell(0, Vector2i(myX, myY), 0, v2)
			
			if Vector2i(pos.x, pos.y) not in loaded_chunks:
				loaded_chunks.append(Vector2i(pos.x, pos.y))


func unload_distant_chunks(player_pos):
	# Removes chunks that are far from the player to optimize performance

	# Set the distance threshold to at least 2 times the width to limit visual glitches
	# Higher values unload chunks further away
	var unload_distance_threshold = (width * 2) + 1

	for chunk in loaded_chunks:
		var distance_to_player = get_dist(chunk, player_pos)

		if distance_to_player > unload_distance_threshold:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)

func clear_chunk(pos):
	# Function to clear a chunk
	for x in range(width):
		for y in range(height):
			set_cell(0, Vector2i(pos.x - (width/2) + x, pos.y - (height/2) + y), -1, Vector2(-1, -1), -1)

func get_dist(p1, p2):
	# Function to calculate distance between two points
	var resultant = p1 - p2
	return sqrt(resultant.x ** 2 + resultant.y ** 2)


func _on_level_game_over():
	is_game_over = true
