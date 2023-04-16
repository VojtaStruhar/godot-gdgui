extends Node3D

@onready var gdgui: GDGui = $CanvasLayer/Control

func _process(delta: float) -> void:
	if (gdgui.button("Vojta")):
		print("Pressed - GDGui works?!")
