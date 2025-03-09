extends TouchScreenButton

@onready var overlay = $"../../../Knight/Camera2D/ColorRect"
@onready var btn = $"../../../btn"
@onready var zoom = $"../../../settings/VBoxContainer/TouchScreenButton/HSlider"
func _ready() -> void:
	if overlay:
		overlay.hide() 
		zoom.hide()

func _on_pressed() -> void:
	#get_tree().change_scene_to_file("res://sw.tscn")
	if overlay:
		overlay.visible = !overlay.visible
		zoom.visible = !zoom.visible
