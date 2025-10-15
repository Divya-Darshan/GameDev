extends Node2D

@onready var character_holder = $CharacterHolder
@onready var select_button = $HBoxContainer/TouchScreenButton

var characters = [
	preload("res://char scene/doremon/doreamon.tscn"),
	preload("res://char scene/spider/spider.tscn"),
	preload("res://char scene/hollow knight/knight.tscn"),
	preload("res://char scene/sonic/sonic.tscn"),
	preload("res://char scene/Kirby/Kirby.tscn"),
	preload("res://char scene/burger_spritesheet/Cheeseburger.tscn"),
	preload("res://char scene/cube/cube.tscn"),
	preload("res://char scene/sem/sem.tscn"),
	preload("res://char scene/Vegeta/Vegeta.tscn"),
	preload("res://char scene/gojo/gojo.tscn"),
	preload("res://char scene/skate/skate.tscn"),

]


var current_index = 0
var swipe_start_x = 0
var swipe_handled = false  # prevents multiple triggers per swipe
var current_character = null

func _ready():
	Touchcontrols.visible = false
	show_character(current_index)

	# Ensure button works even if not connected in editor
	if select_button:
		select_button.pressed.connect(_on_TouchScreenButton_pressed)

func show_character(index):
	if current_character:
		current_character.queue_free()
	current_character = characters[index].instantiate()
	character_holder.add_child(current_character)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_x = event.position.x
			swipe_handled = false
		else:
			if not swipe_handled:
				var swipe_distance = event.position.x - swipe_start_x
				_handle_swipe(swipe_distance)
			swipe_handled = true

	elif event is InputEventScreenDrag:
		if not swipe_handled:
			var swipe_distance = event.position.x - swipe_start_x
			if abs(swipe_distance) > 100:  # increase threshold so tiny swipes don't trigger
				_handle_swipe(swipe_distance)
				swipe_handled = true  # only trigger once per swipe

func _handle_swipe(swipe_distance):
	if swipe_distance > 0:
		current_index = (current_index - 1 + characters.size()) % characters.size()
	else:
		current_index = (current_index + 1) % characters.size()
	show_character(current_index)

func _on_TouchScreenButton_pressed():
	Global.selected_character = current_index
	get_tree().change_scene_to_file("res://main.tscn")
