extends Node

# Zombie Game (or whatever it gets renamed)
#
# Written by Ryan Brown and Lucas De Caux for Dr. G's Fall 2022 educational games co-op.
# Primarily commented by Ryan Brown.
#
# This is the first scene you'll see, so here's some information.
# Directly to the left there's a list of all scripts in this project.
# Both Global.gd and Tile_Functions.gd are globally accessible.
# You can access their functions and variables with Global.whatever and Tiles.whatever.
#
# Also, sorry for any hell-code we left in.


# Change as levels are added
var last_level = 9

var current_button = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str("Current level: " + str(Global.level_int))
	
	if current_button == 1 && Input.is_action_just_pressed("select"):
		_on_Button_pressed()
	elif current_button == 2 && Input.is_action_just_pressed("select"):
		_on_Button2_pressed()
		
func _on_Button_pressed():
	Global.menu = false
	get_tree().change_scene("res://TSCN/World.tscn")


func _on_Button2_pressed():
	if (Global.level_int == last_level):
		Global.change_level(1)
	else:
		var x = Global.level_int + 1
		Global.change_level(x)


func _Start_Button_Entered(area):
	current_button = 1
func _Start_Button_Left(area):
	current_button = 0
func _Level_Button_Entered(area):
	current_button = 2
func _Level_Button_Left(area):
	current_button = 0
