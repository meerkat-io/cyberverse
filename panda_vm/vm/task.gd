class_name Task
extends RefCounted

# registers [R0,R1,R2,R3,PC,SP,FLAGS,FP]
var regs: Array[int] = []
var stack: Array[int] = []
var finished: bool = false
var stack_size: int = 64
var bytecode: PackedByteArray = PackedByteArray()

func _init(_stack_size = 64):
	stack_size = _stack_size
	stack.resize(stack_size)
	# init registers
	regs = [0, 0, 0, 0, 0, 0, 0, 0]
