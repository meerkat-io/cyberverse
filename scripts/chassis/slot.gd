class_name Slot
extends ColorRect

enum SlotType { GENERAL, ENGINE, SENSOR, WEAPON }

@export var tile_span: Vector2i = Vector2i(1, 1)

@export var slot_type: SlotType = SlotType.GENERAL

const SLOT_COLORS := {
	SlotType.GENERAL: Color("#447cff80"),
	SlotType.ENGINE: Color("#ee545480"),
	SlotType.SENSOR: Color("#44ff4480"),
	SlotType.WEAPON: Color("#ff44ff80")
}

const SLOT_COMPONENTS := {
	SlotType.GENERAL: [Component.ComponentType.BATTERY, Component.ComponentType.CPU],
	SlotType.ENGINE: [Component.ComponentType.ENGINE]
}

func _ready() -> void:
	color = SLOT_COLORS.get(slot_type, Color("#447cff80"))
	custom_minimum_size = tile_span * 128
