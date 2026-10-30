class_name Vessel
extends Node2D

@export var max_health:float = 20
@export var current_health:float = max_health
var max_velocity:float = 900
var acceleration:float = 900
var velocity:Vector2 = Vector2.ZERO
var friction:float = 0.95

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
	velocity.limit_length(max_velocity)
	
	position += velocity * delta
	velocity *= friction
	pass
