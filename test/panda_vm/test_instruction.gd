extends GutTest

var _vm: VM = VM.new()
var _assembler: Assembler = Assembler.new()

func before_each():
	_vm.reset()

func test_push() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 42
		PUSH 100
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 100)
	assert_eq(task.pop_stack(), 42)

func test_load_store_global() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 123
		STORE_GLOBAL 0
		LOAD_GLOBAL 0
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 123)

func test_load_store_local() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 456
		STORE_LOCAL 0
		LOAD_LOCAL 0
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 456)

func test_push_pop_register() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 1
		POP_R0
		PUSH_R0
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 1)
	assert_eq(task._regs[0], 1)

	bytecode = _assembler.assemble(
	"""
		PUSH 2
		POP_R1
		PUSH_R1
	""")
	_vm.reset()
	task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 2)
	assert_eq(task._regs[1], 2)

	bytecode = _assembler.assemble(
	"""
		PUSH 3
		POP_R2
		PUSH_R2
	""")
	_vm.reset()
	task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 3)
	assert_eq(task._regs[2], 3)

	bytecode = _assembler.assemble(
	"""
		PUSH 4
		POP_R3
		PUSH_R3
	""")
	_vm.reset()
	task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 4)
	assert_eq(task._regs[3], 4)

func test_duplicate_top() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 99
		DUP
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 99)
	assert_eq(task.pop_stack(), 99)

func test_swap_top() -> void:
	var bytecode = _assembler.assemble(
	"""		
		PUSH 1
		PUSH 2
		SWAP
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 1)
	assert_eq(task.pop_stack(), 2)

func test_drop_top() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 1
		PUSH 2
		DROP
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 1)

func test_add_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 10
		PUSH 20
		ADD_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 30)

func test_sub_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 20
		PUSH 5
		SUB_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 15)

func test_mul_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 6
		PUSH 7
		MUL_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 42)

func test_div_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 21
		PUSH 4
		DIV_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 5)

func test_mod_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 20
		PUSH 6
		MOD_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 2)

func test_neg_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 10
		NEG_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), -10)

func test_and() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 9
		PUSH 10
		AND
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 8)

func test_or() -> void:
	var bytecode = _assembler.assemble(
	"""		
		PUSH 9
		PUSH 10
		OR
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 11)

func test_xor() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 9
		PUSH 8
		XOR
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 1)

func test_not() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 9
		NOT 
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), ~9)

func test_add_fixed() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 1
		INT_TO_FIXED
		PUSH 2
		INT_TO_FIXED
		ADD_FIXED
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 3 << 16)

func test_sub_fixed() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 3
		INT_TO_FIXED
		SUB_FIXED
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 2 << 16)

func test_mul_fixed() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 5
		INT_TO_FIXED
		PUSH 3
		INT_TO_FIXED
		MUL_FIXED
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 15 << 16)

func test_div_fixed() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 10
		INT_TO_FIXED
		PUSH 5
		INT_TO_FIXED
		DIV_FIXED
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 2 << 16)

func test_neg_fixed() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 5
		INT_TO_FIXED
		NEG_FIXED
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), -(5 << 16))

func test_int_to_fixed() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 5
		INT_TO_FIXED
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 5 << 16)

func test_fixed_to_int() -> void:
	var bytecode = _assembler.assemble(
	"""
		PUSH 5
		INT_TO_FIXED
		FIXED_TO_INT
	""")
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 5)