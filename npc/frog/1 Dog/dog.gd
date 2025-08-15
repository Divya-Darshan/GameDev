extends CharacterBody2D

const FOLLOW_SPEED      := 100.0
const WALKOFF_SPEED     := 70.0
const STOP_DISTANCE     := 6.0
const EXPLODE_DISTANCE  := 30.0  # Distance to start fuse
const FUSE_TIME         := 1.0   # Delay before explosion

var dog          : Node2D  = null
var is_following : bool    = false
var walking_to_A : bool    = false
var point_A      : Vector2 = Vector2.ZERO
var fuse_started : bool    = false  # Track if fuse countdown has begun

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var expo   : AnimatedSprite2D = $expo

var decided_action : String = ""  # "explode" or "follow"

func _ready() -> void:
	randomize()
	decided_action = "explode" if random_bool() else "follow"
	expo.visible = false
	point_A = position + Vector2(400, 0)

func random_bool() -> bool:
	return randf() < 0.5

func _physics_process(delta: float) -> void:
	if is_following and dog and not walking_to_A:
		var dir := dog.position - position
		var dist := dir.length()

		# Always chase until close enough
		if decided_action == "explode":
			if not fuse_started:
				if dist > EXPLODE_DISTANCE:
					position += dir.normalized() * FOLLOW_SPEED * delta
					_play_run(dir.x)
				else:
					# Start creeper fuse delay
					fuse_started = true
					sprite.play("idle") # Could play fuse animation here
					_start_fuse()
			# If fuse started, stop chasing
		else:
			# Non-exploding dogs just follow normally
			if dist > STOP_DISTANCE:
				position += dir.normalized() * FOLLOW_SPEED * delta
				_play_run(dir.x)
			else:
				sprite.play("idle")

	elif walking_to_A:
		var to_A := point_A - position
		if to_A.length() > STOP_DISTANCE:
			position += to_A.normalized() * WALKOFF_SPEED * delta
			_play_run(to_A.x)
		else:
			sprite.play("idle")
			queue_free()
	else:
		sprite.play("idle")

func _play_run(dir_x: float) -> void:
	sprite.play("run")
	if dir_x != 0:
		sprite.flip_h = dir_x < 0

func _start_fuse() -> void:
	await get_tree().create_timer(FUSE_TIME).timeout
	_trigger_explosion()

func _trigger_explosion() -> void:
	is_following = false
	expo.visible = true
	expo.play("idle")  # Explosion animation
	await expo.animation_finished
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	is_following = true
	dog = body

	if body.has_method("frog"):
		print("Frog detected → will walk away in 3 s.")
		await get_tree().create_timer(3.0).timeout
		is_following = false
		walking_to_A = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	is_following = false
	dog = null
