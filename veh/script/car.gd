extends CharacterBody2D

var SPEED := 300
var car_entered := false
var car: Node2D = null

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var enter: TouchScreenButton = $TouchScreenButton
@onready var statcoll: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var enterlab: Label = $TouchScreenButton/enterlab
@onready var exitlab: Label = $TouchScreenButton/exitlab
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadowrl: Sprite2D = $AnimatedSprite2D/Shadowrl
@onready var shadowud: Sprite2D = $AnimatedSprite2D/Shadowud

func _ready() -> void:
	enter.visible = false

func _physics_process(delta: float) -> void:
	if car_entered and car:
		var input_vector := Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)

		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			velocity = input_vector * SPEED
			_handle_animation(input_vector)
		else:
			velocity = Vector2.ZERO
			sprite.play("idle")
			shadowud.visible = false
			shadowrl.visible = true

		move_and_slide()

func _handle_animation(input_vector: Vector2) -> void:
	if abs(input_vector.x) > abs(input_vector.y):
		sprite.play("move")
		sprite.flip_h = input_vector.x < 0
		shadowrl.visible = true
		shadowud.visible = false
	else:
		if input_vector.y > 0:
			sprite.play("down")
		else:
			sprite.play("up")
		shadowrl.visible = false
		shadowud.visible = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not car:
		car = body
		enter.visible = true
		var tween = create_tween()
		tween.tween_property(enter, "position", Vector2(-12, 20), 0.2)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == car:
		car.visible = true
		car = null
		car_entered = false
		var tween = create_tween()
		tween.tween_property(enter, "position", Vector2(-12, -7), 0.2)
		await get_tree().create_timer(0.3).timeout
		enter.visible = false

func _on_touch_screen_button_pressed() -> void:
	if car:
		car_entered = !car_entered
		car.SPEED = 300
		enterlab.visible = !enterlab.visible
		exitlab.visible = !exitlab.visible
		statcoll.disabled = !statcoll.disabled
		car.visible = not car_entered
