class_name Inventory
extends Control

## The size of the grid in cells (e.g., 6x6).
@export var grid_size: Vector2i = Vector2i(6, 6)
## The size of each grid cell in pixels.
@export var cell_size: Vector2i = Vector2i(128, 128)

@onready var container: Control = $Container

var _occupied_cells: Dictionary = {}
var _dragged_component: Component = null
var _drag_offset: Vector2

func _ready() -> void:
	custom_minimum_size = grid_size * cell_size
	queue_redraw()

	# For testing, we can add some components to the inventory on startup.
	var components: Array[Component.ComponentData] = [
		Component.ComponentData.new("/Users/sang/Dev/meerkat/cyberverse/scenes/components/energy_cell/level_1.tscn", Vector2i(0, 0))
	]
	init_inventory(components)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var clicked_grid_pos := _local_to_grid_coords(event.position)
			var component = _occupied_cells.get(clicked_grid_pos)
			if component:
				_start_drag(component, event.global_position)
		elif _dragged_component:
			_stop_drag(event.global_position)

func _process(_delta: float) -> void:
	if _dragged_component:
		_dragged_component.global_position = get_global_mouse_position() + _drag_offset

func _draw() -> void:
	# Draw grid lines for visualization.
	for x in range(1, grid_size.x):
		draw_line(Vector2(x * cell_size.x, 0), Vector2(x * cell_size.x, size.y), Color.GRAY, 0.5)
	for y in range(1, grid_size.y):
		draw_line(Vector2(0, y * cell_size.y), Vector2(size.x, y * cell_size.y), Color.GRAY, 0.5)

func _start_drag(component: Component, click_position: Vector2) -> void:
	if not is_instance_valid(component): return

	_dragged_component = component
	_drag_offset = component.global_position - click_position
	_clear_component_occupation(component)

	component.move_to_front()
	component.z_index = 10

func _stop_drag(drop_position: Vector2) -> void:
	var component = _dragged_component
	_dragged_component = null
	if not is_instance_valid(component): return

	component.z_index = 0
	var inventory_rect := get_global_rect()

	if inventory_rect.has_point(drop_position):
		var local_drop_pos := drop_position - inventory_rect.position
		var grid_pos := _local_to_grid_coords(local_drop_pos)

		if _can_place(component, grid_pos):
			_place_component(component, grid_pos)
		else:
			_place_component(component, component.grid_position)
	else:
		# Dropped outside: The AssemblyUI could handle this.
		# For now, return it to its original spot.
		print("Component dropped outside inventory.")
		_place_component(component, component.grid_position)

## Tries to add a component to the inventory. Returns true on success.
func _add_component(component: Component, grid_pos: Vector2i) -> bool:
	if not _can_place(component, grid_pos):
		print("Cannot place component at ", grid_pos)
		return false
	
	_place_component(component, grid_pos)
	return true

## Checks if a component can be placed at the given coordinates.
func _can_place(component: Component, grid_pos: Vector2i) -> bool:
	var target_rect := Rect2i(grid_pos, component.tile_span)
	var grid_bounds := Rect2i(Vector2i.ZERO, grid_size)
	if not grid_bounds.encloses(target_rect):
		return false

	for x in range(component.tile_span.x):
		for y in range(component.tile_span.y):
			var cell := grid_pos + Vector2i(x, y)
			if _occupied_cells.has(cell):
				return false
	return true

func _place_component(component: Component, grid_pos: Vector2i) -> void:
	if component.get_parent() != self:
		if component.get_parent():
			component.get_parent().remove_child(component)
		container.add_child(component)

	component.grid_position = grid_pos
	component.position = grid_pos * cell_size

	for x in range(component.tile_span.x):
		for y in range(component.tile_span.y):
			var cell := grid_pos + Vector2i(x, y)
			_occupied_cells[cell] = component

func _clear_component_occupation(component: Component) -> void:
	if not is_instance_valid(component) or component.grid_position == null:
		return

	for x in range(component.tile_span.x):
		for y in range(component.tile_span.y):
			var cell := component.grid_position + Vector2i(x, y)
			if _occupied_cells.get(cell) == component:
				_occupied_cells.erase(cell)

func _local_to_grid_coords(local_pos: Vector2) -> Vector2i:
	return Vector2i(floor(local_pos.x / cell_size.x), floor(local_pos.y / cell_size.y))

func init_inventory(components: Array[Component.ComponentData]) -> void:
	for component_data in components:
		var packed_scene: PackedScene = load(component_data.resource)
		if packed_scene:
			var component_instance := packed_scene.instantiate()
			if component_instance is Component:
				_add_component(component_instance, component_data.grid_pos)
			else:
				push_error("Instantiated scene is not a Component: " + component_data.resource)
				component_instance.queue_free() # Clean up the orphan node
		else:
			push_error("Failed to load component resource: " + component_data.resource)
