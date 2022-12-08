extends KinematicBody2D

var tile_position = Vector2.ZERO
var direction = 0

func _ready():
	if Global.menu:
		global_position = Vector2(64*9+32,64*9+32)
	else:
		global_position = Vector2(64*22+32,64*11+32)


func _process(delta):
	tile_position = Tiles.get_tile(global_position)
	move()


# Moves the cursor
# Currently hard coded to stay within window size
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
	
	# When not in the menu, jumps the divder between level and tiles.
	# It looks a little odd at 30 FPS, since you can for a moment see the cursor on the wall.
		# The game runs at 30 FPS because this was written for the arcade machine, 
		# and Wentworth loves to just reuse Razer laptops, which, by default, lock to 30 FPS
		# if they come unplugged from the wall. This way, nothing breaks if that happens.
	# It can definitely be fixed, but it functionally changes nothing.
	if (Global.menu == false):
		if (tile_position.x == 17):
			global_position.x = global_position.x + 128
		elif (tile_position.x == 18):
			global_position.x = global_position.x - 128
