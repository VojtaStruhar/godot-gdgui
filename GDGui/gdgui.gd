extends Control
class_name GDGui

@onready var main := VBoxContainer.new()

var _layout_stack = []

var _elements_registry: Dictionary = {}

var __button_presses: Dictionary = {}


func _ready() -> void:
	add_child(main)

func _process(delta: float) -> void:
	for key in __button_presses:
		__button_presses[key] = false

func _add_element(id: Variant, element: Control):
	var last = main
	if _layout_stack.size() > 0:
		last = _layout_stack[_layout_stack.size() - 1]
	
	_elements_registry[id] = element
	last.add_child(element)
	

func button(title: String = "Button", options: Dictionary = {}) -> bool:
	var button_id = options["id"] if "id" in options else "button_" + title
	
	if (button_id not in _elements_registry):
		var btn = Button.new()
		btn.pressed.connect(func(): __button_presses[button_id] = true)
		btn.text = title
		btn.name = str(button_id)
		_add_element(button_id, btn)
	
	return __button_presses[button_id] if button_id in __button_presses else false

## Static label identified by its text. Do not use for labels with dynamic text.
func label(text: String) -> void:
	var label_id = "label_static_" + str(text.hash())
	
	if label_id not in _elements_registry:
		var l = Label.new()
		l.name = "Static label"
		l.text = text
		_add_element(label_id, l)
