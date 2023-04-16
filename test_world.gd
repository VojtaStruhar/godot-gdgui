extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

func _process(delta: float) -> void:
	if (gdgui.button("Vojta", {"id": 1} )):
		print("Print 1 - you want to see me")
		
	if (gdgui.button("Vojta")):
		print("Print 2 - oops")
