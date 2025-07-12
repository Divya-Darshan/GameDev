extends CharacterBody2D

const FOLLOW_SPEED   := 100.0   # normal speed when following the dog
const WALKOFF_SPEED  := 70.0    # speed while walking to point A
const STOP_DISTANCE  := 6.0     # how close to A before stopping/queuing


var dog          : Node2D  = null
var is_following : bool    = false
var walking_to_A : bool    = false
var point_A      : Vector2 = Vector2.ZERO  # set in _ready()

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Choose the off‑screen point you want to walk to (e.g., right side)
	point_A = position + Vector2(400, 0)   # 400 px to the right; change as needed

func _physics_process(delta: float) -> void:
	# 1) Following the dog
	if is_following and dog and not walking_to_A:
		var dir := (dog.position - position)
		if dir.length() > 20.0:
			position += dir.normalized() * FOLLOW_SPEED * delta
			_play_run(dir.x)
		else:
			sprite.play("idle")

	# 2) Walking to A after frog event
	elif walking_to_A:
		var to_A := point_A - position
		if to_A.length() > STOP_DISTANCE:
			position += to_A.normalized() * WALKOFF_SPEED * delta
			_play_run(to_A.x)
		else:
			sprite.play("idle")
			queue_free()          # vanish when arrived

	else:
		sprite.play("idle")


# --- Helper to flip & play run animation ---
func _play_run(dir_x: float) -> void:
	sprite.play("run")
	if dir_x != 0:
		sprite.flip_h = dir_x < 0




func _on_area_2d_body_entered(body: Node2D) -> void:
	is_following = true
	dog = body

	# SPECIAL: If this body has a `frog()` method, trigger the walk‑off sequence
	if body.has_method("frog"):
		print("Frog detected → will walk away in 3 s.")
		await get_tree().create_timer(3.0).timeout
		is_following = false
		walking_to_A = true    # start walking toward point_A


func _on_area_2d_body_exited(body: Node2D) -> void:
	is_following = false
	dog = null
