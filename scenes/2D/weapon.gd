class_name Weapon
extends Node2D

@export var deploy_speed:float = 0.5
@export var fire_sound:AudioStream
@export var radius:float = 30
@export var damage:float = 1
@export var damage_type:Constants.WeaponTypes

var deploy_timer:Timer = Timer.new()
var fire_sound_player:AudioStreamPlayer2D = AudioStreamPlayer2D.new()

func _ready() -> void:
	deploy_timer.wait_time = deploy_speed
	deploy_timer.one_shot = true
	deploy_timer.timeout.connect(_fire_weapon)
	add_child(deploy_timer)
	deploy_timer.start()
	
	fire_sound_player.stream = fire_sound
	fire_sound_player.volume_db = -20
	add_child(fire_sound_player)


func _process(_delta: float) -> void:
	var deploy_percent = 1.0 - (deploy_timer.time_left / deploy_speed)
	$ProgressBar.value = deploy_percent


func _fire_weapon() -> void:
	# Apply damage to in-range enemies
	# Play audio
	fire_sound_player.play()
	# Do damage while we play the animation
	$Area2D.position = position
	get_parent().propogate_weapon_fire($Area2D, damage, damage_type)
	#$Area2D.position = Vector2.ZERO
	$AnimationPlayer.play("Fire")
	# Wait for animation to complete
	await $AnimationPlayer.animation_finished
	# DELETE THIS
	queue_free()
	pass
