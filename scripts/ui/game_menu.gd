extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
@onready var menu: PanelContainer = $Menu
@onready var buttons: VBoxContainer = $Menu/Buttons
@onready var label: Label = $options/Label
@onready var options: Panel = $options

func _ready() -> void:
	options.visible = false
	menu.visible = true

func _on_start_pressed():
	pass


func _on_option_3_pressed() -> void:
	options.visible = true
	menu.visible = false

func _on_exit_2_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _on_inventory_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Ui/Inventory/Code_inevntory.tscn")


func _on_back_button_down() -> void:
	_ready()


func _on_try_pressed() -> void:
	pass # Replace with function body.
