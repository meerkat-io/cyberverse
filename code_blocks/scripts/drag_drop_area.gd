extends Control

const MINIMUM_DRAG_THRESHOLD = 25
const SNAP_DISTANCE = 50

var _is_dragging: bool = false
var _drag_offset: Vector2
var _root_block: Node2D
var _drag_start_position: Vector2 = Vector2.INF
var _snap_points: Array[Control] = []

func _ready() -> void:
	_root_block = _get_root_block()
	if not _root_block:
		set_process(false)
		push_error("DragDropArea could not find a root block (Node2D) to drag.")
	else:
		set_process(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
	if not _root_block:
		return

	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_LEFT and button_event.pressed:
			if get_global_rect().has_point(button_event.global_position):
				_drag_start_position = button_event.global_position

func _process(_delta: float) -> void:
	if not _root_block:
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_dragging or _drag_start_position != Vector2.INF:
			_is_dragging = false
			_drag_start_position = Vector2.INF
			_snap_points.clear()
		return

	var current_mouse_pos = get_global_mouse_position()

	if not _is_dragging and _drag_start_position != Vector2.INF:
		if _drag_start_position.distance_to(current_mouse_pos) > MINIMUM_DRAG_THRESHOLD:
			_is_dragging = true
			_drag_offset = _root_block.global_position - current_mouse_pos
			get_viewport().set_input_as_handled()
			_update_snap_points()

	if _is_dragging:
		var target_pos = current_mouse_pos + _drag_offset
		var closest_snap_point = _get_closest_snap_point(target_pos)
		
		if closest_snap_point:
			_root_block.global_position = closest_snap_point.global_position
		else:
			_root_block.global_position = target_pos

func _update_snap_points() -> void:
	_snap_points.clear()
	for sp in get_tree().get_nodes_in_group("snap_point"):
		if sp is Control and not _root_block.is_ancestor_of(sp):
			_snap_points.append(sp)

func _get_closest_snap_point(p_pos: Vector2) -> Control:
	var closest_sp: Control = null
	var min_dist_sq = SNAP_DISTANCE * SNAP_DISTANCE
	
	for sp in _snap_points:
		var dist_sq = p_pos.distance_squared_to(sp.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_sp = sp
	
	return closest_sp

func _get_root_block() -> Node2D:
	return _get_block().get_parent() as Node2D

func _get_block() -> BaseBlock:
	var parent = self.get_parent()
	while parent and not parent is BaseBlock:
		parent = parent.get_parent()
	return parent as BaseBlock

func _get_block_content() -> BlockContent:
	return _get_block().get_content()
