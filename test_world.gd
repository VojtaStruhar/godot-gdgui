extends Node3D

@onready var gui: GDGui = %GDGui

var lesgo = false
var numeric: float = 20

var options = ["Pizza", "Hamburger", "French Fries"]
var selected_option = 0

func gdgui():
	gui.label(options[selected_option] + " is the best")
	
	gui.begin_panel()
	gui.label(str(numeric))
	
	gui.begin_horizontal()
	gui.label("Threshold")
	
	gui.separator()
	
	numeric = gui.slider(numeric, 0, 1)
	gui.end_horizontal()
	
	gui.end_panel()
	
	gui.separator()
	
	selected_option = gui.dropdown(selected_option, options)


func _process(_delta: float) -> void:
	gdgui()
