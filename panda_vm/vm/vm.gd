class_name VM
extends RefCounted

var tasks: Array[Task] = []
var max_tasks = 4
var memory: Array[int] = []

func _init(_max_memory = 256, _max_tasks = 4):
	max_tasks = _max_tasks
	# assuming 4 bytes per int
	memory.resize(_max_memory) 

func add_task(stack_size = 1024):
	if tasks.size() >= max_tasks:
		push_error("Reached max task limit")
		return null

	var t = Task.new(stack_size)
	# t.bytecode = task_bytecode
	tasks.append(t)
	return t

# tick 调度
# func tick():
#     for t in tasks:
#         if t.finished:
#             continue
#         _step_task(t)

# task 执行一步
# func _step_task(t: VMTask):
#     var pc = t.regs[4]
#     if pc >= t.bytecode.size():
#         t.finished = true
#         return
#     var instr = t.bytecode[pc]
#     match instr.op:
#         "LOAD_CONST":
#             _push_stack(t, instr.arg)
#         "SYSCALL":
#             _syscall(t, instr.arg)
#         "HALT":
#             t.finished = true
#     t.regs[4] += 1 # PC +1

# 栈操作
# func _push_stack(t: VMTask, val):
#     var sp = t.regs[5]
#     if sp >= t.stack_size:
#         push_error("Stack overflow")
#         return
#     t.stack[sp] = val
#     t.regs[5] += 1

# func _pop_stack(t: VMTask):
#     var sp = t.regs[5]
#     if sp <= 0:
#         push_error("Stack underflow")
#         return 0
#     t.regs[5] -= 1
#     return t.stack[t.regs[5]]

# 简单 syscall
# func _syscall(t: VMTask, name):
#     match name:
#         "print":
#             var val = _pop_stack(t)
#             print("[VM]", val)
#         _:
#             print("[VM] unknown syscall:", name)
