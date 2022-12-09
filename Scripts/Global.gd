extends Node


var menu = true
var level_int = 1
var level

var points = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	change_level(level_int)
	OS.set_window_maximized(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("f11"):
		OS.window_fullscreen = !OS.window_fullscreen

# Changes what level is started when start is pressed
# x is an integer value that corresponds to a level number
# I suppose it could read any string, technically
# However all levels are currently numbered to easily cycle them.
func change_level(x):
	level = "res://Levels/" + str(x) + ".png"
	level_int = x
	print(level)

# Resets the variables necessary for the menu
# Then actually returns to menu
func return_menu():
	menu = true
	points = 0
	get_tree().change_scene("res://TSCN/Menu.tscn")
