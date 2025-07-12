extends CharacterBody2D

@onready var v_box_container: VBoxContainer = $CanvasLayer/VBoxContainer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_screen_button: TouchScreenButton = $TouchScreenButton
@onready var skip: Label = $TouchScreenButton/skip
@onready var talk: Label = $TouchScreenButton/talk

var npc = null
var is_npc = false
var btn_inter := false
var SPEED := 70

# 🟡 Walk-away frog logic
var walking_to_exit := false
var exit_target := Vector2.ZERO


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if walking_to_exit:
		var direction = exit_target - position
		if direction.length() > 10:
			position += direction.normalized() * SPEED * delta
			animated_sprite_2d.play("run")
			animated_sprite_2d.flip_h = direction.x < 0
		else:
			animated_sprite_2d.play("idle")
			queue_free()

	elif is_npc:
		var direction = npc.position - position
		if direction.length() > 20:
			position += direction.normalized() * SPEED * delta
			animated_sprite_2d.play("run")
			animated_sprite_2d.flip_h = direction.x < 0
		else:
			animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("idle")


func _on_area_2d_body_entered(body: Node2D) -> void:
	npc = body
	is_npc = true
	touch_screen_button.visible = true

	# 🐸 Handle special frog NPCs
	if body.has_method("frog"):
		print("Frog detected... will walk away after 2 seconds")
		await get_tree().create_timer(6.0).timeout
		is_npc = false
		npc = null
		walking_to_exit = true
		exit_target = position + Vector2(300, 0)  # Walk 300px to the right before disappearing


func _on_area_2d_body_exited(body: Node2D) -> void:
	npc = null
	is_npc = false
	touch_screen_button.visible = false
	talk.visible = !talk.visible
	skip.visible = !skip.visible
	var tween = create_tween()
	tween.tween_property(v_box_container, "position", Vector2(644, 748), 0.4)
	await get_tree().create_timer(0.4).timeout


func _on_touch_screen_button_pressed() -> void:
	btn_inter = !btn_inter
	print(btn_inter)
	if btn_inter:
		var tween = create_tween()
		tween.tween_property(v_box_container, "position", Vector2(644, 479), 0.2)
		v_box_container.visible = !v_box_container.visible
	else:
		var tween = create_tween()
		tween.tween_property(v_box_container, "position", Vector2(644, 748), 0.2)

	talk.visible = !talk.visible
	skip.visible = !skip.visible


func frog():
	pass
