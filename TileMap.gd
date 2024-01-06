extends TileMap


@onready var is_game_over = false

@onready var loaded_chunks = []
@onready var loaded = {}

@onready var texture_location = {
	
	"flower": [
		
		Vector2(2,0),
		Vector2(2,1),
		Vector2(3,0),
		Vector2(3,1)
	],
	
	"grass": [
		
		Vector2(0,0),
		Vector2(0,1),
		Vector2(1,0),
		Vector2(1,1)

	],
	
	"road": [
		
		Vector2(0,2),
		Vector2(0,3),
		Vector2(2,3),
		Vector2(3,3)
		
	]
	
}

@onready var probability = {
	# the sum of probability is equal to 1
	"flower": 0.3,
	"grass": 0.5,
	"road": 0.2
	
}
var width = 65
var height = 35

var chunk_center
var player_tile_pos 
var myNoise = FastNoiseLite.new()
var myNoise2 = FastNoiseLite.new()
var player

func _ready():
	myNoise.seed = randi()
	myNoise2.seed = randi()
	myNoise.frequency = 0.01

func _process(_delta):
	if !is_game_over:
		player_tile_pos = local_to_map(player.position)
		print(len(loaded))
		
		
		
		generate_chunk(player_tile_pos)
				
		
		unload_distant_chunks(player_tile_pos)

	

func mapping_noise_values_to_coordinates(noiseValueX,noiseValueY, p, texture_loc): #the range of noseValue is [-1,1]
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
	return Vector2(-1,-1)
		
func generate_chunk(pos):

	for x in range(width):
		for y in range(height):
			
				var tileX = pos.x - width/2 + x
				var tileY = pos.y - height/2 + y
				var noiseValue = myNoise.get_noise_2d(tileX, tileY)
				var noiseValue2 = myNoise2.get_noise_2d(tileX, tileY)

				var v2 = mapping_noise_values_to_coordinates(noiseValue, noiseValue2,probability, texture_location)

				if Vector2i(tileX,tileY) not in loaded:
					loaded[Vector2i(tileX,tileY)] = v2
				
					set_cell(0, Vector2i(tileX, tileY), 0, v2)
				else:
					set_cell(0, Vector2i(tileX, tileY), 0, loaded[Vector2i(tileX,tileY)])
					
				
				if pos not in loaded_chunks:
					loaded_chunks.append(pos)
	


# Function to unload chunks that are too far away
func unload_distant_chunks(player_pos):
	# Set the distance threshold to at least 2 times the width to limit visual glitches
	# Higher values unload chunks further away
	var unload_distance_threshold = (width * 2) + 1

	for chunk in loaded_chunks:
		var distance_to_player = get_dist(chunk, player_pos)

		if distance_to_player > unload_distance_threshold:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)


# Function to clear a chunk
func clear_chunk(pos):
	for x in range(width):
		for y in range(height):
			set_cell(0, Vector2i(pos.x - (width/2) + x, pos.y - (height/2) + y), -1, Vector2(-1, -1), -1)

# Function to calculate distance between two points
func get_dist(p1, p2):
	var resultant = p1 - p2
	return sqrt(resultant.x ** 2 + resultant.y ** 2)


func _on_level_game_over():
	is_game_over = true
