extends Control
class_name GDGui

@onready var main := VBoxContainer.new()


var _call_count_stack: Array[int] = [0];
var dom: Dictionary = {}
var __button_presses: Dictionary = {}

var _layout_stack = []

func _process(delta: float) -> void:
	# clean out the dom according to the call_count_stack
	
	_call_count_stack = [0]

func _ready() -> void:
	add_child(main)

func label(text: String) -> void:
	var current = _get_current_element()
	if current is Label:
		current.text = text
	else:
		print("Creating a label - ", _call_count_stack)
		var l = Label.new()
		l.text = text
		_add_element(l)
		dom[_get_call_count()] = l
	
	_increase_call_count()

func _add_element(e: Control) -> void:
	_get_parent_layout().add_child(e)

## Reads the element for this call_count from the dom
func _get_current_element():
	var tree = dom
	for cc in _call_count_stack:
		if cc not in tree:
			return null
		tree = dom[cc]
	
	return tree

func _increase_call_count() -> void:
	_call_count_stack[-1] += 1

func _get_call_count() -> int:
	return _call_count_stack[-1]

func _get_parent_layout() -> Control:
	if _layout_stack.size() > 0:
		return _layout_stack[-1]
	return main
