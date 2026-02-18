class_name AssemblyUI
extends Control

@onready var inventory: Inventory = $Inventory

@onready var chassis: SteeringSmartCar = $AutoBot/Chassis

func _ready() -> void:
	# In the future, you can get references to your inventory and
	# assembly area nodes here. You can also connect to signals.
	#
	# For example, if the inventory emits a signal when a component is
	# dropped outside its bounds, this UI can catch it and decide if
	# it landed in the assembly area.
	print("Assembly UI is ready.")
	inventory.component_dropped_outside.connect(_on_inventory_component_dropped_outside)

func _on_inventory_component_dropped_outside(component: Component, drop_position: Vector2) -> void:
	for slot in chassis.slots:
		if slot.get_global_rect().has_point(drop_position + Inventory.cell_size * 0.5):
			if slot.accepts_component(component):
				_equip_component_to_slot(component, slot)
				return

func _equip_component_to_slot(component: Component, slot: Slot) -> void:
	# Disconnect Inventory signals so it doesn't interfere
	if component.drag_started.is_connected(inventory._on_component_drag_started):
		component.drag_started.disconnect(inventory._on_component_drag_started)
	if component.drag_ended.is_connected(inventory._on_component_drag_ended):
		component.drag_ended.disconnect(inventory._on_component_drag_ended)
	
	# Move component to chassis
	if component.get_parent():
		component.get_parent().remove_child(component)
	
	chassis.add_child(component)
	component.global_position = slot.global_position
	
	# Hide the slot to indicate it's filled
	slot.visible = false
	
	# Store reference to the slot on the component so we know where it belongs
	component.set_meta("occupied_slot", slot)
	
	# Connect local drag handler for when we want to remove it
	if not component.drag_ended.is_connected(_on_chassis_component_drag_ended):
		component.drag_ended.connect(_on_chassis_component_drag_ended.bind(component))

func _on_chassis_component_drag_ended(drop_position: Vector2, component: Component) -> void:
	# Try to put back in inventory
	if inventory.try_add_component_at(component, drop_position):
		# Success: Unhide the slot it came from
		var slot = component.get_meta("occupied_slot") as Slot
		if slot:
			slot.visible = true
		
		component.drag_ended.disconnect(_on_chassis_component_drag_ended)
		component.remove_meta("occupied_slot")
	else:
		# Failed: Snap back to slot
		var slot = component.get_meta("occupied_slot") as Slot
		if slot:
			component.global_position = slot.global_position
