class_name Task
extends RefCounted

enum State {
	RUNNING,
	SLEEPING,
	WAITING,
	FINISHED
}

var _bytecode: PackedByteArray
var _entry_addr: int = 0
var _pc: int = 0
var _sp: int = 0

var _regs: PackedInt32Array = PackedInt32Array()
var _stack: PackedInt32Array = PackedInt32Array()
var _locals: PackedInt32Array = PackedInt32Array()

var state: State
var sleep_ticks: int = 0
var wait_signal: int = 0

# TODO: max call frame depth = 8
# flatten call frames and locals

func _init(bytecode: PackedByteArray, entry_addr: int):
	_bytecode = bytecode
	_entry_addr = entry_addr

	_stack.resize(8)
	_regs.resize(4)
	_regs.fill(0)
	_locals.resize(32)

	reset()

func reset():
	_regs.fill(0)
	_sp = 0
	_pc = _entry_addr
	state = State.RUNNING

func push_stack(value: int):
	if _sp >= _stack.size():
		push_error("Stack overflow")
		return
	_stack[_sp] = value
	_sp += 1

func pop_stack() -> int:
	if _sp <= 0:
		push_error("Stack underflow")
		return 0
	_sp -= 1
	return _stack[_sp]

func peek_stack() -> int:
	if _sp <= 0:
		push_error("Stack underflow")
		return 0
	return _stack[_sp - 1]
