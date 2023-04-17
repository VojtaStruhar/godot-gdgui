extends Control
class_name GDGui

@onready var main := VBoxContainer.new()


var _call_count_stack: Array[int] = [0];
var dom: Dictionary = {}
var __button_presses: Dictionary = {}

var _layout_stack = []

func _process(delta: float) -> void:
	# reset button presses cache
	for key in __button_presses:
		__button_presses[key] = false
	
	# clean out the dom according to the call_count_stack
	
	_call_count_stack = [0]

func _ready() -> void:
	add_child(main)

func label(text: String) -> void:
	var current = _get_current_element()
	if current is Label:
		current.text = text
	else:
		print(_call_count_stack, " Creating a label")
		var l = Label.new()
		l.text = text
		_add_element(l)
		dom[_get_call_count()] = l
	
	_increase_call_count()

func button(text: String) -> bool:
	var current = _get_current_element()
	var button_id = str(_call_count_stack)
	
	if current is Button:
		current.text = text
	else:
		if current is Node:
			print(_call_count_stack, " Destroying ", current.name, " and creating a button")
			current.queue_free()
		else:
			print(_call_count_stack, " Creating a button")
		
		var b = Button.new()
		b.text = text
		b.pressed.connect(func(): __button_presses[button_id] = true)
		_add_element(b)
		dom[_get_call_count()] = b
	
	
	_increase_call_count()
	return __button_presses[button_id] if button_id in __button_presses else false


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
