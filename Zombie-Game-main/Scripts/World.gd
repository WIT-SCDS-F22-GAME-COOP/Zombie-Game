extends Node

var current_button = 0
var selected_tile_pos = Vector2.ZERO
var selected_tile = -1
var durability_matrix = []
var matrix_output = ""
var last_pos_red = Vector2.ZERO
var last_pos_green = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	assign_ids()
	draw_map(Global.level)
	level_specific()
	for x in range(25):
		durability_matrix.append([])
		for y in range(16):
			match $ActionTile.get_cell(x+1, y+1):
				-1:
					durability_matrix[x].append(-1)
				0:
					durability_matrix[x].append(2)
				1:
					durability_matrix[x].append(3)
				_:
					durability_matrix[x].append(-1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str($Cursor.tile_position)
	
	if current_button == 1 && Input.is_action_just_pressed("select"):
		_on_Button_pressed()
		
	if Input.is_action_just_pressed("select"):
		if ($ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) != -1 && initial_pos_check()):
			selected_tile_pos = $Cursor.tile_position
			selected_tile = $ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y)
			$SelectedCursor.position = $Cursor.position
		elif (selected_tile != -1 && $TileMap.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) == 1 && initial_pos_check()):
			durability_matrix[$Cursor.tile_position.x-1][$Cursor.tile_position.y-1] = durability_matrix[selected_tile_pos.x-1][selected_tile_pos.y-1]
			durability_matrix[selected_tile_pos.x-1][selected_tile_pos.y-1] = -1;
			$ActionTile.set_cell($Cursor.tile_position.x, $Cursor.tile_position.y, selected_tile, false,false,false, Vector2(0,0))
			$ActionTile.set_cell(selected_tile_pos.x, selected_tile_pos.y, -1, false,false,false, Vector2(0,0))
			selected_tile = -1
			$SelectedCursor.position = Vector2(-256,0)
		
	pass_tile()
	
	if (Global.points >= 2):
		$WinGraphic.visible = true
	else:
		$WinGraphic.visible = false


func initial_pos_check():
	if $Red.position == $Red.starting_pos && $Red.direction == $Red.initial_direction:
		if $Green.position == $Green.starting_pos && $Green.direction == $Green.initial_direction:
			return true
		else:
			return false
	else:
		return false


func level_specific():
	match(Global.level_int):
		1:
			$Red.position = Vector2(6*64+32,16*64+32)
			$Green.position = Vector2(7*64+32,16*64+32)
		2:
			$Red.position = Vector2(6*64+32,16*64+32)
			$Green.position = Vector2(7*64+32,16*64+32)
		3:
			$Red.position = Vector2(16*64+32,16*64+32)
			$Green.position = Vector2(15*64+32,16*64+32)
		4:
			$Red.position = Vector2(2*64+32,8*64+32)
			$Green.position = Vector2(1*64+32,8*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 1
		5:
			$Red.position = Vector2(2*64+32,6*64+32)
			$Green.position = Vector2(1*64+32,6*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 1
		6:
			$Red.position = Vector2(1*64+32,2*64+32)
			$Green.position = Vector2(14*64+32,2*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 3
			$TileMap.set_cell(7,1,10,false,false,false,Vector2(0,0))
			$TileMap.set_cell(8,1,6,false,false,false,Vector2(0,0))
			$TileMap.set_cell(16,1,8,false,false,false,Vector2(0,0))
			$TileMap.set_cell(16,2,6,false,false,false,Vector2(0,0))
		7:
			$Red.position = Vector2(8*64+32,11*64+32)
			$Green.position = Vector2(8*64+32,10*64+32)
			$TileMap.set_cell(8,5,11,false,false,false,Vector2(0,0))
			$TileMap.set_cell(5,9,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(5,12,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(6,12,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(6,11,10,false,false,false,Vector2(0,0))
			$TileMap.set_cell(7,11,10,false,false,false,Vector2(0,0))
		8:
			$Red.position = Vector2(1*64+32,1*64+32)
			$Green.position = Vector2(16*64+32,16*64+32)
			$Red.initial_direction = 2
			$TileMap.set_cell(1,10,11,false,false,false,Vector2(0,0))


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
	$Red.current_floor = pass_floor($Red.current_floor,red)
	$Green.current_floor = pass_floor($Green.current_floor,green)
	
	if (red != last_pos_red):
		last_pos_red = red
		if(durability_matrix[red.x-1][red.y-1] > 0):
			durability_matrix[red.x-1][red.y-1] -=1
			if (durability_matrix[red.x-1][red.y-1] == 0):
				$ActionTile.set_cell(red.x, red.y, -1, false,false,false, Vector2(0,0))
	
	if (green != last_pos_green):
		last_pos_green = green
		if(durability_matrix[green.x-1][green.y-1] > 0):
			durability_matrix[green.x-1][green.y-1] -=1
			if (durability_matrix[green.x-1][green.y-1] == 0):
				$ActionTile.set_cell(green.x, green.y, -1, false,false,false, Vector2(0,0))

func pass_floor(a,b):
	a[3] = $TileMap.get_cell(b.x - 1,b.y)
	a[4] = $TileMap.get_cell(b.x,b.y)
	a[5] = $TileMap.get_cell(b.x + 1,b.y)
	
	a[0] = $TileMap.get_cell(b.x - 1,b.y - 1)
	a[1] = $TileMap.get_cell(b.x,b.y - 1)
	a[2] = $TileMap.get_cell(b.x + 1,b.y - 1)
	
	a[6] = $TileMap.get_cell(b.x - 1,b.y + 1)
	a[7] = $TileMap.get_cell(b.x,b.y + 1)
	a[8] = $TileMap.get_cell(b.x + 1,b.y + 1)
	
	return a

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
			# Blue
			elif (str(pixel) == "0,0,1,1"):
				$TileMap.set_cell(index,index2,4,false,false,false,Vector2(0,0))
			else:
				print(str(pixel) + " at " + str(Vector2(index,index2)))

# Temporary button
func _on_Button_pressed():
	Global.return_menu()
	
#prints durability matrix for testing
func print_matrix():
	matrix_output = ""
	for y in range(16):
			for x in range(25):
				matrix_output += str(durability_matrix[x][y])
				matrix_output += ", "
			matrix_output += "\n"
	print(matrix_output)


func _Back_Button_Entered(area):
	current_button = 1
func _Back_Button_Left(area):
	current_button = 0
