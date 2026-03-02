class_name Blocks

enum Category {
	ENGINE,
	CONTROL
}

enum BlockType {
	SET_POWER,
	STOP_MOTOR,

	ON_START,
	ON_SIGNAL,
	ON_TICK
}

const TINTS := {
	Category.CONTROL: Color("#ffb700"),
	Category.ENGINE: Color("#e95d35")
}

static var _all_blocks: Array[BlockData] = [
	BlockData.new(
		"Set Power", 
		BlockType.SET_POWER, 
		Category.ENGINE, 
		"res://code_blocks/scenes/blocks/engine/set_power.tscn"
	),
	BlockData.new(
		"Stop Motor", 
		BlockType.STOP_MOTOR, 
		Category.ENGINE, 
		"res://code_blocks/scenes/blocks/engine/stop_motor.tscn"
	),
	BlockData.new(
		"On Start", 
		BlockType.ON_START,
		Category.CONTROL, 
		"res://code_blocks/scenes/blocks/entry/on_start.tscn"
	),
	BlockData.new(
		"On Signal", 
		BlockType.ON_SIGNAL,
		Category.CONTROL, 
		"res://code_blocks/scenes/blocks/entry/on_signal.tscn"
	),
	BlockData.new(
		"On Tick", 
		BlockType.ON_TICK,
		Category.CONTROL, 
		"res://code_blocks/scenes/blocks/entry/on_tick.tscn"
	)
]

static func get_tint(category: Blocks.Category) -> Color:
	return TINTS.get(category, Color("#FFFFFF"))


static func get_category_name(category: Blocks.Category) -> String:
	return Category.find_key(category).to_lower()

static func get_categorized_blocks(enabled_categories: Array[Blocks.Category], enabed_types: Array[BlockType]) -> Array[CategoryData]:
	var result: Array[CategoryData] = []
	for category in enabled_categories:
		var category_data := CategoryData.new()
		category_data.category = category
		category_data.blocks = []
		for block in _all_blocks:
			if block.category == category:
				category_data.blocks.append(block)
		if not category_data.blocks.is_empty():
			result.append(category_data)

	for block_type in enabed_types:
		var block_to_add: BlockData
		for block in _all_blocks:
			if block.type == block_type:
				block_to_add = block
				break
		if not block_to_add:
			continue

		var category_found := false
		for category_data in result:
			if category_data.category == block_to_add.category:
				if not category_data.blocks.has(block_to_add):
					category_data.blocks.append(block_to_add)
				category_found = true
				break
		if not category_found:
			var category_data := CategoryData.new()
			category_data.category = block_to_add.category
			category_data.blocks = [block_to_add]
			result.append(category_data)

	return result

class BlockData extends RefCounted:
	var name: String
	var type: BlockType
	var category: Blocks.Category
	var scene_path: String

	func _init(name: String, type: BlockType, category: Blocks.Category, scene_path: String) -> void:
		self.name = name
		self.type = type
		self.category = category
		self.scene_path = scene_path

class CategoryData extends RefCounted:
	var category: Category
	var blocks: Array[BlockData]
