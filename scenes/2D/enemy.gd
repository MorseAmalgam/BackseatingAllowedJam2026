class_name Enemy
extends Node2D

@export var max_hitpoints:int = 1
@export var affected_by:Constants.WeaponTypes
var current_hitpoints:float = max_hitpoints
@onready var collider:Area2D = $Area2D
@onready var death_sound_player:AudioStreamPlayer2D = $DeathAudioPlayer

var dying:bool = false

func _ready() -> void:
	current_hitpoints = max_hitpoints
	# Connect to world to recieve attacks
	get_parent().on_weapon_fire.connect(_process_attack)

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
		if dying:
			return
		dying = true
		# just stop everything, he's already dead
		set_process(false)
		# Remove collider from the real world
		collider.queue_free()
		death_sound_player.play()
		$AnimationPlayer.play("Die")
		await $AnimationPlayer.animation_finished
		queue_free()
		
	pass
