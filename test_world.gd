extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

var lesgo = false

func _process(_delta: float) -> void:
	gdgui.label("lesgo: " + str(lesgo))
	
	if gdgui.button("Toggle"):
		lesgo = not lesgo
	
	
	if lesgo:
		gdgui.label("Nice")
	
	gdgui.begin_horizontal()
	gdgui.button("Useless")
	gdgui.button("Useless 2")
	gdgui.end_horizontal()
	
	
	gdgui.label("Survive!")
	
