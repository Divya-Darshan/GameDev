extends Node2D

# Declare PackedScene variables for each character's scene
var gojo : PackedScene
var knight : PackedScene
var batgirl : PackedScene
var luffy : PackedScene

# Store characters in an array for easy swiping
var character_scenes = []
var current_index = 0
var current_character : CharacterBody2D

# Cooldown variable to prevent rapid swiping
var can_swipe : bool = true

func _ready():
	# Load character scenes
	gojo = load("res://Chars scene/gojo.tscn")
	knight = load("res://Chars scene/knight.tscn")
	batgirl = load("res://Chars scene/batgirl.tscn")
	luffy = load("res://Chars scene/luffy.tscn")
	# Store them in an array for easy access
	character_scenes = [ knight, batgirl, gojo, luffy]
	
	# Load the first character (default to knight)
	load_character(0)

	# Set Timer properties
	$Timer.wait_time = 1.0  # ✅ Set 1-second cooldown
	$Timer.one_shot = true  # ✅ Ensures the timer runs once per swipe

# Function to load a character with smooth animation at the same position
func load_character(index, direction = 1):
	# Ensure index wraps correctly within the array range
	if index < 0 or index >= character_scenes.size():
		return  # Stop if index is out of range

	# Update the current index
	current_index = index  

	# Create a new character instance
	var new_character = character_scenes[current_index].instantiate()
	new_character.position = Vector2(direction * 300, 0)  # Start off-screen (right or left)

	# Add the new character to the scene
	add_child(new_character)

	# Animate the transition to the origin (Vector2.ZERO)
	var tween = get_tree().create_tween()
	tween.tween_property(new_character, "position", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# If there is an existing character, fade it out and remove it
	if current_character:
		var old_character = current_character
		var fade_tween = get_tree().create_tween()
		fade_tween.tween_property(old_character, "modulate:a", 0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		fade_tween.tween_callback(old_character.queue_free)

	# Update the current character reference
	current_character = new_character

	# Enable swiping after transition
	tween.tween_callback(func(): can_swipe = true)

# Function to switch characters on swipe
func swipe_left():
	if can_swipe:
		can_swipe = false  # Disable swiping temporarily
		# Loop to the next character to the left
		load_character((current_index + 1) % character_scenes.size(), 1)
		start_swipe_cooldown()

func swipe_right():
	if can_swipe:
		can_swipe = false  # Disable swiping temporarily
		# Loop to the next character to the right
		load_character((current_index - 1 + character_scenes.size()) % character_scenes.size(), -1)
		start_swipe_cooldown()

# Detect swipe gestures
func _input(event):
	if event is InputEventScreenDrag and can_swipe:
		if event.relative.x > 50:  # Adjusted swipe threshold
			swipe_right()
		elif event.relative.x < -50:
			swipe_left()

# Function to add cooldown after each swipe
func start_swipe_cooldown():
	$Timer.start()  # ✅ Start the cooldown timer

# Called when Timer timeout occurs
func _on_Timer_timeout():
	can_swipe = true  # ✅ Ensures swiping works after switching
