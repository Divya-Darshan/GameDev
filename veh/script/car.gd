extends CharacterBody2D

@onready var enter: TouchScreenButton = $TouchScreenButton
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var target_body: Node2D = null
var should_follow := false
var speed := 200.0  # Speed to follow the target

func _ready() -> void:
	enter.visible = false  # Hide button by default

func _physics_process(delta: float) -> void:
	if should_follow and target_body:
		var distance = global_position.distance_to(target_body.global_position)
		if distance > 10:  # ✅ Small gap to avoid overlap
			var direction = (target_body.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
			
			# Flip sprite
			if direction.x != 0:
				animated_sprite_2d.flip_h = direction.x < 0
		else:
			velocity = Vector2.ZERO
			move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "sem":  # Only allow if the target is the 'sem' node (player)
		target_body = body
		enter.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == target_body:
		target_body = null
		should_follow = false  # Stop following
		enter.visible = false  # Hide the button too

func _on_touch_screen_button_pressed() -> void:
	should_follow = !should_follow  # Toggle follow on/off
