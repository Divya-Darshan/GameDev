extends Node2D

var dragging := false
var drag_offset := Vector2.ZERO

const SCALE_FACTOR_X := 5.0
const SCALE_FACTOR_Y := 8.83

var tap_count := 0
var double_tap_timer := Timer.new()
var last_double_tap_pos := Vector2.ZERO
const DOUBLE_TAP_TIME := 0.3

func _ready() -> void:
	double_tap_timer.wait_time = DOUBLE_TAP_TIME
	double_tap_timer.one_shot = true
	double_tap_timer.connect("timeout", Callable(self, "_on_double_tap_timeout"))
	add_child(double_tap_timer)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var touch_pos = event.position

		if event is InputEventScreenTouch and event.pressed:
			tap_count += 1
			if tap_count == 1:
				double_tap_timer.start()
				last_double_tap_pos = touch_pos
			elif tap_count == 2:
				teleport_to_position(touch_pos)
				double_tap_timer.stop()
				tap_count = 0
				dragging = false
				return

			if get_global_rect().has_point(touch_pos):
				dragging = true
				drag_offset = position - touch_pos

		elif event is InputEventScreenTouch and not event.pressed:
			dragging = false

		elif dragging and event is InputEventScreenDrag:
			position = touch_pos + drag_offset

func _on_double_tap_timeout() -> void:
	tap_count = 0

func teleport_to_position(target_pos: Vector2) -> void:
	position = target_pos

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
