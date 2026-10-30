class_name Enemy
extends Node2D

@export var attack_range:float = 80
@export var attack_damage:float = 1
@export var movement_speed:float = 10
@export var max_hitpoints:int = 1
@export var affected_by:Constants.WeaponTypes
var current_hitpoints:float = max_hitpoints
@onready var projection:Node2D = $WorldProjection
@onready var collider:Area2D = $WorldProjection/Area2D
@onready var navigation_agent:NavigationAgent2D = $WorldProjection/NavigationAgent2D
@onready var attack_sound_player:AudioStreamPlayer2D = $WorldProjection/AttackAudioPlayer
@onready var death_sound_player:AudioStreamPlayer2D = $WorldProjection/DeathAudioPlayer
@onready var move_sound_player:AudioStreamPlayer2D = $WorldProjection/MoveAudioPlayer


var target:Node2D


func _ready() -> void:
	get_parent().get_parent().get_parent().on_weapon_fire.connect(_process_attack)
	# Move collision to the real world
	projection.call_deferred("reparent", get_parent().get_parent().get_parent())
	projection.position = position


func _process(delta: float) -> void:
	# Do not attempt to move the projection if it has been deleted
	if (projection != null):
		projection.position = position
	
	if target == null:
		target = get_parent().get_parent().get_parent().vessel
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	# Do not try to navigate if we are at our destination
	if navigation_agent.is_navigation_finished():
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
	#position.x += 5 * delta


func _on_attack_cooldown_timer() -> void:
	print("Rawr >:3")
	if target.has_method("take_damage"):
		attack_sound_player.play()
		target.take_damage(attack_damage)
	pass


func _on_recalculate_nav_timer() -> void:
	# Only attempt to find a path if they have a target
	if (target != null):
		navigation_agent.set_target_position(target.position)


func _process_attack(area_affected:Area2D, damage_amount:float, damage_type:Constants.WeaponTypes) -> void:
	# Ignore damage if it's the wrong type
	if (damage_type != affected_by):
		return
	
	# Ignore damage if it didn't hit
	if !collider.overlaps_area(area_affected):
		return
	
	# Take damage
	current_hitpoints -= damage_amount
	# Dead?
	if current_hitpoints <= 0:
		# Remove collider from the real world
		collider.queue_free()
		death_sound_player.play()
		$AnimationPlayer.play("Die")
		await $AnimationPlayer.animation_finished
		projection.queue_free()
		queue_free()
		
	pass
