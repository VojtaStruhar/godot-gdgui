extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

var lesgo = false


func gui():
	gdgui.label("lesgo: " + str(lesgo))
	
	if gdgui.button("Toggle"):
		lesgo = not lesgo

	if lesgo:
		gdgui.label("Nice")

	gdgui.begin_horizontal()
	gdgui.label("Absolute bottom!")
	gdgui.end_horizontal()


func _process(_delta: float) -> void:
	gui()
	pass
