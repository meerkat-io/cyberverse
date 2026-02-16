class_name BlockContent
extends HBoxContainer

signal value_changed(p_name: String, p_value: Variant)

func build_block(p_elements: Array[BlockElement]):
	# Clear existing children if reusing the node
	for child in get_children():
		child.queue_free()
	
	for element in p_elements:
		if element is BlockElement.BlockTextElement:
			_add_label(element.text)
		elif element is BlockElement.BlockParamElement:
			_add_input(element)

func _add_label(p_text: String):
	var label = Label.new()
	label.text = p_text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", load("res://assets/fonts/NotoSans.ttf"))
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", "#292929")
	add_child(label)

func _add_input(p_param: BlockElement.BlockParamElement):
	match p_param.type:
		BlockElement.ParamType.INT:
			var spin = SpinBox.new()
			spin.min_value = p_param.min_val if p_param.min_val != null else -9999
			spin.max_value = p_param.max_val if p_param.max_val != null else 9999
			spin.value = p_param.default_val if p_param.default_val != null else 0
			spin.value_changed.connect(func(v): value_changed.emit(p_param.name, v))
			var line_edit = spin.get_line_edit()
			line_edit.add_theme_font_override("font", load("res://assets/fonts/NotoSans.ttf"))
			line_edit.add_theme_font_size_override("font_size", 24)
			line_edit.add_theme_color_override("font_color", Color("#d5d5d5"))
			add_child(spin)
			
		BlockElement.ParamType.LIST:
			var combo = OptionButton.new()
			combo.add_theme_font_override("font", load("res://assets/fonts/NotoSans.ttf"))
			combo.add_theme_font_size_override("font_size", 24)
			
			var popup = combo.get_popup()
			popup.add_theme_font_override("font", load("res://assets/fonts/NotoSans.ttf"))
			popup.add_theme_font_size_override("font_size", 24)
			
			# Here you would call your API: get_list_options(p_param.name)
			_populate_list(combo, p_param.name)
			combo.item_selected.connect(func(idx): 
				var metadata = combo.get_item_metadata(idx)
				value_changed.emit(p_param.name, metadata)
			)
			add_child(combo)
		
		BlockElement.ParamType.BOOL:
			var check = CheckBox.new()
			check.button_pressed = p_param.default_val if p_param.default_val != null else false
			check.toggled.connect(func(v): value_changed.emit(p_param.name, v))
			add_child(check)

# Placeholder for your list resolution logic
func _populate_list(p_button: OptionButton, _p_list_name: String):
	# Mock data: [{"name": "Motor A", "id": 0}, {"name": "Motor B", "id": 1}]
	var mock_options = [{"name": "Motor A", "id": 0}]
	for opt in mock_options:
		p_button.add_item(opt.name)
		p_button.set_item_metadata(p_button.get_item_count() - 1, opt.id)
