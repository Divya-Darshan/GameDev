extends Node2D

var characters = [
	preload("res://char scene/bird/bird.tscn"),
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

func _ready():
	var chosen_index = Global.selected_character
	var chosen_character = characters[chosen_index].instantiate()
	chosen_character.position = Vector2(1166, 1002) 
	add_child(chosen_character)
