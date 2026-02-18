class_name Programming
extends Control

@onready var start_button: Button = $StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/map/test_map.tscn")

#	var test_data = {
#		"Engine": {"Set Power": "res://code_blocks/scenes/blocks/engine/set_power.tscn"},
#		"Control": {"On Start": "res://code_blocks/scenes/blocks/entry/on_start.tscn"}
#	}
