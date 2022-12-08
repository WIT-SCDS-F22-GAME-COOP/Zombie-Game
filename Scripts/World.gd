extends Node

var current_button = 0
var selected_tile_pos = Vector2.ZERO
# X = Tile, Y = Durability
var selected_tile = Vector2(-1,-1)

var new_walls = false


# Called when the node enters the scene tree for the first time.
func _ready():
	assign_ids()
	draw_tiles(Global.level)
	draw_map(Global.level)
	durmap_backup()
	level_specific()
	if new_walls:
		draw_walls_new()
	else:
		draw_walls()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Debug info on cursor's current position.
	# Can just be hidden for release.
	$Label.text = str($Cursor.tile_position)
	
	if current_button == 1 && Input.is_action_just_pressed("select"):
		_on_Button_pressed()
	
	# Direct all questions on this if statement to Lucas De Caux.
	# I'm not super familiar with it.
	if Input.is_action_just_pressed("select"):
		$LossGraphic.visible = false
		if ($ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) != -1 && initial_pos_check()):
			selected_tile_pos = $Cursor.tile_position
			selected_tile.x = $ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y)
			selected_tile.y = $DurMap.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y)
			$SelectedCursor.position = $Cursor.position
		elif (selected_tile.x != -1 && $TileMap.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) == 1 && initial_pos_check()):
			$ActionTile.set_cell($Cursor.tile_position.x, $Cursor.tile_position.y, selected_tile.x, false,false,false, Vector2(0,0))
			$ActionTile.set_cell(selected_tile_pos.x, selected_tile_pos.y, -1, false,false,false, Vector2(0,0))
			$DurMap.set_cell($Cursor.tile_position.x, $Cursor.tile_position.y, selected_tile.y, false,false,false, Vector2(0,0))
			$DurMap.set_cell(selected_tile_pos.x, selected_tile_pos.y, -1, false,false,false, Vector2(0,0))
			selected_tile.x = -1
			selected_tile.y = -1
			durmap_backup()
			$SelectedCursor.position = Vector2(-256,0)
	
	# Pass information about the current location of the characters to them.
	pass_tile()
	
	# The only time you have two points is when both characters have won.
	# Continuously checked in case reset is pressed after winning.
	if (Global.points >= 2):
		$WinGraphic.visible = true
	else:
		$WinGraphic.visible = false
	
	# The purpose of this method should be obvious enough.
	# Check if a character went into the wall, thus failing.
	# It only happens if you place an action tile in a 1 wide corridor.
	fail_check($Red.frames,$Red.failed)
	fail_check($Green.frames,$Green.failed)
	
	# Pass information about the current location of the characters to them...
	# But again.
	# I can't quite remember why, but there is a reason this is done twice.
	pass_tile()
	
	# This bugs out if pressed when a character is on top of an action tile.
	# Pressing a second time solves it.
	# Not a huge deal but probably should be figured out.
	if Input.is_action_just_pressed("reset_level"):
		durmap_restore()


# Just checks if both characters are where they start.
func initial_pos_check():
	if $Red.position == $Red.starting_pos && $Red.direction == $Red.initial_direction:
		if $Green.position == $Green.starting_pos && $Green.direction == $Green.initial_direction:
			return true
		else:
			return false
	else:
		return false


# Anything specific that needs to be done for a level that isn't covered elsewhere.
# Layout of the map and what tiles are usable are in the images.
# Almost everything else is handled here.
# If not specified otherwise, both characters face up.
func level_specific():
	match(Global.level_int):
		1:
			$Red.position = Vector2(6*64+32,16*64+32)
			$Green.position = Vector2(7*64+32,16*64+32)
		2:
			$Red.position = Vector2(6*64+32,16*64+32)
			$Green.position = Vector2(7*64+32,16*64+32)
		4:
			$Red.position = Vector2(16*64+32,16*64+32)
			$Green.position = Vector2(15*64+32,16*64+32)
		3:
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
		9:
			$Red.position = Vector2(2*64+32,8*64+32)
			$Green.position = Vector2(1*64+32,8*64+32)
			$TileMap.set_cell(11,10,6,false,false,false,Vector2(0,0))
			$Red.initial_direction = 1
			$Green.initial_direction = 1


# Just gives the two characters different ID values to reference
# They use the exact same script so this makes differentiating them easier
func assign_ids():
	$Red.id = 1
	$Green.id = 2
	# Just modulates their colors to red and green.
	# Probably worth making separate sprites later.
	$Red.modulate = Color(1,0,0)
	$Green.modulate = Color(0,1,0)


# Passes all data about where a character is standing to it
# Current action tile, its durability, 3x3 floor tiles around it
func pass_tile():
	var red = Tiles.get_tile($Red.position)
	var green = Tiles.get_tile($Green.position)
	$Red.current_tile = $ActionTile.get_cell(red.x,red.y)
	$Green.current_tile = $ActionTile.get_cell(green.x,green.y)
	$Red.current_floor = pass_floor($Red.current_floor,red)
	$Green.current_floor = pass_floor($Green.current_floor,green)
	$Red.current_dur = $DurMap.get_cell(red.x,red.y)
	$Green.current_dur = $DurMap.get_cell(green.x,green.y)


# Only used by pass_tile
# Just gets a cell's tile ID and the 8 around it
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
# Storing a map as an 22*18 image file makes it easy to design and keep many
# different levels without having to actually create them in Godot
# Image size can be larger, but it will only read 18*18 pixels in top left
# Lines 19-22 are for placeable tiles. See tile documentation in levels folder.
# If other colors are added for starting map tiles, make sure to standardize
# and write them down, then add them to this function
# Placeable tiles and other level data will be handled separately
# For placeable tiles, read the documentation in the levels folder
func draw_map(x):
	# Clean up the walls from tile generation
	for index in (30):
		for index2 in (30):
			if $TileMap.get_cell(index2,index) == 0:
				$TileMap.set_cell(index2,index,1,false,false,false,Vector2(0,0))
	
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

# Draws placeable tiles on the right side of the screen
# Basically everything other than read_tiles and actually_draw...
# is the same as draw map
func draw_tiles(x):
	var image = load(x)
	var data = image.get_data()
	data.lock()
	for index in (18):
		var current_tile = []
		for index2 in(4):
			var pixel = data.get_pixel(index2 + 18,index)
			current_tile.append(pixel)
		if (str(current_tile[0]) != "1,1,1,1"):
			var tile = Tiles.read_tile(current_tile)
			print(tile)
			actually_draw_the_tile(tile)

# A separate method just so it can return and end the loop
# If I wasn't so tired I'm sure I'd remember a better way
func actually_draw_the_tile(tile):
	for index in (30):
		for index2 in (30):
			# Places tiles on top of a wall
			# These walls are removed by draw map, so don't leave any tiles with ID 0 elsewhere
			if $TileMap.get_cell(index2,index) == 0 && $ActionTile.get_cell(index2,index) == -1:
				$ActionTile.set_cell(index2,index,tile[0],false,false,false,Vector2(0,0))
				var x = tile[1]
				$DurMap.set_cell(index2,index,x,false,false,false,Vector2(0,0))
				return

# Backup map allows for restoring after reset
func durmap_backup():
	for index in (30):
		for index2 in (30):
			$BackupDurMap.set_cell(index,index2,$DurMap.get_cell(index,index2),false,false,false,Vector2(0,0))
func durmap_restore():
	for index in (30):
		for index2 in (30):
			$DurMap.set_cell(index,index2,$BackupDurMap.get_cell(index,index2),false,false,false,Vector2(0,0))


# Currently functional, less interesting walls
# Just randomly picks a texture of brick
func draw_walls():
	var random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	for index in (18):
		for index2 in (18):
			if $TileMap.get_cell(index,index2) == 0:
				var x = random_generator.randi()%10+1
				if x <= 7:
					$WallGraphics.set_cell(index,index2,9,false,false,false,Vector2(0,0))
				elif x == 8:
					$WallGraphics.set_cell(index,index2,10,false,false,false,Vector2(0,0))
				elif x == 9:
					$WallGraphics.set_cell(index,index2,11,false,false,false,Vector2(0,0))
				elif x >= 10:
					$WallGraphics.set_cell(index,index2,12,false,false,false,Vector2(0,0))


# I hate this function
# Draws wall graphics over the actual functional, pure black walls
# It kind of works
# Maybe worth activating if you can fix the bugs
func draw_walls_new():
	for index in (18):
		for index2 in (18):
			if $TileMap.get_cell(index,index2) == 0 && $TileMap.get_cell(index,index2+1) != 0:
				$WallGraphics.set_cell(index,index2,1,false,false,false,Vector2(0,0))
			elif $TileMap.get_cell(index,index2) == 0 && $TileMap.get_cell(index,index2-1) != 0:
				$WallGraphics.set_cell(index,index2,6,false,false,false,Vector2(0,0))
			elif $TileMap.get_cell(index,index2) == 0 && $TileMap.get_cell(index+1,index2) != 0:
				$WallGraphics.set_cell(index,index2,4,false,false,false,Vector2(0,0))
			elif $TileMap.get_cell(index,index2) == 0 && $TileMap.get_cell(index-1,index2) != 0:
				$WallGraphics.set_cell(index,index2,3,false,false,false,Vector2(0,0))
	
	for index in (18):
		for index2 in (18):
			if $WallGraphics.get_cell(index,index2) != -1 && $TileMap.get_cell(index,index2 + 1) != 0 && $TileMap.get_cell(index + 1,index2) != 0:
				$WallGraphics.set_cell(index,index2,2,false,false,false,Vector2(0,0))
			elif $WallGraphics.get_cell(index,index2) != -1 && $TileMap.get_cell(index,index2 + 1) != 0 && $TileMap.get_cell(index - 1,index2) != 0:
				$WallGraphics.set_cell(index,index2,0,false,false,false,Vector2(0,0))
			elif $WallGraphics.get_cell(index,index2) != -1 && $TileMap.get_cell(index,index2 - 1) != 0 && $TileMap.get_cell(index + 1,index2) != 0:
				$WallGraphics.set_cell(index,index2,7,false,false,false,Vector2(0,0))
			elif $WallGraphics.get_cell(index,index2) != -1 && $TileMap.get_cell(index,index2 - 1) != 0 && $TileMap.get_cell(index - 1,index2) != 0:
				$WallGraphics.set_cell(index,index2,5,false,false,false,Vector2(0,0))
	
	for index in (18):
		if index != 0 && index != 17 && $TileMap.get_cell(16,index) != 0:
			$WallGraphics.set_cell(17,index,8,false,false,false,Vector2(0,0))
		if index != 0 && index != 17 && $TileMap.get_cell(1,index) != 0:
			$WallGraphics.set_cell(0,index,8,false,false,false,Vector2(0,0))

# Temporary buttons
func _on_Button_pressed():
	Global.return_menu()
func _Back_Button_Entered(area):
	current_button = 1
func _Back_Button_Left(area):
	current_button = 0


# If a character enters a wall
# x = character frame count, y = fail state
# For more info on these variables, see Character
func fail_check(x,y):
	if x != -1 && y == true:
		$LossGraphic.visible = true
		$LossTimer.start()
		$Red.failed = false
		$Green.failed = false
		$Green.reset()
		$Red.reset()
		durmap_restore()


func _on_LossTimer_timeout():
	$LossGraphic.visible = false


# Does what the name suggests
# pos = position of character
func lower_durability(pos):
	# Convert to tile instead of raw position
	pos = Tiles.get_tile(pos)
	# Get durability of that tile
	var dur = $DurMap.get_cell(pos.x,pos.y)
	# If tile isn't used up or infinite, lower the durability
	if dur > 0 && dur < 5:
		$DurMap.set_cell(pos.x,pos.y,dur-1,false,false,false,Vector2(0,0))


# This thing is magic
# x = character ID
func _on_dur_lower_signal(x):
	if x == 1:
		lower_durability($Red.position)
	elif x == 2:
		lower_durability($Green.position)
