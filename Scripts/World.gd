extends Node

var current_button = 0
var selected_tile_pos = Vector2.ZERO
# X = Tile, Y = Durability
var selected_tile = Vector2(-1,-1)

var new_walls = false

var level_name = "UNNAMED"

# Import font to project
onready var path2font = "res://Graphics/font/Boxy-Bold.ttf"

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_ids()
	draw_tiles(Global.level)
	draw_map(Global.level)
	durmap_backup()
	level_specific()
	$Label.text = level_name
	if new_walls:
		draw_walls_new()
	else:
		draw_walls()

	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load(path2font)
	dynamic_font.size = 8
	$Button.set("custom_fonts/font", dynamic_font)
	$Button2.set("custom_fonts/font", dynamic_font)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	# If a level is left unnamed, shows the tile coordinates of the cursor instead
	# Useful for figuring out specific placements when implementing new levels
	if level_name == "UNNAMED":
		$Label.text = str($Cursor.tile_position)
	
	if current_button == 1 && Input.is_action_just_pressed("select"):
		_on_Button_pressed()
	if current_button == 2 && Input.is_action_just_pressed("select"):
		_on_Button2_pressed()
	
	if Input.is_action_just_pressed("select"):
		selection()
	
	# Pass information about the current location of the characters to them.
	pass_tile()
	
	# The only time you have two points is when both characters have won.
	# For the race gamemode, instead checks for win or loss depending on
	# which character has won
	# Continuously checked in case reset is pressed after winning.
	if (Global.points >= 2 && Global.race == false):
		$WinGraphic.visible = true
	elif (Global.points == 1 && Global.race == true && $Red.position.x < 0 && $Green.position.x > 0):
		$WinGraphic.visible = true
		$Red.frames = -1
		$Green.frames = -1
	elif (Global.race == true && $Green.position.x < 0):
		$RaceLossGraphic.visible = true
		$Red.frames = -1
		$Green.frames = -1
	else:
		$WinGraphic.visible = false
		$RaceLossGraphic.visible = false
	
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

#Sets the Selected tile variable to whatever tile you select
#if you have a tile selected, choosing an empty square will move your selected tile there
func selection():
	$LossGraphic.visible = false
	if ($ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) != -1 && initial_pos_check()):
		selected_tile_pos = $Cursor.tile_position
		selected_tile.x = $ActionTile.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y)
		selected_tile.y = $DurMap.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y)
		$SelectedCursor.position = $Cursor.position
		setText()
	elif (selected_tile.x != -1 && $TileMap.get_cell($Cursor.tile_position.x, $Cursor.tile_position.y) == 1 && initial_pos_check()):
		$ActionTile.set_cell($Cursor.tile_position.x, $Cursor.tile_position.y, selected_tile.x, false,false,false, Vector2(0,0))
		$ActionTile.set_cell(selected_tile_pos.x, selected_tile_pos.y, -1, false,false,false, Vector2(0,0))
		$DurMap.set_cell($Cursor.tile_position.x, $Cursor.tile_position.y, selected_tile.y, false,false,false, Vector2(0,0))
		$DurMap.set_cell(selected_tile_pos.x, selected_tile_pos.y, -1, false,false,false, Vector2(0,0))
		selected_tile.x = -1
		selected_tile.y = -1
		durmap_backup()
		$MarginContainer2/RichTextLabel.text = "Select a tile to see info"
		$SelectedCursor.position = Vector2(-256,0)

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
			level_name = "Starting Simple"
		2:
			$Red.position = Vector2(6*64+32,16*64+32)
			$Green.position = Vector2(7*64+32,16*64+32)
			level_name = "The Long Way Around"
		4:
			$Red.position = Vector2(16*64+32,16*64+32)
			$Green.position = Vector2(15*64+32,16*64+32)
			level_name = "Hitting a Wall"
		3:
			$Red.position = Vector2(2*64+32,8*64+32)
			$Green.position = Vector2(1*64+32,8*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 1
			level_name = "Acrobatics"
		5:
			$Red.position = Vector2(2*64+32,6*64+32)
			$Green.position = Vector2(1*64+32,6*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 1
			level_name = "Cornering"
		6:
			$Red.position = Vector2(1*64+32,2*64+32)
			$Green.position = Vector2(14*64+32,2*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 3
			$TileMap.set_cell(7,1,10,false,false,false,Vector2(0,0))
			$TileMap.set_cell(8,1,6,false,false,false,Vector2(0,0))
			$TileMap.set_cell(16,1,8,false,false,false,Vector2(0,0))
			$TileMap.set_cell(16,2,6,false,false,false,Vector2(0,0))
			level_name = "Multi Function Room"
		7:
			$Red.position = Vector2(1*64+32,2*64+32)
			$Green.position = Vector2(14*64+32,2*64+32)
			$Red.initial_direction = 1
			$Green.initial_direction = 3
			$TileMap.set_cell(7,1,10,false,false,false,Vector2(0,0))
			$TileMap.set_cell(8,1,6,false,false,false,Vector2(0,0))
			$TileMap.set_cell(16,1,8,false,false,false,Vector2(0,0))
			$TileMap.set_cell(16,2,6,false,false,false,Vector2(0,0))
			level_name = "Something Missing"
		9:
			$Red.position = Vector2(8*64+32,11*64+32)
			$Green.position = Vector2(8*64+32,10*64+32)
			$TileMap.set_cell(8,5,11,false,false,false,Vector2(0,0))
			$TileMap.set_cell(5,9,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(5,12,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(6,12,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(6,11,10,false,false,false,Vector2(0,0))
			$TileMap.set_cell(7,11,10,false,false,false,Vector2(0,0))
			level_name = "One Way"
		11:
			$Red.position = Vector2(1*64+32,1*64+32)
			$Green.position = Vector2(16*64+32,16*64+32)
			$Red.initial_direction = 2
			$TileMap.set_cell(1,10,11,false,false,false,Vector2(0,0))
			level_name = "A Difficult Task"
		8:
			$Red.position = Vector2(2*64+32,8*64+32)
			$Green.position = Vector2(1*64+32,8*64+32)
			$TileMap.set_cell(11,10,6,false,false,false,Vector2(0,0))
			$Red.initial_direction = 1
			$Green.initial_direction = 1
			level_name = "Single Function Room"
		10:
			$Red.position = Vector2(2*64+32,14*64+32)
			$Green.position = Vector2(1*64+32,2*64+32)
			$Green.initial_direction = 1
			level_name = "Snake"
		12:
			# This action tile is meant to be placed manually in code
			# Do not remove
			$ActionTile.set_cell(16,11,5,false,false,false,Vector2(0,0))
			$DurMap.set_cell(16,11,5,false,false,false,Vector2(0,0))
			$BackupDurMap.set_cell(16,11,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(18,11,4,false,false,false,Vector2(0,0))
			$Green.position = Vector2(15*64+32,6*64+32)
			$Red.position = Vector2(8*64+32,16*64+32)
			$Red.initial_direction = 1
			level_name = "Take Control"
		13:
			$Red.position = Vector2(0*64+32,10*64+32)
			$Green.position = Vector2(1*64+32,9*64+32)
			$TileMap.set_cell(17,9,5,false,false,false,Vector2(0,0))
			level_name = "coop demo"
			Global.race = true
			$Red.initial_direction = 1
			$Green.initial_direction = 1
		14:
			$Red.position = Vector2(15*64+32,9*64+32)
			$Green.position = Vector2(2*64+32,3*64+32)
			$TileMap.set_cell(2,6,6,false,false,false,Vector2(0,0))
			$TileMap.set_cell(3,6,9,false,false,false,Vector2(0,0))
			$TileMap.set_cell(4,6,9,false,false,false,Vector2(0,0))
			$TileMap.set_cell(15,2,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(12,2,5,false,false,false,Vector2(0,0))
			$TileMap.set_cell(12,11,6,false,false,false,Vector2(0,0))
			$TileMap.set_cell(1,11,6,false,false,false,Vector2(0,0))
			level_name = "Time Stall"
			
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
	for index in (5):
		for index2 in (5):
			if $TileMap.get_cell(index2+20,index+6) == 0:
				$TileMap.set_cell(index2+20,index+6,1,false,false,false,Vector2(0,0))
	
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
	for index in (29):
		for index2 in (5):
			# Places tiles on top of a wall
			# These walls are removed by draw map, so don't leave any tiles with ID 0 elsewhere
			if $TileMap.get_cell(index2+20,index+1) == 0 && $ActionTile.get_cell(index2+20,index+1) == -1:
				$ActionTile.set_cell(index2+20,index+1,tile[0],false,false,false,Vector2(0,0))
				var x = tile[1]
				$DurMap.set_cell(index2+20,index+1,x,false,false,false,Vector2(0,0))
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
	for index in (30):
		for index2 in (30):
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
func _on_Button2_pressed():
	if $Red.frames == -1 && initial_pos_check():
		$Red.frames = 0
		$Green.frames = 0
	else:
		$Green.reset()
		$Red.reset()
		durmap_restore()
func _on_Area2D_area_entered(area):
	current_button = 2
func _on_Area2D_area_exited(area):
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


# Mouse support
# Left click to move and select
# Right click to only move
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton && Input.is_action_just_pressed("click"):
		move_mouse(event)
		$Timer.start()
	elif event is InputEventMouseButton && Input.is_action_just_pressed("click_r"):
		move_mouse(event)

func move_mouse(event):
	var x = int(event.position.x)
	var y = int(event.position.y)
	x = int(x/64)
	y = int(y/64)
	$Cursor.position = Vector2(x*64+32,y*64+32)

func _on_Timer_timeout():
	selection()
	
#sets the text for the text box to explain selected tile
func setText():
	var text = ""
	var dur = $DurMap.get_cell(selected_tile_pos.x,selected_tile_pos.y)
	if (dur == 1):
		text = set_text_helper(false)
	elif (dur == 5):
		text += "while(true){\n   "
		text += set_text_helper(true)
		text += "   }\n"
		text += "}"
	elif (dur > 1):
		text += "int i = 0;\nwhile(i < "
		text += String(dur)
		text += "){\n   "
		text += set_text_helper(true)
		text += "   i++;\n"
		text += "   }"
		text += "\n}"
	$MarginContainer2/RichTextLabel.text = text
	
	
#Helper function for setText
#This is kinda gross but I couldnt think of a better way to do it with accurate spacing
func set_text_helper(indented):
	print(selected_tile.x)
	match int(selected_tile.x):
		0:
			return "turnLeft();\n"
		1:
			return "turnRight();\n"
		2:
			return "moveUp();\n"
		3:
			return "moveDown();\n"
		4:
			return "moveLeft();\n"
		5:
			return "moveRight();\n"
		6:
			if indented:
				return "if(species == zombie){\n      turnLeft();\n   "
			return "if(species == zombie){\n   turnLeft();\n}"
		7:
			if indented:
				return "if(species == zombie){\n      turnRight();\n   "
			return "if(species == zombie){\n   turnRight();\n}"
		8:
			if indented:
				return "if(species == zombie){\n      moveUp();\n   "
			return "if(species == zombie){\n   moveUp();\n}"
		9:
			if indented:
				return "if(species == zombie){\n      moveDown();\n   "
			return "if(species == zombie){\n   moveDown();\n}"
		10:
			if indented:
				return "if(species == zombie){\n      moveLeft();\n   "
			return "if(species == zombie){\n   moveLeft();\n}"
		11:
			if indented:
				return "if(species == zombie){\n      moveRight();\n   "
			return "if(species == zombie){\n   moveRight();\n}"
		12:
			if indented:
				return "if(species == human){\n      turnLeft();\n   "
			return "if(species == human){\n   turnLeft();\n}"
		13:
			if indented:
				return "if(species == human){\n      turnRight();\n   "
			return "if(species == human){\n   turnRight();\n}"
		14:
			if indented:
				return "if(species == human){\n      moveUp();\n   "
			return "if(species == human){\n   moveUp();\n}"
		15:
			if indented:
				return "if(species == human){\n      moveDown();\n   "
			return "if(species == human){\n   moveDown();\n}"
		16:
			if indented:
				return "if(species == human){\n      moveLeft();\n   "
			return "if(species == human){\n   moveLeft();\n}"
		17:
			if indented:
				return "if(species == human){\n      moveRight();\n   "
			return "if(species == human){\n   moveRight();\n}"
		_: 
			return "ERROR"
