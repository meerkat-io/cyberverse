extends Control
@onready var rightmenu: PanelContainer = $menu3/rightmenu
@onready var leftmenu: PanelContainer = $Node/leftmenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	#rightmenu.visible = true
	#leftmenu.visible = true
	queue_free()



	
	

signal diamonds_changed(amount)



var diamonds := 0

func add_diamonds(value):
	diamonds += value
	emit_signal("diamonds_changed", diamonds)


func _on_buy_pressed() -> void:
	add_diamonds(30)
