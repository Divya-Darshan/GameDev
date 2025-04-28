extends Node2D

@onready var players = [ $gojo]  # Add all starting players here
@onready var camera = $gojo/Camera2D  # (Optional, if you still need a reference to Gojo's camera)

var spawn_delay = 6.0
var active_spawn_distance = 500
var despawn_distance = 800
var mobs = []  # Track spawned mobs
var max_mobs_near_players = 15  # Maximum mobs allowed at once near players

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

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		
		if count_mobs_near_players() < max_mobs_near_players:
			spawn_enemy()

func get_spawn_position_near_random_player():
	if players.size() == 0:
		return Vector2.ZERO  # Safety check if no players
		
	var random_player = players[randi() % players.size()]
	
	var angle = randf() * TAU
	var distance = randf_range(active_spawn_distance * 0.8, active_spawn_distance)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return random_player.global_position + offset

func spawn_enemy():
	var skl = preload("res://Enemy/scene/Skeleton.tscn").instantiate()
	skl.global_position = get_spawn_position_near_random_player()
	add_child(skl)
	mobs.append(skl)
	
	# Fancy fade-in spawn effect
	skl.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(skl, "modulate:a", 1.0, 1.0)  # Fade in
	tween.parallel().tween_property(skl, "position:y", skl.position.y - 20, 1.0)  # Rise up

func start_despawn_check():
	check_despawn_loop()

func check_despawn_loop():
	while true:
		await get_tree().create_timer(5.0).timeout
		
		for mob in mobs.duplicate():
			if not is_instance_valid(mob):
				mobs.erase(mob)
				continue
			var nearest_distance = get_nearest_player_distance(mob.global_position)
			if nearest_distance > despawn_distance:
				mobs.erase(mob)
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
