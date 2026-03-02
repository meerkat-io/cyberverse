class_name Programming	
extends Control

@export var enabled_categories: Array[Blocks.Category] = []
@export var enabled_types: Array[Blocks.BlockType] = []

@onready var start_button: Button = $StartButton

@onready var code_blocks_container: Control = $MarginContainer/HBoxContainer/MarginContainer
# NOTE: The paths below assume a more standard UI layout.
# You may need to adjust your scene tree to match.
@onready var code_blocks_list: VBoxContainer = $MarginContainer/HBoxContainer/BlocksContainer
@onready var categories_list: VBoxContainer = $MarginContainer/HBoxContainer/CategoriesContainer

const CATEGORY_SCENE_PATH := "res://code_blocks/scenes/blocks/category.tscn"

var _category_data_list: Array[Blocks.CategoryData]

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)

	_category_data_list = Blocks.get_categorized_blocks(enabled_categories, enabled_types)
	for category_data in _category_data_list:
		var category_scene = load(CATEGORY_SCENE_PATH)
		var category_instance = category_scene.instantiate()
		category_instance.set_category(category_data.category)
		categories_list.add_child(category_instance)
		for block_data in category_data.blocks:
			var block_scene = load(block_data.scene_path)
			var block_instance = block_scene.instantiate()
			code_blocks_list.add_child(block_instance)
			
	code_blocks_list.queue_sort()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("scene_path") and code_blocks_container.get_global_rect().has_point(at_position)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var block_scene = load(data.scene_path)
	var block_instance = block_scene.instantiate() as BaseBlock
	code_blocks_container.add_child(block_instance)
	block_instance.position = code_blocks_container.to_local(at_position) - block_instance.size / 2.0

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/map/test_map.tscn")
