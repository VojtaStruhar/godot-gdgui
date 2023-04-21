extends Node3D

@onready var gui: GDGui = %GDGui

var lesgo = false
var numeric: float = 20
var number2 = 10
var title = ""

var options = ["Pizza", "Hamburger", "French Fries"]
var selected_option = 0

func gdgui():
	gui.label(title)
	gui.separator()
	gui.label(options[selected_option] + " is the best")
	
	gui.begin_panel()
	gui.label(str(numeric))
	
	gui.begin_horizontal()
	gui.label("Threshold")
	
	gui.separator()
	
	numeric = gui.slider(numeric, 0, 1)
	gui.end_horizontal()
	
	gui.end_panel()
	
	lesgo = gui.checkbox("Show food options", lesgo)
	if lesgo:
		gui.separator()
		gui.space()
		
		selected_option = gui.dropdown(selected_option, options)
	
	options[0] = gui.textfield(options[0])
	gui.space()
	number2 = gui.numberfield(number2, 0, 20, 0.5, true)

func _process(_delta: float) -> void:
	gdgui()
