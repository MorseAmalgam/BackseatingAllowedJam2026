class_name ButtonJuicerEnhancer
extends Node

@onready var button:Button = get_parent()
@onready var mouseover_sound:AudioStream = load("res://assets/audio/button_chirp.wav")
@onready var pressed_sound:AudioStream = load("res://assets/audio/button_confirm.wav")
var audio_player:AudioStreamPlayer
var tween:Tween


func _ready() -> void:
	button.mouse_entered.connect(_on_mouse_hovered.bind(true))
	button.mouse_exited.connect(_on_mouse_hovered.bind(false))
	button.pressed.connect(_on_pressed)
	button.offset_transform_enabled = true
	
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = -8
	audio_player.stream = mouseover_sound
	add_child(audio_player)
	

func _on_mouse_hovered(mouseover:bool):
	if (mouseover):
		audio_player.pitch_scale = randf_range(0.95, 1.05)
		audio_player.stream = mouseover_sound
		audio_player.play()
	reset_tween()
	tween.tween_property(button, "offset_transform_scale", Vector2.ONE * 1.1 if mouseover else Vector2.ONE, 0.1)
	pass

func _on_pressed() -> void:
	audio_player.stream = pressed_sound
	audio_player.pitch_scale = 1
	audio_player.play()
	pass

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
