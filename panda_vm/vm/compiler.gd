class_name Compiler
extends RefCounted

# assembler/opcodes.gd
const OPCODES := {
	# Data
	"PUSH": 0x01,
	"LOAD_GLOBAL": 0x02,
	"STORE_GLOBAL": 0x03,
	"LOAD_LOCAL": 0x04,
	"STORE_LOCAL": 0x05,

	# Stack / Registers
	"PUSH_R0": 0x10,
	"POP_R0": 0x11,
	"PUSH_R1": 0x12,
	"POP_R1": 0x13,
	"PUSH_R2": 0x14,
	"POP_R2": 0x15,
	"PUSH_R3": 0x16,
	"POP_R3": 0x17,
	"DUP": 0x18,
	"SWAP": 0x19,

	# Integer
	"ADD_INT": 0x20,
	"SUB_INT": 0x21,
	"MUL_INT": 0x22,
	"DIV_INT": 0x23,
	"MOD_INT": 0x24,
	"NEG_INT": 0x25,
	"SHL_INT": 0x26,
	"SHR_INT": 0x27,
	"SAR_INT": 0x28,
	"AND": 0x29,
	"OR": 0x2A,
	"XOR": 0x2B,
	"NOT": 0x2C,

	# Fixed
	"ADD_FIXED": 0x40,
	"SUB_FIXED": 0x41,
	"MUL_FIXED": 0x42,
	"DIV_FIXED": 0x43,
	"NEG_FIXED": 0x44,
	"INT_TO_FIXED": 0x45,
	"FIXED_TO_INT": 0x46,

	# Compare
	"CMP_EQ_INT": 0x50,
	"CMP_NE_INT": 0x51,
	"CMP_LT_INT": 0x52,
	"CMP_LE_INT": 0x53,
	"CMP_GT_INT": 0x54,
	"CMP_GE_INT": 0x55,
	"CMP_EQ_FIXED": 0x56,
	"CMP_NE_FIXED": 0x57,
	"CMP_LT_FIXED": 0x58,
	"CMP_LE_FIXED": 0x59,
	"CMP_GT_FIXED": 0x5A,
	"CMP_GE_FIXED": 0x5B,

	# Branch
	"JMP": 0x60,
	"JMP_IF_TRUE": 0x61,
	"JMP_IF_FALSE": 0x62,
	"CALL": 0x63,
	"RET": 0x64,

	# Modules
	"SYSCALL": 0x70,
	"TASK": 0x71,
}

func first_pass(lines: Array) -> Dictionary:
	var labels := {}
	var pc := 0

	for line in lines:
		line = line.strip_edges()
		if line == "" or line.begins_with(";"):
			continue

		if line.ends_with(":"):
			var label = line.substr(0, line.length() - 1)
			labels[label] = pc
			continue

		var parts = line.split(" ", false)
		var inst = parts[0]

		pc += 1 # opcode

		# immediates
		if inst == "PUSH":
			pc += 4
		elif inst in ["LOAD_GLOBAL", "STORE_GLOBAL", "LOAD_LOCAL", "STORE_LOCAL"]:
			pc += 1
		elif inst in ["JMP", "JMP_IF_TRUE", "JMP_IF_FALSE", "CALL"]:
			pc += 2
		elif inst in ["SYSCALL", "TASK"]:
			pc += 1

	return labels

func assemble(source: String) -> PackedByteArray:
	var lines = source.split("\n")
	var labels = first_pass(lines)

	var bytecode := PackedByteArray()
	var pc := 0

	for raw_line in lines:
		var line = raw_line.strip_edges()
		if line == "" or line.begins_with(";") or line.ends_with(":"):
			continue

		var parts = line.split(" ", false)
		var inst = parts[0]

		# ---- registers sugar ----
		if inst == "PUSH" and parts[1].begins_with("R"):
			inst = "PUSH_" + parts[1]
		elif inst == "POP" and parts[1].begins_with("R"):
			inst = "POP_" + parts[1]

		var opcode = OPCODES.get(inst, -1)
		if opcode == -1:
			push_error("Unknown instruction: %s" % inst)
			return PackedByteArray()

		bytecode.append(opcode)
		pc += 1

		match inst:
			"PUSH":
				var v = int(parts[1])
				emit_i32(bytecode, v)

			"LOAD_GLOBAL", "STORE_GLOBAL", "LOAD_LOCAL", "STORE_LOCAL":
				bytecode.append(int(parts[1]))

			"JMP", "JMP_IF_TRUE", "JMP_IF_FALSE", "CALL":
				var target = parts[1]
				var addr = labels[target]
				emit_u16(bytecode, addr)

			"SYSCALL", "TASK":
				bytecode.append(int(parts[1]))

	return bytecode

func emit_i32(out: PackedByteArray, v: int) -> void:
	out.append(v & 0xFF)
	out.append((v >> 8) & 0xFF)
	out.append((v >> 16) & 0xFF)
	out.append((v >> 24) & 0xFF)

func emit_u16(out: PackedByteArray, v: int) -> void:
	out.append(v & 0xFF)
	out.append((v >> 8) & 0xFF)