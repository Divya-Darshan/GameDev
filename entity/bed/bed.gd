extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $BedsBr
@onready var ff_1: Sprite2D = $"Ff-1"

func _ready() -> void:
	timer.one_shot = true
	timer.stop()

func bed() -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
		var tween = create_tween()
		tween.tween_property(ff_1, "position", Vector2(1, -30), 4)


func _on_area_2d_body_exited(body: Node2D) -> void:
		var tween = create_tween()
		tween.tween_property(ff_1, "position", Vector2(1, 1), 2)
