extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $BedsBr

func _ready() -> void:
	timer.one_shot = true
	timer.stop()

func bed() -> void:
	pass
