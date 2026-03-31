extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var input1_code: LineEdit = $"VBoxContainer/input code"
@onready var confirm: Label = $VBoxContainer/confirm
@onready var try: Button = $VBoxContainer/try



var cheats = ["2012390","Max", "ALLUNLOCK"]

func _on_try_pressed():
	var input_code = input1_code.text.strip_edges().to_upper()

	if cheats.has(input_code):
		#cheats[input1_code].call()
		confirm.text = "✅ Cheat aktiviert!"
	else:
		confirm.text = "❌ Ungültiger Code"
