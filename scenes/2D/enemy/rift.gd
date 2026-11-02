class_name Rift
extends Enemy

@export var spawnables:Array[PackedScene]


func _on_spawn_cooldown_timer_timeout() -> void:
	if dying:
		$SpawnCooldownTimer.stop()
		return
	
	$SpawnAudioPlayer.play()
	var new_enemy = spawnables.pick_random().instantiate()
	new_enemy.position = position
	get_parent().add_child(new_enemy)
	pass # Replace with function body.
