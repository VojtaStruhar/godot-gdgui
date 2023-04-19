extends Node3D

@onready var gdgui: GDGui = %GDGui

var lesgo = false
var numeric: float = 20

var options = ["Pizza", "Hamburger", "French Fries"]

func gui():
	gdgui.label("lesgo: " + str(lesgo))
	
	gdgui.separator()
	
	gdgui.begin_panel()
	gdgui.label(str(numeric))
	
	gdgui.separator()
	
	gdgui.begin_horizontal()
	gdgui.label("Threshold")
	
	gdgui.separator()
	
	numeric = gdgui.slider(numeric, 0, 1)
	gdgui.end_horizontal()
	
	gdgui.end_panel()



func _process(_delta: float) -> void:
	pass
	gui()
