extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

var lesgo = true

func _process(delta: float) -> void:
	gdgui.label("lesgo: " + str(lesgo))
	
	if gdgui.button("Toggle"):
		lesgo = not lesgo
	
	if lesgo:
		gdgui.label("Nice")
	
	gdgui.label("Survive!")
	
