extends Node2D

var dragging := false
var drag_offset := Vector2.ZERO
const SCALE_FACTOR := 1.83

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var touch_pos = event.position

		if event is InputEventScreenTouch and event.pressed:
			# Start dragging if touch is on the scaled object
			if get_global_rect().has_point(touch_pos):
				dragging = true
				drag_offset = position - touch_pos

		elif event is InputEventScreenTouch and not event.pressed:
			dragging = false

		elif dragging and event is InputEventScreenDrag:
			position = touch_pos + drag_offset

func get_global_rect() -> Rect2:
	var sprite = get_node_or_null("Sprite")  # Replace with your sprite node name
	if sprite:
		var texture = sprite.texture
		if texture:
			var size = texture.get_size() * sprite.scale * SCALE_FACTOR
			return Rect2(global_position - size / 2, size)
	# Fallback rectangle if no sprite found
	return Rect2(global_position - Vector2(50, 50) * SCALE_FACTOR, Vector2(100, 100) * SCALE_FACTOR)
