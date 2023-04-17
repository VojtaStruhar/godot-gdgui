extends Control
class_name GDGui

@onready var main := VBoxContainer.new()


var _call_count_stack: Array[int] = [0];
var dom: Dictionary = {}
var __button_presses: Dictionary = {}

var _layout_stack = []

func _process(_delta: float) -> void:
	# reset button presses cache
	for key in __button_presses:
		__button_presses[key] = false
	
	if _get_current_element() != null:
		_cleanup()
	
	_call_count_stack = [0]


func _ready() -> void:
	add_child(main)


func label(text: String) -> void:
	var current = _get_current_element()
	if current is Label:
		current.text = text
	else:
		if current is Node:
			print(_call_count_stack, " <-> Replacing ", current.name," (", current.get_class(), ") with a label")
			current.queue_free()
		else:
			print(_call_count_stack, " + Creating a label")

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
			print(_call_count_stack, " <-> Replacing ", current.name, " (", current.get_class(), ") with a button")
			current.queue_free()
		else:
			print(_call_count_stack, " + Creating a button")
		
		var b = Button.new()
		b.text = text
		b.pressed.connect(func(): __button_presses[button_id] = true)
		_add_element(b)
		dom[_get_call_count()] = b
	
	
	_increase_call_count()
	return __button_presses[button_id] if button_id in __button_presses else false

func begin_horizontal() -> void:
	var current = _get_current_element()
	if current is HBoxContainer:
		_layout_stack.push_back(current)
	else:
		if current is Node:
			print(_call_count_stack, " <-> Replacing ", current.name, " (", current.get_class(), ") with a hbox")
			current.queue_free()
		else:
			print(_call_count_stack, " + Creating a hbox")
		
		var h = HBoxContainer.new()
		_add_element(h)
		_layout_stack.push_back(h)
		dom[_get_call_count()] = h
	
	_increase_call_count()

func end_horizontal() -> void:
	var h = _layout_stack.pop_back()
	if not h is HBoxContainer:
		printerr("[GDGui] Called end_horizontal, but the topmost layout wasn't a HBoxContainer: ", h, _layout_stack)
	

func _add_element(e: Control) -> void:
	_get_parent_layout().add_child(e)


## Reads the element for this call_count from the dom
func _get_current_element():
	var element = dom
	for cc in _call_count_stack:
		if cc not in element:
			return null
		element = dom[cc]
	# Dont return freed object, etc
	if not is_instance_valid(element):
		return null
	return element


func _increase_call_count() -> void:
	_call_count_stack[-1] += 1


func _get_call_count() -> int:
	return _call_count_stack[-1]


func _get_parent_layout() -> Control:
	if _layout_stack.size() > 0:
		return _layout_stack[-1]
	return main


func _cleanup() -> void:
	while _call_count_stack.size() > 0:
		var current = _get_current_element()
		
		if current != null:
			print(_call_count_stack, " Deleting ", current)
			if current is Node:
				current.queue_free()
			
			var el = dom
			for cc in _call_count_stack.slice(0, _call_count_stack.size() - 1):
				if cc in el:
					el = el[cc]
				else: print(cc, " as in ", _call_count_stack, " not found in ", el, ", (dom): ", dom)
			el[_call_count_stack[-1]] = null
			
			_increase_call_count()
		else:
			_call_count_stack.pop_back()
