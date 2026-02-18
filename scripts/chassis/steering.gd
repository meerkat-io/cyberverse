class_name SteeringSmartCar
extends Node2D

@export var wheels_animation: Array[AnimatedSprite2D] = []

@export var slots: Array[Slot] = []

@export var pre_populate_components: Array[String] = []

var _power := 0.5

func _ready() -> void:
	# For testing, we can pre-populate some components in the chassis.
	# In a real game, you might load this from a save file or start empty.
	for i in range(min(pre_populate_components.size(), slots.size())):
		var component_scene := load(pre_populate_components[i]) as PackedScene
		if component_scene:
			var component_instance := component_scene.instantiate() as Component
			if component_instance:
				_equip_component_to_slot(component_instance, slots[i])

func _equip_component_to_slot(component: Component, slot: Slot) -> void:
	# Move component to chassis
	if component.get_parent():
		component.get_parent().remove_child(component)
	
	add_child(component)
	component.global_position = slot.global_position
	
	# Hide the slot to indicate it's filled
	slot.visible = false
