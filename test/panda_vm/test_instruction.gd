extends GutTest

var _vm: VM = VM.new()
var _assembler: Assembler = Assembler.new()

func before_each():
	_vm.reset()

func execute_bytecode(code: String) -> Task:
	var bytecode = _assembler.assemble(code)
	var handler = Handler.new()
	handler._bytecode = bytecode
	handler._entry_addr = 0
	var task = _vm._get_or_create_task()
	task.set_handler(handler)
	_vm._execute(task)
	if task._state == Task.State.FINISHED:
		_vm._recycle_task(task)
	return task

func test_push() -> void:
	var task = execute_bytecode(
	"""
		PUSH 42
		PUSH 100
	""")
	assert_eq(task.pop_stack(), 100)
	assert_eq(task.pop_stack(), 42)

func test_load_store_global() -> void:
	var task = execute_bytecode(
	"""
		PUSH 123
		STORE_GLOBAL 0
		LOAD_GLOBAL 0
	""")
	assert_eq(task.pop_stack(), 123)

func test_load_store_local() -> void:
	var task = execute_bytecode(
	"""
		PUSH 456
		STORE_LOCAL 0
		LOAD_LOCAL 0
	""")
	assert_eq(task.pop_stack(), 456)

func test_push_pop_register() -> void:
	var task = execute_bytecode(
	"""
		PUSH 1
		POP_R0
		PUSH_R0
	""")
	assert_eq(task.pop_stack(), 1)
	assert_eq(task._regs[0], 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 2
		POP_R1
		PUSH_R1
	""")
	assert_eq(task.pop_stack(), 2)
	assert_eq(task._regs[1], 2)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 3
		POP_R2
		PUSH_R2
	""")
	assert_eq(task.pop_stack(), 3)
	assert_eq(task._regs[2], 3)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 4
		POP_R3
		PUSH_R3
	""")
	assert_eq(task.pop_stack(), 4)
	assert_eq(task._regs[3], 4)

func test_duplicate_top() -> void:
	var task = execute_bytecode(
	"""
		PUSH 99
		DUP
	""")
	assert_eq(task.pop_stack(), 99)
	assert_eq(task.pop_stack(), 99)

func test_swap_top() -> void:
	var task = execute_bytecode(
	"""		
		PUSH 1
		PUSH 2
		SWAP
	""")
	assert_eq(task.pop_stack(), 1)
	assert_eq(task.pop_stack(), 2)

func test_drop_top() -> void:
	var task = execute_bytecode(
	"""
		PUSH 1
		PUSH 2
		DROP
	""")
	assert_eq(task.pop_stack(), 1)

func test_add_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 10
		PUSH 20
		ADD_INT
	""")
	assert_eq(task.pop_stack(), 30)

func test_sub_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 20
		PUSH 5
		SUB_INT
	""")
	assert_eq(task.pop_stack(), 15)

func test_mul_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 6
		PUSH 7
		MUL_INT
	""")
	assert_eq(task.pop_stack(), 42)

func test_div_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 21
		PUSH 4
		DIV_INT
	""")
	assert_eq(task.pop_stack(), 5)

func test_mod_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 20
		PUSH 6
		MOD_INT
	""")
	assert_eq(task.pop_stack(), 2)

func test_neg_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 10
		NEG_INT
	""")
	assert_eq(task.pop_stack(), -10)

func test_and() -> void:
	var task = execute_bytecode(
	"""
		PUSH 9
		PUSH 10
		AND
	""")
	assert_eq(task.pop_stack(), 8)

func test_or() -> void:
	var task = execute_bytecode(
	"""		
		PUSH 9
		PUSH 10
		OR
	""")
	assert_eq(task.pop_stack(), 11)

func test_xor() -> void:
	var task = execute_bytecode(
	"""
		PUSH 9
		PUSH 8
		XOR
	""")
	assert_eq(task.pop_stack(), 1)

func test_not() -> void:
	var task = execute_bytecode(
	"""
		PUSH 9
		NOT 
	""")
	assert_eq(task.pop_stack(), ~9)

func test_add_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 1
		INT_TO_FIXED
		PUSH 2
		INT_TO_FIXED
		ADD_FIXED
	""")
	assert_eq(task.pop_stack(), 3 << 16)

func test_sub_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 3
		INT_TO_FIXED
		SUB_FIXED
	""")
	assert_eq(task.pop_stack(), 2 << 16)

func test_mul_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 3
		INT_TO_FIXED
		MUL_FIXED
	""")
	assert_eq(task.pop_stack(), 15 << 16)

func test_div_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 10
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		DIV_FIXED
	""")
	assert_eq(task.pop_stack(), 2 << 16)

func test_neg_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		NEG_FIXED
	""")
	assert_eq(task.pop_stack(), -(5 << 16))

func test_int_to_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
	""")
	assert_eq(task.pop_stack(), 5 << 16)

func test_fixed_to_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		FIXED_TO_INT
	""")
	assert_eq(task.pop_stack(), 5)

func test_cmp_eq_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		PUSH 5
		CMP_EQ_INT
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 4
		CMP_EQ_INT
	""")
	assert_eq(task.pop_stack(), 0)

func test_cmp_ne_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		PUSH 5
		CMP_NE_INT
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 4
		CMP_NE_INT
	""")
	assert_eq(task.pop_stack(), 1)

func test_cmp_lt_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 4
		PUSH 5
		CMP_LT_INT
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 5
		CMP_LT_INT
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 6
		PUSH 5
		CMP_LT_INT
	""")
	assert_eq(task.pop_stack(), 0)

func test_cmp_le_int() -> void:		
	var task = execute_bytecode(
	"""
		PUSH 4
		PUSH 5
		CMP_LE_INT
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 5
		CMP_LE_INT
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 6
		PUSH 5
		CMP_LE_INT
	""")
	assert_eq(task.pop_stack(), 0)

func test_cmp_gt_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		PUSH 6
		CMP_GT_INT
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 5
		CMP_GT_INT
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 4
		CMP_GT_INT
	""")
	assert_eq(task.pop_stack(), 1)

func test_cmp_ge_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		PUSH 6
		CMP_GE_INT
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 5
		CMP_GE_INT
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		PUSH 4
		CMP_GE_INT
	""")
	assert_eq(task.pop_stack(), 1)

func test_cmp_eq_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_EQ_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 4
		INT_TO_FIXED
		CMP_EQ_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

func test_cmp_ne_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_NE_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 4
		INT_TO_FIXED
		CMP_NE_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

func test_cmp_lt_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 4
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_LT_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_LT_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 6
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_LT_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

func test_cmp_le_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 4
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_LE_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_LE_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 6
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_LE_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

func test_cmp_gt_fixed() -> void:
	var task = execute_bytecode(
	"""		
		PUSH 5
		INT_TO_FIXED
		PUSH 6
		INT_TO_FIXED
		CMP_GT_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_GT_FIXED
	""")
	assert_eq(task.pop_stack(), 0)	

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 4
		INT_TO_FIXED
		CMP_GT_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

func test_cmp_ge_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 6
		INT_TO_FIXED
		CMP_GE_FIXED
	""")
	assert_eq(task.pop_stack(), 0)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		CMP_GE_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

	_vm.reset()
	task = execute_bytecode(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 4
		INT_TO_FIXED
		CMP_GE_FIXED
	""")
	assert_eq(task.pop_stack(), 1)

func test_jmp() -> void:
	var task = execute_bytecode(
	"""
		JMP end
		PUSH 1
	end:
		PUSH 2
	""")
	assert_eq(task.pop_stack(), 2)
	assert_eq(task._sp, 0) # stack empty after execution

func test_jmp_if_true() -> void:
	var task = execute_bytecode(
	"""		
		PUSH 1
		JMP_IF_TRUE true_label
		PUSH 0
		JMP end
	true_label:
		PUSH 42
	end:
	""")
	assert_eq(task.pop_stack(), 42)
	assert_eq(task._sp, 0) # stack empty after execution

func test_jmp_if_false() -> void:
	var task = execute_bytecode(
	"""
		PUSH 0
		JMP_IF_FALSE false_label
		PUSH 0
		JMP end
	false_label:
		PUSH 42
	end:
	""")
	assert_eq(task.pop_stack(), 42)
	assert_eq(task._sp, 0) # stack empty after execution

func test_call_return() -> void:
	var task = execute_bytecode(
	"""
		PUSH 42
		PUSH 12
		PUSH 2
		CALL add
		JMP end
	add:
		LOAD_LOCAL 0
		LOAD_LOCAL 1
		ADD_INT
		RET
	end:
	""")
	assert_eq(task.pop_stack(), 54)
	assert_eq(task._locals[8], 42) # first local slot of call frame should have first arg
	assert_eq(task._locals[9], 12) # second local slot of call frame should have second arg
	assert_eq(task._frame, 0) # call frame should be cleaned up after RET
