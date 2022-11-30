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
#func _process(delta):
#	pass

func change_level(x):
	level = "res://Levels/" + str(x) + ".png"
	level_int = x
	print(level)

func return_menu():
	menu = true
	points = 0
	get_tree().change_scene("res://TSCN/Menu.tscn")
