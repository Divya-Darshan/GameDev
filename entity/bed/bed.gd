extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $BedsBr

func _ready() -> void:
	timer.one_shot = true
	timer.stop()

func bed() -> void:
	if not collision_shape_2d.disabled:
		collision_shape_2d.disabled = true
		position = Vector2(0, 0)  # Move to the center or a different position
		print("Bed function triggered, position set to (0, 0)")
		sprite.visible = true  # Ensure the sprite is visible
		timer.start(1.0)
		await timer.timeout
		print("Timer completed, position after timeout: ", position)
		collision_shape_2d.disabled = false

func _process(delta: float) -> void:
	print("Current position: ", position)  # Debugging the position in every frame
