class_name AssemblyUI
extends Control

@onready var inventory: Inventory = $Inventory

@onready var chassis: CharacterBody2D = $AutoBot/Chassis

func _ready() -> void:
	# In the future, you can get references to your inventory and
	# assembly area nodes here. You can also connect to signals.
	#
	# For example, if the inventory emits a signal when a component is
	# dropped outside its bounds, this UI can catch it and decide if
	# it landed in the assembly area.
	print("Assembly UI is ready.")
	add_test_items_to_inventory()

func add_test_items_to_inventory() -> void:
	pass
