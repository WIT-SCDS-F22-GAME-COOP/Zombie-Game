extends Node


var menu = true
var level_int = 0
var level = "res://Levels/0.png"

var points = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	print(level)
	pass # Replace with function body.


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
