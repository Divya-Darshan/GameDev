extends Node2D

@onready var players = [$gojo]  # Add all starting players here
@onready var cyc = $cycle  # Track the day cycle

const SPAWN_DELAY := 6.0
const SPAWN_PER_CYCLE := 10
const ACTIVE_SPAWN_DISTANCE := 500
const DESPAWN_DISTANCE := 800
const INTERACTION_RADIUS := 100
const INACTIVITY_LIMIT := 300.0
const CYCLE_DURATION := 120  # Total day+night = 2 minutes
const ACTIVE_DURATION := 60  # First 60s = INACTIVE (day), next 60s = ACTIVE (night)

var mobs: Array = []
var active_mobs: Array = []
var mob_last_interaction := {}
var world_start_time := Time.get_ticks_msec() / 1000

const ENEMY_SCENES = [
	preload("res://Enemy/scene/Skeleton.tscn"),
	preload("res://Enemy/scene/mus.tscn"),
	preload("res://Enemy/scene/red_slime.tscn"),
	preload("res://Enemy/scene/blue_slime.tscn"),
	preload("res://Enemy/scene/eyefliy.tscn")
]

func _ready():
	get_tree().connect("node_added", _on_node_added)
	get_tree().connect("node_removed", _on_node_removed)
	spawn_loop()

func _on_node_added(node):
	if node.is_in_group("players") and not players.has(node):
		players.append(node)

func _on_node_removed(node):
	if players.has(node):
		players.erase(node)

func spawn_loop():
	while true:
		await get_tree().create_timer(SPAWN_DELAY).timeout

		var valid_players = players.filter(func(p): return is_instance_valid(p))
		if valid_players.is_empty():
			continue

		var time_passed := int(Time.get_ticks_msec() / 1000 - world_start_time)
		var cycle_time := time_passed % CYCLE_DURATION
		var is_active := cycle_time >= ACTIVE_DURATION

		print("[Time: ", time_passed, "s] State: ", "ACTIVE (Nighttime)" if is_active else "INACTIVE (Daytime)")

		if is_active:
			if mobs.size() < valid_players.size() * SPAWN_PER_CYCLE:
				await fade_in_cyc()
				spawn_random_enemies()
		else:
			await fade_out_cyc()
			# Replace despawn loop with check_for_dead_mobs for regular checks during the day
			await check_for_dead_mobs()

		# Regular check during daytime for mobs still in the world
		if not is_active:
			await check_for_dead_mobs()

func fade_in_cyc():
	cyc.visible = true
	var tween = create_tween()
	tween.tween_property(cyc, "color:a", 1, 3.0)

func fade_out_cyc():
	var tween = create_tween()
	tween.tween_property(cyc, "color:a", 0.0, 3.0)
	await tween.finished
	cyc.visible = false

func spawn_random_enemies():
	for i in range(SPAWN_PER_CYCLE):
		var enemy_scene = ENEMY_SCENES[randi() % ENEMY_SCENES.size()].instantiate()
		enemy_scene.global_position = get_spawn_position_near_random_player()
		add_child(enemy_scene)
		mobs.append(enemy_scene)
		active_mobs.append(enemy_scene)
		mob_last_interaction[enemy_scene] = Time.get_ticks_msec() / 1000
		apply_smooth_fade_in_effect(enemy_scene)

func get_spawn_position_near_random_player() -> Vector2:
	if players.is_empty():
		return Vector2.ZERO

	var valid_players = players.filter(func(p): return is_instance_valid(p))
	if valid_players.is_empty():
		return Vector2.ZERO

	var player = valid_players[randi() % valid_players.size()]
	var angle = randf() * TAU
	var distance = randf_range(ACTIVE_SPAWN_DISTANCE * 0.8, ACTIVE_SPAWN_DISTANCE * 2.2)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return player.global_position + offset

func apply_smooth_fade_in_effect(mob):
	mob.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(mob, "modulate:a", 1, 1.0)
	tween.parallel().tween_property(mob, "position:y", mob.position.y - 20, 1.0)

# New function to check and remove any inactive or stuck mobs during the daytime
func check_for_dead_mobs():
	var now = Time.get_ticks_msec() / 1000
	for mob in mobs.duplicate():
		if not is_instance_valid(mob):
			continue

		# If it's day time, the mob should die
		var time_passed := int(Time.get_ticks_msec() / 1000 - world_start_time)
		var cycle_time := time_passed % CYCLE_DURATION
		var is_active := cycle_time >= ACTIVE_DURATION

		# If it's daytime (morning), make sure all mobs are checked and removed
		if not is_active:
			if mob.has_method("die"):
				await mob.call("die")  # Play death animation if mob has a die method
			else:
				mob.queue_free()  # Directly free mob if no death method
			mobs.erase(mob)
			mob_last_interaction.erase(mob)

func get_nearest_player_distance(pos: Vector2) -> float:
	var min_dist = INF
	for p in players:
		if is_instance_valid(p):
			min_dist = min(min_dist, p.global_position.distance_to(pos))
	return min_dist

func despawn_active_mobs():
	for mob in active_mobs.duplicate():
		if is_instance_valid(mob):
			# Always play the death animation before despawning
			if mob.has_method("die"):
				await mob.call("die")
			else:
				mob.queue_free()
			mobs.erase(mob)
			mob_last_interaction.erase(mob)
			active_mobs.erase(mob)
