class_name Rift
extends Enemy

@export var spawnables:Array[PackedScene]

var spawn_interval:float = 7.0


func _on_spawn_cooldown_timer_timeout() -> void:
	if dying:
		$SpawnCooldownTimer.stop()
		return
	
	$SpawnAudioPlayer.play()
	var new_enemy = spawnables.pick_random().instantiate()
	new_enemy.position = position
	get_parent().add_child(new_enemy)
	$SpawnCooldownTimer.start(spawn_interval)


func set_spawn_interval(seconds:float) -> void:
	spawn_interval = seconds
	# Random first spawn so rifts don't all fire on the same frame
	$SpawnCooldownTimer.start(randf_range(seconds * 0.5, seconds))
