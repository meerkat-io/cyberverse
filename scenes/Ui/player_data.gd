extends Node
var dia = 100
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#.diamonds_changed.connect(_on_diamonds_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func diamonds_changed():
	dia -= 30
	label.text = dia + "💎"
