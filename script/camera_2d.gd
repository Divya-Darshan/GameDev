extends Camera2D

@export var zoom_min: float = 1.0  # Allows really far zoom out
@export var zoom_max: float = 9.0  # Allows really far zoom in
@export var zoom_speed: float = 0.9
@export var zoom_smooth_speed: float = 0.9  # Reduced for smoother transition

var desired_zoom: float = 1.0
var touch_start_position: Vector2
var is_touching: bool = false
var is_touching_slider: bool = false  # Only allow scrolling when touching the slider

@onready var slider: HSlider = $"../../settings/VBoxContainer/TouchScreenButton/HSlider" # Ensure correct reference

func _ready():
	if slider:  # Ensure slider exists before using it
		slider.min_value = zoom_min
		slider.max_value = zoom_max
		slider.value = desired_zoom  # Sync with zoom

	desired_zoom = zoom.x

func _process(delta):
	zoom = zoom.lerp(Vector2(desired_zoom, desired_zoom), zoom_smooth_speed * delta * 10)

func _on_h_slider_value_changed(value: float) -> void:
	desired_zoom = clamp(value, zoom_min, zoom_max)

func _input(event):
	if slider == null:
		return  # Prevent errors if the slider is missing

	# Detect touch start
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_position = event.position
			is_touching = true
			is_touching_slider = is_touch_inside_slider(event.position)  # Check if touch is on slider
		else:
			is_touching = false
			is_touching_slider = false

	# Detect touch drag (Move)
	elif event is InputEventScreenDrag and is_touching and is_touching_slider:
		var touch_delta = event.relative.x
		var zoom_adjustment = touch_delta * 0.005  # Reduced effect for finer control

		desired_zoom = clamp(desired_zoom - zoom_adjustment, zoom_min, zoom_max)

		if slider:
			slider.value = desired_zoom  # Sync slider with zoom

# Function to check if the touch is inside the full area of the slider
func is_touch_inside_slider(touch_position: Vector2) -> bool:
	if slider == null:
		return false
	
	var global_position = slider.global_position
	var global_size = slider.get_size()  # Ensure full size is used
	var slider_rect = Rect2(global_position, global_size)

	return slider_rect.has_point(touch_position)
