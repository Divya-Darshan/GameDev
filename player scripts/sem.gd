extends CharacterBody2D

var _health := 100 # Internal storage

var is_cow = false
var is_bed = false


var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, 100)

signal progressbar
@export var cur_heath := _health
var SPEED = 200.0
const DEADZONE = 0.1
const FULL_DAMAGE_DELAY := 0.5  # seconds
@onready var bucket: Sprite2D = $bucket
@onready var bucketmilk: Sprite2D = $bucketmilk
@onready var drink: AudioStreamPlayer2D = $drink


@onready var animated_sprite = $AnimatedSprite2D
@onready var touch_controls = $"../Touchcontrols"
@onready var slashsfx: AudioStreamPlayer2D = $slashsfx
@onready var endscr: HBoxContainer = $CanvasLayer/HBoxContainer
@onready var col2d: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = $Shadow
@onready var touchcontrols: CanvasLayer = %Touchcontrols
@onready var progress_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar


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
	#print("Took damage, health:", health)
	
	if health == 0:
		SPEED = 300.0
		col2d.disabled = true
		animated_sprite.visible = false
		endscr.visible = true
		var tween = create_tween()
		tween.tween_property(endscr, "position", Vector2(94, 324), 0.3) #btn animaction
		tween.tween_property(progress_bar, "position", Vector2(189, 24), 0.1)
		shadow.visible = false
		Touchcontrols.visible = false
		

			
		

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
	if is_cow:
		if Input.is_action_pressed("inter") and Input.get_action_strength("inter") > 0:

			bucketmilk.visible = false
		else:
			# Normal short press
			bucketmilk.visible = true
	else:
		pass


func inter2() -> void:

	drink.play()


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
		SPEED = 200.0
		col2d.disabled = false
		animated_sprite.visible = true
		shadow.visible = true
		Touchcontrols.visible = true
		health = 100
		progressbar.emit()
		var tween = create_tween()
		tween.tween_property(progress_bar, "position", Vector2(189, 137), 0.1)
		tween.tween_property(endscr, "position", Vector2(-440, 324), 0.3)

		await get_tree().create_timer(0.4).timeout
		endscr.visible = false
	


func _on_env_body_entered(body: Node2D) -> void:
	if body.has_method('cow'):
		is_cow = true
	if body.has_method('bed'):
		body.bed()
		is_bed = true

func _on_env_body_exited(body: Node2D) -> void:
	if body.has_method('cow'):
		is_cow = false
	if body.has_method('bed'):
		is_bed = false


func _on_drink_finished() -> void:
	bucketmilk.visible = false
	health += 20
	progressbar.emit()
	
