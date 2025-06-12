extends CharacterBody2D

var health := 40
signal progressbar
@export var cur_heath := health
const SPEED = 200.0
const DEADZONE = 0.1
const FULL_DAMAGE_DELAY := 0.5  # seconds

@onready var animated_sprite = $AnimatedSprite2D
@onready var touch_controls = $"../Touchcontrols"
@onready var slashsfx: AudioStreamPlayer2D = $slashsfx
@onready var endscr: HBoxContainer = $CanvasLayer/HBoxContainer

@onready var col2d: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = $Shadow
@onready var touchcontrols: CanvasLayer = %Touchcontrols


var last_attack_time := 0.0
var players_in_range := []
var is_attacking1 = false
var is_attacking2 = false  # For the second attack action
var is_inter = false
var is_inter2 = false
var last_direction = 1  # 1 = right, -1 = left
var ack_in = false






func _ready():
	if touch_controls:
		touch_controls.button_pressed.connect(_on_touch_button_pressed)

#func _process(delta: float) -> void:
	#if health == 0:
		#ply.visible = false
	

func _on_touch_button_pressed(action_name: String) -> void:
	if action_name == "attack1" and not is_attacking1:
		attack1()
	elif action_name == "attack2" and not is_attacking2:
		attack2()
	elif action_name == "inter" and not is_inter:
		inter()
	elif action_name == "inter2" and not is_inter2:
		inter2()
		
func take_damage(amount: int) -> void:
	health -= amount
	progressbar.emit()
	print("Took damage, health:", health)
	
	if health <= 0:
		col2d.disabled = true
		animated_sprite.visible = false
		endscr.visible = true
		shadow.visible = false
		touchcontrols.visible = false
		

			
		

func attack1() -> void:
	is_attacking1 = true
	animated_sprite.play("ack1")
	slashsfx.pitch_scale = randf_range(0.9, 1.2)
	slashsfx.play()
	for target in players_in_range:
		if target and target.has_method("take_damage"):
			target.take_damage(10)
			await animated_sprite.animation_finished
			animated_sprite.play("hit")
	await animated_sprite.animation_finished
	animated_sprite.play("default")
	is_attacking1 = false
	
func play_hit_animation():
	pass


	
	 # Slows down animation to half speed





func attack2() -> void:
	is_attacking1 = true
	animated_sprite.play("ack1")
	slashsfx.pitch_scale = randf_range(0.9, 1.2)
	slashsfx.play()
	for target in players_in_range:
		if target and target.has_method("take_damage"):
			target.take_damage(10)
			await animated_sprite.animation_finished
			animated_sprite.play("hit")
	await animated_sprite.animation_finished
	animated_sprite.play("default")
	is_attacking1 = false

func inter() -> void:
	is_inter = true
	health = 100
	progressbar.emit()
	is_inter = false

func inter2() -> void:
	is_inter2 = true
	animated_sprite.play("hit")  # Play the second special animation
	await animated_sprite.animation_finished
	animated_sprite.play("default")
	is_inter2 = false

func _physics_process(delta: float) -> void:
	
	if is_attacking1 or is_attacking2 or is_inter or is_inter2:
		return  # Prevent movement and other actions during attack or special animations

	var direction = Vector2.ZERO
	var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if abs(horizontal) < DEADZONE:
		horizontal = 0
	if abs(vertical) < DEADZONE:
		vertical = 0

	direction.x = horizontal
	direction.y = vertical

	if direction.length() > 0:
		direction = direction.normalized()

	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED

	# Update last facing direction only if player is actively moving left or right
	if horizontal != 0:
		last_direction = sign(horizontal)

	# Play animations
	if direction == Vector2.ZERO:
		animated_sprite.play("default")
	else:
		animated_sprite.play("run")

	move_and_slide()

	# Flip sprite based on last known horizontal direction
	animated_sprite.flip_h = last_direction < 0

func is_player() -> bool:
	return true



func _on_hitbox_body_entered(body: Node2D) -> void:
	if body != self and body.has_method("is_player") and body.is_player():
		if not players_in_range.has(body):
			players_in_range.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if players_in_range.has(body):
		players_in_range.erase(body)



func _on_touch_screen_button_pressed() -> void:

		col2d.disabled = false
		animated_sprite.visible = true
		endscr.visible = false
		shadow.visible = true
		touchcontrols.visible = true
		health = 100
		progressbar.emit()
	
