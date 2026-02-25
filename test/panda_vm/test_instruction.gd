extends GutTest

func before_each():
	print("before each")
	
func add(a: int, b: int) -> int:
	return a + b

func test_add() -> void:
	assert_eq(add(1, 2), 3)
	assert_eq(add(0, 0), 0)
	assert_eq(add(-1, -2), -3)
