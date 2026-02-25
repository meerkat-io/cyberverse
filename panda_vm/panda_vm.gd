extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VM.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

'''
; comment
start:
    PUSH 10
    INT_TO_FIXED
    CALL foo
    JMP end

foo:
    LOAD_LOCAL 0
    ADD_INT
    RET

end:
    TASK TASK_EXIT
'''
