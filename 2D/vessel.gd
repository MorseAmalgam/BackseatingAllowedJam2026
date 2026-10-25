extends Node2D


var velocity:float = 80
var rotation_speed:float = 0.05

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position += Vector2.UP.rotated(rotation) * velocity * delta
	elif Input.is_action_pressed("ui_down"):
		position -= Vector2.UP.rotated(rotation) * (velocity * 0.75) * delta
	
	# Rotation
	if Input.is_action_pressed("ui_left"):
		rotate(-rotation_speed)
		pass
	elif Input.is_action_pressed("ui_right"):
		rotate(rotation_speed)
		pass
	pass
