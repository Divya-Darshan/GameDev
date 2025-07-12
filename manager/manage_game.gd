extends Node

var dog_scene = preload("res://npc/frog/1 Dog/dog.tscn")
var frog_scene = preload("res://npc/frog/frognpc.tscn")

# Define the area (boundaries) where NPCs should spawn
var spawn_min = Vector2(100, 100)
var spawn_max = Vector2(800, 500)

func _ready() -> void:
	while true:
		await get_tree().create_timer(60.0).timeout
		spawn_random_npc(dog_scene, 1)  # spawn 3 dogs
		spawn_random_npc(frog_scene, 1) # spawn 2 frogs


func spawn_random_npc(scene: PackedScene, count: int) -> void:
	for i in count:
		var npc = scene.instantiate()
		var random_pos = Vector2(
			randf_range(spawn_min.x, spawn_max.x),
			randf_range(spawn_min.y, spawn_max.y)
		)
		npc.position = random_pos
		add_child(npc)
