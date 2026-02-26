class_name VM
extends RefCounted

var _tasks: Array[Task] = []
var _max_tasks = 4
var _signal_queue: Array[int] = []
var _globals: PackedInt32Array = PackedInt32Array()

func _init(memory = 256, max_tasks = 4):
	_max_tasks = max_tasks
	_globals.resize(memory)
	reset()

func reset():
	_tasks.clear()
	_signal_queue.clear()
	_globals.fill(0)

func add_task(bytecode: PackedByteArray, entry_addr: int = 0) -> Task:
	if _tasks.size() >= _max_tasks:
		push_error("Reached max task limit")
		return null
	
	var task = Task.new(bytecode, entry_addr)
	_tasks.append(task)
	return task

func tick():
	for task in _tasks:
		if task.state == Task.State.FINISHED:
			_tasks.remove_at(_tasks.find(task))
			continue

		# handle waiting later
		if task.state == Task.State.WAITING:
			continue

		if task.state == Task.State.SLEEPING:
			task.sleep_ticks -= 1
			if task.sleep_ticks <= 0:
				task.state = Task.State.RUNNING
			else:
				continue

		if task.state == Task.State.RUNNING:
			var code = task._bytecode
			var pc = task._pc
			var registers = task._regs
			var locals = task._locals

			while task.state == Task.State.RUNNING:
				if pc >= code.size():
					task.state = Task.State.FINISHED
					continue
					
				var opcode = code[pc]; pc += 1
				
				match opcode:
					# Data Operations
					0x01: # PUSH <val>
						var value = int(code[pc]) | int(code[pc + 1]) << 8 | int(code[pc + 2]) << 16 | int(code[pc + 3]) << 24
						pc += 4
						task.push_stack(value)
					0x02: # LOAD_GLOBAL <idx>
						var idx = code[pc]; pc += 1
						task.push_stack(_globals[idx])
					0x03: # STORE_GLOBAL <idx>
						var idx = code[pc]; pc += 1
						_globals[idx] = task.pop_stack()
					0x04: # LOAD_LOCAL <idx>
						var idx = code[pc]; pc += 1
						task.push_stack(locals[idx + task._frame * task.LOCALS_PER_FRAME])
					0x05: # STORE_LOCAL <idx>
						var idx = code[pc]; pc += 1
						locals[idx + task._frame * task.LOCALS_PER_FRAME] = task.pop_stack()
					
					# Stack Operations
					0x10: # PUSH_R0
						task.push_stack(registers[0])
					0x11: # POP_R0
						registers[0] = task.pop_stack()
					0x12: # PUSH_R1
						task.push_stack(registers[1])
					0x13: # POP_R1
						registers[1] = task.pop_stack()
					0x14: # PUSH_R2
						task.push_stack(registers[2])
					0x15: # POP_R2
						registers[2] = task.pop_stack()
					0x16: # PUSH_R3
						task.push_stack(registers[3])
					0x17: # POP_R3
						registers[3] = task.pop_stack()
					0x18: # DUP
						task.push_stack(task.peek_stack())
					0x19: # SWAP
						var top = task.pop_stack()
						var second = task.pop_stack()
						task.push_stack(top)
						task.push_stack(second)
					0x1A: # DROP
						task.pop_stack()
					
					# Integer Arithmetic
					0x20: # ADD_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a + b)
					0x21: # SUB_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a - b)
					0x22: # MUL_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a * b)
					0x23: # DIV_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						@warning_ignore("integer_division")
						task.push_stack(a / b) # integer division
					0x24: # MOD_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a % b)
					0x25: # NEG_INT
						var a = task.pop_stack()
						task.push_stack(-a)
					0x29: # AND
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a & b)
					0x2A: # OR
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a | b)
					0x2B: # XOR
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a ^ b)
					0x2C: # NOT
						var a = task.pop_stack()
						task.push_stack(~a)
					
					# Fixed-Point (16.16) Arithmetic
					0x40: # ADD_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a + b)
					0x41: # SUB_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(a - b)
					0x42: # MUL_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack((a * b) >> 16)
					0x43: # DIV_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						@warning_ignore("integer_division")
						task.push_stack((a << 16) / b)
					0x44: # NEG_FIXED
						var a = task.pop_stack()
						task.push_stack(-a)
					0x45: # INT_TO_FIXED
						var a = task.pop_stack()
						task.push_stack(a << 16)
					0x46: # FIXED_TO_INT
						var a = task.pop_stack()
						task.push_stack(a >> 16)
					
					# Integer Compare
					0x50: # CMP_EQ_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a == b else 0)
					0x51: # CMP_NE_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a != b else 0)
					0x52: # CMP_LT_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a < b else 0)
					0x53: # CMP_LE_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a <= b else 0)
					0x54: # CMP_GT_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a > b else 0)
					0x55: # CMP_GE_INT
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a >= b else 0)

					# Fixed Compare (16.16)
					0x56: # CMP_EQ_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a == b else 0)

					0x57: # CMP_NE_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a != b else 0)

					0x58: # CMP_LT_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a < b else 0)

					0x59: # CMP_LE_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a <= b else 0)

					0x5A: # CMP_GT_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a > b else 0)

					0x5B: # CMP_GE_FIXED
						var b = task.pop_stack()
						var a = task.pop_stack()
						task.push_stack(1 if a >= b else 0)
						
					# Comparison / Branch
					0x60: # JMP <addr>
						var addr = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
						pc = addr
					0x61: # JMP_IF_TRUE <addr>
						var addr = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
						var cond = task.pop_stack()
						if cond != 0:
							pc = addr
					0x62: # JMP_IF_FALSE <addr>
						var addr = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
						var cond = task.pop_stack()
						if cond == 0:
							pc = addr
					0x63: # CALL <addr>
						var addr = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
						task._frame += 1
						if task._frame >= task.MAX_FRAMES:
							push_error("Max call frame depth exceeded")
							task.state = Task.State.FINISHED
						var arg_count = code[pc]; pc += 1
						for i in range(arg_count):
							# args are passed to local variables of the callee in reverse order
							var arg_value = task.pop_stack()
							locals[(task._frame * task.LOCALS_PER_FRAME) + (arg_count - 1 - i)] = arg_value
						task.push_stack(pc)
						pc = addr
					0x64: # RET
						var ret_value = task.pop_stack()
						pc = task.pop_stack()
						task._frame -= 1
						task.push_stack(ret_value)

					# System Calls
					0x70: # SYSCALL <idx>
						var sub_code = code[pc]; pc += 1
						match sub_code:
							0x01: # PRINT_INT
								var value = task.pop_stack()
								print(value)
							0x02: # PRINT_FIXED
								var value = task.pop_stack()
								print(float(value) / 65536.0)
							0x03: # PRINT_STR
								var addr = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
								var str_len = int(code[addr]) | int(code[addr + 1]) << 8
								var str_bytes = code.subarray(addr + 2, addr + 2 + str_len)
								var string = String(str_bytes)
								print(string)
							_: # unknown syscall
								push_error("Unknown syscall %s" % sub_code)
								task.state = Task.State.FINISHED

					# Task Management
					0x71: # TASK
						var sub_code = code[pc]; pc += 1
						match sub_code:
							0x01: # CREATE <entry_addr>
								var entry_addr = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
								var new_task = add_task(code, entry_addr)
								if new_task == null:
									task.state = Task.State.FINISHED
							0x02: # EXIT
								task.state = Task.State.FINISHED
							0x03: # SLEEP <ticks>
								var ticks = int(code[pc]) | int(code[pc + 1]) << 8; pc += 2
								task._pc = pc
								task.sleep_ticks = ticks
								
								task.state = Task.State.SLEEPING
							0x04: # WAIT_SIGNAL <signal_id>
								var signal_id = int(code[pc]); pc += 1
								task._pc = pc
								task.wait_signal = signal_id
								task.state = Task.State.WAITING
							0x05: # SIGNAL <signal_id>
								var signal_id = int(code[pc]); pc += 1
								_signal_queue.append(signal_id)
							_: # unknown task subcode
								push_error("Unknown task subcode %s" % sub_code)
								task.state = Task.State.FINISHED

					# TODO: other extensions should be registered dynamically

					_: # unknown opcode
						push_error("Unknown opcode %s" % opcode)
						task.state = Task.State.FINISHED
