extends KinematicBody2D

var tile_position = Vector2.ZERO
var direction = 0

func _ready():
	global_position = Vector2(32,32)


func _process(delta):
	tile_position = Tiles.get_tile(global_position)
	move()


# Moves the cursor
# Currently hard coded to stay within window size
# But it would probably be better to restrict to tiles later
func move():
	if Input.is_action_just_pressed("move_right") && tile_position.x < 26:
		global_position.x = global_position.x + 64
	if Input.is_action_just_pressed("move_left") && tile_position.x > 0:
		global_position.x = global_position.x - 64
	if Input.is_action_just_pressed("move_up") && tile_position.y > 0:
		global_position.y = global_position.y - 64
	if Input.is_action_just_pressed("move_down") && tile_position.y < 17:
		global_position.y = global_position.y + 64
