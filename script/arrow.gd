extends Area2D

var speed = 1000

func _ready():
	set_as_top_level(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += (Vector2.RIGHT*speed).rotated(rotation) * delta
	


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
