extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

var lesgo = false
var numeric = 20

func gui():
	gdgui.label("lesgo: " + str(lesgo))
	
	
	gdgui.begin_panel()
	gdgui.label(str(numeric))
	
	gdgui.begin_horizontal()
	gdgui.label("Threshold")
	numeric = gdgui.slider(numeric, 50, 0)
	gdgui.end_horizontal()
	
	gdgui.end_panel()



func _process(_delta: float) -> void:
	pass
	gui()
