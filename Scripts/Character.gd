extends KinematicBody2D

var direction = 0
var initial_direction = 0
var move_direction = -1

var id = 0
var frames = -1
var failed = false

var starting_pos = Vector2.ZERO
var current_tile = -1
var current_floor = [-1,-1,-1,-1,-1,-1,-1,-1,-1,]
var current_dur = -1
signal dur_lower(x)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start_level"):
		frames = 0
	
	if Input.is_action_just_pressed("reset_level") && starting_pos != Vector2(0,0):
		reset()
	
	if frames != -1 && global_position.x > 0:
		frames = frames + 1
		if frames % 5 == 0:
			tick()
	
	if current_floor[4] == 0:
		failed = true

# Update with any new level attributes added
func reset():
	frames = -1
	Global.points = 0
	global_position = starting_pos
	direction = initial_direction
	move_direction = -1

func tick():
	use_tile(current_tile)
	if (move_direction == -1):
		direction = walk(direction)
	else:
		# direction = walk(move_direction)
		walk(move_direction)
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
	x = convert_color(x)
	if current_dur > 0:
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


func convert_color(x):
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


func _on_Timer_timeout():
	starting_pos = global_position
	direction = initial_direction
