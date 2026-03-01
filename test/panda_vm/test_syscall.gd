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

func test_print_int() -> void:
	var task = execute_bytecode(
	"""
		PUSH 123
		SYSCALL PRINT_INT
	""")
	assert_eq(_vm._console._last_output, 123)

func test_print_fixed() -> void:
	var task = execute_bytecode(
	"""
		PUSH 65536
		SYSCALL PRINT_FIXED
	""")
	assert_eq(_vm._console._last_output, 1.0)

func test_print_str() -> void:
	var task = execute_bytecode(
	"""
		PUSH_STR "Hello, Panda VM!"
		SYSCALL PRINT_STR
	""")
	assert_eq(_vm._console._last_output, "Hello, Panda VM!")
