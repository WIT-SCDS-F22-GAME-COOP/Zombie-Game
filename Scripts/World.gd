extends Node

var current_button = 0
var selected_tile_pos = Vector2.ZERO
var selected_tile = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_ids()
	draw_map(Global.level)
	level_specific()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str($Cursor.tile_position)
	
	if current_button == 1 && Input.is_action_just_pressed("select"):
		_on_Button_pressed()
		
	if Input.is_action_just_pressed("select"):
		if ($ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) != -1):
			selected_tile_pos = $Cursor.tile_position
			selected_tile = $ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y)
			$SelectedCursor.position = $Cursor.position
		elif (selected_tile != -1 && $TileMap.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) == 1):
			$ActionTile.set_cell($Cursor.tile_position.x, $Cursor.tile_position.y, selected_tile, false,false,false, Vector2(0,0))
			$ActionTile.set_cell(selected_tile_pos.x, selected_tile_pos.y, -1, false,false,false, Vector2(0,0))
			selected_tile = -1
			$SelectedCursor.position = Vector2(-256,0)
		
	pass_tile()


func level_specific():
	match(Global.level_int):
		2:
			$Red.position = Vector2(6*64+32,16*64+32)
			$Green.position = Vector2(7*64+32,16*64+32)


func assign_ids():
	$Red.id = 1
	$Green.id = 2
	$Red.modulate = Color(1,0,0)
	$Green.modulate = Color(0,1,0)

func pass_tile():
	var red = Tiles.get_tile($Red.position)
	var green = Tiles.get_tile($Green.position)
	$Red.current_tile = $ActionTile.get_cell(red.x,red.y)
	$Green.current_tile = $ActionTile.get_cell(green.x,green.y)
	$Red.current_floor = $TileMap.get_cell(red.x,red.y)
	$Green.current_floor = $TileMap.get_cell(green.x,green.y)

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
			else:
				print(str(pixel) + " at " + str(Vector2(index,index2)))

# Temporary button
func _on_Button_pressed():
	Global.return_menu()


func _Back_Button_Entered(area):
	current_button = 1
func _Back_Button_Left(area):
	current_button = 0
