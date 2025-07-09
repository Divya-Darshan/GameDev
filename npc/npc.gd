extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_screen_button: TouchScreenButton = $TouchScreenButton
@onready var skip: Label = $TouchScreenButton/skip
@onready var talk: Label = $TouchScreenButton/talk
var npc = null
var is_npc = false
var SPEED := 70


func  _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_npc:
		var direction = npc.position - position

		if direction.length() > 20:
			position += direction.normalized() * SPEED * delta
			animated_sprite_2d.play("run")

			if direction.x != 0:
				animated_sprite_2d.flip_h = direction.x < 0
		else:
			animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("idle")
 # or "idle"
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	npc = body
	is_npc = true
	touch_screen_button.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	npc = null
	is_npc = false
	touch_screen_button.visible = false


func _on_touch_screen_button_pressed() -> void:
	talk.visible = !talk.visible
	skip.visible = !skip.visible
	
