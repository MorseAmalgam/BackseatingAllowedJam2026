class_name Tutorial
extends Control

## Full-screen "how to play" card. Pauses the game while it is open.
signal dismissed

@onready var _start_button:Button = %StartButton  

func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)

func open() -> void:
	visible = true
	get_tree().paused = true
	_start_button.grab_focus()

func _on_start_pressed() -> void:
	visible = false
	get_tree().paused = false
	dismissed.emit()
