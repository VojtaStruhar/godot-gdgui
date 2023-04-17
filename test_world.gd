extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

func _process(delta: float) -> void:
	gdgui.label("This is a GDGui test!")
	gdgui.label("This is a GDGui test!")
	
	if gdgui.button("Test"):
		print("It works!!")
