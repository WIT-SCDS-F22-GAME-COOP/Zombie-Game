extends KinematicBody2D

var direction = 0
var initial_direction = 0
var move_direction = -1

var id = 0

var starting_pos = Vector2.ZERO
var current_tile = -1
var current_floor = [-1,-1,-1,-1,-1,-1,-1,-1,-1,]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do not leave active after game timer implemented
	# Mapped to R button, walks
	if Input.is_action_just_pressed("debug_input"):
		use_tile()
		if (move_direction == -1):
			direction = walk(direction)
		else:
			# direction = walk(move_direction)
			walk(move_direction)
			move_direction = -1
	# Mapped to T button, turns right
	if Input.is_action_just_pressed("debug_input2"):
		direction = Tiles.turn(direction, true)
		# print(current_tile)
	
	# Update with any new level attributes added
	if Input.is_action_just_pressed("reset_level") && starting_pos != Vector2(0,0):
		Global.points = 0
		global_position = starting_pos
		direction = initial_direction
		move_direction = -1


# Current facing direction. 0 Up, 1 right, 2 down, 3 left
func walk(x):
	if (current_floor[4] - 1 != id):
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
	else:
		global_position = Vector2(-128,-64)
		Global.points = Global.points + 1
		print(Global.points)
	return x


func wall_check(x):
	match(x):
		0:
			if (current_floor[1] == 0):
				x = Tiles.flip(x)
		1:
			if (current_floor[5] == 0):
				x = Tiles.flip(x)
		2:
			if (current_floor[7] == 0):
				x = Tiles.flip(x)
		3:
			if (current_floor[3] == 0):
				x = Tiles.flip(x)
	return x


func use_tile():
	match(current_tile):
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


func _on_Timer_timeout():
	starting_pos = global_position
	direction = initial_direction
