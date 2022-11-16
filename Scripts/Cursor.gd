extends KinematicBody2D

var tile_position = Vector2.ZERO
var direction = 0

func _ready():
	global_position = Vector2(64+32,64+32)


func _process(delta):
	tile_position = Tiles.get_tile(global_position)
	move()


# Moves the cursor
# Currently hard coded to stay within window size
# But it would probably be better to restrict to tiles later
func move():
	if Input.is_action_just_pressed("move_right") && tile_position.x < 25:
		global_position.x = global_position.x + 64
		direction = 1
	if Input.is_action_just_pressed("move_left") && tile_position.x > 1:
		global_position.x = global_position.x - 64
		direction = 3
	if Input.is_action_just_pressed("move_up") && tile_position.y > 1:
		global_position.y = global_position.y - 64
		direction = 0
	if Input.is_action_just_pressed("move_down") && tile_position.y < 16:
		global_position.y = global_position.y + 64
		direction = 2
	if (tile_position.x == 17):
		global_position.x = global_position.x + 128
	elif (tile_position.x == 18):
		global_position.x = global_position.x - 128
