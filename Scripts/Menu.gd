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
var last_level = 14

var current_button = 0

# Feel free to edit yourself in if you contributed
onready var file = "res://Levels/LevelCredits.txt"
var credits = "DEFAULT"

var menu_location = 0

# Import font to project
onready var path2font = "res://Graphics/font/Boxy-Bold.ttf"




# Called when the node enters the scene tree for the first time.
func _ready():
	load_file(file)
	$Credits.text = credits

	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load(path2font)
	dynamic_font.size = 8
	$Button.set("custom_fonts/font", dynamic_font)
	$Button2.set("custom_fonts/font", dynamic_font)
	$Button3.set("custom_fonts/font", dynamic_font)
	$Label.set("custom_fonts/font", dynamic_font)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str("Current level: " + str(Global.level_int))
	
	if current_button == 1 && Input.is_action_just_pressed("select"):
		_on_Button_pressed()
	elif current_button == 2 && Input.is_action_just_pressed("select"):
		_on_Button2_pressed()
	elif current_button == 3 && Input.is_action_just_pressed("select"):
		_on_Button3_pressed()
	elif (Input.is_action_just_pressed("select") || Input.is_action_just_pressed("click")) && $Cursor.position.x < 0:
		$Camera2D2.current = false
		$Camera2D.current = true
		menu_location = 0
		$Cursor._ready()
	
	# The scroll currently stops to leave everything on screen
	# But it's close to not all fitting
	# So I'm sure you can solve that
	if menu_location == 1 && $Credits.rect_global_position.y >= 69:
		$Credits.rect_global_position.y = $Credits.rect_global_position.y - 3
	elif menu_location != 1:
		$Credits.rect_global_position.y = 1152

func load_file(file):
	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		if (credits == "DEFAULT"):
			credits = line
		else:
			credits = credits + "\n" + line
		line += " "
		index += 1
	f.close()
	return

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
func _on_Button3_area_entered(area):
	current_button = 3
func _on_Button3_area_exited(area):
	current_button = 0


func _on_Button3_pressed():
	$Camera2D.current = false
	$Camera2D2.current = true
	menu_location = 1
	$Cursor.position = Vector2(-6400,-6400)
