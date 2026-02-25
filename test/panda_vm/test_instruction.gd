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
	assert_eq(bytecode.size(), 10) # 2 instructions + 2 * 4 bytes for values
	var task = _vm.add_task(bytecode)
	_vm.tick()
	assert_eq(task.pop_stack(), 100)
	assert_eq(task.pop_stack(), 42)
