class_name MovingEnemy
extends Enemy

@export var attack_range:float = 80
@export var attack_damage:float = 1
@export var movement_speed:float = 10
@onready var navigation_agent:NavigationAgent2D = $NavigationAgent2D
@onready var attack_sound_player:AudioStreamPlayer2D = $AttackAudioPlayer
@onready var move_sound_player:AudioStreamPlayer2D = $MoveAudioPlayer


var target:Node2D


func _process(delta: float) -> void:
	if target == null:
		target = get_parent().vessel
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	# Do not try to navigate if we are at our destination
	if navigation_agent.is_navigation_finished():
		return
	
	# If dead, stop moving - halloween is now over
	if dying:
		return
	
	# If the creature is close enough to the vessel to attack, it should attack instead of moving closer.
	if global_position.distance_to(target.position) < attack_range:
		if $AttackCooldownTimer.is_stopped():
			$AttackCooldownTimer.start()
		return
	else:
		$AttackCooldownTimer.stop()
	
	# We're still too far away from the target - continue chasing it
	var movement_target_position:Vector2 = navigation_agent.get_next_path_position()
	var movement_delta = movement_speed * delta
	var adjusted_target_position = movement_target_position - get_parent().position
	var new_velocity = global_position.direction_to(adjusted_target_position) * movement_delta
	look_at(adjusted_target_position)
	global_position = global_position.move_toward(global_position + new_velocity, movement_delta)
	


func _on_attack_cooldown_timer() -> void:
	if target.has_method("take_damage"):
		attack_sound_player.play()
		target.take_damage(attack_damage)
	pass


func _on_recalculate_nav_timer() -> void:
	# Only attempt to find a path if they have a target
	if (target != null):
		navigation_agent.set_target_position(target.position)
