extends Node2D

@onready var players = [ $gojo]  # Add all starting players here
@onready var camera = $gojo/Camera2D  # (Optional, if you still need a reference to Gojo's camera)

var spawn_delay = 6.0
var active_spawn_distance = 500
var despawn_distance = 800
var mobs = []  # Track spawned mobs
var max_mobs_near_players = 15  # Maximum mobs allowed at once near players

# ✅ NEW: Track last interaction times
var mob_last_interaction = {}
const INACTIVITY_LIMIT = 300.0  # 5 minutes
const INTERACTION_RADIUS = 100  # pixels

# ✅ NEW: Track start time for 5-minute cycle (1 minute active, 4 minutes inactive)
var world_start_time := Time.get_ticks_msec() / 1000

# Track the list of mobs that should be despawned at the start of the inactive period
var active_mobs = []

func _ready():
	# Track when players join/leave
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	get_tree().connect("node_removed", Callable(self, "_on_node_removed"))
	
	spawn_loop()
	start_despawn_check()

func _on_node_added(node):
	if node.is_in_group("players"):
		players.append(node)
		print("Player added:", node.name)

func _on_node_removed(node):
	if node.is_in_group("players"):
		players.erase(node)
		print("Player removed:", node.name)

# ✅ UPDATED: Spawn only during 1-minute "active" windows, with 4 minutes "inactive" cycles
func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_delay).timeout

		var time_since_start = Time.get_ticks_msec() / 1000 - world_start_time
		var cycle_time = int(time_since_start) % 300  # 300 = 5 minute cycle (1 minute active, 4 minutes inactive)

		# Print the cycle time and the phase (active/inactive)
		print("Cycle Time: ", cycle_time)
		if cycle_time < 60:
			print("Active Phase - Spawning mobs")
			# First 1 minute = spawn mobs
			if count_mobs_near_players() < max_mobs_near_players:
				spawn_enemy()
		else:
			print("Inactive Phase - Despawning mobs")
			# Second 4 minutes = inactive time, despawn mobs that were spawned during the active time
			despawn_active_mobs()

func get_spawn_position_near_random_player():
	if players.size() == 0:
		return Vector2.ZERO  # Safety check if no players
		
	var random_player = players[randi() % players.size()]
	
	var angle = randf() * TAU
	var distance = randf_range(active_spawn_distance * 0.8, active_spawn_distance)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return random_player.global_position + offset

func spawn_enemy():
	# Create instances of all the enemies
	var skl = preload("res://Enemy/scene/Skeleton.tscn").instantiate()
	var mus = preload("res://Enemy/scene/mus.tscn").instantiate()
	var slime_red = preload("res://Enemy/scene/red_slime.tscn").instantiate()
	var slime_blue = preload("res://Enemy/scene/blue_slime.tscn").instantiate()
	var eyemon = preload("res://Enemy/scene/eyefliy.tscn").instantiate()

	# Assign each enemy a spawn position near a random player
	skl.global_position = get_spawn_position_near_random_player()
	mus.global_position = get_spawn_position_near_random_player()
	slime_red.global_position = get_spawn_position_near_random_player()
	slime_blue.global_position = get_spawn_position_near_random_player()

	eyemon.global_position = get_spawn_position_near_random_player()

	# Add the enemies to the scene and the mobs list
	add_child(skl)
	add_child(mus)
	add_child(slime_red)
	add_child(slime_blue)

	add_child(eyemon)

	mobs.append(skl)
	mobs.append(mus)
	mobs.append(slime_red)
	mobs.append(slime_blue)

	mobs.append(eyemon)

	# Track time of last "interaction" at spawn
	mob_last_interaction[skl] = Time.get_ticks_msec() / 1000
	mob_last_interaction[mus] = Time.get_ticks_msec() / 1000
	mob_last_interaction[slime_red] = Time.get_ticks_msec() / 1000
	mob_last_interaction[slime_blue] = Time.get_ticks_msec() / 1000

	mob_last_interaction[eyemon] = Time.get_ticks_msec() / 1000

	# Store mobs that spawn during the active phase
	active_mobs.append(skl)
	active_mobs.append(mus)
	active_mobs.append(slime_red)
	active_mobs.append(slime_blue)

	active_mobs.append(eyemon)

	# Fancy fade-in spawn effect for each mob
	apply_fade_in_effect(skl)
	apply_fade_in_effect(mus)
	apply_fade_in_effect(slime_red)
	apply_fade_in_effect(slime_blue)

	apply_fade_in_effect(eyemon)

	# Optionally: You could add different animation effects for each mob as they spawn

# Helper function to apply fade-in effect to any mob
func apply_fade_in_effect(mob):
	mob.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(mob, "modulate:a", 1.0, 1.0)  # Fade in effect
	tween.parallel().tween_property(mob, "position:y", mob.position.y - 20, 1.0)  # Rise up effect

# Function to despawn all mobs that were spawned during the active phase when entering the inactive phase
func despawn_active_mobs():
	for mob in active_mobs.duplicate():
		if is_instance_valid(mob):
			mobs.erase(mob)
			mob_last_interaction.erase(mob)
			mob.queue_free()
			active_mobs.erase(mob)

func start_despawn_check():
	check_despawn_loop()

func check_despawn_loop():
	while true:
		await get_tree().create_timer(5.0).timeout
		
		var current_time = Time.get_ticks_msec() / 1000

		for mob in mobs.duplicate():
			if not is_instance_valid(mob):
				mobs.erase(mob)
				mob_last_interaction.erase(mob)
				continue

			var nearest_distance = get_nearest_player_distance(mob.global_position)

			# ✅ Update "interaction" timestamp if player is nearby
			if nearest_distance <= INTERACTION_RADIUS:
				mob_last_interaction[mob] = current_time

			# ✅ Despawn if inactive too long
			var last_time = mob_last_interaction.get(mob, current_time)
			if current_time - last_time > INACTIVITY_LIMIT:
				mobs.erase(mob)
				mob_last_interaction.erase(mob)
				mob.queue_free()
				continue

			# Existing despawn if too far
			if nearest_distance > despawn_distance:
				mobs.erase(mob)
				mob_last_interaction.erase(mob)
				mob.queue_free()

func count_mobs_near_players() -> int:
	var count = 0
	for mob in mobs:
		if is_instance_valid(mob):
			var nearest_distance = get_nearest_player_distance(mob.global_position)
			if nearest_distance <= despawn_distance:
				count += 1
	return count

func get_nearest_player_distance(position: Vector2) -> float:
	var min_distance = INF
	for player in players:
		if is_instance_valid(player):
			var dist = player.global_position.distance_to(position)
			if dist < min_distance:
				min_distance = dist
	return min_distance
