### Modules

| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| SYSCALL <id> | Invoke system function | SYSCALL 0x01 | 0x70 |
| PRINT_INT | Print integer | PRINT_INT | 0x71 |
| PRINT_FLOAT | Print float | PRINT_FLOAT | 0x72 |
| PRINT_FIXED | Print fixed-point | PRINT_FIXED | 0x73 |
| PRINT_STR <offset> | Print string from constant pool | PRINT_STR str_hello | 0x74 |