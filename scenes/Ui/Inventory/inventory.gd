extends Control

 # standardmäßig geschlossen



func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Ui/main_menu.tscn")
