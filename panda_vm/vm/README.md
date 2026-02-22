# Panda VM Instruction Set

This instruction set is designed for a stack-based VM with tasks and syscalls. Opcodes are one byte (0–255), and parameters follow as needed. Opcodes are grouped by function, leaving space for future expansion.


### Data Operations

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| PUSH_INT <val> | Push int32 onto stack | PUSH_INT 42 | 0x01 |
| PUSH_FLOAT <val> | Push float32 onto stack | PUSH_FLOAT 1.5 | 0x02 |
| PUSH_FIXED <val> | Push 16.16 fixed-point number | PUSH_FIXED 65536 | 0x03 |
| LOAD_GLOBAL <idx> | Push global/shared variable | LOAD_GLOBAL 5 | 0x04 |
| STORE_GLOBAL <idx> | Store to global/shared variable | STORE_GLOBAL 5 | 0x05 |
| LOAD_LOCAL <idx> | Push task-local variable | LOAD_LOCAL 2 | 0x06 |
| STORE_LOCAL <idx> | Store to task-local variable | STORE_LOCAL 2 | 0x07 |

### Stack Operations

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| PUSH R0 | Push register R0 onto stack | PUSH R0 | 0x10 |
| POP R0 | Pop stack to register R0 | POP R0 | 0x11 |
| DUP | Duplicate top of stack | DUP | 0x12 |
| SWAP | Swap top two stack elements | SWAP | 0x13 |

### Integer Arithmetic

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| ADD_INT | Add top two integers on stack | ADD_INT | 0x20 |
| SUB_INT | Subtract top two integers | SUB_INT | 0x21 |
| MUL_INT | Multiply top two integers | MUL_INT | 0x22 |
| DIV_INT | Divide top two integers | DIV_INT | 0x23 |
| MOD_INT | Modulo of top two integers | MOD_INT | 0x24 |
| NEG_INT | Negate top integer | NEG_INT | 0x25 |
| SHL_INT | Shift top integer by n bits | SHL | 0x26 |
| SHR_INT | Logical shift right (zero-fill) | SHR | 0x27 |
| SAR_INT | Arithmetic shift right (sign-fill) | SAR | 0x28 |
| AND | Bitwise AND of top two integers | AND | 0x29 |
| OR | Bitwise OR of top two integers| OR | 0x2A |
| XOR | Bitwise XOR of top two integers| XOR | 0x2B |
| NOT | Bitwise NOT of top integer| NOT | 0x2C |

### Floating-Point Arithmetic

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| ADD_FLOAT | Add top two floats | ADD_FLOAT | 0x30 |
| SUB_FLOAT | Subtract top two floats | SUB_FLOAT | 0x31 |
| MUL_FLOAT | Multiply top two floats | MUL_FLOAT | 0x32 |
| DIV_FLOAT | Divide top two floats | DIV_FLOAT | 0x33 |
| NEG_FLOAT | Negate top float | NEG_FLOAT | 0x34 |

### Fixed-Point (16.16) Arithmetic

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| ADD_FIXED | Add top two fixed-point numbers | ADD_FIXED | 0x40 |
| SUB_FIXED | Subtract top two fixed-point numbers | SUB_FIXED | 0x41 |
| MUL_FIXED | Multiply top two fixed-point numbers | MUL_FIXED | 0x42 |
| DIV_FIXED | Divide top two fixed-point numbers | DIV_FIXED | 0x43 |
| NEG_FIXED | Negate top fixed-point number | NEG_FIXED | 0x44 |
| SHL_FIXED | Shift top integer by n bits | SHL | 0x45 |
| SHR_FIXED | Logical shift right (zero-fill) | SHR | 0x46 |
| SAR_FIXED | Arithmetic shift right (sign-fill) | SAR | 0x47 |

### Comparison / Branch (Expanded by Type)

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| **Integer Compare** |  |  |  |
| CMP_EQ_INT | Compare equal (int) | CMP_EQ_INT | 0x50 |
| CMP_NE_INT | Compare not equal (int) | CMP_NE_INT | 0x51 |
| CMP_LT_INT | Compare less than (int) | CMP_LT_INT | 0x52 |
| CMP_LE_INT | Compare less or equal (int) | CMP_LE_INT | 0x53 |
| CMP_GT_INT | Compare greater than (int) | CMP_GT_INT | 0x54 |
| CMP_GE_INT | Compare greater or equal (int) | CMP_GE_INT | 0x55 |
| **Float Compare** |  |  |  |
| CMP_EQ_FLOAT | Compare equal (float) | CMP_EQ_FLOAT | 0x56 |
| CMP_NE_FLOAT | Compare not equal (float) | CMP_NE_FLOAT | 0x57 |
| CMP_LT_FLOAT | Compare less than (float) | CMP_LT_FLOAT | 0x58 |
| CMP_LE_FLOAT | Compare less or equal (float) | CMP_LE_FLOAT | 0x59 |
| CMP_GT_FLOAT | Compare greater than (float) | CMP_GT_FLOAT | 0x5A |
| CMP_GE_FLOAT | Compare greater or equal (float) | CMP_GE_FLOAT | 0x5B |
| **Fixed Compare** |  |  |  |
| CMP_EQ_FIXED | Compare equal (16.16 fixed) | CMP_EQ_FIXED | 0x5C |
| CMP_NE_FIXED | Compare not equal (fixed) | CMP_NE_FIXED | 0x5D |
| CMP_LT_FIXED | Compare less than (fixed) | CMP_LT_FIXED | 0x5E |
| CMP_LE_FIXED | Compare less or equal (fixed) | CMP_LE_FIXED | 0x5F |
| CMP_GT_FIXED | Compare greater than (fixed) | CMP_GT_FIXED | 0x60 |
| CMP_GE_FIXED | Compare greater or equal (fixed) | CMP_GE_FIXED | 0x61 |
| **Branch / Call / Return** |  |  |  |
| JMP <addr> | Unconditional jump | JMP 0x10 | 0x62 |
| JMP_IF_TRUE <addr> | Jump if top stack != 0 | JMP_IF_TRUE 0x20 | 0x63 |
| JMP_IF_FALSE <addr> | Jump if top stack == 0 | JMP_IF_FALSE 0x30 | 0x64 |
| CALL <addr> | Call function | CALL 0x50 | 0x65 |
| RET | Return from call | RET | 0x66 |

### System Calls

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| SYSCALL <id> | Invoke system function | SYSCALL 0x01 | 0x70 |
| PRINT_INT | Print integer | PRINT_INT | 0x71 |
| PRINT_FLOAT | Print float | PRINT_FLOAT | 0x72 |
| PRINT_FIXED | Print fixed-point | PRINT_FIXED | 0x73 |
| PRINT_STR <offset> | Print string from constant pool | PRINT_STR str_hello | 0x74 |

### Task / Extensions
| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| TASK_CREATE <bytecode> | Create a new task | TASK_CREATE game_task | 0x80 |
| TASK_YIELD | Yield current task | TASK_YIELD | 0x81 |
| TASK_SLEEP <ms> | Sleep task for milliseconds | TASK_SLEEP 50 | 0x82 |
| TASK_EXIT | Exit current task | TASK_EXIT | 0x83 |
| HALT | Stop VM execution | HALT | 0x84 |