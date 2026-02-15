extends Control

const MINIMUM_DRAG_THRESHOLD = 25

var _is_dragging: bool = false
var _drag_offset: Vector2
var _root_block: Node2D
var _drag_start_position: Vector2 = Vector2.INF

func _ready() -> void:
	_root_block = _get_root_block()
	if not _root_block:
		set_process(false)
		push_error("DragDropArea could not find a root block (Node2D) to drag.")
	else:
		set_process(true)

func _gui_input(event: InputEvent) -> void:
	if not _root_block:
		return

	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_LEFT and button_event.pressed:
			_drag_start_position = get_global_mouse_position()

func _process(_delta: float) -> void:
	if not _root_block:
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_dragging or _drag_start_position != Vector2.INF:
			_is_dragging = false
			_drag_start_position = Vector2.INF
		return

	var current_mouse_pos = get_global_mouse_position()

	if not _is_dragging and _drag_start_position != Vector2.INF:
		if _drag_start_position.distance_to(current_mouse_pos) > MINIMUM_DRAG_THRESHOLD:
			_is_dragging = true
			_drag_offset = _root_block.global_position - current_mouse_pos
			get_viewport().set_input_as_handled()

	if _is_dragging:
		_root_block.global_position = current_mouse_pos + _drag_offset

func _get_root_block() -> Node2D:
	return _get_block().get_parent() as Node2D

func _get_block() -> BaseBlock:
	var parent = self.get_parent()
	while parent and not parent is BaseBlock:
		parent = parent.get_parent()
	return parent as BaseBlock
