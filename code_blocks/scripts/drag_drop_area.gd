extends Control

const MINIMUM_DRAG_THRESHOLD = 25
const SNAP_DISTANCE = 30

var _is_dragging: bool = false
var _drag_offset: Vector2
var _root_block: Node2D
var _drag_start_position: Vector2 = Vector2.INF
var _snap_points: Array[Control] = []
var _connected_roots: Array[Node2D] = []
var _connected_offsets: Array[Vector2] = []

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
			var hovered_control = get_viewport().gui_get_hovered_control()
			if hovered_control and _root_block.is_ancestor_of(hovered_control):
				_drag_start_position = button_event.global_position
				get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not _root_block:
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_dragging or _drag_start_position != Vector2.INF:
			_on_drag_ended()
		return

	var current_mouse_pos = get_global_mouse_position()

	if not _is_dragging and _drag_start_position != Vector2.INF:
		if _drag_start_position.distance_to(current_mouse_pos) > MINIMUM_DRAG_THRESHOLD:
			_is_dragging = true
			_drag_offset = _root_block.global_position - current_mouse_pos
			get_viewport().set_input_as_handled()
			_on_drag_started()

	if _is_dragging:
		var target_pos = current_mouse_pos + _drag_offset
		var closest_snap_point = _get_closest_snap_point(target_pos)
		
		if closest_snap_point:
			_root_block.global_position = closest_snap_point.global_position
		else:
			_root_block.global_position = target_pos
			
		for i in range(_connected_roots.size()):
			if is_instance_valid(_connected_roots[i]):
				_connected_roots[i].global_position = _root_block.global_position + _connected_offsets[i]

func _on_drag_started() -> void:
	_update_snap_points()
	
	var my_block = _get_block()
	if my_block:
		var head = my_block.get_head_block()
		if head:
			head.set_tail_block(null)
			my_block.set_head_block(null)
			
		_connected_roots.clear()
		_connected_offsets.clear()
		
		var curr = my_block.get_tail_block()
		while curr:
			var root = _get_root_of_block(curr)
			if root:
				_connected_roots.append(root)
				_connected_offsets.append(root.global_position - _root_block.global_position)
			curr = curr.get_tail_block()

func _on_drag_ended() -> void:
	if _is_dragging:
		var closest_snap_point = _get_closest_snap_point(_root_block.global_position)
		if closest_snap_point:
			var target_block = _get_block_snap_point(closest_snap_point)
			var my_block = _get_block()
			
			if target_block and my_block and target_block != my_block:
				var old_tail = target_block.get_tail_block()
				
				target_block.set_tail_block(my_block)
				my_block.set_head_block(target_block)
				
				if old_tail:
					var my_last = my_block
					while my_last.get_tail_block():
						my_last = my_last.get_tail_block()
					
					my_last.set_tail_block(old_tail)
					old_tail.set_head_block(my_last)
					_reposition_chain(my_last)

	_is_dragging = false
	_drag_start_position = Vector2.INF
	_snap_points.clear()
	_connected_roots.clear()
	_connected_offsets.clear()

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

func _get_block_snap_point(p_snap_point: Control) -> BaseBlock:
	var parent = p_snap_point.get_parent()
	while parent and not parent is BaseBlock:
		parent = parent.get_parent()
	return parent as BaseBlock

func _get_root_of_block(p_block: BaseBlock) -> Node2D:
	return p_block.get_parent() as Node2D

func _reposition_chain(p_start_block: BaseBlock) -> void:
	var curr = p_start_block
	while curr.get_tail_block():
		var tail = curr.get_tail_block()
		var snap = _find_snap_point(curr)
		var tail_root = _get_root_of_block(tail)
		if snap and tail_root:
			tail_root.global_position = snap.global_position
		curr = tail

func _find_snap_point(p_block: BaseBlock) -> Control:
	var root = _get_root_of_block(p_block)
	if not root: return null
	for child in root.find_children("*", "Control", true, false):
		if child.is_in_group("snap_point") and _get_block_snap_point(child) == p_block:
			return child
	return null
