extends Control

@onready var texture: TextureRect = $VBoxContainer/TextureRect
@onready var category_label: Label = $VBoxContainer/Label

var _category: Blocks.Category

func _ready() -> void:
	texture.modulate = Blocks.get_tint(_category)
	category_label.text = Blocks.get_category_name(_category)

func set_category(category: Blocks.Category) -> void:
	_category = category
