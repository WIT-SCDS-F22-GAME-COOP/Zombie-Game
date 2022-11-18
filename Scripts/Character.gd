extends KinematicBody2D

var direction = 0
var move_direction = -1

var id = 0

var starting_pos = Vector2.ZERO
var current_tile = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do not leave active after game timer implemented
	# Mapped to R button, walks
	if Input.is_action_just_pressed("debug_input"):
		use_tile()
		if (move_direction == -1):
			walk(direction)
		else:
			walk(move_direction)
			move_direction = -1
	# Mapped to T button, turns right
	if Input.is_action_just_pressed("debug_input2"):
		direction = Tiles.turn(direction, true)
		print(current_tile)


# Current facing direction. 0 Up, 1 right, 2 down, 3 left
func walk(x):
	match(x):
		0:
			global_position.y = global_position.y - 64
		1:
			global_position.x = global_position.x + 64
		2:
			global_position.y = global_position.y + 64
		3:
			global_position.x = global_position.x - 64


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
