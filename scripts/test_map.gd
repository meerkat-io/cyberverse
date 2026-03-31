extends Node2D

@onready var stop_button: Button = $StopButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop_button.pressed.connect(_on_stop_button_pressed)

func _on_stop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/game_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
