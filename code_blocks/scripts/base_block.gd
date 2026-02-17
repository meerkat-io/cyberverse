class_name BaseBlock
extends Node

@export var display_template: String

@export var code_template: String

@export var data_source: Dictionary[String, String]

@onready var _content: BlockContent = $VBoxContainer/MarginContainer/MarginContainer/Content

const BLOCK_ELEMENT_PATTERN = r"\{(\w+):(\w+)(?:\((.*?)\))?\}"

var _regex: RegEx
var _head_block: BaseBlock = null
var _tail_block: BaseBlock = null

func _init() -> void:
	_regex = RegEx.new()
	_regex.compile(BLOCK_ELEMENT_PATTERN)

func _ready() -> void:
	var elements = _parse_display_template(display_template)
	_content.build_block(elements)


func _parse_display_template(p_template: String) -> Array[BlockElement]:
	var elements: Array[BlockElement] = []
	
	var last_offset = 0
	var matches = _regex.search_all(p_template)
	
	for m in matches:
		# 1. Capture text BEFORE the placeholder
		var pre_text = p_template.substr(last_offset, m.get_start() - last_offset)
		if not pre_text.is_empty():
			elements.append(BlockElement.BlockTextElement.new(pre_text))
		
		# 2. Parse Parameter details
		var p_name = m.get_string(1)
		var p_type_str = m.get_string(2).to_upper()
		var p_meta_raw = m.get_string(3)
		
		# Map string to Enum
		var p_type = BlockElement.ParamType.STRING # Default
		if BlockElement.ParamType.has(p_type_str):
			p_type = BlockElement.ParamType[p_type_str]
		
		var param = BlockElement.BlockParamElement.new(p_name, p_type)
		
		# 3. Parse Metadata if it exists (min, max, default)
		if not p_meta_raw.is_empty():
			_parse_into_metadata(param, p_meta_raw)
			
		elements.append(param)
		last_offset = m.get_end()
	
	# 4. Capture any remaining text AFTER the last placeholder
	if last_offset < p_template.length():
		elements.append(BlockElement.BlockTextElement.new(p_template.substr(last_offset)))

	return elements

func _parse_into_metadata(p_param: BlockElement.BlockParamElement, p_raw: String):
	var pairs = p_raw.split(",")
	for pair in pairs:
		var kv = pair.split(":")
		if kv.size() != 2: continue
		
		var key = kv[0].strip_edges()
		var val = kv[1].strip_edges()
		
		match key:
			"min": p_param.min_val = _cast_variant(val)
			"max": p_param.max_val = _cast_variant(val)
			"default": p_param.default_val = _cast_variant(val)

func _cast_variant(p_value: String) -> Variant:
	if p_value.is_valid_int(): return p_value.to_int()
	if p_value.is_valid_float(): return p_value.to_float()
	if p_value.to_lower() == "true": return true
	if p_value.to_lower() == "false": return false
	return p_value

func get_content() -> BlockContent:
	return _content

func set_head_block(p_block: BaseBlock) -> void:
	_head_block = p_block

func set_tail_block(p_block: BaseBlock) -> void:
	_tail_block = p_block

func get_head_block() -> BaseBlock:
	return _head_block

func get_tail_block() -> BaseBlock:
	return _tail_block
