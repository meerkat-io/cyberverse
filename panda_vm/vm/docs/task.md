### Task / Extensions
| Assembly | Description | Example | Opcode |
| :--- | :--- | :--- | :--- |
| TASK_CREATE <bytecode> | Create a new task | TASK_CREATE game_task | 0x80 |
| TASK_YIELD | Yield current task | TASK_YIELD | 0x81 |
| TASK_SLEEP <ms> | Sleep task for milliseconds | TASK_SLEEP 50 | 0x82 |
| TASK_EXIT | Exit current task | TASK_EXIT | 0x83 |
| HALT | Stop VM execution | HALT | 0x84 |