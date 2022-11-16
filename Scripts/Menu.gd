extends Node

# Change as levels are added
var last_level = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	$Label.text = str(Global.level_int)

# Buttons are for testing only

func _on_Button_pressed():
	Global.menu = false
	get_tree().change_scene("res://TSCN/World.tscn")


func _on_Button2_pressed():
	if (Global.level_int == last_level):
		Global.change_level(0)
	else:
		var x = Global.level_int + 1
		Global.change_level(x)
