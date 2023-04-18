extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

var lesgo = false


func gui():
	gdgui.label("lesgo: " + str(lesgo))
	
	gdgui.begin_horizontal()
	lesgo = gdgui.toggle("", lesgo)
	gdgui.label("Lesgo")
	gdgui.end_horizontal()


	gdgui.begin_horizontal()
	gdgui.label("Left")
	if lesgo:
		gdgui.begin_vertical()
		gdgui.label("Top")
		gdgui.label("Bottom")
		gdgui.end_vertical()
	gdgui.end_horizontal()


func _process(_delta: float) -> void:
	gui()
	pass
