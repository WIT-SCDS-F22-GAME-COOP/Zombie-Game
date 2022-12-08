extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# dir: Current facing direction. 0 Up, 1 right, 2 down, 3 left
# right: Turning direction. T = right, F = left
func turn(dir,right):
	if (right):
		if dir < 3:
			dir = dir + 1
		elif dir == 3:
			dir = 0
	else:
		if dir > 0:
			dir = dir - 1
		elif dir == 0:
			dir = 3
	return dir

# Turns direction around to the opposite
# I mean, what did you think flipping was?
# Same direction values as used by turn, as well as basically everything else.
func flip(dir):
	match(dir):
		0:
			dir = 2
		1:
			dir = 3
		2:
			dir = 0
		3:
			dir = 1
	return dir

# Converts a position value to a tile
# Each tile is 64 pixels, so they get divided by 64.
# And characters go in the middle, so subtract half a tile.
func get_tile(a):
	var b = Vector2.ZERO
	b.x = (a.x - 32) / 64
	b.y = (a.y - 32) / 64
	return b

# Turns placeable tile names readable, then send to interpret tile
# At the end returns the ID of a tile
# arr is the values of the final four columns in the image
# x[0] = tile ID, x[1] = tile durability
func read_tile(arr):
	var name
	var dur = -1
	
	if str(arr[0]) == "0,0,0,1":
		name = "turn"
	elif str(arr[0]) == "1,0,0,1":
		name = "push"
	else:
		name = "ERROR"
	
	if str(arr[1]) == "1,0,0,1":
		name = name + "red"
	elif str(arr[1]) == "0,1,0,1":
		name = name + "green"
	else:
		name = name + "gen"
	
	if str(arr[2]) == "1,1,1,1":
		name = name + "up"
	elif str(arr[2]) == "0,0,0,1":
		name = name + "right"
	elif str(arr[2]) == "1,0,0,1":
		name = name + "down"
	elif str(arr[2]) == "0,1,0,1":
		name = name + "left"
	else:
		name = name + "ERROR"
	
	if str(arr[3]) == "1,1,1,1":
		dur = 1
	elif str(arr[3]) == "0,0,0,1":
		dur = 2
	elif str(arr[3]) == "1,0,0,1":
		dur = 3
	elif str(arr[3]) == "0,1,0,1":
		dur = 4
	else:
		dur = 5
	
	var x = []
	x.append(name)
	x.append(dur)
	x = interpret_tile(x)
	return x

# I hate how this is more efficient than the alternative
# These are literally all just converting to tile IDs
# If you ever reorder the action tiles, you'll have to fix ALL of this
func interpret_tile(arr):
	match(arr[0]):
		"pushredup":
			arr[0]=14
		"pushredright":
			arr[0]=17
		"pushreddown":
			arr[0]=15
		"pushredleft":
			arr[0]=16
		"turnredright":
			arr[0]=13
		"turnredleft":
			arr[0]=12
		"pushgreenup":
			arr[0]=8
		"pushgreenright":
			arr[0]=11
		"pushgreendown":
			arr[0]=9
		"pushgreenleft":
			arr[0]=10
		"turngreenright":
			arr[0]=7
		"turngreenleft":
			arr[0]=6
		"pushgenup":
			arr[0]=2
		"pushgenright":
			arr[0]=5
		"pushgendown":
			arr[0]=3
		"pushgenleft":
			arr[0]=4
		"turngenright":
			arr[0]=1
		"turngenleft":
			arr[0]=0
		_:
			arr[0] = -1
			arr[1] = -1
	
	# Hopefully this is never able to happen
	if "ERROR" in str(arr[0]):
		arr[0] = -1
		arr[1] = -1
	
	return arr
