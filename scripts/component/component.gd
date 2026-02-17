class_name Component
extends Control

## Emitted when the user starts dragging the component.
signal drag_started
## Emitted when the user drops the component.
## Passes the global position of the drop.
signal drag_ended(drop_position: Vector2)

enum ComponentType { ENGINE, BATTERY, CPU, CHASSIS }

## The size of the component in grid tiles (width, height).
## You can set this in the Inspector for each component scene.
@export var tile_span: Vector2i = Vector2i(1, 1)

# The type of component, which can be used to determine its function in the assembly.
@export var component_type: ComponentType = ComponentType.ENGINE

## The component's top-left grid coordinate. This is managed by the Inventory.
var grid_position: Vector2i

var _is_dragging := false
var _drag_offset: Vector2

func _ready() -> void:
	# Ensure the control has a size so it can receive input.
	# Node2D children (like AnimatedSprite2D) do not expand the Control automatically.
	if size == Vector2.ZERO:
		custom_minimum_size = Vector2(tile_span) * 128

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_drag_offset = global_position - get_global_mouse_position()
			z_index = 100 # Render on top while dragging
			move_to_front()
			drag_started.emit()
		elif _is_dragging:
			_is_dragging = false
			z_index = 0
			drag_ended.emit(global_position)

func _process(_delta: float) -> void:
	if _is_dragging:
		global_position = get_global_mouse_position() + _drag_offset


class ComponentData extends  RefCounted:
	var resource: String
	var grid_pos: Vector2i

	func _init(p_resource: String, p_grid_pos: Vector2i):
		resource = p_resource
		grid_pos = p_grid_pos
