extends Node

# Edit to the corresponding image from menu
# Leave 0 as default to avoid issues
var level = "res://Levels/0.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.modulate = Color(1,0,0)
	assign_ids()
	draw_map(level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str($Cursor.tile_position)


func assign_ids():
	$Red.id = 1
	$Green.id = 2
	$Red.modulate = Color(1,0,0)
	$Green.modulate = Color(0,1,0)

# Function to import and draw maps from images
# Storing a map as an 18*18 image file makes it easy to design and keep many
# different levels without having to actually create them in Godot
# Image size can be larger, but it will only read 18*18 pixels in top left
# If other colors are added for starting map tiles, make sure to standardize
# and write them down, then add them to this function
# Placeable tiles and other level data will be handled separately
func draw_map(x):
	var image = load(x)
	var data = image.get_data()
	data.lock()
	for index in (18):
		for index2 in (18):
			var pixel = data.get_pixel(index,index2)
			# Black
			if (str(pixel) == "0,0,0,1"):
				$TileMap.set_cell(index,index2,0,false,false,false,Vector2(0,0))
			# White
			elif (str(pixel) == "1,1,1,1"):
				$TileMap.set_cell(index,index2,1,false,false,false,Vector2(0,0))
			# Green
			elif (str(pixel) == "0,1,0,1"):
				$TileMap.set_cell(index,index2,3,false,false,false,Vector2(0,0))
			# Red
			elif (str(pixel) == "1,0,0,1"):
				$TileMap.set_cell(index,index2,2,false,false,false,Vector2(0,0))
