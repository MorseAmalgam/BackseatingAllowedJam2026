class_name Squid
extends MovingEnemy

@export var tentacles:Array[Line2D]

var tentacle_offsets:Array[float]

func _ready() -> void:
	super()
	for i in range(tentacles.size()):
		tentacle_offsets.append(randf_range(-1, 1))

func _process(delta: float) -> void:
	super(delta)
	
	for tentacle_iterator in range(tentacles.size()):
		var new_point_positions:Array[Vector2] = []
		for i in range(6):
			tentacle_offsets[tentacle_iterator] += delta * 0.1
			new_point_positions.append(Vector2(-cos((i / 20.0 + tentacle_offsets[tentacle_iterator]) * TAU) * 5* i, 20 * i))
		tentacles[tentacle_iterator].points = new_point_positions
