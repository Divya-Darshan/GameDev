extends CanvasLayer

signal button_pressed(action_name)

@onready var joystick = $"Virtual Joystick"
@onready var t = $t
@onready var o = $o
@onready var x = $x
@onready var b = $b

func _ready():
	# Connect the buttons to their corresponding actions.
	if t:
		t.pressed.connect(_on_button_pressed_t)
	if o:
		o.pressed.connect(_on_button_pressed_o)
	if x:
		x.pressed.connect(_on_button_pressed_x)
	if b:
		b.pressed.connect(_on_button_pressed_b)

# Button press actions
func _on_button_pressed_t() -> void:
	  # Debugging statement
	emit_signal("button_pressed", "attack1")

func _on_button_pressed_o() -> void:
# Debugging statement
	emit_signal("button_pressed", "inter")

func _on_button_pressed_x() -> void:
# Debugging statement
	emit_signal("button_pressed", "inter2")

func _on_button_pressed_b() -> void:
  # Debugging statement
	emit_signal("button_pressed", "attack2")


	


# Function to get the joystick direction
func get_joystick_direction() -> Vector2:
	# Fetch the joystick direction from the actual VirtualJoystick node
	return joystick.output if joystick else Vector2.ZERO
