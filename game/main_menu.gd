extends Control








# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/Ui/Inventory/Inventory.tscn")
	




func _on_option_3_pressed() -> void:
	pass # Replace with function body.


func _on_exit_2_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_inventory_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Ui/Inventory/Code_inevntory.tscn")
