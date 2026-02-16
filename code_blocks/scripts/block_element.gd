class_name BlockElement
extends RefCounted

enum ParamType { BOOL, INT, FLOAT, STRING, LIST }

class BlockTextElement extends BlockElement:
	var text: String
	
	func _init(p_text: String):
		text = p_text

class BlockParamElement extends BlockElement:
	var name: String
	var type: ParamType
	var min_val: Variant = null
	var max_val: Variant = null
	var default_val: Variant = null

	func _init(p_name: String, p_type: ParamType, p_default = null):
		name = p_name
		type = p_type
		default_val = p_default

	func set_range(p_min, p_max) -> BlockParamElement:
		min_val = p_min
		max_val = p_max
		return self