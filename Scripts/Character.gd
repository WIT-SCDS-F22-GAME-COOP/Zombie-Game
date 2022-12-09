extends KinematicBody2D

# Direction variables.
# Defaults to facing up if not set in $World.level_specific().
var direction = 0
var initial_direction = 0
# Direction used for push tiles.
var move_direction = -1

var id = 0
var frames = -1
var failed = false

# Position related data
# Passed from World
var starting_pos = Vector2.ZERO
var current_tile = -1
# 3x3 grid around position
# Left to right, top to bottom
var current_floor = [-1,-1,-1,-1,-1,-1,-1,-1,-1,]
var current_dur = -1

# Signals to World when using a tile.
signal dur_lower(x)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Sets initial direction and position after 0.01 seconds.
	# Makes sure $World.level_specific() has completed before setting them.
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# By setting frames to anything other than -1 movement starts.
	if Input.is_action_just_pressed("start_level"):
		frames = 0
	
	# Resets the character.
	# Same button is mapped to all reset functions.
	if Input.is_action_just_pressed("reset_level") && starting_pos != Vector2(0,0):
		reset()
	
	# Works as long as the level is not reset and the character has not already won.
	# Tick every five frames.
	if frames != -1 && global_position.x > 0:
		frames = frames + 1
		if frames % 5 == 0:
			tick()
	
	# If in a wall, failed = true.
	# In World.tscn this is read and checked.
	if current_floor[4] == 0:
		failed = true
	
	if (direction == 0):
		$Sprite.set_rotation_degrees(0)
	elif (direction == 1):
		$Sprite.set_rotation_degrees(90)
	elif (direction == 2):
		$Sprite.set_rotation_degrees(180)
	elif (direction == 3):
		$Sprite.set_rotation_degrees(270)

# Update with any new level attributes added
# Resets character to original position, direction, etc.
func reset():
	frames = -1
	Global.points = 0
	global_position = starting_pos
	direction = initial_direction
	move_direction = -1

# Runs whenever current frame is divisble by 5.
# Game runs at 30 FPS.
func tick():
	# Sets direction based on tile.
	use_tile(current_tile)
	# If not being pushed by a push tile.
	# For all other cases
	if (move_direction == -1):
		direction = walk(direction)
	# For when being pushed.
	else:
		# Pushes don't change direction, so the return isn't saved.
		walk(move_direction)
		# Resets the direction used to push.
		move_direction = move_direction - 1
		if move_direction == 0:
			move_direction = -1

# Current facing direction. 0 Up, 1 right, 2 down, 3 left
func walk(x):
	# If statement checks if NOT on character's win spot.
	if (current_floor[4] - 1 != id):
		# Check if hitting a wall.
		# If hits a wall, flip and go the opposite direction.
		x = wall_check(x)
		match(x):
			0:
				global_position.y = global_position.y - 64
			1:
				global_position.x = global_position.x + 64
			2:
				global_position.y = global_position.y + 64
			3:
				global_position.x = global_position.x - 64
	# If character wins.
	# Move off the map and add a point.
	else:
		global_position = Vector2(-128,-64)
		Global.points = Global.points + 1
		print(Global.points)
	# Return the direction after using the tile.
	return x


func wall_check(x):
	match(x):
		0:
			if (current_floor[1] == 0 || current_floor[1] - id == 10):
				x = Tiles.flip(x)
		1:
			if (current_floor[5] == 0 || current_floor[5] - id == 10):
				x = Tiles.flip(x)
		2:
			if (current_floor[7] == 0 || current_floor[7] - id == 10):
				x = Tiles.flip(x)
		3:
			if (current_floor[3] == 0 || current_floor[3] - id == 10):
				x = Tiles.flip(x)
	return x


func use_tile(x):
	# Check if color specific tile. If so, converts.
	x = convert_color(x)
	# Check if durability is present.
	# If not, try to use permanent floor tile.
	if current_dur > 0:
		# Uses the current tile.
		# Turns methods are in Tile_Functions.gd
		# Pushes are just in the tick function.
		match(x):
			0:
				direction = Tiles.turn(direction,false)
				emit_signal("dur_lower",id)
			1:
				direction = Tiles.turn(direction,true)
				emit_signal("dur_lower",id)
			# UDLR
			2:
				move_direction = 0
				emit_signal("dur_lower",id)
			3:
				move_direction = 2
				emit_signal("dur_lower",id)
			4:
				move_direction = 3
				emit_signal("dur_lower",id)
			5:
				move_direction = 1
				emit_signal("dur_lower",id)
	elif x == -1:
				use_permanent_tile()

# Converts tile values to the ones for general use tiles.
func convert_color(x):
	# Only works if the ID is correct for the color.
	# Green
	if id == 2:
		match(x):
			6:
				x = 0
			7:
				x = 1
			8:
				x = 2
			9:
				x = 3
			10:
				x = 4
			11:
				x = 5
	elif id == 1:
		# Yeah, just subtract an extra 6 for red. Easy.
		match(x - 6):
			6:
				x = 0
			7:
				x = 1
			8:
				x = 2
			9:
				x = 3
			10:
				x = 4
			11:
				x = 5
	return x


# TurnL 5, TurnR 6, Up 7, Down 8, Left 9, Right 10
# Works the same as action tiles but a permanent part of the floor.
func use_permanent_tile():
	var x = current_floor[4] - 5
	match(x):
		0:
			direction = Tiles.turn(direction,false)
		1:
			direction = Tiles.turn(direction,true)
		# UDLR
		2:
			move_direction = 0
		3:
			move_direction = 2
		4:
			move_direction = 3
		5:
			move_direction = 1


# And this is where the initial variables are actually set.
func _on_Timer_timeout():
	starting_pos = global_position
	direction = initial_direction
