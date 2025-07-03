extends CharacterBody2D

var SPEED := 6
var car_entered := false
var car = null
var last_position = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var boomcol: CollisionShape2D = $StaticBody2D2/boomcol
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var enter: TouchScreenButton = $TouchScreenButton
@onready var statcoll: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var enterlab: Label = $TouchScreenButton/enterlab
@onready var exitlab: Label = $TouchScreenButton/exitlab
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadowrl: Sprite2D = $AnimatedSprite2D/Shadowrl
@onready var shadowud: Sprite2D = $AnimatedSprite2D/Shadowud
@onready var area_2d: Area2D = $Area2D
@onready var shap: CollisionShape2D = $Area2D2/CollisionShape2D


@onready var boom_1: AnimatedSprite2D = $boom
@onready var boom_2: AnimatedSprite2D = $boom2
@onready var boom_3: AnimatedSprite2D = $boom3

@onready var boomcoll: CollisionShape2D = $Area2D2/CollisionShape2D



func _ready() -> void:
	enter.visible = false
	last_position = global_position
	boomcol.disabled = true



func _physics_process(delta: float) -> void:
	if car_entered and car != null:
		position += (car.position - position) / SPEED
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

		# Only normalize if non-zero to avoid NaN
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()

			# Play correct animation based on input
			if abs(input_vector.x) > abs(input_vector.y):
				if input_vector.x > 0:
					#right
					shap.position = Vector2(51, 2)
					statcoll.rotation_degrees = 180
					shadowrl.visible = true
					shadowud.visible = false
					sprite.play("move")
					sprite.flip_h = true  # ✅ Facing right
				else:
					#left
					shap.position = Vector2(-42, 3)
					statcoll.rotation_degrees = 180
					shadowrl.visible = true
					shadowud.visible = false
					sprite.play("move")
					sprite.flip_h = false   # ✅ Facing left
			 # or "left"
			else:
				if input_vector.y > 0:
					#down
					shap.position = Vector2(6, 44)
					shadowud.visible = true
					shadowrl.visible = false
					sprite.play("down")
				else:
					#up
					shap.position = Vector2(7, -45)
					shadowud.visible = true
					shadowrl.visible = false
					sprite.play("up")
		else:
			sprite.play("idle")
			shadowud.visible = false
			shadowrl.visible = true  # No input → idle


func _on_area_2d_body_entered(body: Node2D) -> void:
	car = body
	enter.visible = true  # ✅ Show when body enters
	var tween = create_tween()
	tween.tween_property(enter, "position", Vector2(-12, 20), 0.2)


func _on_area_2d_body_exited(body: Node2D) -> void:
	
	if body == car:
		car.visible = true
		car.SPEED = 200.0
		car = null
		car_entered = false
		var tween = create_tween()
		tween.tween_property(enter, "position", Vector2(-12, -7), 0.2)
		await get_tree().create_timer(0.3).timeout
		enter.visible = false


func _on_touch_screen_button_pressed() -> void:
	if car != null:
		car_entered = !car_entered
		car.SPEED = 300
		enterlab.visible = !enterlab.visible
		exitlab.visible = !exitlab.visible
		statcoll.disabled = !statcoll.disabled
		car.visible = false


func boom(body: Node2D) -> void:
	if self.has_meta("boom_done") and self.get_meta("boom_done"):
		return

	if body.has_method("enytake_damage"):
		self.set_meta("boom_done", true)
		
		boom_1.visible = true
		boom_2.visible = true
		boom_3.visible = true
		boom_1.play("idle")
		boom_2.play("idle")
		boom_3.play("idle")
		await boom_3.animation_finished

		sprite.visible = false
		sprite_2d.visible = true
		car.visible = true
		car.SPEED = 200.0
		car = null
		car_entered = false

		var tween = create_tween()
		tween.tween_property(enter, "position", Vector2(-12, -7), 0.2)
		await get_tree().create_timer(0.3).timeout

		area_2d.queue_free()
		boom_1.visible = false
		boom_2.visible = false
		boom_3.visible = false
		boomcol.disabled = false
		print(body)
