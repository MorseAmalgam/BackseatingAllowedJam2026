class_name Vessel
extends Node2D

@export var max_health:float = 20
@export var current_health:float = max_health
@export var max_velocity:float = 900
@export var acceleration:float = 900
@export var friction:float = 0.95
var velocity:Vector2 = Vector2.ZERO
var dying:bool = false

func _process(delta: float) -> void:
	
	var added_velocity:Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		added_velocity += Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		added_velocity += Vector2.RIGHT

	if Input.is_action_pressed("ui_up"):
		added_velocity += Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		added_velocity += Vector2.DOWN
	
	
	velocity += added_velocity.normalized() * acceleration * delta
	velocity = velocity.limit_length(max_velocity)
	
	position += velocity * delta
	velocity *= friction
	
	# LAZZZYYYY
	position = Vector2(clampf(position.x, 40, 1240), clampf(position.y, 40, 680))


func take_damage(amount:float) -> void:
	# This is the 'stooooop he's already deaaaaaad' rule
	if dying:
		return
	current_health -= amount
	if current_health <= 0:
		dying = true
		$DestroyedAudioPlayer.play()
		$AnimationPlayer.play("Die")
		await $AnimationPlayer.animation_finished
		queue_free()
	else:
		$DamageAudioPlayer.play()
		
