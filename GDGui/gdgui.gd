extends Container
class_name GDGui

var _dom = {}
var _main := VBoxContainer.new()
var _call_count_stack: Array[int] = []
var _layout_stack: Array[Container] = []

var __button_presses:   Dictionary = {}
var __checkbox_toggles: Dictionary = {}
var __slider_drags:     Dictionary = {}
var __dropdown_selects: Dictionary = {}

func _ready() -> void:
	_layout_stack = []
	_call_count_stack = [0]
	
	custom_minimum_size.x = 200
	
	var panel = PanelContainer.new()
	self.add_child(panel)
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	margin.add_child(_main)


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


func toggle(text: String, default_value: bool = false) -> bool:
	var current = _get_current_element()
	var id = str(_call_count_stack)
	if current is CheckBox:
		current.text = text
	else:
		if current != null:
			_remove_current_element()
		
		var ch = CheckBox.new()
		ch.text = text
		ch.button_pressed = default_value
		ch.toggled.connect(func (toggled): __checkbox_toggles[id] = toggled)
		_add_element(ch)
	
	_increase_call_count()
	return __checkbox_toggles[id] if id in __checkbox_toggles else default_value


func slider(value: float, min_value: float = 0, max_value: float = 100, step: float = 0) -> float:
	var current = _get_current_element()
	var id = str(_call_count_stack)
	var step_value = ((max_value - min_value) / 100.0) if step == 0 else step
	
	if current is HSlider:
		current.set_value_no_signal(value)
		current.max_value = max_value
		current.min_value = min_value
		current.step = step_value
	else:
		if current != null:
			_remove_current_element()
		
		var slider = HSlider.new()
		slider.set_value_no_signal(value)
		slider.max_value = max_value
		slider.min_value = min_value
		slider.step = step_value
		
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		slider.custom_minimum_size.x = 100
		slider.value_changed.connect(func (new_val): __slider_drags[id] = new_val)
		_add_element(slider)
	
	_increase_call_count()
	return __slider_drags[id] if id in __slider_drags else value

func dropdown(selected_index: int, options: Array) -> int:
	var current = _get_current_element()
	var id = str(_call_count_stack)
	selected_index = clamp(selected_index, -1, options.size())
	
	if current is OptionButton:
		current.clear()
		for o in options: current.add_item(o)
		current.selected = selected_index
	else:
		if current != null:
			_remove_current_element()
		
		var opt_button = OptionButton.new()
		for o in options: opt_button.add_item(o)
		opt_button.selected = selected_index
		opt_button.item_selected.connect(func (new_index): __dropdown_selects[id] = new_index)
		_add_element(opt_button)
	
	_increase_call_count()
	return __dropdown_selects[id] if id in __dropdown_selects else selected_index


func label(text: String) -> void:
	var current = _get_current_element()
	if current is Label:
		current.text = text
	else:
		if current != null:
			_remove_current_element()
		
		var l = Label.new()
		l.text = text
		_add_element(l)
	
	_increase_call_count()


## Places a separator automatically according to the current parent container node. 
## VSeparator for HBox and HSeparator for VBox.
func separator() -> void:
	var layout = _get_parent_layout()
	var current = _get_current_element()
	
	if layout is HBoxContainer:
		if not current is VSeparator:
			if current != null:
				_remove_current_element()
			_add_element(VSeparator.new())
	else: # layout is vbox
		if not current is HSeparator:
			if current != null:
				_remove_current_element()
			_add_element(HSeparator.new())
	
	_increase_call_count()


func begin_horizontal() -> void:
	_begin_layout("HBoxContainer")


func end_horizontal() -> void:
	_end_layout("HBoxContainer")


func begin_vertical() -> void:
	_begin_layout("VBoxContainer")


func end_vertical() -> void:
	_end_layout("VBoxContainer")


## Panel contains margin and vertical containers by default
func begin_panel() -> void:
	_begin_layout("PanelContainer")
	_begin_layout("MarginContainer")
	begin_vertical()


func end_panel() -> void:
	end_vertical()
	_end_layout("MarginContainer")
	_end_layout("PanelContainer")


func _handle_nested_layout_dict() -> void:
	var nested_layout = _get_current_element()
	# There is a Node in its place
	if not nested_layout is Dictionary:
		if nested_layout != null:
			_remove_current_element()
		_add_element({})

	_call_count_stack.append(0)


# Use this for begin_* layouts - less copypaste, more polar bears :)
func _begin_layout(layout_name: String) -> void:
	var current = _get_current_element()
	
	var is_desired_class = false
	match layout_name:
		"HBoxContainer":   is_desired_class = current is HBoxContainer
		"VBoxContainer":   is_desired_class = current is VBoxContainer
		"PanelContainer":  is_desired_class = current is PanelContainer
		"MarginContainer": is_desired_class = current is MarginContainer
		_: printerr("[GDGui internal] Unknown layout! ", layout_name)
	
	if is_desired_class:
		_layout_stack.append(current)
	else:
		if current != null:
			_remove_current_element()
		
		var layout
		match layout_name:
			"HBoxContainer":   layout = HBoxContainer.new()
			"VBoxContainer":   layout = VBoxContainer.new()
			"PanelContainer":  layout = PanelContainer.new()
			"MarginContainer": layout = MarginContainer.new()
			_: printerr("[GDGui internal] Unknown layout! ", layout_name)
		
		_add_element(layout)
		_layout_stack.append(layout)
	
	_increase_call_count()
	_handle_nested_layout_dict()


# Use this for end_* layout calls and save on copypaste!
func _end_layout(layout_name: String) -> void:
	_cleanup_layout()  # Get rid of any extra items from previous runs
	_call_count_stack.pop_back()
	var layout = _layout_stack.pop_back()
	_increase_call_count()
	
	var should_print_warning = false
	match layout_name:
		"HBoxContainer":   should_print_warning = not layout is HBoxContainer
		"VBoxContainer":   should_print_warning = not layout is VBoxContainer
		"PanelContainer":  should_print_warning = not layout is PanelContainer
		"MarginContainer": should_print_warning = not layout is MarginContainer
		_: printerr("[GDGui internal] Unknown layout! ", layout_name)
	
	if should_print_warning:
		push_warning("WARNING: Mismatched layout ending - topmost layout wasn't a %s. It was " % layout_name, layout)


# -------------------------------------------------------- #
#                                                          #
#                       UTILITIES                          #
#                                                          #
# -------------------------------------------------------- #

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
