extends Control
class_name GDGui

var _dom = {}
var _main := VBoxContainer.new()
var _call_count_stack: Array[int] = []
var _layout_stack: Array[Container] = []

var __button_presses: Dictionary = {}

func _ready() -> void:
	_layout_stack = []
	_call_count_stack = [0]

	self.add_child(_main)


func _process(_delta: float) -> void:
	_cleanup_layout()
	_call_count_stack = [0]
	_layout_stack = []
	
	for key in __button_presses:
		__button_presses[key] = false


func button(text: String) -> bool:
	var current = _get_current_element()
	var button_id = str(_call_count_stack)

	if current is Button:
		# You should connect the press signal again here, but we don't have that in python
		current.text = text
	else:
		if current != null:
			_remove_current_element()

		var b = Button.new()
		b.pressed.connect(func(): __button_presses[button_id] = true)
		b.text = text
		_add_element(b)

	_increase_call_count()
	return __button_presses[button_id] if button_id in __button_presses else false


func label(text: String) -> void:
	var current = _get_current_element()
	if current is Label:
		current.text = text
	else:
		if current != null:
			_remove_current_element()

		var label = Label.new()
		label.text = text
		_add_element(label)

	_increase_call_count()


func begin_horizontal() -> void:
	var current = _get_current_element()
	if current is HBoxContainer:
		_layout_stack.append(current)
	else:
		if current != null:
			_remove_current_element()
		var hbox = HBoxContainer.new()
		_add_element(hbox)
		_layout_stack.append(hbox)

	_increase_call_count()

	var nested_layout = _get_current_element()
	# There is a Node in its place
	if not nested_layout is Dictionary:
		if nested_layout != null:
			_remove_current_element()
		_add_element({})


	_call_count_stack.append(0)


func end_horizontal() -> void:
	_cleanup_layout()  # Get rid of any extra items from previous runs
	_call_count_stack.pop_back()
	var layout = _layout_stack.pop_back()
	_increase_call_count()

	if not layout is HBoxContainer:
		print("WARNING: Called end_horizontal, but the topmost layout wasn't a HBoxContainer: ", layout)


func _increase_call_count() -> void:
	_call_count_stack[-1] += 1


# If this method accidentally replaces some element, it's not its fault and it will not free it!
# Check what you are doing beforehand.
func _add_element(element) -> void:
	if element is Control:
		_get_parent_layout().add_child(element)

	var destination = _dom
	for cc in _call_count_stack.slice(0, _call_count_stack.size() - 1):
		destination = destination[cc]

	destination[_call_count_stack[-1]] = element


func _get_current_element():
	var subtree = _dom
	for i in range(len(_call_count_stack) - 1):
		var cc = _call_count_stack[i]
		if cc not in subtree:
			return null
		subtree = subtree[cc]

	var cc = _call_count_stack[-1]
	if cc not in subtree:
		return null

	var element = subtree[cc]
	if element is Control and not is_instance_valid(element):
		return null

	return element

	return subtree[_call_count_stack[-1]]


func _get_parent_layout() -> Control:
	if len(_layout_stack) > 0:
		return _layout_stack[-1]
	return _main


func _remove_current_element() -> void:
	var subtree = _dom
	for cc in _call_count_stack.slice(0, _call_count_stack.size() - 1):
		if cc not in subtree:
			print("removing ", _call_count_stack, " failed. ", _dom)
			return
		if not subtree[cc] is Dictionary:
			print("removing ", _call_count_stack, " failed. ", _dom)
			return

		subtree = subtree[cc]

	var cc = _call_count_stack[-1]
	if cc not in subtree:
		print("removing ", _call_count_stack, " failed. ", _dom)
		return

	var element = subtree[cc]
	if element is Control:
		element.queue_free()
	else:
		# Dictionary - destroy all its children too
		for key in element.keys().duplicate():
			_call_count_stack.push_back(key)
			_remove_current_element()
			_call_count_stack.pop_back()

	subtree.erase(cc)


# Cleans up the rest of current layout so there are no leftover elements.
func _cleanup_layout() -> void:
	var subtree = _dom
	for cc in _call_count_stack.slice(0, _call_count_stack.size() - 1):
		subtree = subtree[cc]
	
	var current = _get_current_element()
	while current != null:
		var cc = _call_count_stack[-1]

		if current is Control:
			current.queue_free()
		else:  # the element is a dictionary, that means a nested layout
			_call_count_stack.append(0)
			_cleanup_layout()
			_call_count_stack.pop_back()

		subtree.erase(cc)
		_increase_call_count()
		current = _get_current_element()
