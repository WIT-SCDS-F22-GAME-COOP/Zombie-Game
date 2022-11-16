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


# Converts a position value to a tile
func get_tile(a):
	var b = Vector2.ZERO
	b.x = (a.x - 32) / 64
	b.y = (a.y - 32) / 64
	return b
