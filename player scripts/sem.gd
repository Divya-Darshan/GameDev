extends CharacterBody2D

# Multiplayer-synced properties
@export var player_id: int = 0
@export var spawn_point: String = "point1"
@export var charpos: Vector2
@export var health: int = 100

# Signals
signal progressbar

# Movement
var SPEED := 200.0
const DEADZONE := 0.1

# Attack states
var is_attacking1 := false
var is_attacking2 := false
var is_inter := false
var is_inter2 := false
var last_direction := 1
var players_in_range := []

# Onready nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slashsfx: AudioStreamPlayer2D = $slashsfx
@onready var col2d: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = $Shadow
@onready var endscr: HBoxContainer = $CanvasLayer/HBoxContainer
@onready var touchcontrols: CanvasLayer = $"../Touchcontrols"
@onready var progress_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar

func _ready():
	setup(spawn_point)
	if touchcontrols:
		touchcontrols.button_pressed.connect(_on_touch_button_pressed)

func setup(spawn_point: String):
	var spawn_node = get_tree().current_scene.get_node("spawnpoint")
	if spawn_node and spawn_node.has_node(spawn_point):
		global_position = spawn_node.get_node(spawn_point).global_position
	else:
		push_error("❌ Spawn point not found: " + spawn_point)


func _process(_delta: float) -> void:
	charpos = global_position

func _physics_process(_delta: float) -> void:
	if is_attacking1 or is_attacking2 or is_inter or is_inter2:
		return

	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_vector.length() > DEADZONE:
		input_vector = input_vector.normalized()
	else:
		input_vector = Vector2.ZERO

	velocity = input_vector * SPEED
	move_and_slide()

	if input_vector.x != 0:
		last_direction = sign(input_vector.x)

	animated_sprite.play("run" if input_vector != Vector2.ZERO else "default")
	animated_sprite.flip_h = last_direction < 0

func _on_touch_button_pressed(action_name: String) -> void:
	match action_name:
		"attack1":
			if not is_attacking1: attack1()
		"attack2":
			if not is_attacking2: attack2()
		"inter":
			if not is_inter: inter()
		"inter2":
			if not is_inter2: inter2()

func attack1() -> void:
	is_attacking1 = true
	animated_sprite.play("ack1")
	slashsfx.pitch_scale = randf_range(0.9, 1.2)
	slashsfx.play()
	for target in players_in_range:
		if target.has_method("take_damage"):
			target.take_damage(10)
			await animated_sprite.animation_finished
			animated_sprite.play("hit")
	await animated_sprite.animation_finished
	animated_sprite.play("default")
	is_attacking1 = false

func attack2() -> void:
	is_attacking2 = true
	animated_sprite.play("ack1")
	slashsfx.pitch_scale = randf_range(0.9, 1.2)
	slashsfx.play()
	for target in players_in_range:
		if target.has_method("take_damage"):
			target.take_damage(10)
			await animated_sprite.animation_finished
			animated_sprite.play("hit")
	await animated_sprite.animation_finished
	animated_sprite.play("default")
	is_attacking2 = false

func inter():
	is_inter = true
	health = 100
	progressbar.emit()
	is_inter = false

func inter2():
	is_inter2 = true
	animated_sprite.play("hit")
	await animated_sprite.animation_finished
	animated_sprite.play("default")
	is_inter2 = false

func take_damage(amount: int):
	health -= amount
	progressbar.emit()
	print("Took damage. Health:", health)

	if health <= 0:
		SPEED = 0
		col2d.disabled = true
		animated_sprite.visible = false
		endscr.visible = true
		touchcontrols.visible = false
		shadow.visible = false
		var tween = create_tween()
		tween.tween_property(endscr, "position", Vector2(94, 324), 0.3)
		tween.tween_property(progress_bar, "position", Vector2(189, 24), 0.1)

func is_player() -> bool:
	return true

func _on_hitbox_body_entered(body: Node2D):
	if body != self and body.has_method("is_player") and body.is_player():
		if not players_in_range.has(body):
			players_in_range.append(body)

func _on_hitbox_body_exited(body: Node2D):
	if players_in_range.has(body):
		players_in_range.erase(body)

func _on_touch_screen_button_pressed():
	SPEED = 200
	col2d.disabled = false
	animated_sprite.visible = true
	shadow.visible = true
	touchcontrols.visible = true
	health = 100
	progressbar.emit()
	var tween = create_tween()
	tween.tween_property(progress_bar, "position", Vector2(189, 137), 0.1)
	tween.tween_property(endscr, "position", Vector2(-440, 324), 0.3)
	await get_tree().create_timer(0.4).timeout
	endscr.visible = false
