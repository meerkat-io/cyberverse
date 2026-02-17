class_name Component
extends Node2D

enum ComponentType { ENGINE, BATTERY, CPU, CHASSIS }

## The size of the component in grid tiles (width, height).
## You can set this in the Inspector for each component scene.
@export var tile_span: Vector2i = Vector2i(1, 1)

# The type of component, which can be used to determine its function in the assembly.
@export var component_type: ComponentType = ComponentType.ENGINE

## The component's top-left grid coordinate. This is managed by the Inventory.
var grid_position: Vector2i

class ComponentData extends  RefCounted:
	var resource: String
	var grid_pos: Vector2i

	func _init(p_resource: String, p_grid_pos: Vector2i):
		resource = p_resource
		grid_pos = p_grid_pos
