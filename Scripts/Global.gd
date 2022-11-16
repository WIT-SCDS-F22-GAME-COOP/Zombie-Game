extends Node


var menu = true
var level_int = 0
var level = "res://Levels/0.png"


# Called when the node enters the scene tree for the first time.
func _ready():
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
	get_tree().change_scene("res://TSCN/Menu.tscn")
