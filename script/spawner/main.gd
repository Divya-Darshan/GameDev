extends Node2D

@onready var players = [$gojo]  # Add all starting players here
@onready var cyc = $cycle # Track the day cycle
var spawn_delay := 6.0
var spawn_per_cycle := 10
var active_spawn_distance := 500
var despawn_distance := 800
var mobs := []
var mob_last_interaction := {}
var active_mobs := []

const INTERACTION_RADIUS := 100
const INACTIVITY_LIMIT := 300.0
const CYCLE_DURATION := 120  # total day+night = 2 minutes
const ACTIVE_DURATION := 60  # first 60s = INACTIVE (day), next 60s = ACTIVE (night)

var world_start_time := Time.get_ticks_msec() / 1000

func _ready():
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	get_tree().connect("node_removed", Callable(self, "_on_node_removed"))
	spawn_loop()
	despawn_loop()

func _on_node_added(node):
	if node.is_in_group("players") and not players.has(node):
		players.append(node)

func _on_node_removed(node):
	if players.has(node):
		players.erase(node)

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		var time_passed := int(Time.get_ticks_msec() / 1000 - world_start_time)
		var cycle_time := time_passed % CYCLE_DURATION

		var is_active := cycle_time >= ACTIVE_DURATION
		var state := "ACTIVE (Nighttime)" if is_active else "INACTIVE (Daytime)"
		print("[Time: ", time_passed, "s] State: ", state)

		if is_active:
			if mobs.size() < players.size() * spawn_per_cycle:
				fade_in_cyc()
				spawn_random_enemies()
		else:
			fade_out_cyc()
			despawn_active_mobs()

func fade_in_cyc():
	
	var tween = create_tween()
	tween.tween_property(cyc, "modulate:a", 1, 2.0)
	cyc.visible = true  # Fade in over 1 second

func fade_out_cyc():
	cyc.visible = false
	var tween = create_tween()
	tween.tween_property(cyc, "modulate:a", 0, 2.0)

func spawn_random_enemies():
	var enemy_paths = [
		"res://Enemy/scene/Skeleton.tscn",
		"res://Enemy/scene/mus.tscn",
		"res://Enemy/scene/red_slime.tscn",
		"res://Enemy/scene/blue_slime.tscn",
		"res://Enemy/scene/eyefliy.tscn"
	]
	for i in range(spawn_per_cycle):
		var enemy_scene = load(enemy_paths[randi() % enemy_paths.size()]).instantiate()
		enemy_scene.global_position = get_spawn_position_near_random_player()
		add_child(enemy_scene)
		mobs.append(enemy_scene)
		active_mobs.append(enemy_scene)
		mob_last_interaction[enemy_scene] = Time.get_ticks_msec() / 1000
		apply_fade_in_effect(enemy_scene)

func get_spawn_position_near_random_player() -> Vector2:
	if players.is_empty():
		return Vector2.ZERO  # Default spawn location when no players exist
	var valid_players = players.filter(func(p): return is_instance_valid(p))
	if valid_players.is_empty():
		return Vector2.ZERO
	var player = valid_players[randi() % valid_players.size()]
	return player.global_position + Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * randf_range(active_spawn_distance * 0.8, active_spawn_distance)


func apply_fade_in_effect(mob):
	mob.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(mob, "modulate:a", 1, 1.0)
	tween.parallel().tween_property(mob, "position:y", mob.position.y - 20, 1.0)

func despawn_loop():
	while true:
		await get_tree().create_timer(5.0).timeout
		var now = Time.get_ticks_msec() / 1000
		for mob in mobs.duplicate():
			if not is_instance_valid(mob):
				mobs.erase(mob)
				mob_last_interaction.erase(mob)
				continue

			var dist = get_nearest_player_distance(mob.global_position)
			if dist <= INTERACTION_RADIUS:
				mob_last_interaction[mob] = now
			if now - mob_last_interaction.get(mob, now) > INACTIVITY_LIMIT or dist > despawn_distance:
				mobs.erase(mob)
				mob_last_interaction.erase(mob)
				mob.queue_free()

func get_nearest_player_distance(pos: Vector2) -> float:
	var min_dist = INF
	for p in players:
		if is_instance_valid(p):
			min_dist = min(min_dist, p.global_position.distance_to(pos))
	return min_dist

func despawn_active_mobs():
	for mob in active_mobs.duplicate():
		if is_instance_valid(mob):
			mobs.erase(mob)
			mob_last_interaction.erase(mob)
			mob.queue_free()
			active_mobs.erase(mob)
