extends Node2D

var dragging := false
var drag_offset := Vector2.ZERO
var target_position := Vector2.ZERO
var free_look := false  # 🔹 Set this to true to allow full XY movement

const SCALE_FACTOR_X := 7.0
const SCALE_FACTOR_Y := 10.0
const DRAG_SMOOTHNESS := 0.5  # Lower = smoother
const SNAP_DURATION := 0.5

@onready var tween := create_tween()

func _ready() -> void:
	free_look = false
	target_position = position

func _process(delta: float) -> void:
	if dragging:
		if free_look:
			position = position.lerp(target_position, DRAG_SMOOTHNESS)
		else:
			position.y = lerp(position.y, target_position.y, DRAG_SMOOTHNESS)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var touch_pos = event.position

		if event is InputEventScreenTouch and event.pressed:
			if get_global_rect().has_point(touch_pos):
				dragging = true
				drag_offset = position - touch_pos

		elif event is InputEventScreenTouch and not event.pressed:
			if dragging:
				snap_to_position(position)
			dragging = false

		elif dragging and event is InputEventScreenDrag:
			if free_look:
				target_position = touch_pos + drag_offset
			else:
				target_position.y = touch_pos.y + drag_offset.y
				target_position.x = position.x

func snap_to_position(pos: Vector2) -> void:
	tween.kill()
	tween = create_tween()
	if free_look:
		tween.tween_property(self, "position", pos, SNAP_DURATION)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "position:y", pos.y, SNAP_DURATION)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

func get_global_rect() -> Rect2:
	var sprite = get_node_or_null("Sprite")
	if sprite:
		var texture = sprite.texture
		if texture:
			var size = Vector2(
				texture.get_width() * sprite.scale.x * SCALE_FACTOR_X,
				texture.get_height() * sprite.scale.y * SCALE_FACTOR_Y
			)
			return Rect2(global_position - size / 2, size)
	return Rect2(
		global_position - Vector2(50 * SCALE_FACTOR_X, 50 * SCALE_FACTOR_Y),
		Vector2(100 * SCALE_FACTOR_X, 100 * SCALE_FACTOR_Y)
	)
